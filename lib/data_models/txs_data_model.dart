import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'package:another_telephony/telephony.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/data_models/wallet_data_model.dart';
import 'package:flutter_application_1/data_models/weekly_reports_data_model.dart';
import 'package:flutter_application_1/db/db.dart';
import 'package:flutter_application_1/view_models/txs.dart';
import 'package:flutter_application_1/view_models/wallet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:intl/intl.dart';

const String mpesaReceived = "received";
const String mpesaBought = "bought";
const String mpesaPaid = "paid to";
const String mpesaSent = "sent to";
const String mpesaTransferred = "transferred";
const String equitySent = 'sent';
const String ncbaCredited = 'credited';
const String equityPaid = 'Bill payment';
const String ncbaPaid = 'Paybill';
const String equityCardPayment = 'Auth for card';

enum TxType {
  spend('spend'),
  credit('credit'),
  fromSaving('from saving'),
  toSaving("to saving");

  const TxType(this.val);
  final String val;
}

class TransactionObj {
  final String? messageHashCode;
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
    this.messageHashCode,
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
      'message_hash_code': ?messageHashCode,
    };
  }

  @override
  String toString() {
    return 'Transaction{id:$id,type:$type,source:$source,amount:$amount,date:$date,category:$category,account_id:$accountId,desc:$desc,messageHashCode:$messageHashCode}';
  }
}

Map<String, dynamic>? parseMpesa(SmsMessage messageObj) {
  if (messageObj.body != null) {
    RegExp dateRegex = RegExp(r'\b\d{1,2}/\d{1,2}/\d{2}\b');
    final regex = RegExp(r'Transaction cost,?\s*Ksh\s?\d+\.\d{2}');
    final DateFormat formatter = DateFormat('dd/MM/yy');
    String? message = messageObj.body;
    // log("message:${messageObj.body}");
    Map<String, dynamic> transaction = {
      "type": "",
      "source": "Mpesa",
      "amount": 0,
      'date': "",
      'desc': '',
    };
    double txCost = 0;
    if (message != null) {
      final match = regex.firstMatch(message);
      if (match != null) {
        txCost = double.parse(match.group(0)!.split('Ksh')[1]);
      }
    }
    if (message!.contains(mpesaBought)) {
      List<String> boughtArray = message.split(mpesaBought);
      String amount = boughtArray[1]
          .split('of')[0]
          .replaceAll(',', '')
          .split('Ksh')[1]
          .trim();

      transaction["type"] = TxType.spend.val;
      transaction['date'] = formatter
          .tryParse(dateRegex.allMatches(message).first.group(0) ?? '')
          .toString();
      dateRegex.firstMatch(message);
      transaction["amount"] = double.parse(amount) + txCost;
      transaction['desc'] = message;
    }
    if (message.contains(mpesaReceived)) {
      List<String> receivedArray = message.split(mpesaReceived);
      String amount = receivedArray[1]
          .split("from")[0]
          .trim()
          .split("Ksh")[1]
          .replaceAll(',', '');

      transaction['date'] = formatter
          .tryParse(dateRegex.allMatches(message).first.group(0) ?? '')
          .toString();
      transaction["amount"] = double.parse(amount) + txCost;
      transaction["type"] = TxType.credit.val;
      transaction['desc'] = message;

      return transaction;
    }
    if (message.contains(mpesaPaid)) {
      List<String> paidArray = message.split(mpesaPaid);

      String amount = paidArray[0].split("Ksh")[1].trim().replaceAll(",", "");

      transaction['date'] = formatter
          .tryParse(dateRegex.allMatches(message).first.group(0) ?? '')
          .toString();
      transaction["amount"] = double.parse(amount) + txCost;
      transaction["type"] = TxType.spend.val;
      transaction['desc'] = message;

      return transaction;
    }
    if (message.contains(mpesaSent)) {
      List<String> sentArray = message.split(mpesaSent);
      String amount = sentArray[0].split("Ksh")[1].replaceAll(",", "");

      transaction["amount"] = double.parse(amount) + txCost;
      transaction['date'] = formatter
          .tryParse(dateRegex.allMatches(message).first.group(0) ?? '')
          .toString();
      transaction["type"] = TxType.spend.val;
      transaction['desc'] = message;

      return transaction;
    }

    if (message.contains(mpesaTransferred)) {
      List<String> transferredArray = message.split(mpesaTransferred);
      if (transferredArray[1].trim().split(' ')[0] == 'from') {
        transaction["type"] = TxType.fromSaving.val;
      } else if (transferredArray[1].trim().split(' ')[0] == 'to') {
        transaction["type"] = TxType.toSaving.val;
      }
      String amount = transferredArray[0]
          .split("Ksh")[1]
          .trim()
          .replaceAll(",", "");

      transaction["amount"] = double.parse(amount) + txCost;
      transaction['date'] = formatter
          .tryParse(dateRegex.allMatches(message).first.group(0) ?? '')
          .toString();
      transaction['desc'] = message;

      return transaction;
    }
  }
  return null;
}

Map<String, dynamic>? parseNCBA(SmsMessage messageObj) {
  if (messageObj.body != null) {
    String? message = messageObj.body;
    log("message:${messageObj.body}");
    Map<String, dynamic> transaction = {
      "type": "",
      "source": "NCBA_BANK",
      "amount": 0,
      'date': "",
      'desc': '',
    };
    if (message!.contains(ncbaPaid)) {
      List<String> paidArray = message.split(ncbaPaid);
      String amount = paidArray[1].split('KES')[1].split('to')[0].trim();
      transaction['amount'] = double.parse(amount);
      transaction['desc'] = message;
      transaction["type"] = TxType.spend.val;
      transaction['date'] = DateTime.now().toString();
      return transaction;
    }
    if (message.contains(ncbaCredited)) {
      List<String> creditArray = message.split(ncbaCredited);
      String amount = creditArray[1];
      transaction['amount'] = double.parse(amount);
      transaction["type"] = TxType.credit.val;
      transaction['desc'] = message;
      transaction['date'] = DateTime.now().toString();
      return transaction;
    }
  }
  return null;
}

Map<String, dynamic>? parseEquity(SmsMessage messageObj) {
  if (messageObj.body != null) {
    String? message = messageObj.body;
    log("message:${messageObj.body}");
    Map<String, dynamic> transaction = {
      "type": "",
      "source": "Equity_BANK",
      "amount": 0,
      'date': "",
      'desc': '',
    };
    if (message!.contains(equitySent)) {
      List<String> sentArray = message.split(equitySent);
      String amount = sentArray[1].split('to')[0].split('KShs.')[1].trim();
      transaction['amount'] = double.parse(amount);
      transaction["type"] = TxType.spend.val;
      transaction['date'] = DateTime.now().toString();
      transaction['desc'] = message;
      return transaction;
    }
    if (message.contains(equityPaid)) {
      List<String> paidArray = message.split(equityPaid);
      String amount = paidArray[1]
          .split('for')[0]
          .split('of')[1]
          .trim()
          .replaceAll('KES.', '')
          .trim();

      transaction['amount'] = double.parse(amount);

      transaction["type"] = TxType.spend.val;
      transaction['desc'] = message;
      transaction['date'] = DateTime.now().toString();

      return transaction;
    }
    if (message.contains(equityCardPayment)) {
      List<String> paidArray = message.split(equityCardPayment);
      String amount = paidArray[0]
          .split('KES')[1]
          .replaceAll(',', '')
          .trim()
          .replaceAll(' ', '');

      transaction['amount'] = double.parse(amount);
      transaction["type"] = TxType.spend.val;
      transaction['desc'] = message;
      transaction['date'] = DateTime.now().toString();

      return transaction;
    }
  }

  return null;
}

Future<void> queryEquity() async {
  try {
    final telephony = Telephony.instance ?? Telephony.backgroundInstance;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final db = await DatabaseHelper().database;
    int? accountId = prefs.getInt("budget_lite_current_account_id");
    List<SmsMessage> messages = await telephony.getInboxSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY],
      filter: SmsFilter.where(SmsColumn.ADDRESS).equals("Equity Bank"),
      sortOrder: [
        OrderBy(SmsColumn.ADDRESS, sort: Sort.ASC),
        OrderBy(SmsColumn.BODY),
      ],
    );
    for (var message in messages) {
      log('parsing Equity tx message');
      var transaction = parseEquity(message);

      log('equity_transaction:$transaction');
      if (message.body != null) {
        var bytes = utf8.encode(message.body!); // data being hashed

        var digest = sha1.convert(bytes);
        debugPrint('equity_transaction:$transaction');
        log('from:${message.address} message:${message.body}');
        if (transaction != null) {
          if (transaction['type'] == TxType.spend.val) {
            TransactionObj tx = TransactionObj(
              messageHashCode: digest.toString(),
              desc: transaction['desc'],
              type: transaction['type'],
              source: transaction['source'],
              amount: transaction['amount'],
              date: transaction['date'],
            );
            // txM.insertTransaction(tx);

            db.transaction((txn) async {
              var txs = await txn.query(
                'transactions',
                where: 'message_hash_code = ?',
                whereArgs: ['${digest.toString()}'],
              );

              bool exists = txs.isNotEmpty;
              if (!exists) {
                Wallet? accountWallet;

                final List<Map<String, Object?>> walletMap = await txn.rawQuery(
                  "SELECT * FROM wallets WHERE account_id = ? AND name = ?",
                  [accountId, 'default'],
                );
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

                accountWallet = Wallet(
                  id: foundWalletMap['id'] as int,
                  accountId: foundWalletMap['account_id'] as int,
                  name: foundWalletMap['name'] as String,
                  balance: foundWalletMap['balance'] as double,
                  savings: foundWalletMap['savings'] as double,
                );

                int txId = await txn.insert('transactions', tx.toMap());
                await txn.rawUpdate(
                  'UPDATE transactions SET account_id = ? WHERE id = ? ',
                  ['$accountId', '$txId'],
                );

                double balance = accountWallet.balance - tx.amount;
                await txn.rawUpdate(
                  "UPDATE wallets SET balance = ? WHERE account_id = ? AND name = ?",
                  ['$balance', '$accountId', 'default'],
                );
              }
            });
          }
        }
      }
    }
  } catch (e) {
    log('Error occured while querying sms', error: e);
    debugPrint('Error occured while querying sms:$e');
  }
}

Future<void> queryNcba() async {
  try {
    final telephony = Telephony.instance ?? Telephony.backgroundInstance;
    final db = await DatabaseHelper().database;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? accountId = prefs.getInt("budget_lite_current_account_id");
    List<SmsMessage> messages = await telephony.getInboxSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY],
      filter: SmsFilter.where(SmsColumn.ADDRESS).equals("NCBA_BANK"),
      sortOrder: [
        OrderBy(SmsColumn.ADDRESS, sort: Sort.ASC),
        OrderBy(SmsColumn.BODY),
      ],
    );
    for (var message in messages) {
      if (message.body != null) {
        var bytes = utf8.encode(message.body!); // data being hashed

        var digest = sha1.convert(bytes);
        var transaction = parseNCBA(message);

        log('ncba_transaction:$transaction');
        debugPrint('ncba_transaction:$transaction');
        if (transaction != null && accountId != null) {
          if (transaction['type'] == TxType.credit.val) {
            TransactionObj tx = TransactionObj(
              messageHashCode: digest.toString(),
              desc: transaction['desc'],
              type: transaction['type'],
              source: transaction['source'],
              amount: transaction['amount'],
              date: transaction['date'],
              category: 'credit',
            );
            await db.transaction((Transaction txn) async {
              var txs = await txn.query(
                'transactions',
                where: 'message_hash_code = ?',
                whereArgs: ['${digest.toString()}'],
              );
              bool exists = txs.isNotEmpty;
              if (!exists) {
                Wallet? accountWallet;

                final List<Map<String, Object?>> walletMap = await txn.rawQuery(
                  "SELECT * FROM wallets WHERE account_id = ? AND name = ?",
                  [accountId, 'default'],
                );
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

                accountWallet = Wallet(
                  id: foundWalletMap['id'] as int,
                  accountId: foundWalletMap['account_id'] as int,
                  name: foundWalletMap['name'] as String,
                  balance: foundWalletMap['balance'] as double,
                  savings: foundWalletMap['savings'] as double,
                );

                int txId = await txn.insert('transactions', tx.toMap());
                await txn.rawUpdate(
                  'UPDATE transactions SET account_id = ? WHERE id = ? ',
                  ['$accountId', '$txId'],
                );

                double newBalance = accountWallet.balance + tx.amount;
                await txn.rawUpdate(
                  "UPDATE wallets SET balance = ? WHERE account_id = ? AND name = ?",
                  ['$newBalance', '$accountId', 'default'],
                );
              }
            });

            // wM.creditDefaultWallet(tx);
          } else if (transaction['type'] == TxType.spend.val) {
            TransactionObj tx = TransactionObj(
              messageHashCode: digest.toString(),
              desc: transaction['desc'],
              type: transaction['type'],
              source: transaction['source'],
              amount: transaction['amount'],
              date: transaction['date'],
            );
            // txM.insertTransaction(tx);

            db.transaction((txn) async {
              var txs = await txn.query(
                'transactions',
                where: 'message_hash_code = ?',
                whereArgs: ['${digest.toString()}'],
              );

              bool exists = txs.isNotEmpty;
              if (!exists) {
                Wallet? accountWallet;

                final List<Map<String, Object?>> walletMap = await txn.rawQuery(
                  "SELECT * FROM wallets WHERE account_id = ? AND name = ?",
                  [accountId, 'default'],
                );
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

                accountWallet = Wallet(
                  id: foundWalletMap['id'] as int,
                  accountId: foundWalletMap['account_id'] as int,
                  name: foundWalletMap['name'] as String,
                  balance: foundWalletMap['balance'] as double,
                  savings: foundWalletMap['savings'] as double,
                );

                int txId = await txn.insert('transactions', tx.toMap());
                await txn.rawUpdate(
                  'UPDATE transactions SET account_id = ? WHERE id = ? ',
                  ['$accountId', '$txId'],
                );

                double balance = accountWallet.balance - tx.amount;
                await txn.rawUpdate(
                  "UPDATE wallets SET balance = ? WHERE account_id = ? AND name = ?",
                  ['$balance', '$accountId', 'default'],
                );
              }
            });
          }
        }
      }
    }
  } catch (e) {
    log('Error occured while querying sms', error: e);
    debugPrint('Error occured while querying sms:$e');
  }
}

Future<void> queryMpesa() async {
  try {
    final telephony = Telephony.instance ?? Telephony.backgroundInstance;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final db = await DatabaseHelper().database;
    int? accountId = prefs.getInt("budget_lite_current_account_id");
    List<SmsMessage> messages = await telephony.getInboxSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY],
      filter: SmsFilter.where(SmsColumn.ADDRESS).equals("MPESA"),
      sortOrder: [OrderBy(SmsColumn.BODY, sort: Sort.ASC)],
    );
    if (messages.isNotEmpty) {
      for (var message in messages) {
        // log('parsing mpesa tx message');

        if (message.body != null) {
          var bytes = utf8.encode(message.body!); // data being hashed

          var digest = sha1.convert(bytes);
          var transaction = parseMpesa(message);

          // log('mpesa_transaction:$transaction');

          // debugPrint('mpesa_transaction:$transaction');
          if (transaction != null && accountId != null) {
            // if (DateTime.parse(transaction['date']).isAtSameMomentAs(
            //       DateTime.parse(prefs.getString('begin_date') ?? ''),
            //     ) ||
            //     DateTime.parse(
            //       transaction['date'],
            //     ).isAfter(DateTime.parse(prefs.getString('begin_date') ?? ''))) {
            if (DateTime.parse(
              transaction['date'],
            ).isAfter(DateTime.parse('2025-06-01'))) {
              if (transaction['type'] == TxType.credit.val) {
                TransactionObj tx = TransactionObj(
                  messageHashCode: digest.toString(),
                  desc: transaction['desc'],
                  type: transaction['type'],
                  source: transaction['source'],
                  amount: transaction['amount'],
                  date: transaction['date'],
                  category: 'credit',
                );
                await db.transaction((Transaction txn) async {
                  var txs = await txn.query(
                    'transactions',
                    where: 'message_hash_code = ?',
                    whereArgs: [digest.toString()],
                  );
                  bool exists = txs.isNotEmpty;
                  if (!exists) {
                    Wallet? accountWallet;

                    final List<Map<String, Object?>>
                    walletMap = await txn.rawQuery(
                      "SELECT * FROM wallets WHERE account_id = ? AND name = ?",
                      [accountId, 'default'],
                    );
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

                    accountWallet = Wallet(
                      id: foundWalletMap['id'] as int,
                      accountId: foundWalletMap['account_id'] as int,
                      name: foundWalletMap['name'] as String,
                      balance: foundWalletMap['balance'] as double,
                      savings: foundWalletMap['savings'] as double,
                    );

                    int txId = await txn.insert('transactions', tx.toMap());
                    await txn.rawUpdate(
                      'UPDATE transactions SET account_id = ? WHERE id = ? ',
                      ['$accountId', '$txId'],
                    );

                    double newBalance = accountWallet.balance + tx.amount;
                    await txn.rawUpdate(
                      "UPDATE wallets SET balance = ? WHERE account_id = ? AND name = ?",
                      ['$newBalance', '$accountId', 'default'],
                    );
                  }
                });

                // wM.creditDefaultWallet(tx);
              } else if (transaction['type'] == TxType.fromSaving.val) {
                TransactionObj tx = TransactionObj(
                  messageHashCode: digest.toString(),
                  desc: transaction['desc'],
                  type: transaction['type'],
                  category: 'credit',
                  source: transaction['source'],
                  amount: transaction['amount'],
                  date: transaction['date'],
                );
                // wM.removeFromSavings(tx);
                await db.transaction((txn) async {
                  var txs = await txn.query(
                    'transactions',
                    where: 'message_hash_code = ?',
                    whereArgs: [digest.toString()],
                  );
                  bool exists = txs.isNotEmpty;
                  if (!exists) {
                    Wallet? accountWallet;

                    final List<Map<String, Object?>>
                    walletMap = await txn.rawQuery(
                      "SELECT * FROM wallets WHERE account_id = ? AND name = ?",
                      [accountId, 'default'],
                    );
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

                    accountWallet = Wallet(
                      id: foundWalletMap['id'] as int,
                      accountId: foundWalletMap['account_id'] as int,
                      name: foundWalletMap['name'] as String,
                      balance: foundWalletMap['balance'] as double,
                      savings: foundWalletMap['savings'] as double,
                    );

                    int txId = await txn.insert('transactions', tx.toMap());
                    await txn.rawUpdate(
                      'UPDATE transactions SET account_id = ? WHERE id = ? ',
                      ['$accountId', '$txId'],
                    );

                    bool? isMshwariDepost =
                        prefs.getBool('is_mshwari_savings') ?? true;
                    if (!isMshwariDepost) {
                      double newSavings = accountWallet.savings - tx.amount;
                      double balance = accountWallet.balance + tx.amount;
                      await txn.rawUpdate(
                        "UPDATE wallets SET balance = ?,savings = ? WHERE account_id = ? AND name = ?",
                        ['$balance', '$newSavings', '$accountId', 'default'],
                      );
                    }
                  }
                });
              } else if (transaction['type'] == TxType.toSaving.val) {
                TransactionObj tx = TransactionObj(
                  messageHashCode: digest.toString(),
                  desc: transaction['desc'],
                  type: transaction['type'],
                  source: transaction['source'],
                  category: 'savings',
                  amount: transaction['amount'],
                  date: transaction['date'],
                );
                // wM.addToSavings(tx);
                db.transaction((txn) async {
                  var txs = await txn.query(
                    'transactions',
                    where: 'message_hash_code = ?',
                    whereArgs: [digest.toString()],
                  );

                  bool exists = txs.isNotEmpty;
                  if (!exists) {
                    Wallet? accountWallet;

                    final List<Map<String, Object?>>
                    walletMap = await txn.rawQuery(
                      "SELECT * FROM wallets WHERE account_id = ? AND name = ?",
                      [accountId, 'default'],
                    );
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

                    accountWallet = Wallet(
                      id: foundWalletMap['id'] as int,
                      accountId: foundWalletMap['account_id'] as int,
                      name: foundWalletMap['name'] as String,
                      balance: foundWalletMap['balance'] as double,
                      savings: foundWalletMap['savings'] as double,
                    );

                    int txId = await txn.insert('transactions', tx.toMap());
                    await txn.rawUpdate(
                      'UPDATE transactions SET account_id = ? WHERE id = ? ',
                      ['$accountId', '$txId'],
                    );

                    bool? isMshwariDepost =
                        prefs.getBool('is_mshwari_savings') ?? true;
                    if (!isMshwariDepost) {
                      double newSavings = accountWallet.savings + tx.amount;
                      double balance =
                          accountWallet.balance == 0.0 ||
                              tx.amount > accountWallet.balance
                          ? 0
                          : accountWallet.balance - tx.amount;
                      await txn.rawUpdate(
                        "UPDATE wallets SET balance = ?,savings = ? WHERE account_id = ?",
                        ['$balance', '$newSavings', '$accountId'],
                      );
                    }
                  }
                });
              } else {
                TransactionObj tx = TransactionObj(
                  messageHashCode: digest.toString(),
                  desc: transaction['desc'],
                  type: transaction['type'],
                  source: transaction['source'],
                  amount: transaction['amount'],
                  date: transaction['date'],
                );
                // txM.insertTransaction(tx);

                db.transaction((txn) async {
                  var txs = await txn.query(
                    'transactions',
                    where: 'message_hash_code = ?',
                    whereArgs: [digest.toString()],
                  );

                  bool exists = txs.isNotEmpty;
                  if (!exists) {
                    Wallet? accountWallet;

                    final List<Map<String, Object?>>
                    walletMap = await txn.rawQuery(
                      "SELECT * FROM wallets WHERE account_id = ? AND name = ?",
                      [accountId, 'default'],
                    );
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

                    accountWallet = Wallet(
                      id: foundWalletMap['id'] as int,
                      accountId: foundWalletMap['account_id'] as int,
                      name: foundWalletMap['name'] as String,
                      balance: foundWalletMap['balance'] as double,
                      savings: foundWalletMap['savings'] as double,
                    );

                    int txId = await txn.insert('transactions', tx.toMap());
                    await txn.rawUpdate(
                      'UPDATE transactions SET account_id = ? WHERE id = ? ',
                      ['$accountId', '$txId'],
                    );

                    double balance = accountWallet.balance - tx.amount;
                    await txn.rawUpdate(
                      "UPDATE wallets SET balance = ? WHERE account_id = ? AND name = ?",
                      ['$balance', '$accountId', 'default'],
                    );
                  }
                });
              }
            }
          }
        }

        // debugPrint(
        //   'messageHashCode:${message.hashCode},messageSentDate:${message.dateSent},messageId:${message.id},messageBody:${message.body}',
        // );
      }
    } else {
      log('No mpesa messages to parse');
    }
  } catch (e) {
    log('Error occured while querying sms', error: e);
    debugPrint('Error occured while querying sms:$e');
  }
}

Future<void> calculateWeekInsights() async {
  debugPrint('Calculating weekly insights');
  DateTime now = DateTime.now();

  int weeks = 4;

  // Calculate the start of the current week (Monday)
  // DateTime.monday is 1, DateTime.sunday is 7
  int daysToSubtract = now.weekday;
  DateTime startOfCurrentWeek = DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(Duration(days: daysToSubtract));

  // Iterate to get the start days of the previous 4 weeks
  for (int i = 0; i < weeks; i++) {
    Map<String, dynamic> report = {};
    DateTime weekStartDate = startOfCurrentWeek.subtract(
      Duration(days: 7 * (i + 1)),
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? accountId = prefs.getInt("budget_lite_current_account_id");

    final db = await DatabaseHelper().database;
    db.transaction((txn) async {
      final List<Map<String, Object?>> categoryMaps = await txn.rawQuery(
        "SELECT * FROM categories WHERE account_id = ?",
        ['$accountId'],
      );

      final List<Map<String, Object?>> transactionMaps = await txn.rawQuery(
        'SELECT * FROM transactions WHERE DATE(date) BETWEEN ? AND ? AND account_id = ?',
        [
          weekStartDate.toString().split(' ')[0],
          weekStartDate.add(Duration(days: 7)).toString().split(' ')[0],
          '$accountId',
        ],
      );
      for (final category in categoryMaps) {
        for (final tx in transactionMaps) {
          if (tx["category"] == category['category_name']) {
            double? current = report[category['category_name'] as String];
            // debugPrint('tx for weekly insights:${tx.toString()}');
            // debugPrint('current category:${category.toString()}');
            if (current != null) {
              report[category['category_name'] as String] =
                  current + (tx["amount"] as double);
            } else {
              report[category['category_name'] as String] = tx["amount"];
            }
          }
        }
      }
      await insertWeeklyReport(
        WeeklyReport(
          key:
              '${weekStartDate.day} ${DateFormat('MMM').format(weekStartDate)} - ${weekStartDate.add(Duration(days: 7)).day} ${DateFormat('MMM').format(weekStartDate.add(Duration(days: 7)))}',
          fromDate: weekStartDate.toString(),
          toDate: weekStartDate.add(Duration(days: 7)).toString(),
          reportData: jsonEncode(report),
        ),
        txn,
      );

      log('New report:${report.toString()}');
    });
  }
}

class TransactionCreationFailed implements Exception {}

class TransactionExists implements Exception {}
