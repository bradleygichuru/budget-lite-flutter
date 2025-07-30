import 'package:flutter/material.dart';
import 'package:flutter_application_1/data_models/auth_data_model.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/screens/signup_screen.dart';
import 'package:flutter_application_1/util/result_wraper.dart';
import 'package:flutter_application_1/view_models/auth.dart';
import 'dart:developer';

import 'package:watch_it/watch_it.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  //const LoginForm({super.key});
  AuthModel authM = di.get<AuthModel>();
  TextEditingController emailController = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> loginScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
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
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: const Color.fromARGB(255, 25, 143, 240),
      ),
      home: SafeArea(
        child: ScaffoldMessenger(
          key: loginScaffoldMessengerKey,
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
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                          horizontal: 0,
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
                            horizontal: 0,
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
                      SafeArea(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 0,
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
                                      if (_formKey.currentState!.validate()) {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        log("signing user in");
                                        Result loginResult = await authM
                                            .loginUser(
                                              emailController.value.text,
                                              passwordController.value.text,
                                            );
                                        switch (loginResult) {
                                          case Ok():
                                            {
                                              loginScaffoldMessengerKey
                                                  .currentState!
                                                  .showSnackBar(
                                                    SnackBar(
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      content: const Text(
                                                        "Login success",
                                                      ),
                                                    ),
                                                  );

                                              authM.refreshAuth();

                                              setState(() {
                                                _isLoading = false;
                                              });
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const MyApp(),
                                                ),
                                              );

                                              break;
                                            }
                                          case Error():
                                            {
                                              switch (loginResult.error) {
                                                case ErrorLogginIn():
                                                  {
                                                    setState(() {
                                                      _isLoading = false;
                                                    });
                                                    loginScaffoldMessengerKey
                                                        .currentState!
                                                        .showSnackBar(
                                                          SnackBar(
                                                            behavior:
                                                                SnackBarBehavior
                                                                    .floating,
                                                            content: const Text(
                                                              "Error Login in",
                                                            ),
                                                          ),
                                                        );
                                                  }

                                                  break;
                                                default:
                                                  log(
                                                    'Error login in ',
                                                    error: loginResult.error,
                                                  );
                                                  {
                                                    setState(() {
                                                      _isLoading = false;
                                                    });
                                                    loginScaffoldMessengerKey
                                                        .currentState!
                                                        .showSnackBar(
                                                          SnackBar(
                                                            behavior:
                                                                SnackBarBehavior
                                                                    .floating,
                                                            content: const Text(
                                                              "Error Login in",
                                                            ),
                                                          ),
                                                        );
                                                  }
                                              }
                                            }
                                        }
                                      }
                                    },
                              child: _isLoading
                                  ? Center(
                                      child: SizedBox(
                                        width: 24.0,
                                        height: 24.0,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text('Sign In'),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: const Icon(
                                            Icons.arrow_right_alt,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(3),
                        child: Center(
                          child: const Text("Don't have an account?"),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 16,
                        ),
                        child: Center(
                          child: OutlinedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll<Color>(
                                Colors.white,
                              ),
                            ),
                            onPressed: _isLoading
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SignupForm(),
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
        ),
      ),
    );
  }
}
