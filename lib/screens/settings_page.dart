import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/globals.dart';
import 'package:flutter_application_1/data_models/txs_data_model.dart';
import 'package:flutter_application_1/db/db.dart';
import 'package:flutter_application_1/util/result_wraper.dart';
import 'package:flutter_application_1/view_models/auth.dart';
import 'package:flutter_application_1/view_models/txs.dart';
import 'package:flutter_application_1/view_models/wallet.dart';
import 'package:flutter_application_1/view_models/weekly_reports.dart';
import 'package:open_file_manager/open_file_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:sqflite/sqflite.dart';
import 'package:watch_it/watch_it.dart';
import 'dart:io';
import 'dart:developer';
import 'package:share_plus/share_plus.dart';

Future<void> listDirectoryContents(String path) async {
  final directory = Directory(path);
  if (await directory.exists()) {
    try {
      final List<FileSystemEntity> entities = await directory.list().toList();
      for (var entity in entities) {
        if (entity is File) {
          log('File: ${entity.path}');
        } else if (entity is Directory) {
          log('Directory: ${entity.path}');
        }
      }
    } catch (e) {
      log('Error listing directory: $e');
    }
  } else {
    log('Directory does not exist: $path');
  }
}

Future<Widget> listExports(String path) async {
  final directory = Directory(path);
  List<Widget> exports = [];
  if (await directory.exists()) {
    try {
      final List<FileSystemEntity> entities = await directory.list().toList();
      for (var entity in entities) {
        if (entity is File) {
          exports.add(
            ListTile(
              trailing: IconButton(
                onPressed: () {
                  SharePlus.instance.share(
                    ShareParams(files: [XFile(entity.path)]),
                  );
                },
                icon: Icon(Icons.share_sharp),
              ),
              title: Text(
                entity.path,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          );
          log('File: ${entity.path}');
        } else if (entity is Directory) {
          log('Directory: ${entity.path}');
        }
      }
      return Column(children: exports);
    } catch (e) {
      log('Error listing directory: $e');
      return Column(children: exports);
    }
  } else {
    log('Directory does not exist: $path');

    return Column(children: exports);
  }
}

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
  bool exportLoading = false;
  String version = '';
  String buildNumber = '';
  bool? mshwariDepos = di<AuthModel>().isMshwariDepost ?? false;
  bool? autoImport = di<AuthModel>().autoImport ?? false;
  String directoryPath = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setVersionInfo();
      getDownloadsDirectory().then((val) {
        setState(() {
          if (val != null) {
            directoryPath = val.path;
          }
        });
      });
    });
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
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => di<AuthModel>().shouldShowCase
          ? ShowCaseWidget.of(
              context,
            ).startShowCase([AppGlobal.exportTransactions])
          : null,
    );
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   leading: IconButton(
        //     onPressed: () {
        //       Navigator.pop(context);
        //     },
        //     icon: Icon(Icons.arrow_back_sharp),
        //   ),
        // ),
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
                              watchPropertyValue(
                                    (AuthModel m) => m.email.isEmpty,
                                  )
                                  ? Text(
                                      'Anonymous user',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade900,
                                      ),
                                    )
                                  : Text(
                                      watchPropertyValue(
                                        (AuthModel m) => m.email,
                                      ),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade900,
                                      ),
                                    ),
                              // Text(
                              //   '',
                              //   style: TextStyle(color: Colors.grey.shade600),
                              // ),
                              // Text(
                              //   'Member since ${watchPropertyValue((AuthModel m) => '${months[m.date.month]} ${m.date.year}')}',
                              //   style: TextStyle(
                              //     fontSize: 14,
                              //     color: Colors.grey.shade500,
                              //   ),
                              // ),
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
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  Text(
                                    watchPropertyValue((AuthModel m) => m.tier),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
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
              // Padding(
              //   padding: EdgeInsets.all(7),
              //   child: SizedBox(
              //     width: double.infinity,
              //     child: Card.outlined(
              //       color: Colors.white,
              //       child: Column(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           ListTile(
              //             leading: Icon(Icons.language_outlined, size: 30),
              //             title: Text(
              //               'Country',
              //               style: TextStyle(
              //                 fontSize: 22,
              //                 fontWeight: FontWeight.w500,
              //               ),
              //             ),
              //             subtitle: Text('Your country'),
              //           ),
              //           // WidgetsBinding.instance.platformDispatcher
              //           Padding(
              //             padding: EdgeInsets.all(5),
              //             child: Card.outlined(
              //               color: Colors.grey.shade50,
              //               child: Padding(
              //                 padding: EdgeInsets.all(10),
              //                 child: Center(
              //                   child: Text(
              //                     '${WidgetsBinding.instance.platformDispatcher.locale.countryCode}',
              //                   ),
              //                 ),
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
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
                          leading: Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 30,
                          ),
                          title: Text(
                            'Financial Preferences',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text('Configure app behaviour'),
                        ),
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: ListTile(
                            leading: Checkbox(
                              tristate: false,
                              value: mshwariDepos,
                              onChanged: (bool? value) {
                                setState(() {
                                  mshwariDepos = value!;
                                });
                                di<AuthModel>().setIsMshwariSavings(value!);
                              },
                            ),
                            title: Text('Count M-Shwari deposits as savings'),
                            subtitle: Text(
                              'When enabled, M-Shwari deposits will be automatically categorized as savings transactions',
                            ),
                          ),
                        ),

                        // Padding(
                        //   padding: EdgeInsets.all(5),
                        //   child: ListTile(
                        //     leading: Checkbox(
                        //       tristate: false,
                        //       value: autoImport,
                        //       onChanged: (bool? value) {
                        //         setState(() {
                        //           autoImport = value!;
                        //         });
                        //         di<AuthModel>().setAutoImport(value!);
                        //       },
                        //     ),
                        //     title: Text('Automatic Transaction Imports'),
                        //     subtitle: Text(
                        //       'When enabled, Transactions will be automatically imported using available parsers',
                        //     ),
                        //   ),
                        // ),
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
              Showcase(
                key: AppGlobal.exportTransactions,
                description:
                    "You can export all your recorded transactionson this section",

                enableAutoScroll: true,

                onBarrierClick: () {
                  ShowCaseWidget.of(context).hideFloatingActionWidgetForKeys([
                    AppGlobal.exportTransactions,
                  ]);

                  di<AuthModel>().completeShowcase();
                  // log(
                  //   "Complete Showcase: ${di<AuthModel>().shouldShowCase}",
                  // );
                },

                tooltipActionConfig: const TooltipActionConfig(
                  alignment: MainAxisAlignment.end,
                  position: TooltipActionPosition.outside,
                  gapBetweenContentAndAction: 10,
                ),
                child: Padding(
                  padding: EdgeInsets.all(7),
                  child: SizedBox(
                    width: double.infinity,
                    child: Card.outlined(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ListTile(
                            title: Text(
                              'User Data',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text('Export transactions'),
                          ),
                          Padding(
                            padding: EdgeInsetsGeometry.all(5),
                            child: FutureBuilder<Widget>(
                              future: listExports(directoryPath),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.done &&
                                    snapshot.hasData) {
                                  return snapshot.data!;
                                }

                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.all(5),
                            child: FilledButton(
                              onPressed: exportLoading
                                  ? null
                                  : () async {
                                      setState(() {
                                        exportLoading = true;
                                      });
                                      Result e = await exportDataToExcel();

                                      switch (e) {
                                        case Ok():
                                          {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Transactions Exported to your Downloads folder',
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ),
                                            );

                                            setState(() {
                                              exportLoading = false;
                                            });

                                            // openFileManager(
                                            //   androidConfig: AndroidConfig(
                                            //     folderType:
                                            //         AndroidFolderType.other,
                                            //     folderPath:
                                            //         "/storage/emulated/0/Download",
                                            //   ),
                                            // );

                                            final directory =
                                                await getDownloadsDirectory();
                                            if (directory != null) {
                                              openFileManager(
                                                androidConfig: AndroidConfig(
                                                  folderType:
                                                      AndroidFolderType.other,
                                                  folderPath: directory.path,
                                                ),
                                              );

                                              listDirectoryContents(
                                                directory.path,
                                              );
                                            } else {
                                              openFileManager(
                                                androidConfig: AndroidConfig(
                                                  folderType:
                                                      AndroidFolderType.other,
                                                  folderPath:
                                                      "/storage/emulated/0/Download",
                                                ),
                                              );
                                            }

                                            break;
                                          }
                                        case Error():
                                          {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Error exporting transactions',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            );

                                            setState(() {
                                              exportLoading = false;
                                            });
                                            break;
                                          }
                                      }
                                      // Navigator.pop(context);
                                    },
                              // style: ButtonStyle(
                              //   backgroundColor: WidgetStatePropertyAll(Colors.red),
                              // ),
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(Icons.logout_sharp),
                                    ),
                                    exportLoading
                                        ? Center(
                                            child: SizedBox(
                                              width: 24.0,
                                              height: 24.0,
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            ),
                                          )
                                        : Text('Generate latest Export Excel'),
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

              // Padding(
              //   padding: EdgeInsets.all(7),
              //   child: SizedBox(
              //     width: double.infinity,
              //     child: Card.outlined(
              //       color: Colors.white,
              //       child: Column(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           // ListTile(
              //           //   title: Text(
              //           //     'Account',
              //           //     style: TextStyle(
              //           //       fontSize: 22,
              //           //       fontWeight: FontWeight.w500,
              //           //     ),
              //           //   ),
              //           //   subtitle: Text('Account actions'),
              //           // ),
              //           // Padding(
              //           //   padding: EdgeInsets.all(5),
              //           //   child: FilledButton(
              //           //     onPressed: () {
              //           //       authM.logout();
              //           //       Navigator.pop(context);
              //           //     },
              //           //     // style: ButtonStyle(
              //           //     //   backgroundColor: WidgetStatePropertyAll(Colors.red),
              //           //     // ),
              //           //     child: Padding(
              //           //       padding: EdgeInsets.all(10),
              //           //       child: Row(
              //           //         mainAxisAlignment: MainAxisAlignment.center,
              //           //         children: [
              //           //           Padding(
              //           //             padding: EdgeInsets.all(4),
              //           //             child: Icon(Icons.logout_sharp),
              //           //           ),
              //           //           Text('Logout'),
              //           //         ],
              //           //       ),
              //           //     ),
              //           //   ),
              //           // ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              kDebugMode
                  ? Column(
                      children: [
                        FilledButton(
                          onPressed: () async {
                            SharedPreferencesAsync prefs =
                                SharedPreferencesAsync();
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
                        ),

                        FilledButton(
                          onPressed: () async {
                            final db = await DatabaseHelper().database;
                            await db.execute('DELETE FROM weekly_reports');

                            di<WeeklyReportsModel>().refresh();
                          },
                          child: Text("Reset reports"),
                        ),

                        FilledButton(
                          onPressed: () async {
                            final db = await DatabaseHelper().database;
                            await db.execute('DELETE FROM transactions');

                            await db.rawUpdate(
                              "UPDATE wallets SET balance = ?,savings = ? WHERE account_id = ?",
                              [0, 0, '${await authM.getAccountId()}'],
                            );
                            di<TransactionsModel>().refreshTx();
                            di<WalletModel>().refresh();
                          },
                          child: Text("Reset Transactions and Wallet"),
                        ),
                      ],
                    )
                  : Text(''),
            ],
          ),
        ),
      ),
    );
  }
}
