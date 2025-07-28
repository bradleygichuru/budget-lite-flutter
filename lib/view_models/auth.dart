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
import 'package:flutter_application_1/util/result_wraper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthModel extends ChangeNotifier {
  AuthModel() {
    initAuth();
  }
  String email = '';
  int? accountId;
  late DateTime date;
  late Future<bool> handleAuth;
  late bool isLoggedIn;
  late bool isNewUser;
  late String? authToken;
  late String tier;
  String region = 'not set';

  Widget authWidget = SafeArea(
    child: Center(child: CircularProgressIndicator()),
  );
  void setAccountProfileInfo() async {
    final db = await getDb();
    try {
      final List<Map<String, Object?>> accounts = await db.rawQuery(
        'SELECT * FROM accounts WHERE id = ?',
        ['${await getAccountId()}'],
      );
      date = DateTime.parse(accounts[0]['created_at'] as String);
      email = accounts[0]['email'] as String;
      tier = accounts[0]['account_tier'] as String;
      notifyListeners();
    } catch (e) {
      log('Error Setting account profile', error: e);
    } finally {
      // db.close();
    }
  }

  void refreshAuth() async {
    handleAuth = isSetLoggedIn();

    String? regiontoset = await getRegion();
    if (regiontoset != null) {
      region = regiontoset;
    }
    setAccountProfileInfo();
    getAuthToken();
    notifyListeners();
  }

  void initAuth() async {
    handleAuth = isSetLoggedIn();
    getAuthToken();
    String? regiontoset = await getRegion();
    if (regiontoset != null) {
      region = regiontoset;
    }

    setAccountProfileInfo();

    notifyListeners();
  }

  void completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isNewUser", false);
    refreshAuth();
    notifyListeners();
  }

  Future<String?> getRegion() async {
    final db = await getDb();
    try {
      final List<Map<String, Object?>> accounts = await db.rawQuery(
        'SELECT * FROM accounts WHERE id = ?',
        ['${await getAccountId()}'],
      );

      log('Region :${accounts.first['country']}');
      for (final ac in accounts) {
        log("Account:${jsonEncode(ac)}");
      }
      return accounts.first['country'] as String;
    } catch (e) {
      log('Error getting region:$e');
      rethrow;
    } finally {
      // await db.close();
    }
  }

  Future<Result<int>> loginUser(String email, String password) async {
    try {
      Uri url = Uri(
        scheme: "http",
        host: dotenv.env['BACKEND_ENDPOINT'],
        path: "api/v1/login",
        port: 8000,
      );

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

        Result getacid = await setAccountId(email.trim());
        switch (getacid) {
          case Ok():
            {
              log('Login: setAccount id:${getacid.value}');
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool('isLoggedIn', true);
              log(decodedResponse["response"]["Bearer"]);
              return Result.ok(getacid.value);
            }
          case Error():
            {
              return Result.error(getacid.error);
            }
        }
      } else {
        log("request failed");
        return Result.error(ErrorLogginIn());
      }
    } on Exception catch (e) {
      log('Login Error:$e');
      return Result.error(e);
    }
  }

  Future<Result<int>> registerUser(
    String name,
    String password,
    String email,
    String phone,
    String passwordConfirmation,
  ) async {
    try {
      Uri url = Uri(
        scheme: "http",
        host: dotenv.env['BACKEND_ENDPOINT'],
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
        Result accountCreation = await createAccount(
          Account(
            tier: 'Free',
            createdAt: DateTime.now().toString(),
            email: email,
          ),
        );
        switch (accountCreation) {
          case Ok():
            {
              return Result.ok(accountCreation.value);
            }
          case Error():
            {
              return Result.error(accountCreation.error);
            }
        }
      } else {
        log("request failed");
        return Result.error(ErrorRegistering());
      }
    } on Exception catch (e) {
      log('Signup Error :$e');
      return Result.error(e);
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

  Future<Result<int>> createAccount(Account account) async {
    final db = await getDb();
    try {
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
      return Result.ok(rowId);
    } on Exception catch (e) {
      log('Error creating account : $e');
      return Result.error(e);
    } finally {
      // await db.close();
    }
  }

  void logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setBool("isLoggedIn", false);

    removeAuthToken();
    handleAuth = isSetLoggedIn();

    notifyListeners();
  }

  Future<int> setRegion(String r) async {
    final db = await getDb();
    try {
      var count;
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
    } finally {
      // await db.close();
    }
  }

  Future<Result<int>> setAccountId(String email) async {
    final db = await getDb();
    try {
      final List<Map<String, Object?>> accounts = await db.rawQuery(
        "SELECT * FROM accounts WHERE email = ?",
        [email.trim()],
      );
      log('Found ${accounts.length} Accounts (auth.dart:310)');
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
          int accountIdInner = accounts.first['id'] as int;
          accountId = accountIdInner;

          notifyListeners();
          return Result.ok(accountIdInner);
        } else {
          return Result.error(AccountIdNullException());
        }
      } else {
        return Result.error(NoAccountFound());
      }
    } on Exception catch (e) {
      log('SetAccountid:$e');
      return Result.error(e);
    } finally {
      // await db.close();
    }
  }

  Future<int?> getAccountId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    log(
      'Account id:${prefs.getInt("budget_lite_current_account_id").toString()}',
    );
    return prefs.getInt("budget_lite_current_account_id");
  }
}
