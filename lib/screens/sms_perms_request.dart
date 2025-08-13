import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/screens/setup_budget.dart';
import 'package:flutter_application_1/view_models/auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:watch_it/watch_it.dart';

class SmsPermsRequest extends StatefulWidget {
  const SmsPermsRequest({super.key});
  @override
  SmsPermsRequestState createState() => SmsPermsRequestState();
}

class SmsPermsRequestState extends State<SmsPermsRequest> {
  @override
  void initState() {
    di<AuthModel>().setLastOnboardingStep('sms_perms_request');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> requestPermission() async {
      final permission = Permission.sms;

      // SharedPreferences prefs = await SharedPreferences.getInstance();

      if (await permission.isDenied) {
        log("sms permissions: false");
        var status = await permission.request();
        if (status.isGranted) {
          if (context.mounted) {
            // prefs.setBool("isNewUser", false);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SetupBudget()),
            );
          }
        }
      }
      if (await permission.isGranted) {
        log("sms permissions: true");
        if (context.mounted) {
          // prefs.setBool("isNewUser", false);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SetupBudget()),
          );
        }
      }
    }

    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: const Color.fromARGB(255, 25, 143, 240),
      ),
      home: SafeArea(
        child: AnnotatedRegion(
          value: SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            statusBarColor: Colors.transparent,
          ),

          child: Scaffold(
            body: Container(
              padding: const EdgeInsets.all(8),
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFEFF6FF), Color(0xFFF3E8FF)],
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
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
                          Icons.chat,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        "SMS Permission Required",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        "BudgetLite needs permission to read SMS messages to automatically import your transactions",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 16,
                      ),
                      child: Center(
                        child: Card(
                          color: Colors.white,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                leading: const Icon(
                                  Icons.ad_units_outlined,
                                  size: 30,
                                  color: Colors.black,
                                ),
                                title: Text(
                                  '${Platform.isAndroid ? "Android" : 'IOS'} device',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'Device will ask for permission to access messages. This helps automatically import your financial transactions.',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 16,
                      ),
                      child: Center(
                        child: Card.outlined(
                          color: Colors.green.shade50,

                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(
                                  Icons.shield_outlined,
                                  color: Colors.green.shade600,
                                ),
                                title: Text(
                                  "Your Privacy is Protected",
                                  style: TextStyle(
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              ListTile(
                                dense: true,
                                leading: Text(
                                  "•",

                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                                title: Text(
                                  "Only financial SMS messages are processed",
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              ListTile(
                                dense: true,
                                leading: Text(
                                  "•",

                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                                title: Text(
                                  "Personal messages are ignored",
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              ListTile(
                                dense: true,
                                leading: Text(
                                  "•",
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                                title: Text(
                                  "Only financial SMS messages are processed",
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                          onPressed: () {
                            requestPermission();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Grant SMS Permission'),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: const Icon(Icons.arrow_right_alt),
                              ),
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
