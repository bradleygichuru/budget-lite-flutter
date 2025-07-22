import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

enum Country {
  other('other'),
  kenya('kenya');

  final String name;
  const Country(this.name);
}

class Account {
  final int? id;
  final String email;
  Account({required this.email, this.id});
  Map<String, Object> toMap() {
    return {'id': ?id, 'email': email};
  }

  @override
  String toString() {
    return 'Account{id:$id,email:$email}';
  }
}

Future<int?> getAccountId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  log(
    'Account id:${prefs.getInt("budget_lite_current_account_id").toString()}',
  );
  return prefs.getInt("budget_lite_current_account_id");
}

class AccountIdNullException implements Exception {
  String errMsg() => "Account id null";
}
