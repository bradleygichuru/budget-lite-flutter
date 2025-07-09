import 'dart:developer';

import 'package:another_telephony/telephony.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const String received = "received";
const String paid = "paid to";
const String sent = "sent to";
const String transferred = "transferred to";


class TransactionObj {
  final int? id;
  final String type;
  final String source;
  final double amount;
  final String date;

  TransactionObj({
    this.id,
    required this.type,
    required this.source,
    required this.amount,
    required this.date,
  });

  Map<String, Object> toMap() {
    return {
      "id": ?id,
      "type": type,
      "source": source,
      "amount": amount,
      "date": date,
    };
  }

  @override
  String toString() {
    return 'Transaction{type:$type,source:$source,amount:$amount,date:$date}';
  }
}

Future<void> insertTransaction(TransactionObj transaction) async {
  final db = await openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'budget_lite_database.db'),
    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      return db.execute(
        'CREATE TABLE transactions(id INTEGER PRIMARY KEY, type TEXT,source TEXT, amount REAL,date TEXT)',
      );
    },

    // When the database is first created, create a table to store dogs.
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );

  log("Inserting transaction");
  await db.insert('transactions', transaction.toMap());
}

reset() async {
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
  db.delete("transactions");
}

Future<List<TransactionObj>> getTransactions() async {
  final db = await openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'budget_lite_database.db'),
    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      return db.execute(
        'CREATE TABLE transactions(id INTEGER PRIMARY KEY, type TEXT,source TEXT, amount REAL,date TEXT)',
      );
    },

    // When the database is first created, create a table to store dogs.
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );
  log("Getting Transactions");
  final List<Map<String, Object?>> transactionMaps = await db.query(
    'transactions',
  );
  log("found ${transactionMaps.length} transaction");
  return [
    for (final {
          'id': id as int,
          'type': type as String,
          'date': date as String,
          'amount': amount as double,
          'source': source as String,
        }
        in transactionMaps)
      TransactionObj(
        id: id,
        type: type,
        amount: amount,
        source: source,
        date: date,
      ),
  ];
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
      transaction["type"] = "credit";

      return transaction;
    }
    if (message.contains(paid)) {
      List<String> paidArray = message.split(paid);

      String amount = paidArray[0].split("Ksh")[1].trim().replaceAll(",", "");

      transaction["date"] = message.split(" on ")[1].split("at")[0];
      transaction["amount"] = double.parse(amount);
      transaction["type"] = "spend";

      return transaction;
    }
    if (message.contains(sent)) {
      List<String> sentArray = message.split(sent);
      String amount = sentArray[0].split("Ksh")[1].replaceAll(",", "");

      transaction["amount"] = double.parse(amount);
      transaction['date'] = message.split(" on ")[1].split("at")[0].trim();
      transaction["type"] = "spend";

      return transaction;
    }

    if (message.contains(transferred)) {
      List<String> transferredArray = message.split(transferred);
      String amount = transferredArray[0]
          .split("Ksh")[1]
          .trim()
          .replaceAll(",", "");

      transaction["amount"] = double.parse(amount);

      transaction["type"] = "spend";
      transaction['date'] = message.split(" on ")[1].split("at")[0].trim();

      return transaction;
    }
  }
  return null;
}
