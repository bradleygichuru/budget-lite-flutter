import 'dart:async';
import 'dart:developer';
import 'package:another_telephony/telephony.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/data_models/auth_data_model.dart';
import 'package:flutter_application_1/data_models/transactions.dart';
import 'package:flutter_application_1/data_models/wallet_data_model.dart';
import 'package:flutter_application_1/data_models/categories_data_model.dart';
import 'package:flutter_application_1/db/db.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletModel extends ChangeNotifier {
  Future<double> totalBalance = Future.value(0);
  Future<double> savings = Future.value(0);
  WalletModel() {
    initWallet();
  }
  void refresh() async {
    Wallet? init = await getAccountWallet();
    log(init.toString());
    if (init != null) {
      totalBalance = Future.value(init.balance);
      savings = Future.value(init.savings);
    } else {
      totalBalance = Future.value(0);
      savings = Future.value(0);
    }
    notifyListeners();
  }

  Future<int?> onBoaringWalletInit(double savings, double balance) async {
    try {
      final db = await getDb();
      int updated = await db.rawUpdate(
        'UPDATE wallets SET balance = ? , savings = ? WHERE account_id = ?',
        [balance.toString(), savings.toString(), await getAccountId()],
      );
      notifyListeners();
      return updated;
    } catch (e) {
      log('Error Performing Inital budget Init: $e');
      rethrow;
    }
  }

  void initWallet() async {
    Wallet? init = await getAccountWallet();
    log(init.toString());
    if (init != null) {
      totalBalance = Future.value(init.balance);
      savings = Future.value(init.savings);
    } else {
      totalBalance = Future.value(0);
      savings = Future.value(0);
    }
    notifyListeners();
  }

  Future<Wallet?> getAccountWallet() async {
    try {
      final db = await getDb();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<Map<String, Object?>> walletMap = await db.rawQuery(
        "SELECT * FROM wallets WHERE account_id = ?",
        ['${await getAccountId()}'],
      );
      int? accountId = await getAccountId();
      var foundWalletMap = walletMap.firstWhere(
        (wallet) => wallet['account_id'] as int == accountId,
        orElse: () {
          return {
            "id": 0,
            "name": 'default',
            "balance": 0,
            'account_id': accountId,
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
      rethrow;
    }
  }

  Future<int?> creditDefaultWallet(TransactionObj tx) async {
    final db = await getDb();
    Wallet? accountWallet = await getAccountWallet();

    insertTransaction(tx);
    if (accountWallet != null) {
      double newBalance = accountWallet.balance + tx.amount;
      int count = await db
          .rawUpdate(
            "UPDATE wallets SET balance = ? WHERE account_id = ? AND name = ?",
            ['$newBalance', '${await getAccountId()}', 'default'],
          )
          .whenComplete(() async {
            Wallet? newWalletState = await getAccountWallet();
            log(newWalletState.toString());
            if (newWalletState != null) {
              totalBalance = Future.value(newWalletState.balance);
              savings = Future.value(newWalletState.savings);
            }
          });
      notifyListeners();

      return count;
    } else {
      throw AccountWalletNotFoundException();
    }
  }

  Future<int?> debitDefaultWallet(TransactionObj tx) async {
    try {
      final db = await getDb();
      int? count;
      Wallet? accountWallet = await getAccountWallet();
      if (accountWallet != null) {
        if (accountWallet.balance > 0 && tx.amount <= accountWallet.balance) {
          await db.transaction((txn) async {
            int txId = await txn.insert('transactions', tx.toMap());
            await txn.rawUpdate(
              'UPDATE transactions SET account_id = ? WHERE id = ? ',
              ['${await getAccountId()}', '$txId'],
            );
            final List<Map<String, Object?>> categoryMaps = await txn.rawQuery(
              "SELECT * FROM categories WHERE account_id = ? AND category_name = ?",
              ['${await getAccountId()}', tx.category],
            );
            Map<String, Object?> y = categoryMaps.firstWhere(
              (cat) => cat['category_name'] as String == tx.category,
            );
            double newBalance = accountWallet.balance - tx.amount;
            await txn.rawUpdate(
              "UPDATE wallets SET balance = ? WHERE account_id = ? AND name = ?",
              ['$newBalance', '${await getAccountId()}', 'default'],
            );

            double update = (y['spent'] as double) + tx.amount;
            log('new spent: $update');

            count = await txn.rawUpdate(
              'UPDATE categories SET spent = ? WHERE id = ? AND account_id = ?',
              [
                '$update',
                (y['id'] as int).toString(),
                '${await getAccountId()}',
              ],
            );

            log('Wallet debited');
            log('Wallet cols updated:$count');
            refresh();
            return count;
          });
        } else {
          throw NotEnoughException();
        }
      } else {
        throw AccountWalletNotFoundException();
      }

      notifyListeners();
      return count;
    } catch (e) {
      log('Error debiting default wallet:$e');
      rethrow;
    }
  }

  Future<int?> addToSavings(double amount) async {
    try {
      final db = await getDb();
      Wallet? accountWallet = await getAccountWallet();
      int? count;
      if (accountWallet != null) {
        if (accountWallet.balance >= amount) {
          log('Adding to ${accountWallet.toString()}');
          double newSavings = accountWallet.savings + amount;
          double balance = accountWallet.balance == 0.0
              ? 0
              : accountWallet.balance - amount;
          count = await db.rawUpdate(
            "UPDATE wallets SET balance = ?,savings = ? WHERE account_id = ?",
            ['$balance', '$newSavings', '${await getAccountId()}'],
          );
          log('colums updated ($count)');
          refresh();
          notifyListeners();
          return count;
        } else {
          throw NotEnoughException();
        }
      } else {
        throw AccountWalletNotFoundException();
      }
    } catch (e) {
      log('Error occured adding to savings', error: e);
      rethrow;
    }
  }

  Future<int?> removeFromSavings(double amount) async {
    try {
      final db = await getDb();
      int? count;
      Wallet? accountWallet = await getAccountWallet();
      if (accountWallet != null) {
        if (accountWallet.savings >= amount) {
          double newSavings = accountWallet.savings - amount;
          double balance = accountWallet.balance + amount;
          count = await db.rawUpdate(
            "UPDATE wallets SET balance = ?,savings = ? WHERE account_id = ?",
            ['$balance', '$newSavings', '${await getAccountId()}'],
          );

          refresh();
          notifyListeners();
          return count;
        } else {
          throw NotEnoughSavingsException();
        }
      } else {
        throw AccountWalletNotFoundException();
      }
    } catch (e) {
      log('Error debiting default wallet', error: e);
    }
  }
}
