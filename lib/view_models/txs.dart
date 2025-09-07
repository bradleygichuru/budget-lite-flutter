import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/globals.dart';
import 'package:flutter_application_1/data_models/auth_data_model.dart';
import 'package:flutter_application_1/db/db.dart';
import 'package:flutter_application_1/util/result_wraper.dart';
import 'package:flutter_application_1/view_models/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/utils/utils.dart';
import 'package:toastification/toastification.dart';
import 'package:watch_it/watch_it.dart';
import 'package:flutter_application_1/data_models/txs_data_model.dart';

class TransactionsModel extends ChangeNotifier {
  TransactionsModel() {
    initTxs();
  }
  int txPage = 1;
  bool handleUncategorized = false;
  bool shouldCategorize = false;
  Future<List<TransactionObj>> unCategorizedTxs = Future.value([]);
  late Future<List<TransactionObj>> transactions;
  Future<double> readyToAssign = Future.value(0);
  Future<double> totalSpent = Future.value(0);
  Future<double> totalTransacted = Future.value(0);
  late int pages;
  // List<Widget> composedTranactions = [];
  void initTxs() async {
    transactions = getTransactions();
    final x = await getUncategorizedTx();
    if (x.isNotEmpty) {
      shouldCategorize = x.isNotEmpty;

      unCategorizedTxs = Future.value(x);
    }
    notifyListeners();
  }

  toogleCategorizationOff() {
    handleUncategorized = false;

    notifyListeners();
  }

  toogleCategorizationOn() {
    handleUncategorized = true;
    notifyListeners();
  }

  void refreshTx() async {
    final x = await getUncategorizedTx();
    shouldCategorize = x.isNotEmpty;
    unCategorizedTxs = Future.value(x);
    transactions = getTransactions();
    notifyListeners();
  }

  Future<List<TransactionObj>> getTxPages(int pageSize, int page) async {
    AuthModel aM;
    if (!di.isRegistered<AuthModel>()) {
      aM = AuthModel();
    } else {
      aM = di<AuthModel>();
    }
    List<TransactionObj> x = [];
    final db = await DatabaseHelper().database;

    log("Getting Transactions");
    int offset = (page - 1) * pageSize;
    final List<Map<String, Object?>> transactionMaps = await db.query(
      'transactions',
      where: 'account_id = ?',
      whereArgs: ['${await aM.getAccountId()}'],
      limit: pageSize,
      offset: offset,
      orderBy: 'DATE(date) DESC',
    );
    // final List<Map<String, Object?>> transactionMaps = await db.rawQuery(
    //   'SELECT * FROM transactions ORDER BY date LIMIT ? OFFSET ? WHERE account_id = ?',
    //   ['$pageSize', '$offset', '${await aM.getAccountId()}'],
    // );
    log("found ${transactionMaps.length} transaction");
    // transactionMaps.forEach((tx) {
    //   log(
    //     TransactionObj(
    //       id: tx["id"] as int,
    //       type: tx["type"] as String,
    //       amount: tx["amount"] as double,
    //       source: tx["source"] as String,
    //       date: tx["date"] as String,
    //       category: tx["category"] as String?,
    //       accountId: tx["account_id"] as int,
    //       desc: tx['desc'] as String,
    //
    //       messageHashCode: tx['message_hash_code'] as String?,
    //     ).toString(),
    //   );
    // });
    if (transactionMaps.isNotEmpty) {
      for (final {
            'id': id as int,
            'type': type as String,
            'date': date as String,
            'amount': amount as double,
            'source': source as String,
            'category': category as String?,
            'account_id': accountId as int,
            'desc': desc as String,

            'message_hash_code': messageHashCode as String?,
          }
          in transactionMaps) {
        x.add(
          TransactionObj(
            id: id,
            type: type,
            amount: amount,
            source: source,
            date: date,
            category: category,
            accountId: accountId,
            desc: desc,

            messageHashCode: messageHashCode,
          ),
        );
      }
    }
    return x.reversed.toList();
  }

  Future<Result<int>> setTxCategory(String category, int id) async {
    AuthModel aM;
    try {
      if (!di.isRegistered<AuthModel>()) {
        aM = AuthModel();
      } else {
        aM = di<AuthModel>();
      }
      final db = await DatabaseHelper().database;
      log("categorizing tx of id:$id");
      int count = await db.rawUpdate(
        'UPDATE transactions SET category = ? WHERE id = ? AND account_id = ?',
        [category, '$id', '${await aM.getAccountId()}'],
      );
      notifyListeners();
      return Result.ok(count);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  // Future<int?> handleTxAdd(
  //   Map<String, dynamic> transaction,
  //   int account_id,
  // ) async {
  //   var rowID;
  //   await insertTransaction(
  //     TransactionObj(
  //       desc: transaction['desc'],
  //       type: transaction['type'],
  //       source: transaction['source'],
  //       amount: transaction['amount'],
  //       date: transaction['date'],
  //     ),
  //   ).then((rwid) async {
  //     rowID = rwid;
  //
  //     transactions = getTransactions();
  //   });
  //   notifyListeners();
  //   return rowID;
  // }

  // Future<void> addNewTransaction(
  //   Map<String, dynamic> transaction,
  //   int account_id,
  // ) async {
  //   insertTransaction(
  //     TransactionObj(
  //       desc: transaction['desc'],
  //       type: transaction["type"],
  //       source: transaction["source"],
  //       amount: transaction['amount'],
  //       date: transaction['date'],
  //       accountId: account_id,
  //     ),
  //   ).then((_) {
  //     transactions = getTransactions();
  //   });
  //   notifyListeners();
  // }

  // Future<List<TransactionObj>> getTxById(int id) async {
  //   final db = await DatabaseHelper().database;
  //   final List<Map<String, Object?>> transactionMaps = await db.query(
  //     "transactions",
  //     where: '"id=$id"',
  //   );
  //
  //   log("found ${transactionMaps.length} uncategorized transaction");
  //   return [
  //     for (final {
  //           'id': id as int,
  //           'type': type as String,
  //           'date': date as String,
  //           'amount': amount as double,
  //           'source': source as String,
  //           'category': category as String?,
  //           'account_id': accountId as int,
  //           'desc': desc as String,
  //         }
  //         in transactionMaps)
  //       TransactionObj(
  //         id: id,
  //         type: type,
  //         amount: amount,
  //         source: source,
  //         date: date,
  //         category: category,
  //         accountId: accountId,
  //         desc: desc,
  //       ),
  //   ];
  // }

  Future<List<TransactionObj>> getUncategorizedTx() async {
    List<TransactionObj> x = [];

    AuthModel aM;
    if (!di.isRegistered<AuthModel>()) {
      aM = AuthModel();
    } else {
      aM = di<AuthModel>();
    }
    final db = await DatabaseHelper().database;
    // final List<Map<String, Object?>> transactionMaps = await db.rawQuery(
    //   "SELECT * from transactions WHERE category is null AND account_id = ?",
    //   ['${await aM.getAccountId()}'],
    // );

    final List<Map<String, Object?>> transactionMaps = await db.query(
      'transactions',
      where: 'category is null AND account_id = ?',
      whereArgs: [await aM.getAccountId()],
      orderBy: 'DATE(date) DESC',
    );
    log("found ${transactionMaps.length} uncategorized transaction");
    // transactionMaps.forEach((tx) {
    //   log(
    //     TransactionObj(
    //       id: tx["id"] as int,
    //       type: tx["type"] as String,
    //       amount: tx["amount"] as double,
    //       source: tx["source"] as String,
    //       date: tx["date"] as String,
    //       category: tx["category"] as String?,
    //       accountId: tx['account_id'] as int?,
    //       desc: tx['desc'] as String,
    //
    //       messageHashCode: tx['message_hash_code'] as String?,
    //     ).toString(),
    //   );
    // });
    if (transactionMaps.isNotEmpty) {
      [
        for (final {
              'id': id as int,
              'type': type as String,
              'date': date as String,
              'amount': amount as double,
              'source': source as String,
              'category': category as String?,
              'account_id': accountId as int?,
              'desc': desc as String,

              'message_hash_code': messageHashCode as String?,
            }
            in transactionMaps)
          {
            x.add(
              TransactionObj(
                id: id,
                type: type,
                amount: amount,
                source: source,
                date: date,
                category: category,
                accountId: accountId,
                desc: desc,

                messageHashCode: messageHashCode,
              ),
            ),
          },
      ];
    }

    return x;
  }

  Future<List<TransactionObj>> getTransactions() async {
    AuthModel aM;
    if (!di.isRegistered<AuthModel>()) {
      aM = AuthModel();
    } else {
      aM = di<AuthModel>();
    }
    List<TransactionObj> x = [];
    final db = await DatabaseHelper().database;
    log("Getting Transactions");
    // final List<Map<String, Object?>> transactionMaps = await db.rawQuery(
    //   'SELECT * FROM transactions WHERE account_id = ?',
    //   ['${await aM.getAccountId()}'],
    // );

    final List<Map<String, Object?>> transactionMaps = await db.query(
      'transactions',
      where: 'account_id = ?',
      whereArgs: ['${await aM.getAccountId()}'],

      orderBy: 'DATE(date) DESC',
    );
    log("found ${transactionMaps.length} transaction");
    // transactionMaps.forEach((tx) {
    //   log(
    //     TransactionObj(
    //       id: tx["id"] as int,
    //       type: tx["type"] as String,
    //       amount: tx["amount"] as double,
    //       source: tx["source"] as String,
    //       date: tx["date"] as String,
    //       category: tx["category"] as String?,
    //       accountId: tx["account_id"] as int,
    //       desc: tx['desc'] as String,
    //
    //       messageHashCode: tx['message_hash_code'] as String?,
    //     ).toString(),
    //   );
    // });
    if (transactionMaps.isNotEmpty) {
      for (final {
            'id': id as int,
            'type': type as String,
            'date': date as String,
            'amount': amount as double,
            'source': source as String,
            'category': category as String?,
            'account_id': accountId as int,
            'desc': desc as String,
            'message_hash_code': messageHashCode as String?,
          }
          in transactionMaps) {
        x.add(
          TransactionObj(
            id: id,
            type: type,
            amount: amount,
            source: source,
            date: date,
            category: category,
            accountId: accountId,
            desc: desc,
            messageHashCode: messageHashCode,
          ),
        );
      }
    }
    pages = (x.length / 5).ceil();
    notifyListeners();
    return x;
  }

  Future<Result<int?>> insertTransaction(TransactionObj transaction) async {
    try {
      AuthModel aM;
      if (!di.isRegistered<AuthModel>()) {
        aM = AuthModel();
      } else {
        aM = di<AuthModel>();
      }

      final db = await DatabaseHelper().database;

      log("Inserting transaction");
      var txs = await db.query(
        'transactions',
        where: 'message_hash_code = ?',
        whereArgs: ['${transaction.messageHashCode}'],
      );
      bool exists = txs.isNotEmpty;
      if (!exists) {
        int txId = await db.insert('transactions', transaction.toMap());
        int? acId = await aM.getAccountId();
        int updated = await db.rawUpdate(
          'UPDATE transactions SET account_id = ? WHERE id = ? ',
          ['$acId', '$txId'],
        );
        SharedPreferencesAsync prefs = SharedPreferencesAsync();
        int? notiId = await prefs.getInt('notification_id')!;
        if (updated > 0) {
          switch (transaction.type) {
            case 'credit':
              {
                AwesomeNotifications().createNotification(
                  content: NotificationContent(
                    id: notiId!,
                    displayOnForeground: true,
                    channelKey: 'budgetlite_silent',
                    actionType: ActionType.Default,
                    title: 'New transaction',
                    body: 'Credited from ${transaction.source}',
                  ),
                );
                await prefs.setInt('notification_id', notiId! + 1);
                refreshTx();
                notifyListeners();
                return Result.ok(txId);
              }
            case 'from saving':
              {
                AwesomeNotifications().createNotification(
                  content: NotificationContent(
                    id: notiId!,
                    channelKey: 'budgetlite_silent',
                    actionType: ActionType.Default,
                    title: 'New transaction',
                    body: 'transfered from Savings',
                  ),
                );

                prefs.setInt('notification_id', notiId! + 1);
                refreshTx();
                notifyListeners();
                return Result.ok(txId);
              }
            case 'to saving':
              {
                AwesomeNotifications().createNotification(
                  content: NotificationContent(
                    id: notiId!,
                    channelKey: 'budgetlite_silent',
                    actionType: ActionType.Default,
                    title: 'New transaction',
                    body: 'transfered to savings',
                  ),
                );

                prefs.setInt('notification_id', notiId! + 1);
                refreshTx();
                notifyListeners();
                return Result.ok(txId);
              }
            case 'spend':
              {
                AwesomeNotifications().createNotification(
                  content: NotificationContent(
                    id: notiId!,
                    channelKey: 'budgetlite_silent',
                    actionType: ActionType.Default,
                    title: 'New transaction',
                    body: 'Click to set budget category',
                  ),
                );

                prefs.setInt('notification_id', notiId! + 1);
                refreshTx();
                notifyListeners();
                return Result.ok(txId);
              }

            default:
              {
                refreshTx();
                notifyListeners();
                return Result.ok(txId);
              }
          }
        } else {
          return Result.ok(txId);
        }
      } else {
        return Result.error(TransactionExists());
      }
    } on Exception catch (e) {
      debugPrint('Error occured inserting tx:$e');
      log('Error occured inserting tx:', error: e);
      return Result.error(e);
    }
  }
}
