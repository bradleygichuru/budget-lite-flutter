import 'dart:async';
import 'dart:developer';

import 'package:another_telephony/telephony.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/funcs/transactions.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/signup_screen.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  }
}

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  int currentPageIndex = 0;
  final telephony = Telephony.instance;
  late Timer pollingTx;
  late Future<List<Widget>> initComposed;
  Future<bool> handleAuth = Future.value(true);
  Widget authWidget = Center(child: CircularProgressIndicator());
  bool loading = true;

  Future<bool> isSetLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    bool isNewUser = prefs.getBool("isNewUser") ?? true;
    if (isNewUser) {
      authWidget = SignupForm();
      log("onboarding");
      return true;
    } else {
      if (!isLoggedIn) {
        authWidget = LoginForm();
        log("not logged in");
        return true;
      } else {
        log("Is logged in");
        return false;
      }
    }
  }

  @override
  void initState() {
    super.initState();

    isSetLoggedIn().whenComplete(() {
      loading = false;
    });
    initPlatformState();
    initComposed = initTX();
    pollingTx = Timer.periodic(
      Duration(seconds: 10),
      (Timer t) => pollFetchTx(),
    );

    FlutterNativeSplash.remove();
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

  Future<List<Widget>> initTX() async {
    List<Widget> newComposed = [];
    await transactions().then((txs) {
      log("fetched transactions ${txs.length}");
      newComposed = initComposeTransactions(txs);

      log("composed transactions ${newComposed.length}");
    });
    return newComposed;
  }

  void pollFetchTx() {
    setState(() {
      initComposed = initTX();
    });
  }

  Future<List<Widget>> handleInsert(Map<String, dynamic> transaction) async {
    List<Widget> newComposed = [];
    await insertTransaction(
      TransactionObj(
        type: transaction['type'],
        source: transaction['source'],
        amount: transaction['amount'],
        date: transaction['date'],
      ),
    ).whenComplete(() async {
      List<TransactionObj> txs = await transactions();
      newComposed = initComposeTransactions(txs);
    });

    return newComposed;
  }

  onMessage(SmsMessage message) async {
    log('from:${message.address} message:${message.body}');
    var transaction = parseMpesa(message);

    log('foreground_transaction:$transaction');
    if (transaction != null) {
      setState(() {
        initComposed = handleInsert(transaction);
      });
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
      home: FutureBuilder<bool>(
        future: handleAuth,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              if (snapshot.hasData) {
                if (snapshot.requireData) {
                  return authWidget;
                } else {
                  SafeArea(
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
                            icon: Badge(child: Icon(Icons.wallet)),
                            label: 'Envelopes',
                          ),
                          NavigationDestination(
                            icon: Badge(
                              label: Text(''),
                              child: Icon(Icons.crisis_alert),
                            ),
                            label: 'Goals',
                          ),
                        ],
                      ),
                      body: <Widget>[
                        /// Home page
                        ListView(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Card(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF3b82f6),
                                        Color(0xFF4f46e5),
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            "Total Balance",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            "KSh 32,000",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 30,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Card(
                                          //color: Colors.white,
                                          elevation: 0,

                                          child: Column(
                                            children: [
                                              ListTile(
                                                //leading: Icon(Icons.album),
                                                title: Text('Ready to Assign'),
                                                subtitle: Text('KSh 0'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Budget Overview",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            Wrap(
                              children: [
                                SizedBox(
                                  width: 180,
                                  height: 160,
                                  child: Card.outlined(
                                    color: Colors.white,

                                    child: Column(
                                      children: [
                                        ListTile(
                                          leading: Icon(
                                            Icons.category,
                                            size: 15,
                                          ),
                                          title: Text('Rent'),
                                          subtitle: Text('KSh 15,000 left'),
                                        ),
                                        ListTile(
                                          subtitle: Text("100% remaining"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 180,
                                  height: 160,
                                  child: Card.outlined(
                                    color: Colors.white,

                                    child: Column(
                                      children: [
                                        ListTile(
                                          leading: Icon(
                                            Icons.category,
                                            size: 15,
                                          ),
                                          title: Text('Rent'),
                                          subtitle: Text('KSh 15,000 left'),
                                        ),
                                        ListTile(
                                          subtitle: Text("100% remaining"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 180,
                                  height: 160,
                                  child: Card.outlined(
                                    color: Colors.white,

                                    child: Column(
                                      children: [
                                        ListTile(
                                          leading: Icon(
                                            Icons.category,
                                            size: 15,
                                          ),
                                          title: Text('Rent'),
                                          subtitle: Text('KSh 15,000 left'),
                                        ),
                                        ListTile(
                                          subtitle: Text("100% remaining"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Recent Transactions",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            FutureBuilder<List<Widget>>(
                              future: initComposed,
                              builder:
                                  (
                                    BuildContext context,
                                    AsyncSnapshot<List<Widget>> snapshot,
                                  ) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      // return CircularProgressIndicator();
                                    } else {
                                      if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      } else {
                                        if (snapshot.hasData) {
                                          return Column(
                                            children: snapshot.requireData,
                                          );
                                        }
                                      }
                                    }
                                    return Text(
                                      "Error Occured Fetching transactions",
                                    );
                                  },
                            ),
                          ],
                        ),

                        /// Notifications page
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            children: <Widget>[
                              Card(
                                child: ListTile(
                                  leading: Icon(Icons.notifications_sharp),
                                  title: Text('Notification 1'),
                                  subtitle: Text('This is a notification'),
                                ),
                              ),
                              Card(
                                child: ListTile(
                                  leading: Icon(Icons.notifications_sharp),
                                  title: Text('Notification 2'),
                                  subtitle: Text('This is a notification'),
                                ),
                              ),
                            ],
                          ),
                        ),

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
                                    style: theme.textTheme.bodyLarge!.copyWith(
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
                      ][currentPageIndex],
                    ),
                  );
                }
              }
            }
          }
          return Text("Error Occured Fetching transactions");
        },
      ),
    );
  }
}
