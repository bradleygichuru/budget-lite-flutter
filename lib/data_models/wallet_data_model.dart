import 'dart:developer';

import 'package:flutter_application_1/data_models/auth_data_model.dart';
import 'package:flutter_application_1/data_models/transactions.dart';
import 'package:flutter_application_1/db/db.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Wallet {
  final int? id;
  final String name;
  final double balance;
  final double savings;
  final int? accountId;

  Wallet({
    required this.accountId,
    this.id,
    required this.savings,
    required this.name,
    required this.balance,
  });

  Map<String, Object> toMap() {
    return {
      "id": ?id,
      "name": name,
      "balance": balance,
      'account_id': ?accountId,
      'savings': savings,
    };
  }

  @override
  String toString() {
    return 'Wallet{name:$name,balance:$balance:account_id:$accountId:savings:$savings}';
  }
}

Future<int?> creditDefaultWallet(TransactionObj tx) async {
  final db = await getDb();
  Wallet? accountWallet = await getAccountWallet();
  if (accountWallet != null) {
    double newBalance = accountWallet.balance + tx.amount;
    int count = await db.rawUpdate(
      "UPDATE wallets SET balance = ? WHERE account_id = ? AND name = ?",
      ['$newBalance', '${await getAccountId()}', 'default'],
    );
    return count;
  } else {
    throw AccountWalletNotFoundException();
  }
}

Future<int?> addToSavings(TransactionObj tx) async {
  final db = await getDb();
  Wallet? accountWallet = await getAccountWallet();
  if (accountWallet != null) {
    log('Adding  ${tx.toString()} to ${accountWallet.toString()}');
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

Future<int> removeFromSavings(TransactionObj tx) async {
  final db = await getDb();
  Wallet? accountWallet = await getAccountWallet();
  if (accountWallet != null) {
    double newSavings = accountWallet.savings - tx.amount;
    double balance = accountWallet.balance + tx.amount;
    int count = await db.rawUpdate(
      "UPDATE wallets SET balance = ?,savings = ? WHERE account_id = ?",
      ['$balance', '$newSavings', '${await getAccountId()}'],
    );
    return count;
  } else {
    throw AccountWalletNotFoundException();
  }
}

Future<Wallet?> getAccountWallet() async {
  try {
    final db = await getDb();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, Object?>> walletMap = await db.rawQuery(
      "SELECT * FROM wallets WHERE account_id = ?",
      [prefs.getInt("budget_lite_current_account_id")],
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

class NotEnoughException implements Exception {
  String errMsg() => "Not enough balance";
}

class NotEnoughSavingsException implements Exception {
  String errMsg() => "Not enough savings";
}

class AccountWalletNotFoundException implements Exception {
  String errMsg() => "Wallet Not Found";
}
