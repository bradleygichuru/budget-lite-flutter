import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:another_telephony/telephony.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data_models/auth_data_model.dart';
import 'package:flutter_application_1/data_models/transactions.dart';
import 'package:flutter_application_1/screens/wallet_screen.dart';
import 'package:flutter_application_1/services/main_service.dart';
import 'package:flutter_application_1/services/notification_controller.dart';
import 'package:flutter_application_1/db/db.dart';
import 'package:flutter_application_1/screens/dashboard_screen.dart';
import 'package:flutter_application_1/screens/envelopes_screen.dart';
import 'package:flutter_application_1/screens/goals_page.dart';
import 'package:flutter_application_1/screens/settings_page.dart';
import 'package:flutter_application_1/util/result_wraper.dart';
import 'package:flutter_application_1/view_models/auth.dart';
import 'package:flutter_application_1/view_models/categories.dart';
import 'package:flutter_application_1/view_models/goals.dart';
import 'package:flutter_application_1/view_models/txs.dart';
import 'package:flutter_application_1/view_models/wallet.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_it/watch_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

@pragma('vm:entry-point')
backgroundMessageHandler(SmsMessage message) async {
  //Handle background message
  try {
    TransactionsModel txM = TransactionsModel();
    WalletModel wM = WalletModel();
    AuthModel aM = AuthModel();
    String? currentRegion = await aM.getRegion();
    if (currentRegion == Country.kenya.name) {
      var transaction = parseMpesa(message);
      log('from:${message.address} message:${message.body}');

      int? accountId = await aM.getAccountId();
      log('background_transaction:$transaction');
      if (transaction != null && accountId != null) {
        if (transaction['type'] == TxType.credit.val) {
          TransactionObj tx = TransactionObj(
            desc: transaction['desc'],
            type: transaction['type'],
            source: transaction['source'],
            amount: transaction['amount'],
            date: transaction['date'],
            category: 'credit',
          );
          wM.creditDefaultWallet(tx);
        } else if (transaction['type'] == TxType.fromSaving.val) {
          TransactionObj tx = TransactionObj(
            desc: transaction['desc'],
            type: transaction['type'],
            category: 'credit',
            source: transaction['source'],
            amount: transaction['amount'],
            date: transaction['date'],
          );
          wM.removeFromSavings(tx);
        } else if (transaction['type'] == TxType.toSaving.val) {
          TransactionObj tx = TransactionObj(
            desc: transaction['desc'],
            type: transaction['type'],
            source: transaction['source'],
            category: 'savings',
            amount: transaction['amount'],
            date: transaction['date'],
          );
          wM.addToSavings(tx);
        } else {
          TransactionObj tx = TransactionObj(
            desc: transaction['desc'],
            type: transaction['type'],
            source: transaction['source'],
            amount: transaction['amount'],
            date: transaction['date'],
          );
          txM.insertTransaction(tx);
        }
      }
    }
  } catch (e) {
    log('Error in background message', error: e);
  }
}

void setup() {
  //intialize changenotifier singletons
  di.registerSingleton<TransactionsModel>(TransactionsModel());

  di.registerSingleton<AuthModel>(AuthModel());

  di.registerSingleton<CategoriesModel>(CategoriesModel());

  di.registerSingleton<GoalModel>(GoalModel());

  di.registerSingleton<WalletModel>(WalletModel());
}

setUpNotificationIds() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey('notification_id')) {
    prefs.setInt('notification_id', 0);
  }
}

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await dotenv.load(fileName: ".env");

  // await deleteDatabase(
  //   join(await getDatabasesPath(), 'budget_lite_database.db'),
  // );
  await appDbInit();
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // prefs.remove("budget_lite_current_account_id");

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
  setUpNotificationIds();
  initializeService();
  setup();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget with WatchItStatefulWidgetMixin {
  const MyApp({super.key});
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Future<List<TransactionObj>> unCategorizedTxs = Future.value([]);
  int currentPageIndex = 0;
  late final AppLifecycleListener _listener;
  bool handleUncategorized = false;
  CategoriesModel ctm = di.get<CategoriesModel>();
  TransactionsModel txM = di.get<TransactionsModel>();

  bool categorizing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // Do not forget to dispose the listener
    _listener.dispose();

    super.dispose();
  }
  // @override
  // Future<void> didChangeAppLifecycleState(AppLifecycleState appState) async {
  //   log('new state $appState');
  //   if (appState == AppLifecycleState.resumed) {
  //     List<TransactionObj> uncTxs = await getUncategorizedTx();
  //     setState(() {
  //       unCategorizedTxs = uncTxs;
  //     });
  //   }
  // }

  @override
  void initState() {
    // handleAuth = isSetLoggedIn();
    _listener = AppLifecycleListener(onStateChange: _onStateChanged);
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      onNotificationCreatedMethod:
          NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod:
          NotificationController.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod:
          NotificationController.onDismissActionReceivedMethod,
    );
    //  initPlatformState();
    // initComposed = initTX();
    // pollingTx = Timer.periodic(Duration(seconds: 10), (Timer t) {
    //   pollFetchTx();
    // });

    FlutterNativeSplash.remove();
    super.initState();
  }

  // Future<void> initPlatformState() async {
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (await di.get<AuthModel>().getRegion() == Country.kenya.name) {
  //     final bool? result = await telephony.requestPhoneAndSmsPermissions;
  //
  //     if (result != null && result) {
  //       telephony.listenIncomingSms(
  //         onNewMessage: onMessage,
  //         onBackgroundMessage: backgroundMessageHandler,
  //       );
  //     }
  //   }
  //
  //   if (!mounted) return;
  // }

  void _onStateChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
        _onDetached();
      case AppLifecycleState.resumed:
        _onResumed();
      case AppLifecycleState.inactive:
        _onInactive();
      case AppLifecycleState.hidden:
        _onHidden();
      case AppLifecycleState.paused:
        _onPaused();
    }
  }

  void _onDetached() => log('detached');

  void _onResumed() async {
    log('resumed');
    int? acId = await di.get<AuthModel>().getAccountId();
    if (acId != null) {
      di.get<TransactionsModel>().getUncategorizedTx().then((txs) {
        if (txs.isNotEmpty) {
          setState(() {
            handleUncategorized = true;
            unCategorizedTxs = Future.value(txs);
          });
        }
      });
    }
    if (mounted) {
      di.get<TransactionsModel>().refreshTx();
      di.get<WalletModel>().refresh();
      di.get<CategoriesModel>().refreshCats();
      di.get<GoalModel>().refreshGoals();

      log('Refresh Models');
    }
  }

  void _onInactive() => log('inactive');

  void _onHidden() => log('hidden');

  void _onPaused() => log('paused');

  onMessage(SmsMessage message) async {
    try {
      TransactionsModel txM = TransactionsModel();
      WalletModel wM = WalletModel();
      AuthModel aM = AuthModel();
      String? currentRegion = await aM.getRegion();
      if (currentRegion == Country.kenya.name) {
        var transaction = parseMpesa(message);
        log('from:${message.address} message:${message.body}');

        int? accountId = await aM.getAccountId();
        log('background_transaction:$transaction');
        if (transaction != null && accountId != null) {
          if (transaction['type'] == TxType.credit.val) {
            TransactionObj tx = TransactionObj(
              desc: transaction['desc'],
              type: transaction['type'],
              source: transaction['source'],
              amount: transaction['amount'],
              date: transaction['date'],
              category: 'credit',
            );
            wM.creditDefaultWallet(tx);
          } else if (transaction['type'] == TxType.fromSaving.val) {
            TransactionObj tx = TransactionObj(
              desc: transaction['desc'],
              type: transaction['type'],
              category: 'credit',
              source: transaction['source'],
              amount: transaction['amount'],
              date: transaction['date'],
            );
            wM.removeFromSavings(tx);
          } else if (transaction['type'] == TxType.toSaving.val) {
            TransactionObj tx = TransactionObj(
              desc: transaction['desc'],
              type: transaction['type'],
              source: transaction['source'],
              category: 'savings',
              amount: transaction['amount'],
              date: transaction['date'],
            );
            wM.addToSavings(tx);
          } else {
            TransactionObj tx = TransactionObj(
              desc: transaction['desc'],
              type: transaction['type'],
              source: transaction['source'],
              amount: transaction['amount'],
              date: transaction['date'],
            );
            txM.insertTransaction(tx);
          }
        }
      }
    } catch (e) {
      log('Error in background message', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return handleUncategorized
        ? MaterialApp(
            theme: ThemeData(
              colorSchemeSeed: const Color.fromARGB(255, 25, 143, 240),
            ),
            home: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      handleUncategorized = false;
                    });
                  },
                ),
                backgroundColor: Colors.blue.shade700,
                title: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(7),
                      child: FutureBuilder<List<TransactionObj>>(
                        future: unCategorizedTxs,
                        builder: (context, snapshot) {
                          Widget x = CircularProgressIndicator();
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text("Error occured fetching transactions");
                          } else if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.hasData) {
                            if (snapshot.data!.length < 0) {
                              setState(() {
                                handleUncategorized = false;
                              });
                            }
                            return Text(
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,

                                color: Colors.white,
                              ),
                              "Pending Category Assignment",
                            );
                          }
                          return x;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              body: FutureBuilder<List<TransactionObj>>(
                future: unCategorizedTxs,
                builder: (context, snapshot) {
                  final List<DropdownMenuEntry<String>> menuEntries =
                      UnmodifiableListView<DropdownMenuEntry<String>>(
                        ctm.knownCategoryEntries.map<DropdownMenuEntry<String>>(
                          (String name) => DropdownMenuEntry<String>(
                            value: name,
                            label: name,
                          ),
                        ),
                      );
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return SafeArea(
                      child: CustomScrollView(
                        slivers: [
                          SliverList.builder(
                            itemCount: snapshot.data?.length,
                            //shrinkWrap: true,
                            itemBuilder: (context, index) {
                              String category = '';

                              final String sign =
                                  snapshot.data?[index].type == TxType.spend.val
                                  ? '-'
                                  : '+';
                              final double amount =
                                  snapshot.data![index].amount;
                              Icon iconsToUse =
                                  snapshot.data![index].type == TxType.spend.val
                                  ? Icon(
                                      size: 15,
                                      Icons.outbound,
                                      color: Colors.red,
                                    )
                                  : Icon(
                                      size: 15,
                                      Icons.call_received,
                                      color: Colors.green,
                                    );

                              return Card(
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      child: Card.filled(
                                        color: Colors.white,

                                        child: Column(
                                          children: [
                                            ListTile(
                                              leading: iconsToUse,
                                              title: Text(
                                                snapshot
                                                        .data![index]
                                                        .category ??
                                                    'Pending Category',
                                              ),
                                              subtitle: Text(
                                                '$sign KSh $amount',
                                                style: TextStyle(
                                                  color:
                                                      snapshot
                                                              .data![index]
                                                              .type ==
                                                          TxType.spend.val
                                                      ? Colors.red
                                                      : Colors.green,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "Select Category",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8),
                                            child: DropdownMenu<String>(
                                              width: double.infinity,
                                              hintText: "select category",
                                              onSelected: (value) {
                                                if (value != null) {
                                                  category = value;
                                                }
                                                // This is called when the user selects an item.

                                                log(
                                                  "selected_category:$category",
                                                );
                                              },
                                              dropdownMenuEntries: menuEntries,
                                            ),
                                          ),
                                          FilledButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStatePropertyAll<Color>(
                                                    Colors.black,
                                                  ),
                                            ),
                                            onPressed: categorizing
                                                ? null
                                                : () {
                                                    if (category.isNotEmpty &&
                                                        snapshot
                                                                .data![index]
                                                                .id !=
                                                            null) {
                                                      setState(() {
                                                        categorizing = true;
                                                      });
                                                      txM
                                                          .setTxCategory(
                                                            category,
                                                            snapshot
                                                                .data![index]
                                                                .id!,
                                                          )
                                                          .then((count) async {
                                                            if (count > 0) {
                                                              Result
                                                              res = await ctm
                                                                  .handleCatBalanceCompute(
                                                                    category,
                                                                    snapshot
                                                                        .data![index],
                                                                  );
                                                              switch (res) {
                                                                case Ok():
                                                                  {
                                                                    unCategorizedTxs =
                                                                        txM.getUncategorizedTx();
                                                                    txM.refreshTx();
                                                                    setState(() {
                                                                      categorizing =
                                                                          false;
                                                                    });

                                                                    break;
                                                                  }

                                                                default:
                                                                  {
                                                                    ScaffoldMessenger.of(
                                                                      context,
                                                                    ).showSnackBar(
                                                                      SnackBar(
                                                                        content: Text(
                                                                          'error occured',
                                                                          style: TextStyle(
                                                                            color:
                                                                                Colors.red,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                    setState(() {
                                                                      categorizing =
                                                                          false;
                                                                    });
                                                                  }
                                                              }
                                                            }
                                                          });
                                                    }
                                                  },
                                            child: Text(
                                              "Categorize Transaction",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
          )
        : MaterialApp(
            theme: ThemeData(
              colorSchemeSeed: const Color.fromARGB(255, 25, 143, 240),
            ),
            home: FutureBuilder<bool>(
              future: watch(di<AuthModel>()).handleAuth,
              builder: (context, snapshot) {
                Widget cont = Text("");
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SafeArea(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    if (snapshot.requireData) {
                      return di<AuthModel>().authWidget;
                    } else {
                      return SafeArea(
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
                                selectedIcon: Icon(Icons.mail),
                                icon: Icon(Icons.mail_outlined),
                                label: 'Budget',
                              ),
                              NavigationDestination(
                                selectedIcon: Icon(Icons.crisis_alert),
                                icon: Icon(Icons.crisis_alert_outlined),
                                label: 'Goals',
                              ),
                              NavigationDestination(
                                selectedIcon: Icon(
                                  Icons.account_balance_wallet,
                                ),
                                icon: Icon(
                                  Icons.account_balance_wallet_outlined,
                                ),
                                label: 'Wallet',
                              ),

                              NavigationDestination(
                                icon: Icon(Icons.settings_outlined),
                                selectedIcon: Icon(Icons.settings),
                                label: 'Settings',
                              ),
                            ],
                          ),
                          body: <Widget>[
                            Dashboard(),
                            EnvelopesView(),
                            GoalsPage(),
                            WalletScreen(),
                            SettingsPage(),
                          ][currentPageIndex],
                        ),
                      );
                    }
                  }
                } else {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                }
                return cont;
              },
            ),
          );
  }
}
