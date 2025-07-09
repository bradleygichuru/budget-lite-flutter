import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/landing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/login_screen.dart' show LoginForm;

class AuthModel extends ChangeNotifier {
  AuthModel() {
    initAuth();
  }

  late Future<bool> handleAuth;
  late bool isLoggedIn;
  late bool isNewUser;
  late String authToken;
  Widget authWidget = SafeArea(
    child: Center(child: CircularProgressIndicator()),
  );
  void refreshAuth() {
    handleAuth = isSetLoggedIn();
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
    authToken = "";
  }

  Future<void> getAuthToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString("auth_token") ?? "";
  }
}
