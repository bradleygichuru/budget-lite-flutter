import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/auth.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/screens/signup_screen.dart';

import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  //const LoginForm({super.key});
  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> loginUser() async {
      Uri url = Uri.parse("http://192.168.0.5:8000/api/v1/login");
      final payload = <String, dynamic>{};
      payload["email"] = emailController.value.text;
      payload["password"] = passwordController.value.text;
      payload["device_name"] = Platform.isAndroid ? "Android" : 'IOS';
      http.Response response = await http.post(url, body: payload);
      log("resp:${response.body}");

      var decodedResponse = jsonDecode(response.body) as Map;

      if (decodedResponse["success"]) {
        log("request successful");

        Provider.of<AuthModel>(
          context,
          listen: false,
        ).setAuthToken(decodedResponse["response"]["Bearer"]);

        log("setting auth token");

        Provider.of<AuthModel>(
          context,
          listen: false,
        ).setAccountId(emailController.value.text);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', true);
        log(decodedResponse["response"]["Bearer"]);
        if (context.mounted) {
          Provider.of<AuthModel>(context, listen: false).refreshAuth();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyApp()),
          );
        }
      } else {
        log("request failed");
      }
    }

    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: const Color.fromARGB(255, 25, 143, 240),
      ),
      home: SafeArea(
        child: Scaffold(
          body: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFEFF6FF), Color(0xFFF3E8FF)],
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Center(
                      child: Icon(
                        size: 50,
                        Icons.account_circle,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),

                  Center(
                    child: const Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),

                  Center(
                    child: const Text(
                      "Sign in to continue your budgeting journey",
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16,
                    ),
                    child: TextFormField(
                      controller: emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter valid Email';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'johndoe@gmail.com',
                        labelText: "Email",
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 16,
                      ),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          }
                          return null;
                        },
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Center(
                      child: FilledButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll<Color>(
                            Color(0xFF2563EB),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            log("signing user in");
                            loginUser();
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Sign In'),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: const Icon(Icons.arrow_right_alt),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(3),
                    child: Center(child: const Text("Don't have an account?")),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Center(
                      child: OutlinedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll<Color>(
                            Colors.white,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupForm(),
                            ),
                          );
                          // Navigate back to first route when tapped.
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: const Icon(Icons.person_add),
                            ),

                            const Text('Create Account'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
