import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/globals.dart';
import 'package:flutter_application_1/data_models/auth_data_model.dart';
import 'package:flutter_application_1/data_models/wallet_data_model.dart';
import 'package:flutter_application_1/db/db.dart';
import 'package:flutter_application_1/screens/auto_import_info.dart';
import 'package:flutter_application_1/screens/initial_balance.dart';
import 'package:flutter_application_1/screens/landing.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/select_region_screen.dart';
import 'package:flutter_application_1/screens/setup_budget.dart';
import 'package:flutter_application_1/screens/sms_perms_request.dart';
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
  DateTime date = DateTime.now();
  late Future<bool> handleAuth;
  late bool isLoggedIn;
  late bool isNewUser;
  late String? authToken;
  String tier = '';
  bool pendingBudgetReset = false;
  String region = 'not set';

  Widget authWidget = SafeArea(
    child: Center(child: CircularProgressIndicator()),
  );
  Future<void> setAccountProfileInfo() async {
    final db = await getDb();
    try {
      final List<Map<String, Object?>> accounts = await db.rawQuery(
        'SELECT * FROM accounts WHERE id = ?',
        ['${await getAccountId()}'],
      );
      date = DateTime.parse(accounts[0]['created_at'] as String);
      email = accounts[0]['email'] as String;
      tier = accounts[0]['account_tier'] as String;
      pendingBudgetReset = accounts[0]['resetPending'] as int == 0
          ? false
          : true;
      notifyListeners();
    } catch (e) {
      log('Error Setting account profile', error: e);
    } finally {
      // db.close();
    }
  }

  Future<Result<int>> removePendingBudgetReset() async {
    try {
      final db = await getDb();
      int updated = await db.rawUpdate(
        'UPDATE accounts SET resetPending = 0 WHERE id = ?',
        ['${await getAccountId()}'],
      );

      return Result.ok(updated);
    } on Exception catch (e) {
      log('Error removing pending reset', error: e);
      return Result.error(e);
    }
  }

  Future<void> setLastOnboardingStep(String step) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? id = prefs.getInt("budget_lite_current_account_id");
      if (id != null) {
        prefs.setString('last_onboarding_step', step);
      }
    } catch (e) {
      log('Error occured saving onboarding step', error: e);
    }
  }

  void refreshAuth() async {
    handleAuth = isSetLoggedIn();

    String? regiontoset = await getRegion();
    if (regiontoset != null) {
      region = regiontoset;
    }
    await setAccountProfileInfo();
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

    await setAccountProfileInfo();

    notifyListeners();
  }

  void completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isNewUser", false);
    prefs.remove('last_onboarding_step');
    AppGlobal.analytics.logEvent(name: 'onboarding-complete');

    refreshAuth();
    notifyListeners();
  }

  Future<String?> getRegion() async {
    final db = await getDb();
    try {
      if (await getAccountId() != null) {
        final List<Map<String, Object?>> accounts = await db.rawQuery(
          'SELECT * FROM accounts WHERE id = ?',
          ['${await getAccountId()}'],
        );

        log('Region :${accounts.first['country']}');
        // for (final ac in accounts) {
        //   log("Account:${jsonEncode(ac)}");
        // }
        if (accounts.isNotEmpty) {
          return accounts.first['country'] as String;
        }
      }
    } catch (e) {
      log('Error getting region:$e');
      rethrow;
    } finally {
      // await db.close();
    }
  }

  Future<Result<int>> loginUser(String email, String password) async {
    try {
      bool better_auth = true;
      if (better_auth) {
        Uri url = Uri.parse(
          '${dotenv.env['BACKEND_ENDPOINT']}/api/auth/sign-in/email',
        );

        final payload = <String, dynamic>{};
        payload["email"] = email;
        payload["password"] = password;
        // payload["device_name"] = Platform.isAndroid ? "Android" : 'IOS';
        http.Response response = await http.post(url, body: payload);
        log("resp:${response.body}");

        final Map<String, dynamic> decodedResponse =
            jsonDecode(response.body) as Map<String, dynamic>;

        String? code = decodedResponse['code'];
        String? token = decodedResponse['token'];
        if (code == 'INVALID_EMAIL_OR_PASSWORD') {
          return Result.error(InvalidEmailOrPassword());
        }
        if (token != null) {
          log("request successful");

          setAuthToken(decodedResponse["token"]);

          log("setting auth token");

          Result getacid = await setAccountId(email.trim());
          switch (getacid) {
            case Ok():
              {
                AppGlobal.analytics.logLogin(
                  loginMethod: 'password-authentication',
                );
                log('Login: setAccount id:${getacid.value}');
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool('isLoggedIn', true);
                log(decodedResponse["token"]);
                return Result.ok(getacid.value);
              }
            case Error():
              {
                switch (getacid.error) {
                  case NoAccountFound():
                    {
                      Result accountCreation = await createAccount(
                        Account(
                          // id: decodedResponse['user']['id'],
                          authId: decodedResponse['user']['id'] as String,
                          email: decodedResponse['user']['email'] as String,
                          createdAt:
                              decodedResponse['user']['createdAt'] as String,
                          tier: 'Free',
                        ),
                      );
                      switch (accountCreation) {
                        case Ok():
                          {
                            AppGlobal.analytics.logSignUp(
                              signUpMethod: "password-authenctication",
                            );
                            return Result.ok(accountCreation.value);
                          }
                        case Error():
                          {
                            return Result.error(accountCreation.error);
                          }
                      }
                    }
                  case AccountIdNullException():
                    {
                      Result accountCreation = await createAccount(
                        Account(
                          // id: decodedResponse['user']['id'],
                          authId: decodedResponse['user']['id'] as String,
                          email: decodedResponse['user']['email'],
                          createdAt: decodedResponse['user']['createdAt'],
                          tier: 'Free',
                        ),
                      );
                      switch (accountCreation) {
                        case Ok():
                          {
                            AppGlobal.analytics.logSignUp(
                              signUpMethod: "password-authenctication",
                            );
                            return Result.ok(accountCreation.value);
                          }
                        case Error():
                          {
                            return Result.error(accountCreation.error);
                          }
                      }
                    }

                  default:
                    {
                      return Result.error(getacid.error);
                    }
                }
                // return Result.error(getacid.error);
              }
          }
        } else {
          log("request failed");
          return Result.error(ErrorLogginIn());
        }
      } else {
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
                AppGlobal.analytics.logLogin(
                  loginMethod: 'password-authentication',
                );
                log('Login: setAccount id:${getacid.value}');
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool('isLoggedIn', true);
                log(decodedResponse["response"]["Bearer"]);
                return Result.ok(getacid.value);
              }
            case Error():
              {
                switch (getacid.error) {
                  case NoAccountFound():
                    {
                      Uri getUser = Uri(
                        scheme: 'http',
                        host: dotenv.env['BACKEND_ENDPOINT'],
                        path: 'api/user',
                        port: 8000,
                      );
                      http.Response resp = await http.get(
                        getUser,
                        headers: {
                          'Authorization':
                              'Bearer ${decodedResponse["response"]["Bearer"]}',
                        },
                      );
                      var decodedResp = jsonDecode(resp.body) as Map;

                      Result accountCreation = await createAccount(
                        Account(
                          id: decodedResp['id'],
                          email: decodedResp['email'],
                          createdAt: decodedResp['created_at'],
                          tier: 'Free',
                        ),
                      );
                      switch (accountCreation) {
                        case Ok():
                          {
                            AppGlobal.analytics.logSignUp(
                              signUpMethod: "password-authenctication",
                            );
                            return Result.ok(accountCreation.value);
                          }
                        case Error():
                          {
                            return Result.error(accountCreation.error);
                          }
                      }
                    }
                  case AccountIdNullException():
                    {
                      Uri getUser = Uri(
                        scheme: 'http',
                        host: dotenv.env['BACKEND_ENDPOINT'],
                        path: 'api/user',
                        port: 8000,
                      );
                      http.Response resp = await http.get(
                        getUser,
                        headers: {
                          'Authorization':
                              'Bearer ${decodedResponse["response"]["Bearer"]}',
                        },
                      );
                      var decodedResp = jsonDecode(resp.body) as Map;

                      Result accountCreation = await createAccount(
                        Account(
                          id: decodedResp['id'],
                          email: decodedResp['email'],
                          createdAt: decodedResp['created_at'],
                          tier: 'Free',
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
                    }

                  default:
                    {
                      return Result.error(getacid.error);
                    }
                }
                // return Result.error(getacid.error);
              }
          }
        } else {
          log("request failed");
          return Result.error(ErrorLogginIn());
        }
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
      bool better_auth = true;
      if (better_auth) {
        Uri url = Uri.parse(
          '${dotenv.env['BACKEND_ENDPOINT']}/api/auth/sign-up/email',
        );
        final payload = <String, dynamic>{};
        payload["name"] = name;
        payload["email"] = email;
        payload["password"] = password;
        // payload["device_name"] = Platform.isAndroid ? "Android" : 'IOS';
        // payload["phone"] = phone;
        // payload["password_confirmation"] = passwordConfirmation;

        http.Response response = await http.post(url, body: payload);
        final decodedResponse =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        // log('body:${response.body}');
        log("resp:$decodedResponse");

        log("token:${decodedResponse['token']}");
        // log('code:${decodedResponse['code']}');
        String? code = decodedResponse['code'];
        String? token = decodedResponse['token'];
        String userAlreadyExists = 'USER_ALREADY_EXISTS';
        if (code == userAlreadyExists) {
          return Result.error(AccountAlreadyExists());
        }
        if (token != null) {
          log("request successful");
          // Uri getUser = Uri(
          //   scheme: 'http',
          //   host: dotenv.env['BACKEND_ENDPOINT'],
          //   path: 'api/user',
          //   port: 8000,
          // );
          // http.Response resp = await http.get(
          //   getUser,
          //   headers: {
          //     'Authorization': 'Bearer ${decodedResponse["response"]["Bearer"]}',
          //   },
          // );

          Result accountCreation = await createAccount(
            Account(
              // id: decodedResponse['user']['id'] as String,
              email: decodedResponse['user']['email'] as String,
              authId: decodedResponse['user']['id'] as String,
              createdAt: decodedResponse['user']['createdAt'] as String,
              tier: 'Free',
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
      } else {
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
          Uri getUser = Uri(
            scheme: 'http',
            host: dotenv.env['BACKEND_ENDPOINT'],
            path: 'api/user',
            port: 8000,
          );
          http.Response resp = await http.get(
            getUser,
            headers: {
              'Authorization':
                  'Bearer ${decodedResponse["response"]["Bearer"]}',
            },
          );
          var decodedResp = jsonDecode(resp.body) as Map;

          Result accountCreation = await createAccount(
            Account(
              id: decodedResp['id'],
              email: decodedResp['email'],
              createdAt: decodedResp['created_at'],
              tier: 'Free',
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
      String? lastStep = prefs.getString('last_onboarding_step');
      if (lastStep != null && lastStep.isNotEmpty) {
        switch (lastStep) {
          case 'select_region':
            {
              authWidget = SelectRegion();
              break;
            }
          case 'auto_import_info':
            {
              authWidget = AutoImportInfoScreen();
            }
          case 'sms_perms_request':
            {
              authWidget = SmsPermsRequest();
              break;
            }
          case 'setup_budget':
            {
              authWidget = SetupBudget();
              break;
            }
          case 'intial_balance':
            {
              authWidget = InitialBalance();
              break;
            }
          default:
            {
              authWidget = Landing();
              break;
            }
        }
      } else {
        authWidget = Landing();
      }

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
    Uri url = Uri.parse(
      '${dotenv.env['BACKEND_ENDPOINT']}/api/auth/revoke-session',
    );

    final payload = <String, dynamic>{};
    payload["token"] = authToken;
    // payload["device_name"] = Platform.isAndroid ? "Android" : 'IOS';
    await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
        'set-cookie': 'better-auth.session_token=${authToken}',
      },
      body: jsonEncode(payload),
    );

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
