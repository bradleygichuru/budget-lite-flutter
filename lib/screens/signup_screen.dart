import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/auth.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/select_region_screen.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});
  @override
  State<SignupForm> createState() => SignUpFormState();
}

class SignUpFormState extends State<SignupForm> {
  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  TextEditingController fullNameController = TextEditingController();

  TextEditingController confirmPasswordController = TextEditingController();

  TextEditingController phoneNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Future<void> registerUser() async {
      Uri url = Uri(
        scheme: "http",
        host: "192.168.0.5",
        path: "api/v1/register",
        port: 8000,
      );
      final payload = <String, dynamic>{};
      payload["name"] = fullNameController.value.text;
      payload["email"] = emailController.value.text;
      payload["password"] = passwordController.value.text;
      payload["device_name"] = Platform.isAndroid ? "Android" : 'IOS';
      payload["phone"] = phoneNumberController.value.text;
      payload["password_confirmation"] = confirmPasswordController.value.text;

      http.Response response = await http.post(url, body: payload);
      log("resp:${response.body}");
      var decodedResponse = jsonDecode(response.body) as Map;
      if (decodedResponse["success"]) {
        log("request successful");
        Provider.of<AuthModel>(
          context,
          listen: false,
        ).createAccount(Account(email: emailController.value.text));
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SelectRegion()),
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,

                end: Alignment.centerRight,
                colors: [Colors.blue.shade50, Colors.purple.shade50],
              ),
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(8),
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
                      "Welcome to BudgetLite",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: const Text(
                      "Let's get started with your zero-friction budgeting journey",
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextFormField(
                      keyboardType: TextInputType.name,
                      controller: fullNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Name';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'John Doe',
                        labelText: "Full name",
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter valid Email';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'johndoe@gmail.com',
                        labelText: "Email",
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextFormField(
                      keyboardType: TextInputType.phone,
                      controller: phoneNumberController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phoneNumber';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '+25471234567',
                        labelText: "Phone Number",
                      ),
                    ),
                  ),
                  Padding(
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
                      keyboardType: TextInputType.visiblePassword,
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16,
                    ),
                    child: TextFormField(
                      controller: confirmPasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        if (value != confirmPasswordController.text) {
                          return 'passwords dont match';
                        }
                        return null;
                      },

                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Confirm Password',
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
                            log("registering user");
                            registerUser();
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Continue'),
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
                    child: Center(
                      child: const Text("Already have an account?"),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Center(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginForm(),
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

                            const Text('Sign In'),
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
