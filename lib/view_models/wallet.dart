import 'dart:async';
import 'dart:developer';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/data_models/transactions.dart';
import 'package:flutter_application_1/data_models/wallet_data_model.dart';
import 'package:flutter_application_1/db/db.dart';
import 'package:flutter_application_1/view_models/auth.dart';
import 'package:flutter_application_1/view_models/txs.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      final db = await getDb();
      SharedPreferences prefs = await SharedPreferences.getInstance();
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
      final db = await getDb();

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

  Future<int?> creditDefaultWallet(TransactionObj tx) async {
    final db = await getDb();
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
    txM.insertTransaction(tx);
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
              SharedPreferences prefs = await SharedPreferences.getInstance();

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

      return count;
    } else {
      throw AccountWalletNotFoundException();
    }
  }

  Future<int?> debitDefaultWallet(TransactionObj tx) async {
    try {
      AuthModel aM;
      if (!di.isRegistered<AuthModel>()) {
        aM = AuthModel();
      } else {
        aM = di<AuthModel>();
      }

      final db = await getDb();
      int? count;

      int? acid = await aM.getAccountId();
      Wallet? accountWallet;
      if (acid != null) {
        accountWallet = await getAccountWallet(acid);
      }
      Future<int?> runDebitTx(TransactionObj tx) async {
        db.transaction((txn) async {
          int txId = await txn.insert('transactions', tx.toMap());
          await txn.rawUpdate(
            'UPDATE transactions SET account_id = ? WHERE id = ? ',
            ['$acid', '$txId'],
          );
          double newBalance = accountWallet!.balance - tx.amount;
          count = await txn.rawUpdate(
            "UPDATE wallets SET balance = ? WHERE account_id = ? AND name = ?",
            ['$newBalance', '$acid}', 'default'],
          );

          log('Wallet debited');
          log('Wallet cols updated:$count');
          refresh();
          notifyListeners();
          if (count != null) {
            if (count! > 0) {
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

              prefs.setInt(
                'notification_id',
                prefs.getInt('notification_id')! + 1,
              );
            }
          }
        });

        return count;
      }

      if (accountWallet != null && acid != null) {
        notifyListeners();
        return runDebitTx(tx);
      } else {
        throw AccountWalletNotFoundException();
      }
    } catch (e) {
      log('Error debiting default wallet:$e');
      rethrow;
    }
  }

  Future<int?> addToSavings(TransactionObj tx) async {
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
      final db = await getDb();
      int? acid = await aM.getAccountId();
      Wallet? accountWallet;
      if (acid != null) {
        accountWallet = await getAccountWallet(acid);
      }

      await txM.insertTransaction(tx);
      // txM.insertTransaction(tx);
      int? count;
      if (accountWallet != null && acid != null) {
        if (tx.source == 'Mpesa') {
          {
            log('Adding to ${accountWallet.toString()}');
            double newSavings = accountWallet.savings + tx.amount;
            double balance = accountWallet.balance == 0.0
                ? 0
                : accountWallet.balance - tx.amount;
            count = await db.rawUpdate(
              "UPDATE wallets SET balance = ?,savings = ? WHERE account_id = ?",
              ['$balance', '$newSavings', '$acid'],
            );
            log('colums updated ($count)');
            refresh();
            notifyListeners();
            if (count > 0) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
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
            return count;
          }
        } else {
          if (accountWallet.balance >= tx.amount) {
            log('Adding to ${accountWallet.toString()}');
            double newSavings = accountWallet.savings + tx.amount;
            double balance = accountWallet.balance == 0.0
                ? 0
                : accountWallet.balance - tx.amount;
            count = await db.rawUpdate(
              "UPDATE wallets SET balance = ?,savings = ? WHERE account_id = ?",
              ['$balance', '$newSavings', '$acid'],
            );
            log('colums updated ($count)');
            refresh();
            notifyListeners();
            if (count > 0) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
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
            return count;
          } else {
            throw NotEnoughException();
          }
        }
      } else {
        throw AccountWalletNotFoundException();
      }
    } catch (e) {
      log('Error occured adding to savings', error: e);
      rethrow;
    }
  }

  Future<int?> removeFromSavings(TransactionObj tx) async {
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
      final db = await getDb();
      int? count;

      txM.insertTransaction(tx);
      int? acid = await aM.getAccountId();
      Wallet? accountWallet;
      if (acid != null) {
        accountWallet = await getAccountWallet(acid);
      }
      if (accountWallet != null && acid != null) {
        if (tx.source == 'Mpesa') {
          double newSavings = accountWallet.savings - tx.amount;
          double balance = accountWallet.balance + tx.amount;
          count = await db.rawUpdate(
            "UPDATE wallets SET balance = ?,savings = ? WHERE account_id = ?",
            ['$balance', '$newSavings', '$acid'],
          );
          refresh();
          notifyListeners();
          if (count > 0) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: prefs.getInt('notification_id')!,
                channelKey: 'budgetlite_silent',
                actionType: ActionType.Default,
                title: 'Savings',
                body: '${tx.amount} kes removed from savings',
              ),
            );
            prefs.setInt(
              'notification_id',
              prefs.getInt('notification_id')! + 1,
            );
          }
          return count;
        } else {
          if (accountWallet.savings >= tx.amount) {
            double newSavings = accountWallet.savings - tx.amount;
            double balance = accountWallet.balance + tx.amount;
            count = await db.rawUpdate(
              "UPDATE wallets SET balance = ?,savings = ? WHERE account_id = ?",
              ['$balance', '$newSavings', '$acid'],
            );
            refresh();
            notifyListeners();
            if (count > 0) {
              SharedPreferences prefs = await SharedPreferences.getInstance();

              AwesomeNotifications().createNotification(
                content: NotificationContent(
                  id: prefs.getInt('notification_id')!,
                  channelKey: 'budgetlite_silent',
                  actionType: ActionType.Default,
                  title: 'Savings',
                  body: '${tx.amount} kes removed from savings',
                ),
              );
              prefs.setInt(
                'notification_id',
                prefs.getInt('notification_id')! + 1,
              );
            }
            return count;
          } else {
            throw NotEnoughSavingsException();
          }
        }
      } else {
        throw AccountWalletNotFoundException();
      }
    } catch (e) {
      log('Error debiting default wallet', error: e);
    }
  }
}
