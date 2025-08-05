import 'dart:developer';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/globals.dart';
import 'package:flutter_application_1/data_models/auth_data_model.dart';
import 'package:flutter_application_1/data_models/transactions.dart';
import 'package:flutter_application_1/db/db.dart';
import 'package:flutter_application_1/view_models/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import 'package:watch_it/watch_it.dart';

class TransactionsModel extends ChangeNotifier {
  TransactionsModel() {
    initTxs();
  }
  late Future<List<TransactionObj>> transactions;
  Future<double> readyToAssign = Future.value(0);
  Future<double> totalSpent = Future.value(0);
  Future<double> totalTransacted = Future.value(0);
  late int pages;
  // List<Widget> composedTranactions = [];
  void initTxs() {
    transactions = getTransactions();
    notifyListeners();
  }

  void refreshTx() {
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
    final db = await getDb();

    log("Getting Transactions");
    int offset = (page - 1) * pageSize;
    final List<Map<String, Object?>> transactionMaps = await db.query(
      'transactions',
      where: 'account_id = ?',
      whereArgs: ['${await aM.getAccountId()}'],
      limit: pageSize,
      offset: offset,
      orderBy: 'date',
    );
    // final List<Map<String, Object?>> transactionMaps = await db.rawQuery(
    //   'SELECT * FROM transactions ORDER BY date LIMIT ? OFFSET ? WHERE account_id = ?',
    //   ['$pageSize', '$offset', '${await aM.getAccountId()}'],
    // );
    log("found ${transactionMaps.length} transaction");
    transactionMaps.forEach((tx) {
      log(
        TransactionObj(
          id: tx["id"] as int,
          type: tx["type"] as String,
          amount: tx["amount"] as double,
          source: tx["source"] as String,
          date: tx["date"] as String,
          category: tx["category"] as String?,
          accountId: tx["account_id"] as int,
          desc: tx['desc'] as String,
        ).toString(),
      );
    });
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
          ),
        );
      }
    }
    return x;
  }

  Future<int> setTxCategory(String category, int id) async {
    AuthModel aM;
    if (!di.isRegistered<AuthModel>()) {
      aM = AuthModel();
    } else {
      aM = di<AuthModel>();
    }
    final db = await getDb();
    log("categorizing tx of id:$id");
    int count = await db.rawUpdate(
      'UPDATE transactions SET category = ? WHERE id = ? AND account_id = ?',
      [category, '$id', '${await aM.getAccountId()}'],
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

  Future<List<TransactionObj>> getTxById(int id) async {
    final db = await getDb();
    final List<Map<String, Object?>> transactionMaps = await db.query(
      "transactions",
      where: '"id=$id"',
    );

    log("found ${transactionMaps.length} uncategorized transaction");
    return [
      for (final {
            'id': id as int,
            'type': type as String,
            'date': date as String,
            'amount': amount as double,
            'source': source as String,
            'category': category as String?,
            'account_id': accountId as int,
            'desc': desc as String,
          }
          in transactionMaps)
        TransactionObj(
          id: id,
          type: type,
          amount: amount,
          source: source,
          date: date,
          category: category,
          accountId: accountId,
          desc: desc,
        ),
    ];
  }

  Future<List<TransactionObj>> getUncategorizedTx() async {
    List<TransactionObj> x = [];

    AuthModel aM;
    if (!di.isRegistered<AuthModel>()) {
      aM = AuthModel();
    } else {
      aM = di<AuthModel>();
    }
    final db = await getDb();
    final List<Map<String, Object?>> transactionMaps = await db.rawQuery(
      "SELECT * from transactions WHERE category is null AND account_id = ?",
      ['${await aM.getAccountId()}'],
    );
    log("found ${transactionMaps.length} uncategorized transaction");
    transactionMaps.forEach((tx) {
      log(
        TransactionObj(
          id: tx["id"] as int,
          type: tx["type"] as String,
          amount: tx["amount"] as double,
          source: tx["source"] as String,
          date: tx["date"] as String,
          category: tx["category"] as String?,
          accountId: tx['account_id'] as int?,
          desc: tx['desc'] as String,
        ).toString(),
      );
    });
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
    final db = await getDb();
    log("Getting Transactions");
    final List<Map<String, Object?>> transactionMaps = await db.rawQuery(
      'SELECT * FROM transactions WHERE account_id = ?',
      ['${await aM.getAccountId()}'],
    );
    log("found ${transactionMaps.length} transaction");
    transactionMaps.forEach((tx) {
      log(
        TransactionObj(
          id: tx["id"] as int,
          type: tx["type"] as String,
          amount: tx["amount"] as double,
          source: tx["source"] as String,
          date: tx["date"] as String,
          category: tx["category"] as String?,
          accountId: tx["account_id"] as int,
          desc: tx['desc'] as String,
        ).toString(),
      );
    });
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
          ),
        );
      }
    }
    pages = (x.length / 5).ceil();
    notifyListeners();
    return x;
  }

  Future<int> insertTransaction(TransactionObj transaction) async {
    AuthModel aM;
    if (!di.isRegistered<AuthModel>()) {
      aM = AuthModel();
    } else {
      aM = di<AuthModel>();
    }

    final db = await getDb();

    log("Inserting transaction");
    int txId = await db.insert('transactions', transaction.toMap());
    int? acId = await aM.getAccountId();
    int updated = await db.rawUpdate(
      'UPDATE transactions SET account_id = ? WHERE id = ? ',
      ['$acId', '$txId'],
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int notiId = prefs.getInt('notification_id')!;
    if (updated > 0) {
      switch (transaction.type) {
        case 'credit':
          {
            // toastification.show(
            //   overlayState: AppGlobal.navigatorKey.currentState?.overlay,
            //   title: Text('New transaction'),
            //   description: RichText(
            //     text: TextSpan(text: 'Credited from ${transaction.source}'),
            //   ),
            //   autoCloseDuration: const Duration(seconds: 5),
            //   animationDuration: const Duration(milliseconds: 300),
            //   alignment: Alignment.topRight,
            //   direction: TextDirection.ltr,
            //   type: ToastificationType.success,
            //   style: ToastificationStyle.fillColored,
            //   icon: const Icon(Icons.check),
            //   showIcon: true, // show or hide the icon
            //   primaryColor: Colors.green,
            //   backgroundColor: Colors.white,
            //   foregroundColor: Colors.black,
            //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            //   margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            //   borderRadius: BorderRadius.circular(12),
            //   boxShadow: const [
            //     BoxShadow(
            //       color: Color(0x07000000),
            //       blurRadius: 16,
            //       offset: Offset(0, 16),
            //       spreadRadius: 0,
            //     ),
            //   ],
            //   showProgressBar: true,
            //   closeButton: ToastCloseButton(
            //     showType: CloseButtonShowType.onHover,
            //     buttonBuilder: (context, onClose) {
            //       return OutlinedButton.icon(
            //         onPressed: onClose,
            //         icon: const Icon(Icons.close, size: 20),
            //         label: const Text('Close'),
            //       );
            //     },
            //   ),
            //   closeOnClick: false,
            //   pauseOnHover: true,
            //   dragToClose: true,
            //   applyBlurEffect: true,
            //   callbacks: ToastificationCallbacks(
            //     onTap: (toastItem) => log('Toast ${toastItem.id} tapped'),
            //     onCloseButtonTap: (toastItem) =>
            //         log('Toast ${toastItem.id} close button tapped'),
            //     onAutoCompleteCompleted: (toastItem) =>
            //         log('Toast ${toastItem.id} auto complete completed'),
            //     onDismissed: (toastItem) =>
            //         log('Toast ${toastItem.id} dismissed'),
            //   ),
            // );
            AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: notiId,
                displayOnForeground: true,
                channelKey: 'budgetlite_silent',
                actionType: ActionType.Default,
                title: 'New transaction',
                body: 'Credited from ${transaction.source}',
              ),
            );
            break;
          }
        case 'from saving':
          {
            // toastification.show(
            //   overlayState: AppGlobal.navigatorKey.currentState?.overlay,
            //   title: Text('New transaction'),
            //   description: RichText(
            //     text: TextSpan(text: 'transfered from savings'),
            //   ),
            //   autoCloseDuration: const Duration(seconds: 5),
            //   animationDuration: const Duration(milliseconds: 300),
            //   alignment: Alignment.topRight,
            //   direction: TextDirection.ltr,
            //   type: ToastificationType.success,
            //   style: ToastificationStyle.fillColored,
            //   icon: const Icon(Icons.check),
            //   showIcon: true, // show or hide the icon
            //   primaryColor: Colors.green,
            //   backgroundColor: Colors.white,
            //   foregroundColor: Colors.black,
            //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            //   margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            //   borderRadius: BorderRadius.circular(12),
            //   boxShadow: const [
            //     BoxShadow(
            //       color: Color(0x07000000),
            //       blurRadius: 16,
            //       offset: Offset(0, 16),
            //       spreadRadius: 0,
            //     ),
            //   ],
            //   showProgressBar: true,
            //   closeButton: ToastCloseButton(
            //     showType: CloseButtonShowType.onHover,
            //     buttonBuilder: (context, onClose) {
            //       return OutlinedButton.icon(
            //         onPressed: onClose,
            //         icon: const Icon(Icons.close, size: 20),
            //         label: const Text('Close'),
            //       );
            //     },
            //   ),
            //   closeOnClick: false,
            //   pauseOnHover: true,
            //   dragToClose: true,
            //   applyBlurEffect: true,
            //   callbacks: ToastificationCallbacks(
            //     onTap: (toastItem) => log('Toast ${toastItem.id} tapped'),
            //     onCloseButtonTap: (toastItem) =>
            //         log('Toast ${toastItem.id} close button tapped'),
            //     onAutoCompleteCompleted: (toastItem) =>
            //         log('Toast ${toastItem.id} auto complete completed'),
            //     onDismissed: (toastItem) =>
            //         log('Toast ${toastItem.id} dismissed'),
            //   ),
            // );

            AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: notiId,
                channelKey: 'budgetlite_silent',
                actionType: ActionType.Default,
                title: 'New transaction',
                body: 'transfered from Savings',
              ),
            );

            break;
          }
        case 'to saving':
          {
            // toastification.show(
            //   overlayState: AppGlobal.navigatorKey.currentState?.overlay,
            //   title: Text('New transaction'),
            //   description: RichText(
            //     text: TextSpan(text: 'transfered to savings'),
            //   ),
            //   autoCloseDuration: const Duration(seconds: 5),
            //   animationDuration: const Duration(milliseconds: 300),
            //   alignment: Alignment.topRight,
            //   direction: TextDirection.ltr,
            //   type: ToastificationType.success,
            //   style: ToastificationStyle.fillColored,
            //   icon: const Icon(Icons.check),
            //   showIcon: true, // show or hide the icon
            //   primaryColor: Colors.green,
            //   backgroundColor: Colors.white,
            //   foregroundColor: Colors.black,
            //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            //   margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            //   borderRadius: BorderRadius.circular(12),
            //   boxShadow: const [
            //     BoxShadow(
            //       color: Color(0x07000000),
            //       blurRadius: 16,
            //       offset: Offset(0, 16),
            //       spreadRadius: 0,
            //     ),
            //   ],
            //   showProgressBar: true,
            //   closeButton: ToastCloseButton(
            //     showType: CloseButtonShowType.onHover,
            //     buttonBuilder: (context, onClose) {
            //       return OutlinedButton.icon(
            //         onPressed: onClose,
            //         icon: const Icon(Icons.close, size: 20),
            //         label: const Text('Close'),
            //       );
            //     },
            //   ),
            //   closeOnClick: false,
            //   pauseOnHover: true,
            //   dragToClose: true,
            //   applyBlurEffect: true,
            //   callbacks: ToastificationCallbacks(
            //     onTap: (toastItem) => log('Toast ${toastItem.id} tapped'),
            //     onCloseButtonTap: (toastItem) =>
            //         log('Toast ${toastItem.id} close button tapped'),
            //     onAutoCompleteCompleted: (toastItem) =>
            //         log('Toast ${toastItem.id} auto complete completed'),
            //     onDismissed: (toastItem) =>
            //         log('Toast ${toastItem.id} dismissed'),
            //   ),
            // );

            AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: notiId,
                channelKey: 'budgetlite_silent',
                actionType: ActionType.Default,
                title: 'New transaction',
                body: 'transfered to savings',
              ),
            );

            break;
          }
        case 'spend':
          {
            // toastification.show(
            //   overlayState: AppGlobal.navigatorKey.currentState?.overlay,
            //   title: Text('New transaction'),
            //   description: RichText(
            //     text: TextSpan(text: 'Click to set budget category'),
            //   ),
            //   autoCloseDuration: const Duration(seconds: 5),
            //   animationDuration: const Duration(milliseconds: 300),
            //   alignment: Alignment.topRight,
            //   direction: TextDirection.ltr,
            //   type: ToastificationType.success,
            //   style: ToastificationStyle.fillColored,
            //   icon: const Icon(Icons.check),
            //   showIcon: true, // show or hide the icon
            //   primaryColor: Colors.green,
            //   backgroundColor: Colors.white,
            //   foregroundColor: Colors.black,
            //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            //   margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            //   borderRadius: BorderRadius.circular(12),
            //   boxShadow: const [
            //     BoxShadow(
            //       color: Color(0x07000000),
            //       blurRadius: 16,
            //       offset: Offset(0, 16),
            //       spreadRadius: 0,
            //     ),
            //   ],
            //   showProgressBar: true,
            //   closeButton: ToastCloseButton(
            //     showType: CloseButtonShowType.onHover,
            //     buttonBuilder: (context, onClose) {
            //       return OutlinedButton.icon(
            //         onPressed: onClose,
            //         icon: const Icon(Icons.close, size: 20),
            //         label: const Text('Close'),
            //       );
            //     },
            //   ),
            //   closeOnClick: false,
            //   pauseOnHover: true,
            //   dragToClose: true,
            //   applyBlurEffect: true,
            //   callbacks: ToastificationCallbacks(
            //     onTap: (toastItem) => log('Toast ${toastItem.id} tapped'),
            //     onCloseButtonTap: (toastItem) =>
            //         log('Toast ${toastItem.id} close button tapped'),
            //     onAutoCompleteCompleted: (toastItem) =>
            //         log('Toast ${toastItem.id} auto complete completed'),
            //     onDismissed: (toastItem) =>
            //         log('Toast ${toastItem.id} dismissed'),
            //   ),
            // );
            AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: notiId,
                channelKey: 'budgetlite_silent',
                actionType: ActionType.Default,
                title: 'New transaction',
                body: 'Click to set budget category',
              ),
            );

            break;
          }

        default:
          {}
      }
    }

    prefs.setInt('notification_id', prefs.getInt('notification_id')! + 1);
    refreshTx();
    notifyListeners();
    return txId;
  }
}
