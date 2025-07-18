import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/data-models/transactions.dart';
import 'package:flutter_application_1/db/db.dart';
import 'package:flutter_application_1/models/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Wallet {
  final int? id;
  final String name;
  final double balance;
  final double? savings;
  final int? accountId;

  Wallet({
    required this.accountId,
    this.id,
    this.savings,
    required this.name,
    required this.balance,
  });

  Map<String, Object> toMap() {
    return {
      "id": ?id,
      "name": name,
      "balance": balance,
      'account_id': ?accountId,
      'savings': ?savings,
    };
  }

  @override
  String toString() {
    return 'Wallet{name:$name,balance:$balance:account_id:$accountId:savings:$savings}';
  }
}

Future<void> insertWallet(Wallet wallet) async {
  final db = await getDb();
  await db.insert("wallets", wallet.toMap());
}

Future<int> creditDefaultWallet(TransactionObj tx) async {
  final db = await getDb();
  Wallet accountWallet = await getAccountWallet();

  double newBalance = accountWallet.balance + tx.amount;
  int count = await db.rawUpdate(
    "UPDATE wallets SET balance = ? WHERE account_id = ?,name = ?",
    ['$newBalance', '${await getAccountId()}', 'default'],
  );
  return count;
}

Future<int> addToSavings(TransactionObj tx) async {
  final db = await getDb();
  Wallet accountWallet = await getAccountWallet();
  double newSavings = accountWallet.savings ?? 0 + tx.amount;
  double balance = (accountWallet.balance) == 0
      ? 0
      : accountWallet.balance - tx.amount;
  int count = await db.rawUpdate(
    "UPDATE wallets SET balance = ?,savings = ? WHERE account_id = ?",
    ['$balance', '$newSavings', '${await getAccountId()}'],
  );
  return count;
}

Future<int> removeFromSavings(TransactionObj tx) async {
  final db = await getDb();
  Wallet accountWallet = await getAccountWallet();
  double newSavings = accountWallet.savings ?? 0 - tx.amount;
  double balance = accountWallet.balance + tx.amount;
  int count = await db.rawUpdate(
    "UPDATE wallets SET balance = ?,savings = ? WHERE account_id = ?",
    ['$balance', '$newSavings', '${await getAccountId()}'],
  );
  return count;
}

Future<Wallet> getAccountWallet() async {
  final db = await getDb();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final List<Map<String, Object?>> walletMap = await db.rawQuery(
    "SELECT * FROM wallets WHERE account_id = ?",
    [prefs.getInt("budget_lite_current_account_id")],
  );
  return Wallet(
    id: walletMap.first['id'] as int,
    accountId: walletMap.first['account_id'] as int,
    name: walletMap.first['name'] as String,
    balance: walletMap.first['balance'] as double,
    savings: walletMap.first['savings'] as double,
  );
}

class WalletModel extends ChangeNotifier {
  Future<double> totalBalance = Future.value(0);
  Future<double> savings = Future.value(0);
  Future<double> cash = Future.value(0);
  WalletModel() {
    initWallet();
  }
  void refresh() async {
    final init = await getAccountWallet();
    totalBalance = Future.value(init.balance);
    savings = Future.value(init.savings);
    cash = Future.value(init.balance - init.savings!);
  }

  void initWallet() async {
    final init = await getAccountWallet();
    log(init.toString());
    totalBalance = Future.value(init.balance);
    savings = Future.value(init.savings);
    cash = Future.value(init.balance - init.savings!);
  }

  Future<Wallet> getAccountWallet() async {
    final db = await getDb();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, Object?>> walletMap = await db.rawQuery(
      "SELECT * FROM wallets WHERE account_id = ?",
      [prefs.getInt("budget_lite_current_account_id")],
    );
    return Wallet(
      id: walletMap.first['id'] as int,
      accountId: walletMap.first['account_id'] as int,
      name: walletMap.first['name'] as String,
      balance: walletMap.first['balance'] as double,
      savings: walletMap.first['savings'] as double,
    );
  }
}
