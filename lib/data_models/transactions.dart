import 'dart:developer';

import 'package:another_telephony/telephony.dart';
import 'package:flutter_application_1/data_models/auth_data_model.dart';
import 'package:flutter_application_1/db/db.dart';

const String received = "received";
const String paid = "paid to";
const String sent = "sent to";
const String transferred = "transferred";

enum TxType {
  spend('spend'),
  credit('credit'),
  fromSaving('from saving'),
  toSaving("to saving");

  const TxType(this.val);
  final String val;
}

class TransactionObj {
  final int? id;
  final String type;
  final String source;
  final double amount;
  final String date;
  final String? category;
  final int? accountId;
  final String desc;

  TransactionObj({
    this.id,
    required this.type,
    required this.desc,
    required this.source,
    required this.amount,
    required this.date,
    this.accountId,
    this.category,
  });

  Map<String, Object> toMap() {
    return {
      "id": ?id,
      "type": type,
      "source": source,
      'desc': desc,
      "amount": amount,
      "date": date,
      "category": ?category,
      'account_id': ?accountId,
    };
  }

  @override
  String toString() {
    return 'Transaction{id:$id,type:$type,source:$source,amount:$amount,date:$date,category:$category,account_id:$accountId,desc:$desc}';
  }
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
  final db = await getDb();
  final List<Map<String, Object?>> transactionMaps = await db.rawQuery(
    "SELECT * from transactions WHERE category is null AND account_id = ?",
    ['${await getAccountId()}'],
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

Future<int> insertTransaction(TransactionObj transaction) async {
  final db = await getDb();

  log("Inserting transaction");
  int txId = await db.insert('transactions', transaction.toMap());
  int? acId = await getAccountId();
  await db.rawUpdate('UPDATE transactions SET account_id = ? WHERE id = ? ', [
    '$acId',
    '$txId',
  ]);
  return txId;
}

reset() async {
  final db = await getDb();
  db.delete("transactions");
}

Future<List<TransactionObj>> getTransactions() async {
  List<TransactionObj> x = [];
  final db = await getDb();
  log("Getting Transactions");
  final List<Map<String, Object?>> transactionMaps = await db.rawQuery(
    'SELECT * FROM transactions WHERE account_id = ?',
    ['${await getAccountId()}'],
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
  return x;
}

Map<String, dynamic>? parseMpesa(SmsMessage messageObj) {
  if (messageObj.body != null) {
    String? message = messageObj.body;
    log("message:${messageObj.body}");
    Map<String, dynamic> transaction = {
      "type": "",
      "source": "Mpesa",
      "amount": 0,
      'date': "",
      'desc': '',
    };
    if (message!.contains(received)) {
      List<String> receivedArray = message.split(received);
      String amount = receivedArray[1]
          .split("from")[0]
          .trim()
          .split("Ksh")[1]
          .replaceAll(',', '');

      transaction['date'] = message.split(" on ")[1].split("at")[0].trim();
      transaction["amount"] = double.parse(amount);
      transaction["type"] = TxType.credit.val;
      transaction['desc'] = receivedArray[1].split('from')[1].split('at')[0];

      return transaction;
    }
    if (message.contains(paid)) {
      List<String> paidArray = message.split(paid);

      String amount = paidArray[0].split("Ksh")[1].trim().replaceAll(",", "");

      transaction["date"] = message.split(" on ")[1].split("at")[0];
      transaction["amount"] = double.parse(amount);
      transaction["type"] = TxType.spend.val;
      transaction['desc'] = paidArray[1].split('on')[0].trim();

      return transaction;
    }
    if (message.contains(sent)) {
      List<String> sentArray = message.split(sent);
      String amount = sentArray[0].split("Ksh")[1].replaceAll(",", "");

      transaction["amount"] = double.parse(amount);
      transaction['date'] = message.split(" on ")[1].split("at")[0].trim();
      transaction["type"] = TxType.spend.val;
      transaction['desc'] = sentArray[1].split('at')[0].trim();

      return transaction;
    }

    if (message.contains(transferred)) {
      List<String> transferredArray = message.split(transferred);
      if (transferredArray[1].trim().split(' ')[0] == 'from') {
        transaction["type"] = TxType.fromSaving.val;
      } else if (transferredArray[1].trim().split(' ')[0] == 'to') {
        transaction["type"] = TxType.toSaving.val;
      }
      String amount = transferredArray[0]
          .split("Ksh")[1]
          .trim()
          .replaceAll(",", "");

      transaction["amount"] = double.parse(amount);

      transaction['date'] = message.split(" on ")[1].split("at")[0].trim();

      return transaction;
    }
  }
  return null;
}
