import 'dart:developer';
import 'package:another_telephony/telephony.dart';
import 'package:flutter_application_1/data_models/auth_data_model.dart';
import 'package:flutter_application_1/db/db.dart';
import 'package:flutter_application_1/view_models/auth.dart';

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

class TransactionCreationFailed implements Exception {}
