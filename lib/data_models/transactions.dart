import 'dart:convert';
import 'dart:developer';
import 'package:another_telephony/telephony.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/view_models/txs.dart';
import 'package:flutter_application_1/view_models/wallet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

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
    String? message = messageObj.body;
    log("message:${messageObj.body}");
    Map<String, dynamic> transaction = {
      "type": "",
      "source": "Mpesa",
      "amount": 0,
      'date': "",
      'desc': '',
    };
    if (message!.contains(mpesaBought)) {
      List<String> boughtArray = message.split(mpesaBought);
      String amount = boughtArray[1]
          .split('of')[0]
          .replaceAll(',', '')
          .split('Ksh')[1]
          .trim();

      transaction["type"] = TxType.spend.val;
      transaction['date'] = DateTime.now().toString();
      transaction["amount"] = double.parse(amount);
      transaction['desc'] = boughtArray[1].split('on')[0].trim();
    }
    if (message!.contains(mpesaReceived)) {
      List<String> receivedArray = message.split(mpesaReceived);
      String amount = receivedArray[1]
          .split("from")[0]
          .trim()
          .split("Ksh")[1]
          .replaceAll(',', '');

      transaction['date'] = DateTime.now().toString();
      transaction["amount"] = double.parse(amount);
      transaction["type"] = TxType.credit.val;
      transaction['desc'] = receivedArray[1].split('from')[1].split('at')[0];

      return transaction;
    }
    if (message.contains(mpesaPaid)) {
      List<String> paidArray = message.split(mpesaPaid);

      String amount = paidArray[0].split("Ksh")[1].trim().replaceAll(",", "");

      transaction['date'] = DateTime.now().toString();
      transaction["amount"] = double.parse(amount);
      transaction["type"] = TxType.spend.val;
      transaction['desc'] = paidArray[1].split('on')[0].trim();

      return transaction;
    }
    if (message.contains(mpesaSent)) {
      List<String> sentArray = message.split(mpesaSent);
      String amount = sentArray[0].split("Ksh")[1].replaceAll(",", "");

      transaction["amount"] = double.parse(amount);
      transaction['date'] = DateTime.now().toString();
      transaction["type"] = TxType.spend.val;
      transaction['desc'] = sentArray[1].split('at')[0].trim();

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

      transaction["amount"] = double.parse(amount);
      transaction['date'] = DateTime.now().toString();
      transaction['desc'] = transferredArray[1].split('on')[0].trim();

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
      transaction['desc'] = paidArray[1];
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
      transaction['desc'] = paidArray[1];
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
      transaction['desc'] = paidArray[1];
      transaction['date'] = DateTime.now().toString();

      return transaction;
    }
  }

  return null;
}

Future<void> queryEquity() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  TransactionsModel txM = TransactionsModel();
  WalletModel wM = WalletModel();
  int? accountId = prefs.getInt("budget_lite_current_account_id");
  List<SmsMessage> messages = await Telephony.instance.getInboxSms(
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
          txM.insertTransaction(tx);
        }
      }
    }
  }
}

Future<void> queryNcba() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  TransactionsModel txM = TransactionsModel();
  WalletModel wM = WalletModel();
  int? accountId = prefs.getInt("budget_lite_current_account_id");
  List<SmsMessage> messages = await Telephony.instance.getInboxSms(
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
          wM.creditDefaultWallet(tx);
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
          wM.removeFromSavings(tx);
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
          wM.addToSavings(tx);
        } else if (transaction['type'] == TxType.spend.val) {
          TransactionObj tx = TransactionObj(
            messageHashCode: digest.toString(),
            desc: transaction['desc'],
            type: transaction['type'],
            source: transaction['source'],
            amount: transaction['amount'],
            date: transaction['date'],
          );
          txM.insertTransaction(tx);
        }
      }
    }
  }
}

Future<void> queryMpesa() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  TransactionsModel txM = TransactionsModel();
  WalletModel wM = WalletModel();
  int? accountId = prefs.getInt("budget_lite_current_account_id");
  List<SmsMessage> messages = await Telephony.instance.getInboxSms(
    columns: [SmsColumn.ADDRESS, SmsColumn.BODY],
    filter: SmsFilter.where(SmsColumn.ADDRESS).equals("MPESA"),
    sortOrder: [
      OrderBy(SmsColumn.ADDRESS, sort: Sort.ASC),
      OrderBy(SmsColumn.BODY),
    ],
  );
  for (var message in messages) {
    log('parsing mpesa tx message');

    if (message.body != null) {
      var bytes = utf8.encode(message.body!); // data being hashed

      var digest = sha1.convert(bytes);
      var transaction = parseMpesa(message);

      log('mpesa_transaction:$transaction');

      debugPrint('mpesa_transaction:$transaction');
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
          wM.creditDefaultWallet(tx);
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
          wM.removeFromSavings(tx);
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
          wM.addToSavings(tx);
        } else {
          TransactionObj tx = TransactionObj(
            messageHashCode: digest.toString(),
            desc: transaction['desc'],
            type: transaction['type'],
            source: transaction['source'],
            amount: transaction['amount'],
            date: transaction['date'],
          );
          txM.insertTransaction(tx);
        }
      }
    }

    // debugPrint(
    //   'messageHashCode:${message.hashCode},messageSentDate:${message.dateSent},messageId:${message.id},messageBody:${message.body}',
    // );
  }
}

class TransactionCreationFailed implements Exception {}

class TransactionExists implements Exception {}
