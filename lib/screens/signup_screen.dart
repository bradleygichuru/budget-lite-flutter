import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/data_models/auth_data_model.dart';
import 'package:flutter_application_1/screens/auto_import_availability.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/setup_budget.dart';
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

  // TextEditingController phoneNumberController = TextEditingController();
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
          child: AnnotatedRegion(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            ),
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
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Icon(
                              size: 50,
                              Icons.account_circle,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),

                        Center(
                          child: Text(
                            "Welcome to BudgetLite",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade900,
                              fontSize: 24,
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            "Let's get started with your zero-friction budgeting journey",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                        // Padding(
                        //   padding: EdgeInsets.all(8),
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.center,
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: [
                        //       OutlinedButton(
                        //         style: ButtonStyle(
                        //           side: WidgetStatePropertyAll(
                        //             BorderSide(color: Colors.blue.shade600),
                        //           ),
                        //           backgroundColor: WidgetStatePropertyAll(
                        //             Colors.white,
                        //           ),
                        //           foregroundColor: WidgetStatePropertyAll(
                        //             Colors.blue.shade600,
                        //           ),
                        //         ),
                        //         onPressed: _isLoading
                        //             ? null
                        //             : () async {
                        //                 Result anonSignin =
                        //                     await di<AuthModel>()
                        //                         .anonymousSignIn(
                        //                           operation: 'signup',
                        //                         );
                        //                 switch (anonSignin) {
                        //                   case Ok():
                        //                     {
                        //                       SharedPreferencesAsync prefs =
                        //                           SharedPreferencesAsync();
                        //                       await prefs.setBool(
                        //                         "isNewUser",
                        //                         true,
                        //                       );
                        //                       if (context.mounted) {
                        //                         signUpScaffoldKey.currentState!
                        //                             .showSnackBar(
                        //                               SnackBar(
                        //                                 behavior:
                        //                                     SnackBarBehavior
                        //                                         .floating,
                        //                                 content: const Text(
                        //                                   "Registration successful",
                        //                                 ),
                        //                               ),
                        //                             );
                        //                         setState(() {
                        //                           _isLoading = false;
                        //                         });
                        //                         Navigator.pushAndRemoveUntil(
                        //                           context,
                        //                           MaterialPageRoute(
                        //                             builder: (context) =>
                        //                                 const AutoImportAvailabilityScreen(),
                        //                           ),
                        //                           (Route<dynamic> route) =>
                        //                               false,
                        //                         );
                        //                       }
                        //                       break;
                        //                     }
                        //                   case Error():
                        //                     {
                        //                       setState(() {
                        //                         _isLoading = false;
                        //                       });
                        //                       switch (anonSignin.error) {
                        //                         case UnknownError():
                        //                           {
                        //                             signUpScaffoldKey
                        //                                 .currentState!
                        //                                 .showSnackBar(
                        //                                   SnackBar(
                        //                                     behavior:
                        //                                         SnackBarBehavior
                        //                                             .floating,
                        //                                     content: const Text(
                        //                                       "Error occured signing up anonymously",
                        //                                     ),
                        //                                   ),
                        //                                 );
                        //
                        //                             break;
                        //                           }
                        //                         case AuthDisabled():
                        //                           {
                        //                             signUpScaffoldKey
                        //                                 .currentState!
                        //                                 .showSnackBar(
                        //                                   SnackBar(
                        //                                     behavior:
                        //                                         SnackBarBehavior
                        //                                             .floating,
                        //                                     content: const Text(
                        //                                       "Authentication Disabled",
                        //                                     ),
                        //                                   ),
                        //                                 );
                        //                             break;
                        //                           }
                        //                         case NoInternetConnection():
                        //                           {
                        //                             setState(() {
                        //                               _isLoading = false;
                        //                             });
                        //                             signUpScaffoldKey
                        //                                 .currentState!
                        //                                 .showSnackBar(
                        //                                   SnackBar(
                        //                                     behavior:
                        //                                         SnackBarBehavior
                        //                                             .floating,
                        //                                     content: const Text(
                        //                                       "No internet connection",
                        //                                     ),
                        //                                   ),
                        //                                 );
                        //                             break;
                        //                           }
                        //                       }
                        //                     }
                        //                 }
                        //               },
                        //         child: _isLoading
                        //             ? Center(
                        //                 child: SizedBox(
                        //                   width: 24.0,
                        //                   height: 24.0,
                        //                   child: CircularProgressIndicator(
                        //                     valueColor:
                        //                         AlwaysStoppedAnimation<Color>(
                        //                           Colors.white,
                        //                         ),
                        //                   ),
                        //                 ),
                        //               )
                        //             : Row(
                        //                 crossAxisAlignment:
                        //                     CrossAxisAlignment.center,
                        //                 mainAxisAlignment:
                        //                     MainAxisAlignment.spaceEvenly,
                        //                 children: [
                        //                   Icon(
                        //                     Icons.account_circle_outlined,
                        //                     color: Colors.blue.shade600,
                        //                   ),
                        //                   Text(
                        //                     'Sign up Anonymously',
                        //                     style: TextStyle(
                        //                       color: Colors.blue.shade600,
                        //                     ),
                        //                   ),
                        //                 ],
                        //               ),
                        //       ),
                        //       Divider(),
                        //       Text(
                        //         'Try BudgetLite without creating an account',
                        //         style: TextStyle(
                        //           fontSize: 12,
                        //           color: Colors.grey.shade500,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
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
                        // Padding(
                        //   padding: EdgeInsets.symmetric(
                        //     horizontal: 8,
                        //     vertical: 16,
                        //   ),
                        //   child: TextFormField(
                        //     keyboardType: TextInputType.phone,
                        //     controller: phoneNumberController,
                        //     validator: (value) {
                        //       if (value == null || value.isEmpty) {
                        //         return 'Please enter phoneNumber';
                        //       }
                        //       return null;
                        //     },
                        //     decoration: InputDecoration(
                        //       border: OutlineInputBorder(),
                        //       hintText: '+25471234567',
                        //       labelText: "Phone Number",
                        //     ),
                        //   ),
                        // ),
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
                                          confirmPasswordController
                                                  .value
                                                  .text ==
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
                                              );
                                          switch (userRegRes) {
                                            case Ok():
                                              {
                                                SharedPreferencesAsync prefs =
                                                    SharedPreferencesAsync();
                                                await prefs.setBool(
                                                  "isNewUser",
                                                  true,
                                                );
                                                if (context.mounted) {
                                                  signUpScaffoldKey
                                                      .currentState!
                                                      .showSnackBar(
                                                        SnackBar(
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                          content: const Text(
                                                            "Registration successful",
                                                          ),
                                                        ),
                                                      );
                                                  setState(() {
                                                    _isLoading = false;
                                                  });
                                                  Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const SetupBudget(),
                                                    ),
                                                    (Route<dynamic> route) =>
                                                        false,
                                                  );
                                                }
                                              }
                                            case Error():
                                              {
                                                switch (userRegRes.error) {
                                                  case NoInternetConnection():
                                                    {
                                                      setState(() {
                                                        _isLoading = false;
                                                      });
                                                      signUpScaffoldKey
                                                          .currentState!
                                                          .showSnackBar(
                                                            SnackBar(
                                                              behavior:
                                                                  SnackBarBehavior
                                                                      .floating,
                                                              content: const Text(
                                                                "No internet connection",
                                                              ),
                                                            ),
                                                          );
                                                      break;
                                                    }

                                                  case AccountAlreadyExists():
                                                    {
                                                      setState(() {
                                                        _isLoading = false;
                                                      });
                                                      signUpScaffoldKey
                                                          .currentState!
                                                          .showSnackBar(
                                                            SnackBar(
                                                              behavior:
                                                                  SnackBarBehavior
                                                                      .floating,
                                                              content: const Text(
                                                                "User already exists",
                                                              ),
                                                            ),
                                                          );

                                                      break;
                                                    }
                                                  case ErrorRegistering():
                                                    {
                                                      setState(() {
                                                        _isLoading = false;
                                                      });
                                                      signUpScaffoldKey
                                                          .currentState!
                                                          .showSnackBar(
                                                            SnackBar(
                                                              behavior:
                                                                  SnackBarBehavior
                                                                      .floating,
                                                              content: const Text(
                                                                "Error Signing Up",
                                                              ),
                                                            ),
                                                          );
                                                    }
                                                }
                                              }
                                            default:
                                              {
                                                {
                                                  setState(() {
                                                    _isLoading = false;
                                                  });
                                                  signUpScaffoldKey
                                                      .currentState!
                                                      .showSnackBar(
                                                        SnackBar(
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                          content: const Text(
                                                            "Error Signing Up",
                                                          ),
                                                        ),
                                                      );
                                                }
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
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    content: const Text(
                                                      "Error Signing Up",
                                                    ),
                                                  ),
                                                );
                                          }
                                        }
                                      } else {
                                        signUpScaffoldKey.currentState!
                                            .showSnackBar(
                                              SnackBar(
                                                behavior:
                                                    SnackBarBehavior.floating,
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
                                        const Text('Continue'),
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
                        Padding(
                          padding: EdgeInsets.all(3),
                          child: Center(
                            child: Text("Already have an account?"),
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
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginForm(),
                                        ),
                                        (Route<dynamic> route) => false,
                                      );
                                    },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: const Icon(Icons.person_add),
                                  ),

                                  const Text('Sign In'),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(6),
                          child: Center(
                            child: Text(
                              "By continuing, you agree to our Terms of Service and Privacy Policy",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
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
      ),
    );
  }
}
