import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/view_models/auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:watch_it/watch_it.dart';

List<String> months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

class SettingsPage extends StatefulWidget with WatchItStatefulWidgetMixin {
  const SettingsPage({super.key});
  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  AuthModel authM = di.get<AuthModel>();
  String version = '';
  String buildNumber = '';
  @override
  void initState() {
    setVersionInfo();
    super.initState();
  }

  void setVersionInfo() {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        version = packageInfo.version;
        buildNumber = packageInfo.buildNumber;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.settings, color: Colors.blue, size: 40),
              title: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
              subtitle: Text(
                'Manage your account and preferences',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(7),
              child: SizedBox(
                width: double.infinity,
                child: Card.outlined(
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ListTile(
                        leading: Icon(Icons.account_circle_rounded, size: 30),
                        title: Text(
                          'Profile Information',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Your account details and personal information',
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Text(
                              watchPropertyValue((AuthModel m) => m.email),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade900,
                              ),
                            ),
                            Text(
                              '',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            Text(
                              'Member since ${watchPropertyValue((AuthModel m) => '${months[m.date.month]} ${m.date.year}')}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Account Type',
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                                Text(
                                  watchPropertyValue((AuthModel m) => m.tier),
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(7),
              child: SizedBox(
                width: double.infinity,
                child: Card.outlined(
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ListTile(
                        leading: Icon(Icons.language_outlined, size: 30),
                        title: Text(
                          'Country',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text('Your selected country'),
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: Card.outlined(
                          color: Colors.grey.shade50,
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Center(
                              child: Text(
                                '${watchPropertyValue((AuthModel m) => m.region)}',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(7),
              child: SizedBox(
                width: double.infinity,
                child: Card.outlined(
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ListTile(
                        title: Text(
                          'Account',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text('Account actions'),
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: FilledButton(
                          onPressed: () {
                            authM.logout();
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(Colors.red),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(Icons.logout_sharp),
                                ),
                                Text('Logout'),
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

            Padding(
              padding: EdgeInsets.all(7),
              child: SizedBox(
                width: double.infinity,
                child: Card.outlined(
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ListTile(
                        title: Text(
                          'App Information',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text('Version and build details'),
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: ListTile(
                                title: Text('Version'),
                                subtitle: Text(version ?? 'version'),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: Text('Build'),
                                subtitle: Text(buildNumber ?? 'build'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            kDebugMode
                ? FilledButton(
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool("isLoggedIn", false);
                      prefs.remove("budget_lite_current_account_id");
                      prefs.setBool("isNewUser", true);
                      await deleteDatabase(
                        join(
                          await getDatabasesPath(),
                          'budget_lite_database.db',
                        ),
                      );
                      authM.removeAuthToken();
                      authM.refreshAuth();
                    },
                    child: Text("Dev Reset App"),
                  )
                : Text(''),
          ],
        ),
      ),
    );
  }
}
