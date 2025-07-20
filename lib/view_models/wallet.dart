import 'dart:async';
import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/data_models/auth_data_model.dart';
import 'package:flutter_application_1/data_models/transactions.dart';
import 'package:flutter_application_1/data_models/wallet_data_model.dart';
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

  Future<int> debitDefaultWallet(TransactionObj tx) async {
    final db = await getDb();
    var count;
    Wallet? accountWallet = await getAccountWallet();
    if (accountWallet != null) {
      if (accountWallet.balance > 0 && tx.amount <= accountWallet.balance) {
        insertTransaction(tx);
        double newBalance = accountWallet.balance - tx.amount;
        count = await db
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
              } else {
                throw AccountWalletNotFoundException();
              }
            });
        notifyListeners();
      } else {
        throw NotEnoughException();
      }
    } else {
      throw AccountWalletNotFoundException();
    }
    return count;
  }

  Future<int?> addToSavings(TransactionObj tx) async {
    final db = await getDb();
    Wallet? accountWallet = await getAccountWallet();
    if (accountWallet != null) {
      log('Adding to ${accountWallet.toString()}');
      double newSavings = accountWallet.savings + tx.amount;
      double balance = accountWallet.balance == 0.0
          ? 0
          : accountWallet.balance - tx.amount;
      int count = await db.rawUpdate(
        "UPDATE wallets SET balance = ?,savings = ? WHERE account_id = ?",
        ['$balance', '$newSavings', '${await getAccountId()}'],
      );
      return count;
    } else {
      throw AccountWalletNotFoundException();
    }
  }

  Future<int?> removeFromSavings(TransactionObj tx) async {
    final db = await getDb();
    var count;
    insertTransaction(tx);
    Wallet? accountWallet = await getAccountWallet();
    if (accountWallet != null) {
      if (accountWallet.savings >= tx.amount) {
        double newSavings = accountWallet.savings - tx.amount;
        double balance = accountWallet.balance + tx.amount;
        count = await db.rawUpdate(
          "UPDATE wallets SET balance = ?,savings = ? WHERE account_id = ?",
          ['$balance', '$newSavings', '${await getAccountId()}'],
        );
        return count;
      } else {
        throw NotEnoughSavingsException();
      }
    } else {
      throw AccountWalletNotFoundException();
    }
  }
}
