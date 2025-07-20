import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data_models/auth_data_model.dart';
import 'package:flutter_application_1/data_models/transactions.dart';
import 'package:flutter_application_1/db/db.dart';

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
    final db = await getDb();
    log("categorizing tx of id:$id");
    int count = await db.rawUpdate(
      'UPDATE transactions SET category = ? WHERE id = ? AND account_id = ?',
      [category, '$id', '${await getAccountId()}'],
    );
    notifyListeners();
    return count;
  }

  Future<int?> handleTxAdd(
    Map<String, dynamic> transaction,
    int account_id,
  ) async {
    var rowID;
    await insertTransaction(
      TransactionObj(
        desc: transaction['desc'],
        type: transaction['type'],
        source: transaction['source'],
        amount: transaction['amount'],
        date: transaction['date'],
      ),
    ).then((rwid) async {
      rowID = rwid;

      transactions = getTransactions();
    });
    notifyListeners();
    return rowID;
  }

  Future<void> addNewTransaction(
    Map<String, dynamic> transaction,
    int account_id,
  ) async {
    insertTransaction(
      TransactionObj(
        desc: transaction['desc'],
        type: transaction["type"],
        source: transaction["source"],
        amount: transaction['amount'],
        date: transaction['date'],
        accountId: account_id,
      ),
    ).then((_) {
      transactions = getTransactions();
    });
    notifyListeners();
  }
}
