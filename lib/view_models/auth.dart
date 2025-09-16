import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:another_telephony/telephony.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/globals.dart';
import 'package:flutter_application_1/data_models/auth_data_model.dart';
import 'package:flutter_application_1/data_models/wallet_data_model.dart';
import 'package:flutter_application_1/db/db.dart';
import 'package:flutter_application_1/screens/auto_import_availability.dart';
import 'package:flutter_application_1/screens/auto_import_info.dart';
import 'package:flutter_application_1/screens/initial_balance.dart';
import 'package:flutter_application_1/screens/landing.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/select_region_screen.dart';
import 'package:flutter_application_1/screens/setup_budget.dart';
import 'package:flutter_application_1/screens/sms_perms_request.dart';
import 'package:flutter_application_1/services/main_service.dart';
import 'package:flutter_application_1/util/result_wraper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:watch_it/watch_it.dart';

class AuthModel extends ChangeNotifier {
  AuthModel() {
    initAuth();
  }
  bool exportTransactionsShowcaseComplete = false;
  bool budgetOverviewShowCaseComplete = false;
  bool recentTransactionsShowcaseComplete = false;
  bool resetBudgetEnvelopeShowcaseComplete = false;
  bool addBudgetEnvelopeShowcaseComplete = false;
  bool addFinancialGoalsShowcaseComplete = false;
  bool addTxShowCaseComplete = false;
  bool addSavingsShowCaseComplete = false;
  bool canLoginAnon = false;
  bool? isMshwariDepost;
  bool isAnon = false;
  bool? autoImport;
  String email = '';
  int? accountId;
  bool shouldShowCase = false;
  DateTime date = DateTime.now();
  Future<bool> handleAuth = Future.value(true);
  late bool isLoggedIn;
  late bool isNewUser;
  late String? authToken;
  late String? curCookie;
  late String? sessionToken;
  String tier = '';
  bool pendingBudgetReset = false;

  Widget authWidget = SafeArea(
    child: Center(child: CircularProgressIndicator()),
  );
  Future<void> setAccountProfileInfo(int acId) async {
    final db = await DatabaseHelper().database;
    try {
      final List<Map<String, Object?>> accounts = await db.rawQuery(
        'SELECT * FROM accounts WHERE id = ?',
        ['$acId'],
      );
      date = DateTime.parse(accounts[0]['created_at'] as String);
      email = (accounts[0]['email'] as String).isNotEmpty
          ? (accounts[0]['email'] as String)
          : '';
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

  void completeShowcase() async {
    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    prefs.setBool('should_showcase', false);
    shouldShowCase = false;
    notifyListeners();
  }

  Future<Result<int>> removePendingBudgetReset() async {
    try {
      final db = await DatabaseHelper().database;
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
      SharedPreferencesAsync prefs = SharedPreferencesAsync();
      int? id = await prefs.getInt("budget_lite_current_account_id");
      if (id != null) {
        prefs.setString('last_onboarding_step', step);
      }
    } catch (e) {
      log('Error occured saving onboarding step', error: e);
    }
  }

  Future<void> setIsMshwariSavings(bool val) async {
    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    prefs.setBool('is_mshwari_savings', val);
    isMshwariDepost = val;
    notifyListeners();
  }

  Future<void> setAutoImport(bool val) async {
    SharedPreferencesAsync prefs = SharedPreferencesAsync();

    prefs.setBool('auto_import', val);
    if (val) {
      bool? res = await Telephony.instance.requestPhoneAndSmsPermissions;
      if (res != null && res) {
        autoImport = val;
      } else {
        autoImport = false;
      }
    } else {
      //TODO set permission to denied
      autoImport = val;
    }
    notifyListeners();
  }

  Future<void> refreshShowcase() async {
    SharedPreferencesAsync prefs = SharedPreferencesAsync();

    shouldShowCase = await prefs.getBool('should_showcase') ?? true;
    exportTransactionsShowcaseComplete =
        await prefs.getBool('export_transactions_showcase_complete') ?? false;
    addFinancialGoalsShowcaseComplete =
        await prefs.getBool('add_financial_goals_complete') ?? false;
    addBudgetEnvelopeShowcaseComplete =
        await prefs.getBool('add_budget_envelope_complete') ?? false;
    resetBudgetEnvelopeShowcaseComplete =
        await prefs.getBool('reset_budget_envelope_complete') ?? false;

    budgetOverviewShowCaseComplete =
        await prefs.getBool('budget_overview_showcase') ?? false;

    recentTransactionsShowcaseComplete =
        await prefs.getBool('recent_transactions_showcase_complete') ?? false;

    addTxShowCaseComplete =
        await prefs.getBool('add_tx_showcase_complete') ?? false;
    addSavingsShowCaseComplete =
        await prefs.getBool('add_savings_showcase_complete') ?? false;
    notifyListeners();
  }

  Future<void> refreshAuth() async {
    handleAuth = isSetLoggedIn();
    int? acid = await getAccountId();
    if (acid != null) {
      await setAccountProfileInfo(acid);
    }

    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    isMshwariDepost = await prefs.getBool('is_mshwari_savings');
    autoImport = await prefs.getBool('auto_import');

    shouldShowCase = await prefs.getBool('should_showcase') ?? true;
    log("shouldShowcase:$shouldShowCase");

    canLoginAnon = await prefs.getBool('canLoginAnon') ?? false;

    exportTransactionsShowcaseComplete =
        await prefs.getBool('export_transactions_showcase_complete') ?? false;
    addFinancialGoalsShowcaseComplete =
        await prefs.getBool('add_financial_goals_complete') ?? false;
    addBudgetEnvelopeShowcaseComplete =
        await prefs.getBool('add_budget_envelope_complete') ?? false;
    resetBudgetEnvelopeShowcaseComplete =
        await prefs.getBool('reset_budget_envelope_complete') ?? false;

    budgetOverviewShowCaseComplete =
        await prefs.getBool('budget_overview_showcase') ?? false;

    recentTransactionsShowcaseComplete =
        await prefs.getBool('recent_transactions_showcase_complete') ?? false;

    addTxShowCaseComplete =
        await prefs.getBool('add_tx_showcase_complete') ?? false;
    addSavingsShowCaseComplete =
        await prefs.getBool('add_savings_showcase_complete') ?? false;
    getAuthToken();
    getSessionToken();

    getCookie();
    notifyListeners();
  }

  Future<void> initAuth() async {
    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    isMshwariDepost = await prefs.getBool('is_mshwari_savings');

    shouldShowCase = await prefs.getBool('should_showcase') ?? true;
    exportTransactionsShowcaseComplete =
        await prefs.getBool('export_transactions_showcase_complete') ?? false;
    addFinancialGoalsShowcaseComplete =
        await prefs.getBool('add_financial_goals_complete') ?? false;
    addBudgetEnvelopeShowcaseComplete =
        await prefs.getBool('add_budget_envelope_complete') ?? false;
    resetBudgetEnvelopeShowcaseComplete =
        await prefs.getBool('reset_budget_envelope_complete') ?? false;

    budgetOverviewShowCaseComplete =
        await prefs.getBool('budget_overview_showcase') ?? false;

    recentTransactionsShowcaseComplete =
        await prefs.getBool('recent_transactions_showcase_complete') ?? false;

    addTxShowCaseComplete =
        await prefs.getBool('add_tx_showcase_complete') ?? false;
    addSavingsShowCaseComplete =
        await prefs.getBool('add_savings_showcase_complete') ?? false;

    log("shouldShowcase:$shouldShowCase");

    canLoginAnon = await prefs.getBool('canLoginAnon') ?? false;
    autoImport = await prefs.getBool('auto_import');
    handleAuth = isSetLoggedIn();
    getAuthToken();
    getCookie();
    getSessionToken();

    int? acid = await getAccountId();
    if (acid != null) {
      await setAccountProfileInfo(acid);
    }

    notifyListeners();
  }

  void completeOnboarding() async {
    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    await prefs.setBool("isNewUser", false);
    await prefs.remove('last_onboarding_step');
    if (!kDebugMode) {
      AppGlobal.analytics.logEvent(name: 'onboarding_complete');
    }

    refreshAuth();
    notifyListeners();
  }

  Future<String?> getRegion() async {
    final db = await DatabaseHelper().database;
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
        if (accounts.isNotEmpty && accounts.first['country'] != null) {
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

  Future<Result<int>> anonCreateAccount() async {
    var uuid = Uuid();

    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    Result accountCreation = await createAccount(
      Account(
        email: '',
        authId: uuid.v1(),
        tier: 'Free',
        createdAt: DateTime.now().toString(),
        anonymous: 1,
      ),
    );
    switch (accountCreation) {
      case Ok():
        {
          setIsMshwariSavings(true);
          if (!kDebugMode) {
            AppGlobal.analytics.logSignUp(signUpMethod: "anon");
          }
          isAnon = true;

          prefs.setBool('canLoginAnon', true);

          canLoginAnon = true;

          refreshAuth();
          notifyListeners();
          return Result.ok(accountCreation.value);
        }
      case Error():
        {
          return Result.error(accountCreation.error);
        }
    }
  }

  Future<Result<int>> anonymousSignIn({required String operation}) async {
    try {
      SharedPreferencesAsync prefs = SharedPreferencesAsync();
      if (operation == 'signup') {
        prefs.setString('begin_date', DateTime.now().toString().split(' ')[0]);

        WidgetsBinding.instance.platformDispatcher.locale.countryCode == 'KE'
            ? setAutoImport(true)
            : setAutoImport(false);
        prefs.setBool('auto_import', false);
      }
      bool result = await InternetConnection().hasInternetAccess;
      if (result) {
        final userCredential = await FirebaseAuth.instance.signInAnonymously();
        if (userCredential.user != null) {
          // final db = await DatabaseHelper().database;
          Result getacid = await setAccountId(anonId: userCredential.user!.uid);

          // Result getacid = await compute(setAccountId, email.trim());
          switch (getacid) {
            case Ok():
              {
                if (!kDebugMode) {
                  AppGlobal.analytics.logLogin(
                    loginMethod: 'anonymous-authentication',
                  );
                }
                log('Login: setAccount id:${getacid.value}');
                SharedPreferencesAsync prefs = SharedPreferencesAsync();
                isAnon = true;
                prefs.setBool('isLoggedIn', true);

                prefs.setBool('canLoginAnon', true);
                canLoginAnon = true;
                // log(decodedResponse["token"]);
                refreshAuth();
                notifyListeners();
                return Result.ok(getacid.value);
              }
            case Error():
              {
                switch (getacid.error) {
                  case NoAccountFound():
                    {
                      // Result accountCreation = await compute(
                      //   createAccount,
                      //   Account(
                      //     // id: decodedResponse['user']['id'],
                      //     authId: decodedResponse['user']['id'] as String,
                      //     email: decodedResponse['user']['email'] as String,
                      //     createdAt:
                      //         decodedResponse['user']['createdAt'] as String,
                      //     tier: 'Free',
                      //   ),
                      // );
                      Result accountCreation = await createAccount(
                        Account(
                          email: '',
                          authId: userCredential.user!.uid,
                          tier: 'Free',
                          createdAt: DateTime.now().toString(),
                          anonymous: 1,
                        ),
                      );
                      switch (accountCreation) {
                        case Ok():
                          {
                            if (!kDebugMode) {
                              AppGlobal.analytics.logSignUp(
                                signUpMethod: "password-authenctication",
                              );
                            }
                            isAnon = true;

                            prefs.setBool('canLoginAnon', true);

                            canLoginAnon = true;

                            refreshAuth();
                            notifyListeners();
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
                      // Result accountCreation = await compute(
                      //   createAccount,
                      //   Account(
                      //     // id: decodedResponse['user']['id'],
                      //     authId: decodedResponse['user']['id'] as String,
                      //     email: decodedResponse['user']['email'] as String,
                      //     createdAt:
                      //         decodedResponse['user']['createdAt'] as String,
                      //     tier: 'Free',
                      //   ),
                      // );
                      Result accountCreation = await createAccount(
                        Account(
                          email: '',
                          authId: userCredential.user!.uid,
                          tier: 'Free',
                          createdAt: DateTime.now().toString(),
                          anonymous: 1,
                        ),
                      );
                      switch (accountCreation) {
                        case Ok():
                          {
                            if (!kDebugMode) {
                              AppGlobal.analytics.logSignUp(
                                signUpMethod: "password-authenctication",
                              );
                            }

                            isAnon = true;

                            prefs.setBool('canLoginAnon', true);

                            canLoginAnon = true;

                            refreshAuth();
                            notifyListeners();
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

          // if (userCredential.user!.isAnonymous == true) {}
        } else {
          return Result.error(UnknownError());
        }
      } else {
        return Result.error(NoInternetConnection());
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          log("Anonymous auth hasn't been enabled for this project.");
          return Result.error(AuthDisabled());
        default:
          log("Unknown error.");
          return Result.error(UnknownError());
      }
    } on Exception catch (e) {
      log('Error occured:', error: e);
      return Result.error(UnknownError());
    }
  }

  Future<Result<int>> loginUser(String email, String password) async {
    try {
      bool result = await InternetConnection().hasInternetAccess;
      if (result) {
        bool better_auth = true;
        if (better_auth) {
          Uri url = Uri.parse(
            '${dotenv.env['BACKEND_ENDPOINT']}/api/auth/sign-in/email',
          );

          final payload = <String, dynamic>{};
          payload["email"] = email;
          payload["password"] = password;
          // payload['rememberMe'] = 'true';
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
            String? rawCookie = response.headers['set-cookie'];
            if (rawCookie != null) {
              int index = rawCookie.indexOf(';');
              String cookieToSet = (index == -1)
                  ? rawCookie
                  : rawCookie.substring(0, index);
              log('cookie:$cookieToSet');
              setCookie(cookieToSet);
            }
            log("request successful");

            setAuthToken(response.headers['set-auth-token'] as String);
            setSessionToken(token);

            Uri url = Uri.parse(
              '${dotenv.env['BACKEND_ENDPOINT']}/api/auth/revoke-other-sessions',
            );

            Map<String, String> headers = authToken != null
                ? {
                    // 'Authorization': 'Bearer $token',
                    'set-auth-token': authToken!,
                  }
                : {};
            log('logut:$headers');
            http.post(url, headers: headers);

            log("setting auth token");

            Result getacid = await setAccountId(email: email.trim());

            // Result getacid = await compute(setAccountId, email.trim());
            switch (getacid) {
              case Ok():
                {
                  if (!kDebugMode) {
                    AppGlobal.analytics.logLogin(
                      loginMethod: 'password-authentication',
                    );
                  }
                  log('Login: setAccount id:${getacid.value}');
                  SharedPreferencesAsync prefs = SharedPreferencesAsync();
                  prefs.setBool('isLoggedIn', true);
                  log(decodedResponse["token"]);
                  return Result.ok(getacid.value);
                }
              case Error():
                {
                  switch (getacid.error) {
                    case NoAccountFound():
                      {
                        // Result accountCreation = await compute(
                        //   createAccount,
                        //   Account(
                        //     // id: decodedResponse['user']['id'],
                        //     authId: decodedResponse['user']['id'] as String,
                        //     email: decodedResponse['user']['email'] as String,
                        //     createdAt:
                        //         decodedResponse['user']['createdAt'] as String,
                        //     tier: 'Free',
                        //   ),
                        // );
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
                              if (!kDebugMode) {
                                AppGlobal.analytics.logSignUp(
                                  signUpMethod: "password-authenctication",
                                );
                              }
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
                        // Result accountCreation = await compute(
                        //   createAccount,
                        //   Account(
                        //     // id: decodedResponse['user']['id'],
                        //     authId: decodedResponse['user']['id'] as String,
                        //     email: decodedResponse['user']['email'] as String,
                        //     createdAt:
                        //         decodedResponse['user']['createdAt'] as String,
                        //     tier: 'Free',
                        //   ),
                        // );
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
                              if (!kDebugMode) {
                                AppGlobal.analytics.logSignUp(
                                  signUpMethod: "password-authenctication",
                                );
                              }
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

            Result getacid = await setAccountId(email: email.trim());
            // Result getacid = await compute(setAccountId, email.trim());
            switch (getacid) {
              case Ok():
                {
                  if (!kDebugMode) {
                    AppGlobal.analytics.logLogin(
                      loginMethod: 'password-authentication',
                    );
                  }
                  log('Login: setAccount id:${getacid.value}');
                  SharedPreferencesAsync prefs = SharedPreferencesAsync();
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
                        // Result accountCreation = await compute(
                        //   createAccount,
                        //   Account(
                        //     id: decodedResp['id'],
                        //     email: decodedResp['email'],
                        //     createdAt: decodedResp['created_at'],
                        //     tier: 'Free',
                        //   ),
                        // );
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
                              if (!kDebugMode) {
                                AppGlobal.analytics.logSignUp(
                                  signUpMethod: "password-authenctication",
                                );
                              }
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

                        // Result accountCreation = await compute(
                        //   createAccount,
                        //   Account(
                        //     id: decodedResp['id'],
                        //     email: decodedResp['email'],
                        //     createdAt: decodedResp['created_at'],
                        //     tier: 'Free',
                        //   ),
                        // );

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
      } else {
        return Result.error(NoInternetConnection());
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
  ) async {
    try {
      SharedPreferencesAsync prefs = SharedPreferencesAsync();
      prefs.setString('begin_date', DateTime.now().toString().split(' ')[0]);

      WidgetsBinding.instance.platformDispatcher.locale.countryCode == 'KE'
          ? setAutoImport(true)
          : setAutoImport(false);
      // prefs.setBool('auto_import', false);
      bool result = await InternetConnection().hasInternetAccess;
      if (result) {
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
              jsonDecode(utf8.decode(response.bodyBytes))
                  as Map<String, dynamic>;
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
            // Result accountCreation = await compute(
            //   createAccount,
            //   Account(
            //     // id: decodedResponse['user']['id'] as String,
            //     email: decodedResponse['user']['email'] as String,
            //     authId: decodedResponse['user']['id'] as String,
            //     createdAt: decodedResponse['user']['createdAt'] as String,
            //     tier: 'Free',
            //   ),
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
          // Uri url = Uri(
          //   scheme: "http",
          //   host: dotenv.env['BACKEND_ENDPOINT'],
          //   path: "api/v1/register",
          //   port: 8000,
          // );
          // final payload = <String, dynamic>{};
          // payload["name"] = name;
          // payload["email"] = email;
          // payload["password"] = password;
          // payload["device_name"] = Platform.isAndroid ? "Android" : 'IOS';
          // payload["phone"] = phone;
          // payload["password_confirmation"] = passwordConfirmation;
          //
          // http.Response response = await http.post(url, body: payload);
          // log("resp:${response.body}");
          // var decodedResponse = jsonDecode(response.body) as Map;
          // if (decodedResponse["success"]) {
          //   log("request successful");
          //   Uri getUser = Uri(
          //     scheme: 'http',
          //     host: dotenv.env['BACKEND_ENDPOINT'],
          //     path: 'api/user',
          //     port: 8000,
          //   );
          //   http.Response resp = await http.get(
          //     getUser,
          //     headers: {
          //       'Authorization':
          //           'Bearer ${decodedResponse["response"]["Bearer"]}',
          //     },
          //   );
          //   var decodedResp = jsonDecode(resp.body) as Map;
          //
          //   Result accountCreation = await createAccount(
          //     Account(
          //       id: decodedResp['id'],
          //       email: decodedResp['email'],
          //       createdAt: decodedResp['created_at'],
          //       tier: 'Free',
          //     ),
          //   );
          //   // Result accountCreation = await compute(
          //   //   createAccount,
          //   //   Account(
          //   //     id: decodedResp['id'],
          //   //     email: decodedResp['email'],
          //   //     createdAt: decodedResp['created_at'],
          //   //     tier: 'Free',
          //   //   ),
          //   // );
          //
          //   switch (accountCreation) {
          //     case Ok():
          //       {
          //         return Result.ok(accountCreation.value);
          //       }
          //     case Error():
          //       {
          //         return Result.error(accountCreation.error);
          //       }
          //   }
          // } else {
          //   log("request failed");
          //   return Result.error(ErrorRegistering());
          // }
        }
      } else {
        return Result.error(NoInternetConnection());
      }
    } on Exception catch (e) {
      log('Signup Error :$e');
      return Result.error(e);
    }
  }

  Future<bool> isSetLoggedIn() async {
    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    isLoggedIn = await prefs.getBool('isLoggedIn') ?? false;

    isNewUser = await prefs.getBool("isNewUser") ?? true;

    log("isNewUser:$isNewUser,isLoggedIn:$isLoggedIn");
    if (isNewUser) {
      SharedPreferencesAsync prefs = SharedPreferencesAsync();
      prefs.setBool('is_mshwari_savinigs', true);
      String? lastStep = await prefs.getString('last_onboarding_step');
      if (lastStep != null && lastStep.isNotEmpty) {
        switch (lastStep) {
          case 'select_region':
            {
              authWidget = SelectRegion();

              notifyListeners();
              break;
            }
          case 'auto_import_info':
            {
              authWidget = AutoImportInfoScreen();

              notifyListeners();
              break;
            }
          case 'sms_perms_request':
            {
              authWidget = SmsPermsRequest();
              notifyListeners();
              break;
            }
          case 'setup_budget':
            {
              authWidget = SetupBudget();
              notifyListeners();
              break;
            }
          case 'intial_balance':
            {
              authWidget = InitialBalance();
              notifyListeners();
              break;
            }
          case 'auto_import_availability':
            {
              authWidget = AutoImportAvailabilityScreen();
              notifyListeners();
              break;
            }
          default:
            {
              const bodyStyle = TextStyle(fontSize: 19.0);
              authWidget = IntroductionScreen(
                // globalFooter: SizedBox(
                //   width: double.infinity,
                //   height: 60,
                //   child: ElevatedButton(
                //     child: const Text(
                //       'Let\'s go right away!',
                //       style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                //     ),
                //     onPressed: () => {},
                //   ),
                // ),
                showSkipButton: false,
                showBackButton: false,
                back: const Icon(Icons.arrow_back),
                skip: const Text(
                  'Skip',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                next: const Icon(Icons.arrow_forward),
                done: const Text(
                  'Done',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                curve: Curves.fastLinearToSlowEaseIn,
                controlsMargin: const EdgeInsets.all(16),
                controlsPadding: kIsWeb
                    ? const EdgeInsets.all(12.0)
                    : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                dotsDecorator: DotsDecorator(
                  size: const Size.square(10.0),
                  activeSize: const Size(20.0, 10.0),
                  color: Colors.black26,
                  spacing: const EdgeInsets.symmetric(horizontal: 3.0),
                  activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                dotsContainerDecorator: const ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
                pages: [
                  PageViewModel(
                    decoration: PageDecoration(
                      titleTextStyle: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.w700,
                      ),
                      bodyTextStyle: bodyStyle,
                      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                      pageColor: Colors.white,
                      imagePadding: EdgeInsets.zero,
                    ),
                    title: "Why budgetlite?",
                    bodyWidget: const Landing(),
                  ),
                ],
                onDone: () => log('Done'),

                // showSkipButton: true,
                // skipOrBackFlex: 0,
                // nextFlex: 0,
                // showBackButton: false,
              );
              notifyListeners();
              break;
            }
        }
      } else {
        const bodyStyle = TextStyle(fontSize: 19.0);
        authWidget = IntroductionScreen(
          globalHeader: SafeArea(
            child: Center(
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: const Text(
                  textAlign: TextAlign.center,
                  'Why budgetlite?',
                  style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          showSkipButton: false,
          showBackButton: false,
          back: const Icon(Icons.arrow_back),
          skip: const Text(
            'Skip',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          next: const Icon(Icons.arrow_forward),
          done: const Text(
            'Done',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          curve: Curves.fastLinearToSlowEaseIn,
          controlsMargin: const EdgeInsets.all(16),
          controlsPadding: kIsWeb
              ? const EdgeInsets.all(12.0)
              : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
          dotsDecorator: DotsDecorator(
            size: const Size.square(10.0),
            activeSize: const Size(20.0, 10.0),
            color: Colors.black26,
            spacing: const EdgeInsets.symmetric(horizontal: 3.0),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
          ),
          dotsContainerDecorator: const ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
          ),
          pages: [
            PageViewModel(
              decoration: PageDecoration(
                bodyAlignment: Alignment.center,
                titleTextStyle: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.w700,
                ),
                bodyTextStyle: bodyStyle,
                bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                pageColor: Colors.white,
                imagePadding: EdgeInsets.zero,
              ),
              title: "Envelope budgeting",
              bodyWidget: const SizedBox(
                width: 180,
                height: 160,
                child: Card(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: Icon(Icons.wallet, color: Color(0xFF1E88E5)),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          "Envelope budgeting",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 20,
                            ),
                            child: Text(
                              "Allocate money to different spending categories and track your progress",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            PageViewModel(
              title: "Savings Goals",
              decoration: PageDecoration(
                bodyAlignment: Alignment.center,
                titleTextStyle: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.w700,
                ),
                bodyTextStyle: bodyStyle,
                bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                pageColor: Colors.white,
                imagePadding: EdgeInsets.zero,
              ),
              bodyWidget: const SizedBox(
                width: 180,
                height: 160,
                child: Card(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: Icon(
                          Icons.crisis_alert_outlined,
                          color: Color(0xFF00CEC8),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          "Savings Goals",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 20,
                            ),
                            child: Text(
                              "Set and achieve financial goals with visual progress tracking",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            PageViewModel(
              title: "Spending Reports",
              decoration: PageDecoration(
                bodyAlignment: Alignment.center,
                titleTextStyle: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.w700,
                ),
                bodyTextStyle: bodyStyle,
                bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                pageColor: Colors.white,
                imagePadding: EdgeInsets.zero,
              ),
              bodyWidget: const SizedBox(
                width: 180,
                height: 160,
                child: Card(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: Icon(
                          Icons.trending_up,
                          color: Color(0xFF805AD5),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          "Spending Reports",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 20,
                            ),
                            child: Text(
                              "Understand your spending patterns with clear charts and insights",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            PageViewModel(
              title: "Smart Alerts",
              decoration: PageDecoration(
                bodyAlignment: Alignment.center,
                titleTextStyle: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.w700,
                ),
                bodyTextStyle: bodyStyle,
                bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                pageColor: Colors.white,
                imagePadding: EdgeInsets.zero,
              ),
              bodyWidget: const SizedBox(
                width: 180,
                height: 160,
                child: Card(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: Icon(
                          Icons.notification_important,
                          color: Colors.red,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          "Smart Alerts",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 20,
                            ),
                            child: Text(
                              "Get notified when you approach budget limits or reach milestones",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            PageViewModel(
              title: "Easy add by sharing transaction message to budgetlite",
              decoration: PageDecoration(
                bodyAlignment: Alignment.center,
                titleTextStyle: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.w700,
                ),
                bodyTextStyle: bodyStyle,
                bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                pageColor: Colors.white,
                imagePadding: EdgeInsets.zero,
              ),
              bodyWidget: const SizedBox(
                width: double.infinity,
                height: 160,
                child: Card(
                  color: Colors.white,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Icon(Icons.share, color: Colors.green),
                      ),
                      // Padding(
                      //   padding: EdgeInsets.symmetric(vertical: 2),
                      //   child: Text(
                      //     "Smart Alerts",
                      //     style: TextStyle(fontWeight: FontWeight.w600),
                      //   ),
                      // ),
                      Expanded(
                        child: BubbleSpecialThree(
                          text:
                              'TI891SAIXJ Confirmed. Ksh1000.00 sent to John Doe ******** on 8/9/25 at 9:06 PM. New M-PESA balance is Ksh16.34. ',
                          color: Color(0xFF1B97F3),
                          tail: true,
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          onDone: () async {
            Result res = await di<AuthModel>().anonCreateAccount();
            switch (res) {
              case Ok():
                {
                  AppGlobal.navigatorKey.currentState!.pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const SetupBudget(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                  // Navigator.pushAndRemoveUntil(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => const SetupBudget(),
                  //   ),
                  //   (Route<dynamic> route) => false,
                  // );
                  break;
                }
              default:
                {
                  AppGlobal.landingScaffoldKey.currentState!.showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: const Text("Error initializing preferences"),
                    ),
                  );
                  break;
                }
            }
          },

          // showSkipButton: true,
          // skipOrBackFlex: 0,
          // nextFlex: 0,
          // showBackButton: false,
        );
        // authWidget = Landing();
        notifyListeners();
      }

      log("onboarding");
      return true;
    } else {
      notifyListeners();
      return false;
      // if (!isLoggedIn) {
      //   authWidget = LoginForm();
      //   log("not logged in");
      //
      //   notifyListeners();
      //   return true;
      // } else {
      //   log("Is logged in");
      //
      //   notifyListeners();
      //   return false;
      // }
    }
  }

  void setCookie(String cookie) async {
    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    await prefs.setString("budgetlite_cookie", cookie);
    curCookie = cookie;
    notifyListeners();
  }

  void getCookie() async {
    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    curCookie = await prefs.getString("budgetlite_cookie");
    notifyListeners();
  }

  void setSessionToken(String token) async {
    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    await prefs.setString("budgetlite_session_token", token);
    sessionToken = token;
    notifyListeners();
  }

  void getSessionToken() async {
    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    sessionToken = await prefs.getString("budgetlite_session_token");
    notifyListeners();
  }

  void setAuthToken(String token) async {
    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    await prefs.setString("auth_token", token);
    authToken = token;
    notifyListeners();
  }

  Future<void> removeAuthToken() async {
    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    prefs.remove("auth_token");
    authToken = null;
    notifyListeners();
  }

  Future<void> getAuthToken() async {
    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    authToken = await prefs.getString("auth_token");
    notifyListeners();
  }

  Future<Result<int>> createAccount(Account account) async {
    final db = await DatabaseHelper().database;
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
      SharedPreferencesAsync prefs = SharedPreferencesAsync();
      prefs.setInt("budget_lite_current_account_id", rowId);
      notifyListeners();
      return Result.ok(rowId);
    } on Exception catch (e) {
      log('Error creating account : $e');
      return Result.error(e);
    }
  }

  void logout() async {
    try {
      SharedPreferencesAsync prefs = SharedPreferencesAsync();
      bool result = await InternetConnection().hasInternetAccess;
      final currUser = FirebaseAuth.instance.currentUser;
      if (currUser != null) {
        if (currUser.isAnonymous) {
          FirebaseAuth.instance.signOut();

          prefs.setBool("isLoggedIn", false);

          prefs.remove("budget_lite_current_account_id");
          removeAuthToken();
          handleAuth = isSetLoggedIn();
          // stopBackgroundService();

          notifyListeners();
        }
      } else {
        if (result) {
          Uri url = Uri.parse(
            '${dotenv.env['BACKEND_ENDPOINT']}/api/auth/sign-out',
          );

          // payload["device_name"] = Platform.isAndroid ? "Android" : 'IOS';

          Map<String, String> headers = curCookie != null && authToken != null
              ? {
                  'Authorization': 'Bearer $authToken',
                  // 'set-auth-token': authToken!,
                  'set-cookie': curCookie!,
                }
              : {
                  // 'Authorization': 'Bearer $authToken',
                };
          log('logout:$headers');
          http.post(url, headers: headers);
        }
        prefs.setBool("isLoggedIn", false);

        prefs.remove("budget_lite_current_account_id");
        removeAuthToken();
        handleAuth = isSetLoggedIn();
        // stopBackgroundService();

        notifyListeners();
      }
    } catch (e) {
      log("error loging out:", error: e);
    }
  }

  // Future<int> setRegion(String r) async {
  //   final db = await DatabaseHelper().database;
  //   try {
  //     var count;
  //     count = await db.rawUpdate(
  //       "UPDATE accounts SET country = ? WHERE id = ?",
  //       [r, '${await getAccountId()}'],
  //     );
  //     notifyListeners();
  //     return count;
  //   } catch (e) {
  //     log('Error Setting Region:$e');
  //     rethrow;
  //   } finally {
  //     // await db.close();
  //   }
  // }

  Future<Result<int>> setAccountId({String? email, String? anonId}) async {
    final db = await DatabaseHelper().database;
    try {
      if (email != null) {
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
            SharedPreferencesAsync prefs = SharedPreferencesAsync();
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
      } else if (anonId != null) {
        final List<Map<String, Object?>> accounts = await db.rawQuery(
          "SELECT * FROM accounts WHERE auth_id = ?",
          [anonId.trim()],
        );
        log('Found ${accounts.length} Accounts (auth.dart:310)');
        for (final ac in accounts) {
          log("Account:${ac.toString()}");
        }
        if (accounts.isNotEmpty) {
          if (accounts.first['id'] != null) {
            SharedPreferencesAsync prefs = SharedPreferencesAsync();
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
    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    log('Account id:${await prefs.getInt("budget_lite_current_account_id")}');
    return prefs.getInt("budget_lite_current_account_id");
  }
}

class NoInternetConnection implements Exception {}

class UnknownError implements Exception {}

class AuthDisabled implements Exception {}
