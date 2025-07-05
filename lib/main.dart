import 'package:another_telephony/telephony.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/funcs/transactions.dart';
import 'package:flutter_application_1/screens/dashboard_screen.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

@pragma('vm:entry-point')
backgroundMessageHandler(SmsMessage message) async {
  //Handle background message
  var transaction = parseMpesa(message);
  print('from:${message.address} message:${message.body}');

  print('background_transaction:${transaction}');
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  List<TransactionObj> initialTransactions = await transactions();

  runApp(
    ChangeNotifierProvider(
      create: (context) => TransactionsModel(initialTransactions),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final telephony = Telephony.instance;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> setTransactions() async {}
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

  onMessage(SmsMessage message) async {
    print('from:${message.address} message:${message.body}');
    var transaction = parseMpesa(message);

    print('foreground_transaction:${transaction}');
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const NavigationExample(),
    );
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData(
      colorSchemeSeed: const Color.fromARGB(255, 25, 143, 240),
    );
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: const Color.fromARGB(255, 25, 143, 240),
      ),
      home: SafeArea(
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
                icon: Badge(label: Text(''), child: Icon(Icons.crisis_alert)),
                label: 'Goals',
              ),
            ],
          ),
          body: <Widget>[
            /// Home page
            const Dashboard(),

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
      ),
    );
  }
}
