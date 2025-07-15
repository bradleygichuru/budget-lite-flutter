import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/setup_budget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SmsPermsRequest extends StatelessWidget {
  const SmsPermsRequest({super.key});

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
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Center(
                      child: Icon(
                        size: 50,
                        Icons.chat,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                  ),
                  Center(
                    child: const Text(
                      "SMS Permission Required",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),

                  Center(
                    child: const Text(
                      "BudgetLite needs permission to read SMS messages to automatically import your transactions",
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16,
                    ),
                    child: Center(
                      child: Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              leading: const Icon(
                                Icons.ad_units,
                                size: 30,
                                color: Color(0xFFA3E635),
                              ),
                              title: Text(
                                '${Platform.isAndroid ? "Android" : 'IOS'} device',
                              ),
                              subtitle: const Text(
                                'Device will ask for permission to access messages. This helps automatically import your financial transactions.',
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
                        color: Color(0xFFF0FDF4),

                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.shield),
                              title: Text("Your Privacy is Protected"),
                            ),
                            ListTile(
                              dense: true,
                              leading: Text("•"),
                              title: Text(
                                "Only financial SMS messages are processed",
                              ),
                            ),
                            ListTile(
                              dense: true,
                              leading: Text("•"),
                              title: Text("Personal messages are ignored"),
                            ),
                            ListTile(
                              dense: true,
                              leading: Text("•"),
                              title: Text(
                                "Only financial SMS messages are processed",
                              ),
                            ),
                          ],
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
    );
  }
}
