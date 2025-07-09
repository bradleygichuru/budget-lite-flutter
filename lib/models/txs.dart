import 'package:flutter/material.dart';
import 'package:flutter_application_1/funcs/transactions.dart';

class TransactionsModel extends ChangeNotifier {
  TransactionsModel() {
    initTxs();
  }
  late Future<List<TransactionObj>> transactions;
  Future<double> ready_to_assign = Future.value(0);
  Future<double> total_spent = Future.value(0);
  Future<double> total_transacted = Future.value(0);
  // List<Widget> composedTranactions = [];
  void initTxs() {
    transactions = getTransactions();
    notifyListeners();
  }

  void refreshTx() {
    transactions = getTransactions();
    notifyListeners();
  }

  Future<void> handleTxAdd(Map<String, dynamic> transaction) async {
    await insertTransaction(
      TransactionObj(
        type: transaction['type'],
        source: transaction['source'],
        amount: transaction['amount'],
        date: transaction['date'],
      ),
    ).whenComplete(() async {
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
// void composeTransactions() {
//     for (var tx in transactions) {
//       final String sign = tx.type == "spend" ? '-' : '+';
//       final double amount = tx.amount;
//       Icon iconsToUse = tx.type == "spend"
//           ? Icon(size: 15, Icons.outbound, color: Colors.red)
//           : Icon(size: 15, Icons.call_received, color: Colors.green);
//       composedTranactions.add(
//         SizedBox(
//           child: Card.outlined(
//             color: Colors.white,

//             child: Column(
//               children: [
//                 ListTile(
//                   leading: iconsToUse,
//                   title: Text('Cat x'),
//                   subtitle: Text(
//                     '$sign KSh $amount',
//                     style: TextStyle(
//                       color: tx.type == "spend" ? Colors.red : Colors.green,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//     notifyListeners();
//   }
