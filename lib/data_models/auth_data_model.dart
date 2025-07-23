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

class AccountIdNullException implements Exception {
  @override
  String toString() => "Account id null";
}

class NoAccountFound implements Exception {
  @override
  String toString() => "Account id null";
}

class ErrorLogginIn implements Exception {
  @override
  String toString() => "Login error";
}

class ErrorRegistering implements Exception {
  @override
  String toString() => "Registering error";
}
