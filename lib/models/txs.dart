import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data-models/transactions.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TransactionsModel extends ChangeNotifier {
  TransactionsModel() {
    initTxs();
  }
  late Future<List<TransactionObj>> transactions;
  Future<double> readyToAssign = Future.value(0);
  Future<double> totalSpent = Future.value(0);
  Future<double> totalTransacted = Future.value(0);
  // List<Widget> composedTranactions = [];
  void initTxs() {
    transactions = getTransactions();
    notifyListeners();
  }

  void refreshTx() {
    transactions = getTransactions();
    notifyListeners();
  }

  Future<int> setTxCategory(String category, int id) async {
    final db = await openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'budget_lite_database.db'),

      // When the database is first created, create a table to store dogs.
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
    log("categorizing tx of id:$id");
    int count = await db.rawUpdate(
      'UPDATE transactions SET category = ? WHERE id = ?',
      [category, '$id'],
    );
    notifyListeners();
    return count;
  }

  Future<int?> handleTxAdd(Map<String, dynamic> transaction) async {
    var rowID;
    await insertTransaction(
      TransactionObj(
        type: transaction['type'],
        source: transaction['source'],
        amount: transaction['amount'],
        date: transaction['date'],
      ),
    ).then((rwid) async {
      rowID = rwid;

      transactions = getTransactions();
    });
  }

  Future<void> addNewTransaction(Map<String, dynamic> transaction) async {
    insertTransaction(
      TransactionObj(
        type: transaction["type"],
        source: transaction["source"],
        amount: transaction['amount'],
        date: transaction['date'],
      ),
    ).then((_) {
      transactions = getTransactions();
    });
    notifyListeners();
  }
}
