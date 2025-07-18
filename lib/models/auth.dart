import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data-models/wallet.dart';
import 'package:flutter_application_1/db/db.dart';
import 'package:flutter_application_1/screens/landing.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class AuthModel extends ChangeNotifier {
  AuthModel() {
    initAuth();
  }
  int? accountId;
  late Future<bool> handleAuth;
  late bool isLoggedIn;
  late bool isNewUser;
  late String? authToken;

  Widget authWidget = SafeArea(
    child: Center(child: CircularProgressIndicator()),
  );
  void refreshAuth() {
    handleAuth = isSetLoggedIn();

    getAuthToken();
    notifyListeners();
  }

  void initAuth() {
    handleAuth = isSetLoggedIn();
    getAuthToken();
    notifyListeners();
  }

  Future<bool> isSetLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    isNewUser = prefs.getBool("isNewUser") ?? true;

    log("isNewUser:${isNewUser},isLoggedIn:${isLoggedIn}");
    if (isNewUser) {
      authWidget = Landing();

      log("onboarding");
      return true;
    } else {
      if (!isLoggedIn) {
        authWidget = LoginForm();
        log("not logged in");
        return true;
      } else {
        log("Is logged in");
        return false;
      }
    }
  }

  void setAuthToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", token);
    authToken = token;
    notifyListeners();
  }

  Future<void> removeAuthToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("auth_token");
    authToken = null;
    notifyListeners();
  }

  Future<void> getAuthToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString("auth_token");
    notifyListeners();
  }

  Future<int> createAccount(Account account) async {
    final db = await getDb();
    log("Creating ${account.toString()}");
    int rowId = await db.insert("accounts", account.toMap());
    accountId = rowId;
    int walletId = await db.insert(
      "wallets",
      Wallet(accountId: null, name: 'default', balance: 0, savings: 0).toMap(),
    );
    await db.rawUpdate('UPDATE wallets SET account_id = ? WHERE id = ?', [
      '$rowId',
      '$walletId',
    ]);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("budget_lite_current_account_id", rowId);
    notifyListeners();
    return rowId;
  }

  void logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setBool("isLoggedIn", false);
    handleAuth = Future.value(true);
    removeAuthToken();

    notifyListeners();
  }

  void setAccountId(String email) async {
    final db = await getDb();
    final List<Map<String, Object?>> accounts = await db.rawQuery(
      "SELECT * FROM accounts WHERE email = ?",
      [email],
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("budget_lite_current_account_id", accounts.first['id'] as int);
    if (accounts.isNotEmpty) {
      accountId = accounts.first['id'] as int;
    }

    notifyListeners();
  }
}

Future<int?> getAccountId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt("budget_lite_current_account_id");
}
