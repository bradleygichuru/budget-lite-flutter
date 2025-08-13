import 'dart:async';
import 'dart:developer';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/data_models/txs_data_model.dart';
import 'package:flutter_application_1/data_models/wallet_data_model.dart';
import 'package:flutter_application_1/db/db.dart';
import 'package:flutter_application_1/util/result_wraper.dart';
import 'package:flutter_application_1/view_models/auth.dart';
import 'package:flutter_application_1/view_models/categories.dart';
import 'package:flutter_application_1/view_models/txs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/data_models/categories_data_model.dart'
    as ct;
import 'package:watch_it/watch_it.dart';

class WalletModel extends ChangeNotifier {
  Future<double> totalBalance = Future.value(0);
  Future<double> savings = Future.value(0);
  WalletModel() {
    initWallet();
  }
  Future<void> refresh() async {
    AuthModel aM;
    if (!di.isRegistered<AuthModel>()) {
      aM = AuthModel();
    } else {
      aM = di<AuthModel>();
    }
    int? accountId = await aM.getAccountId();
    if (accountId != null) {
      Wallet? init = await getAccountWallet(accountId);

      log(init.toString());
      if (init != null) {
        totalBalance = Future.value(init.balance);
        savings = Future.value(init.savings);
      }
    }
    notifyListeners();
  }

  Future<Wallet?> getAccountWallet(int acid) async {
    try {
      final db = await DatabaseHelper().database;
      final List<Map<String, Object?>> walletMap = await db.rawQuery(
        "SELECT * FROM wallets WHERE account_id = ?",
        [acid],
      );
      var foundWalletMap = walletMap.firstWhere(
        (wallet) => wallet['account_id'] as int == acid,
        orElse: () {
          return {
            "id": 0,
            "name": 'default',
            "balance": 0,
            'account_id': acid,
            'savings': 0,
          };
        },
      );

      return Wallet(
        id: foundWalletMap['id'] as int,
        accountId: foundWalletMap['account_id'] as int,
        name: foundWalletMap['name'] as String,
        balance: foundWalletMap['balance'] as double,
        savings: foundWalletMap['savings'] as double,
      );
    } catch (e) {
      log('Error getting account');
    }
  }

  Future<int?> onBoaringWalletInit(double savings, double balance) async {
    try {
      final db = await DatabaseHelper().database;

      AuthModel aM;
      if (!di.isRegistered<AuthModel>()) {
        aM = AuthModel();
      } else {
        aM = di<AuthModel>();
      }
      int updated = await db.rawUpdate(
        'UPDATE wallets SET balance = ? , savings = ? WHERE account_id = ?',
        [balance.toString(), savings.toString(), await aM.getAccountId()],
      );
      notifyListeners();
      return updated;
    } catch (e) {
      log('Error Performing Inital budget Init: $e');
      rethrow;
    }
  }

  Future<void> initWallet() async {
    AuthModel aM;
    if (!di.isRegistered<AuthModel>()) {
      aM = AuthModel();
    } else {
      aM = di<AuthModel>();
    }
    int? accountId = await aM.getAccountId();
    if (accountId != null) {
      Wallet? init = await getAccountWallet(accountId);

      log(init.toString());
      if (init != null) {
        totalBalance = Future.value(init.balance);
        savings = Future.value(init.savings);
      }
    }
    notifyListeners();
  }

  Future<Result<int?>> creditDefaultWallet(TransactionObj tx) async {
    try {
      final db = await DatabaseHelper().database;
      AuthModel aM;
      TransactionsModel txM;
      if (!di.isRegistered<AuthModel>()) {
        aM = AuthModel();
      } else {
        aM = di<AuthModel>();
      }
      if (!di.isRegistered<TransactionsModel>()) {
        txM = TransactionsModel();
      } else {
        txM = di<TransactionsModel>();
      }
      int? acid = await aM.getAccountId();
      Wallet? accountWallet;
      if (acid != null) {
        accountWallet = await getAccountWallet(acid);
      }
      Result txInsert = await txM.insertTransaction(tx);
      switch (txInsert) {
        case Ok():
          {
            if (accountWallet != null && acid != null) {
              double newBalance = accountWallet.balance + tx.amount;
              int count = await db
                  .rawUpdate(
                    "UPDATE wallets SET balance = ? WHERE account_id = ? AND name = ?",
                    ['$newBalance', '$acid', 'default'],
                  )
                  .whenComplete(() async {
                    Wallet? newWalletState = await getAccountWallet(acid);
                    log(newWalletState.toString());
                    if (newWalletState != null) {
                      totalBalance = Future.value(newWalletState.balance);
                      savings = Future.value(newWalletState.savings);
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();

                      AwesomeNotifications().createNotification(
                        content: NotificationContent(
                          id: prefs.getInt('notification_id')!,
                          channelKey: 'budgetlite_silent',
                          actionType: ActionType.Default,
                          title: 'Wallet credited',
                          body: '${tx.amount} kes credited to wallet',
                        ),
                      );

                      prefs.setInt(
                        'notification_id',
                        prefs.getInt('notification_id')! + 1,
                      );
                    }
                  });
              refresh();
              notifyListeners();

              return Result.ok(count);
            } else {
              return Result.error(AccountWalletNotFoundException());
            }
          }
        case Error():
          {
            return Result.error(txInsert.error);
          }
      }
    } on Exception catch (e) {
      log('error occured crediting default wallet', error: e);
      return Result.error(e);
    }
  }

  Future<Result<int?>> debitDefaultWallet(TransactionObj tx) async {
    try {
      AuthModel aM;
      CategoriesModel cM;
      if (!di.isRegistered<AuthModel>()) {
        aM = AuthModel();
      } else {
        aM = di<AuthModel>();
      }

      if (!di.isRegistered<CategoriesModel>()) {
        cM = CategoriesModel();
      } else {
        cM = di<CategoriesModel>();
      }

      final db = await DatabaseHelper().database;
      int count = 0;

      int? acid = await aM.getAccountId();
      Wallet? accountWallet;
      if (acid != null) {
        accountWallet = await getAccountWallet(acid);
      }
      debugPrint('account_id:$acid');
      debugPrint(accountWallet.toString());
      if (accountWallet != null && acid != null) {
        int txId = await db.insert('transactions', tx.toMap());
        await db.update(
          'transactions',
          {'account_id': acid},
          where: 'id = ?',
          whereArgs: ['$txId'],
        );
        // await txn.rawUpdate(
        //   'UPDATE transactions SET account_id = ? WHERE id = ? ',
        //   ['$acid', '$txId'],
        // );

        List<ct.Category> cts = await cM.categories;
        ct.Category? candidate = cts.firstWhere(
          (category) => category.categoryName == tx.category,
        );
        log('deducting from category ${candidate.toString()}');

        debugPrint('deducting from category ${candidate.toString()}');
        double update = candidate.spent + tx.amount;
        log('new spent: $update');

        debugPrint('new spent: $update');
        count = await db.update(
          'categories',
          {'spent': update},
          where: 'id = ? AND account_id = ?',
          whereArgs: ['${candidate.id}', '$acid'],
        );
        // await db.rawUpdate(
        //   'UPDATE categories SET spent = ? WHERE id = ? AND account_id = ?',
        //   ['$update', '${candidate.id},$acid'],
        // );
        // double newBalance = accountWallet.balance - tx.amount;
        // debugPrint('newbalance:$newBalance');
        // count = await db.update(
        //   'wallets',
        //   {'balance': newBalance},
        //   where: 'account_id = ?',
        //   whereArgs: ['$acid'],
        // );
        // // count = await txn.rawUpdate(
        // //   "UPDATE wallets SET balance = ? WHERE account_id = ? ",
        // //   ['$newBalance', '$acid}'],
        // // );
        //
        // log('Wallet debited');
        // log('Wallet cols updated:$count');
        //
        // debugPrint('Wallet debited');
        // debugPrint('Wallet cols updated:$count');
        refresh();
        notifyListeners();
        if (count > 0) {
          SharedPreferences prefs = await SharedPreferences.getInstance();

          AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: prefs.getInt('notification_id')!,
              channelKey: 'budgetlite_silent',
              actionType: ActionType.Default,
              title: 'Wallet debited',
              body: '${tx.amount} kes debited from wallet',
            ),
          );

          prefs.setInt('notification_id', prefs.getInt('notification_id')! + 1);
        }

        notifyListeners();

        return Result.ok(count);
      } else {
        debugPrint('Error finding default wallet');
        return Result.error(AccountWalletNotFoundException());
      }
    } on Exception catch (e) {
      log('$e');
      debugPrint(' Error debiting wallet :$e');
      return Result.error(e);
    }
  }

  Future<Result<int?>> addToSavings(TransactionObj tx) async {
    try {
      AuthModel aM;
      TransactionsModel txM;
      if (!di.isRegistered<AuthModel>()) {
        aM = AuthModel();
      } else {
        aM = di<AuthModel>();
      }

      if (!di.isRegistered<TransactionsModel>()) {
        txM = TransactionsModel();
      } else {
        txM = di<TransactionsModel>();
      }
      final db = await DatabaseHelper().database;
      int? acid = await aM.getAccountId();
      Wallet? accountWallet;
      if (acid != null) {
        accountWallet = await getAccountWallet(acid);
      }

      Result txInsert = await txM.insertTransaction(tx);
      switch (txInsert) {
        case Ok():
          {
            int? count;
            if (accountWallet != null && acid != null) {
              if (accountWallet.balance >= tx.amount) {
                log('Adding to ${accountWallet.toString()}');
                double newSavings = accountWallet.savings + tx.amount;
                count = await db.rawUpdate(
                  "UPDATE wallets SET savings = ? WHERE account_id = ?",
                  ['$newSavings', '$acid'],
                );
                log('colums updated ($count)');
                refresh();
                notifyListeners();
                if (count > 0) {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  AwesomeNotifications().createNotification(
                    content: NotificationContent(
                      id: prefs.getInt('notification_id')!,
                      channelKey: 'budgetlite_silent',
                      actionType: ActionType.Default,
                      title: 'Savings',
                      body: '${tx.amount} kes transferred to savings',
                    ),
                  );

                  prefs.setInt(
                    'notification_id',
                    prefs.getInt('notification_id')! + 1,
                  );
                }
                return Result.ok(count);
              } else {
                return Result.error(NotEnoughException());
              }
            } else {
              return Result.error(AccountWalletNotFoundException());
            }
          }
        case Error():
          {
            return Result.error(txInsert.error);
          }
      }
      // txM.insertTransaction(tx);
    } on Exception catch (e) {
      log('Error occured adding to savings', error: e);
      return Result.error(e);
    }
  }

  Future<Result<int?>> removeFromSavings(TransactionObj tx) async {
    try {
      AuthModel aM;
      TransactionsModel txM;
      if (!di.isRegistered<AuthModel>()) {
        aM = AuthModel();
      } else {
        aM = di<AuthModel>();
      }

      if (!di.isRegistered<TransactionsModel>()) {
        txM = TransactionsModel();
      } else {
        txM = di<TransactionsModel>();
      }
      final db = await DatabaseHelper().database;
      int? count;

      int? acid = await aM.getAccountId();
      Wallet? accountWallet;
      if (acid != null) {
        accountWallet = await getAccountWallet(acid);
      }
      if (accountWallet != null && acid != null) {
        if (accountWallet.savings >= tx.amount) {
          Result txInsert = await txM.insertTransaction(tx);
          switch (txInsert) {
            case Ok():
              {
                double newSavings = accountWallet.savings - tx.amount;
                double balance = accountWallet.balance + tx.amount;
                count = await db.rawUpdate(
                  "UPDATE wallets SET balance = ?,savings = ? WHERE account_id = ?",
                  ['$balance', '$newSavings', '$acid'],
                );
                refresh();
                notifyListeners();
                if (count > 0) {
                  // SharedPreferences prefs =
                  //     await SharedPreferences.getInstance();
                  //
                  // AwesomeNotifications().createNotification(
                  //   content: NotificationContent(
                  //     id: prefs.getInt('notification_id')!,
                  //     channelKey: 'budgetlite_silent',
                  //     actionType: ActionType.Default,
                  //     title: 'Savings',
                  //     body: '${tx.amount} kes removed from savings',
                  //   ),
                  // );
                  // prefs.setInt(
                  //   'notification_id',
                  //   prefs.getInt('notification_id')! + 1,
                  // );
                }
                return Result.ok(count);
              }
            case Error():
              {
                return Result.error(txInsert.error);
              }
          }
        } else {
          return Result.error(NotEnoughSavingsException());
        }
      } else {
        return Result.error(AccountWalletNotFoundException());
      }
    } on Exception catch (e) {
      log('Error debiting default wallet', error: e);
      return Result.error(e);
    }
  }
}
