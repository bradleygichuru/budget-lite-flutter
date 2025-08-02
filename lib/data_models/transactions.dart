import 'dart:developer';
import 'package:another_telephony/telephony.dart';

const String mpesaReceived = "received";
const String mpesaPaid = "paid to";
const String mpesaSent = "sent to";
const String mpesaTransferred = "transferred";
const String equitySent = 'sent';

const String equityPaid = 'Bill payment';

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
    if (message!.contains(mpesaReceived)) {
      List<String> receivedArray = message.split(mpesaReceived);
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
    if (message.contains(mpesaPaid)) {
      List<String> paidArray = message.split(mpesaPaid);

      String amount = paidArray[0].split("Ksh")[1].trim().replaceAll(",", "");

      transaction["date"] = message.split(" on ")[1].split("at")[0];
      transaction["amount"] = double.parse(amount);
      transaction["type"] = TxType.spend.val;
      transaction['desc'] = paidArray[1].split('on')[0].trim();

      return transaction;
    }
    if (message.contains(mpesaSent)) {
      List<String> sentArray = message.split(mpesaSent);
      String amount = sentArray[0].split("Ksh")[1].replaceAll(",", "");

      transaction["amount"] = double.parse(amount);
      transaction['date'] = message.split(" on ")[1].split("at")[0].trim();
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
      transaction['date'] = message.split(" on ")[1].split("at")[0].trim();
      transaction['desc'] = transferredArray[1].split('on')[0].trim();

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
      "source": "Equity",
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
    if (message!.contains(equityPaid)) {
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
      transaction['date'] = message.split('on')[2].split('at')[0].trim();
    }
    if (message!.contains(equityCardPayment)) {
      List<String> paidArray = message.split(equityCardPayment);
      String amount = paidArray[0]
          .split('KES')[1]
          .replaceAll(',', '')
          .trim()
          .replaceAll(' ', '');

      transaction['amount'] = double.parse(amount);
      transaction["type"] = TxType.spend.val;
      transaction['desc'] = paidArray[1];
      transaction['date'] = paidArray[1].split('on')[1].split('Ref')[0].trim();
    }
  }
}

class TransactionCreationFailed implements Exception {}
