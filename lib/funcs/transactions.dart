import 'package:another_telephony/telephony.dart';

const String received = "received";
const String paid = "paid to";
const String sent = "sent to";
const String transferred = "transferred to";

Map<String, dynamic>? parseMpesa(SmsMessage messageObj) {
  if (messageObj.body != null) {
    String? message = messageObj.body;
    print("message:${messageObj.body}");
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

      transaction['date'] = message.split(" on ")[1].split("at")[0].trim();

      return transaction;
    }
  }
  return null;
}
