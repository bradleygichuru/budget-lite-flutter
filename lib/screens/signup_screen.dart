import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/select_region_screen.dart';
import 'package:flutter_application_1/util/result_wraper.dart';
import 'package:flutter_application_1/view_models/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_it/watch_it.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});
  @override
  State<SignupForm> createState() => SignUpFormState();
}

class SignUpFormState extends State<SignupForm> {
  final GlobalKey<ScaffoldMessengerState> signUpScaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  TextEditingController emailController = TextEditingController();
  bool _isLoading = false;
  TextEditingController passwordController = TextEditingController();

  TextEditingController fullNameController = TextEditingController();

  TextEditingController confirmPasswordController = TextEditingController();

  TextEditingController phoneNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: const Color.fromARGB(255, 25, 143, 240),
      ),
      home: SafeArea(
        child: ScaffoldMessenger(
          key: signUpScaffoldKey,
          child: Scaffold(
            body: Container(
              height: double.infinity,
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 16,
                      ),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 16,
                      ),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 16,
                      ),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 16,
                      ),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 16,
                      ),
                      child: Center(
                        child: FilledButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll<Color>(
                              Color(0xFF2563EB),
                            ),
                          ),
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate() &&
                                      confirmPasswordController.value.text ==
                                          passwordController.value.text) {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    log("registering user");
                                    try {
                                      Result userRegRes = await di
                                          .get<AuthModel>()
                                          .registerUser(
                                            fullNameController.value.text,
                                            passwordController.value.text,
                                            emailController.value.text,
                                            phoneNumberController.value.text,
                                            confirmPasswordController
                                                .value
                                                .text,
                                          );
                                      switch (userRegRes) {
                                        case Ok():
                                          {
                                            SharedPreferences prefs =
                                                await SharedPreferences.getInstance();
                                            prefs.setBool("isNewUser", true);
                                            if (context.mounted) {
                                              signUpScaffoldKey.currentState!
                                                  .showSnackBar(
                                                    SnackBar(
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      content: const Text(
                                                        "Registration successful",
                                                      ),
                                                    ),
                                                  );
                                              setState(() {
                                                _isLoading = false;
                                              });
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SelectRegion(),
                                                ),
                                              );
                                            }
                                          }
                                        case Error():
                                          {
                                            setState(() {
                                              _isLoading = false;
                                            });
                                            signUpScaffoldKey.currentState!
                                                .showSnackBar(
                                                  SnackBar(
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    content: const Text(
                                                      "Error Signing Up",
                                                    ),
                                                  ),
                                                );
                                          }
                                      }
                                    } catch (e) {
                                      log('SignUp Error:$e');

                                      setState(() {
                                        _isLoading = false;
                                      });
                                      if (context.mounted) {
                                        signUpScaffoldKey.currentState!
                                            .showSnackBar(
                                              SnackBar(
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                content: const Text(
                                                  "Error Signing Up",
                                                ),
                                              ),
                                            );
                                      }
                                    }
                                  } else {
                                    signUpScaffoldKey.currentState!.showSnackBar(
                                      SnackBar(
                                        behavior: SnackBarBehavior.floating,
                                        content: const Text(
                                          "password and confirmed password might not be same",
                                        ),
                                      ),
                                    );
                                  }
                                },
                          child: _isLoading
                              ? Center(
                                  child: SizedBox(
                                    width: 24.0,
                                    height: 24.0,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Continue'),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 16,
                      ),
                      child: Center(
                        child: OutlinedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
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
      ),
    );
  }
}
