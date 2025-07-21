import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data_models/auth_data_model.dart';
import 'package:flutter_application_1/data_models/wallet_data_model.dart';
import 'package:flutter_application_1/db/db.dart';
import 'package:flutter_application_1/screens/landing.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthModel extends ChangeNotifier {
  AuthModel() {
    initAuth();
  }
  int? accountId;
  late Future<bool> handleAuth;
  late bool isLoggedIn;
  late bool isNewUser;
  late String? authToken;
  late String region;

  Widget authWidget = SafeArea(
    child: Center(child: CircularProgressIndicator()),
  );
  void refreshAuth() async {
    handleAuth = isSetLoggedIn();

    String? regiontoset = await getRegion();
    if (regiontoset != null) {
      region = regiontoset;
    }
    getAuthToken();
    notifyListeners();
  }

  void initAuth() async {
    handleAuth = isSetLoggedIn();
    getAuthToken();
    notifyListeners();
    String? regiontoset = await getRegion();
    if (regiontoset != null) {
      region = regiontoset;
    }
  }

  Future<String?> getRegion() async {
    try {
      final db = await getDb();
      final List<Map<String, Object?>> accounts = await db.rawQuery(
        'SELECT * FROM accounts WHERE id = ?',
        ['${await getAccountId()}'],
      );

      log('Found ${accounts.length} Accounts');
      for (final ac in accounts) {
        log("Account:${ac.toString()}");
      }
      return accounts[0]['country'] as String;
    } catch (e) {
      log('Error getting region:$e');
      rethrow;
    }
  }

  Future<int?> loginUser(String email, String password) async {
    try {
      Uri url = Uri.parse("http://192.168.0.5:8000/api/v1/login");
      int? id;
      final payload = <String, dynamic>{};
      payload["email"] = email;
      payload["password"] = password;
      payload["device_name"] = Platform.isAndroid ? "Android" : 'IOS';
      http.Response response = await http.post(url, body: payload);
      log("resp:${response.body}");

      var decodedResponse = jsonDecode(response.body) as Map;

      if (decodedResponse["success"]) {
        log("request successful");

        setAuthToken(decodedResponse["response"]["Bearer"]);

        log("setting auth token");

        id = await setAccountId(email);
        log('Login: setAccount id:$id');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', true);
        log(decodedResponse["response"]["Bearer"]);
        return id;
      } else {
        log("request failed");
      }
    } catch (e) {
      log('Login Error:$e');
      rethrow;
    }
  }

  Future<int?> registerUser(
    String name,
    String password,
    String email,
    String phone,
    String passwordConfirmation,
  ) async {
    try {
      Uri url = Uri(
        scheme: "http",
        host: "192.168.0.5",
        path: "api/v1/register",
        port: 8000,
      );
      final payload = <String, dynamic>{};
      payload["name"] = name;
      payload["email"] = email;
      payload["password"] = password;
      payload["device_name"] = Platform.isAndroid ? "Android" : 'IOS';
      payload["phone"] = phone;
      payload["password_confirmation"] = passwordConfirmation;

      http.Response response = await http.post(url, body: payload);
      log("resp:${response.body}");
      var decodedResponse = jsonDecode(response.body) as Map;
      if (decodedResponse["success"]) {
        log("request successful");
        var accountId = await createAccount(Account(email: email));
        return accountId;
      } else {
        log("request failed");
      }
    } catch (e) {
      log('Signup Error :$e');
      rethrow;
    }
  }

  Future<bool> isSetLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    isNewUser = prefs.getBool("isNewUser") ?? true;

    log("isNewUser:$isNewUser,isLoggedIn:$isLoggedIn");
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

  Future<int?> createAccount(Account account) async {
    try {
      final db = await getDb();
      log("Creating ${account.toString()}");
      int rowId = await db.insert("accounts", account.toMap());
      accountId = rowId;
      int walletId = await db.insert(
        "wallets",
        Wallet(
          accountId: null,
          name: 'default',
          balance: 0,
          savings: 0,
        ).toMap(),
      );
      await db.rawUpdate('UPDATE wallets SET account_id = ? WHERE id = ?', [
        '$rowId',
        '$walletId',
      ]);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt("budget_lite_current_account_id", rowId);
      notifyListeners();
      return rowId;
    } catch (e) {
      log('Error creating account : $e');
      rethrow;
    }
  }

  void logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setBool("isLoggedIn", false);
    handleAuth = Future.value(true);
    removeAuthToken();

    notifyListeners();
  }

  Future<int> setRegion(String r) async {
    try {
      var count;
      final db = await getDb();
      count = await db.rawUpdate(
        "UPDATE accounts SET country = ? WHERE id = ?",
        [r, '${await getAccountId()}'],
      );
      region = r;
      notifyListeners();
      return count;
    } catch (e) {
      log('Error Setting Region:$e');
      rethrow;
    }
  }

  Future<int?> setAccountId(String email) async {
    try {
      var id;
      final db = await getDb();
      final List<Map<String, Object?>> accounts = await db.rawQuery(
        "SELECT * FROM accounts WHERE email = ?",
        [email.trim()],
      );
      log('Found ${accounts.length} Accounts');
      for (final ac in accounts) {
        log("Account:${ac.toString()}");
      }
      if (accounts.isNotEmpty) {
        if (accounts.first['id'] != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setInt(
            "budget_lite_current_account_id",
            accounts.first['id'] as int,
          );
          accountId = accounts.first['id'] as int;
          id = accountId;
        } else {
          throw AccountIdNullException();
        }
      }

      notifyListeners();
      return id;
    } catch (e) {
      log('SetAccountid:$e');
      rethrow;
    }
  }
}
