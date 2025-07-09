import 'dart:async';
import 'dart:developer';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:another_telephony/telephony.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data-models/transactions.dart';
import 'package:flutter_application_1/data-models/wallet.dart';
import 'package:flutter_application_1/models/auth.dart';
import 'package:flutter_application_1/models/categories.dart';
import 'package:flutter_application_1/models/txs.dart';
import 'package:flutter_application_1/screens/dashboard_screen.dart';
import 'package:flutter_application_1/screens/envelopes_screen.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

@pragma('vm:entry-point')
backgroundMessageHandler(SmsMessage message) async {
  //Handle background message
  var transaction = parseMpesa(message);
  log('from:${message.address} message:${message.body}');

  log('background_transaction:$transaction');
  if (transaction != null) {
    insertTransaction(
      TransactionObj(
        type: transaction['type'],
        source: transaction['source'],
        amount: transaction['amount'],
        date: transaction['date'],
      ),
    );
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'basic_channel',
        actionType: ActionType.Default,
        title: 'New transaction',
        body: 'Click to set transaction category',
      ),
    );
  }
}

class NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    // Your code goes here
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    // Your code goes here

    // Navigate into pages, avoiding to open the notification details page over another details page already opened
  }
}

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  final db = await openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'budget_lite_database.db'),
    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      db.execute(
        'CREATE TABLE transactions(id INTEGER PRIMARY KEY, type TEXT,source TEXT, amount REAL,date TEXT)',
      );
      db.execute(
        "CREATE TABLE categories(id INTEGER PRIMARY KEY,budget REAL,category_name TEXT,spent REAL)",
      );

      db.execute(
        "CREATE TABLE wallets(id INTEGER PRIMARY KEY,balance REAL,name TEXT",
      );
    },

    // When the database is first created, create a table to store dogs.
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );
  await db.execute(
    "CREATE TABLE wallets(id INTEGER PRIMARY KEY,balance REAL,name TEXT",
  );
  insertWallet(Wallet(name: "default", balance: 0));
  await db.execute(
    "CREATE TABLE IF NOT EXISTS categories(id INTEGER PRIMARY KEY,budget REAL,category_name TEXT,spent REAL)",
  ); //TODO: remove on prod
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
    null,
    [
      NotificationChannel(
        channelGroupKey: 'basic_channel_group',
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
      ),
    ],
    // Channel groups are only visual and are not required
    channelGroups: [
      NotificationChannelGroup(
        channelGroupKey: 'basic_channel_group',
        channelGroupName: 'Basic group',
      ),
    ],
    debug: true,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TransactionsModel()),
        ChangeNotifierProvider(create: (context) => AuthModel()),
        ChangeNotifierProvider(create: (context) => CategoriesModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  int currentPageIndex = 0;
  final telephony = Telephony.instance;
  late Timer pollingTx;
  // late Future<List<Widget>> initComposed;
  // late Future<bool> handleAuth;
  // Widget authWidget = SafeArea(
  //   child: Center(child: CircularProgressIndicator()),
  // );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    // handleAuth = isSetLoggedIn();
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      onNotificationCreatedMethod:
          NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod:
          NotificationController.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod:
          NotificationController.onDismissActionReceivedMethod,
    );
    initPlatformState();
    // initComposed = initTX();
    // pollingTx = Timer.periodic(Duration(seconds: 10), (Timer t) {
    //   pollFetchTx();
    // });

    FlutterNativeSplash.remove();
    super.initState();
  }

  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    final bool? result = await telephony.requestPhoneAndSmsPermissions;

    if (result != null && result) {
      telephony.listenIncomingSms(
        onNewMessage: onMessage,
        onBackgroundMessage: backgroundMessageHandler,
      );
    }

    if (!mounted) return;
  }

  // Future<List<Widget>> initTX() async {
  //   List<Widget> newComposed = [];
  //   await transactions().then((txs) {
  //     log("fetched transactions ${txs.length}");
  //     newComposed = initComposeTransactions(txs);

  //     log("composed transactions ${newComposed.length}");
  //   });
  //   return newComposed;
  // }

  // void pollFetchTx() {
  //   setState(() {
  //     initComposed = initTX();
  //   });
  // }

  onMessage(SmsMessage message) async {
    log('from:${message.address} message:${message.body}');
    var transaction = parseMpesa(message);

    log('foreground_transaction:$transaction');
    if (transaction != null) {
      Provider.of<TransactionsModel>(
        context as BuildContext,
        listen: false,
      ).handleTxAdd(transaction);
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 10,
          channelKey: 'basic_channel',
          actionType: ActionType.Default,
          title: 'New transaction',
          body: 'Click to set transaction category',
        ),
      );

      // setState(() {
      //   initComposed = handleInsert(transaction);
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData(
      colorSchemeSeed: const Color.fromARGB(255, 25, 143, 240),
    );
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: const Color.fromARGB(255, 25, 143, 240),
      ),
      home: Consumer<AuthModel>(
        builder: (context, authM, child) {
          return FutureBuilder<bool>(
            future: authM.handleAuth,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              Widget cont = Text("");
              if (snapshot.connectionState == ConnectionState.waiting) {
                cont = SafeArea(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  if (snapshot.requireData) {
                    cont = authM.authWidget;
                  } else {
                    cont = SafeArea(
                      child: Scaffold(
                        bottomNavigationBar: NavigationBar(
                          onDestinationSelected: (int index) {
                            setState(() {
                              currentPageIndex = index;
                            });
                          },
                          indicatorColor: Color(0xFFE0F2FE),
                          selectedIndex: currentPageIndex,
                          destinations: const <Widget>[
                            NavigationDestination(
                              selectedIcon: Icon(Icons.home),

                              icon: Icon(Icons.home_outlined),
                              label: 'DashBoard',
                            ),
                            NavigationDestination(
                              icon: Badge(
                                child: Icon(Icons.account_balance_wallet),
                              ),
                              label: 'Budget',
                            ),
                            NavigationDestination(
                              icon: Badge(
                                label: Text(''),
                                child: Icon(Icons.crisis_alert),
                              ),
                              label: 'Goals',
                            ),
                            NavigationDestination(
                              icon: Badge(
                                label: Text(''),
                                child: Icon(Icons.settings),
                              ),
                              label: 'Settings',
                            ),
                          ],
                        ),
                        body: <Widget>[
                          /// Home page
                          Dashboard(),

                          /// Notifications page
                          EnvelopesView(),

                          /// Messages page
                          ListView.builder(
                            reverse: true,
                            itemCount: 2,
                            itemBuilder: (BuildContext context, int index) {
                              if (index == 0) {
                                return Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    margin: const EdgeInsets.all(8.0),
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Text(
                                      'Hello',
                                      style: theme.textTheme.bodyLarge!
                                          .copyWith(
                                            color: theme.colorScheme.onPrimary,
                                          ),
                                    ),
                                  ),
                                );
                              }
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.all(8.0),
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(
                                    'Hi!',
                                    style: theme.textTheme.bodyLarge!.copyWith(
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          FilledButton(
                            onPressed: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setBool("isLoggedIn", false);
                              authM.isSetLoggedIn();
                            },
                            child: Text("logout"),
                          ),
                        ][currentPageIndex],
                      ),
                    );
                  }
                }
              } else {
                if (snapshot.hasError) {
                  cont = Text('Error: ${snapshot.error}');
                }
              }
              return cont;
            },
          );
        },
      ),
    );
  }
}
