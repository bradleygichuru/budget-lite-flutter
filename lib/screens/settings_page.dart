import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/auth.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorSchemeSeed: Colors.blue),
      home: Scaffold(
        body: Consumer<AuthModel>(
          builder: (context, authM, child) {
            return Column(
              children: [
                FilledButton(
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setBool("isLoggedIn", false);
                    authM.removeAuthToken();
                    authM.isSetLoggedIn();
                  },
                  child: Text("logout"),
                ),
                FilledButton(
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setBool("isLoggedIn", false);

                    prefs.setBool("isNewUser", true);
                    await deleteDatabase(
                      join(await getDatabasesPath(), 'budget_lite_database.db'),
                    );
                    authM.removeAuthToken();
                    authM.refreshAuth();
                  },
                  child: Text("Dev Reset App"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
