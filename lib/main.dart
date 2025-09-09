import 'dart:async';
import 'package:another_telephony/telephony.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/data_models/categories_data_model.dart';
import 'package:flutter_application_1/db/db.dart';
import 'package:flutter_application_1/screens/reports_screen.dart';
import 'package:flutter_application_1/screens/terms_and_conditions.dart';
import 'package:flutter_application_1/view_models/weekly_reports.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:ota_update/ota_update.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'dart:collection';
import 'dart:developer';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/globals.dart';
import 'package:flutter_application_1/data_models/txs_data_model.dart';
import 'package:flutter_application_1/screens/handle_balance.dart';
import 'package:flutter_application_1/screens/handle_savings.dart';
import 'package:flutter_application_1/services/main_service.dart';
import 'package:flutter_application_1/services/notification_controller.dart';
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
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:upgrader/upgrader.dart';
import 'package:watch_it/watch_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_application_1/firebase_options.dart';

void setup() {
  //intialize changenotifier singletons
  di.registerSingleton<TransactionsModel>(TransactionsModel());
  di.registerSingleton<AuthModel>(AuthModel());
  di.registerSingleton<CategoriesModel>(CategoriesModel());
  di.registerSingleton<GoalModel>(GoalModel());
  di.registerSingleton<WalletModel>(WalletModel());
  di.registerSingleton<WeeklyReportsModel>(WeeklyReportsModel());
}

setUpNotificationIds() async {
  SharedPreferencesAsync prefs = SharedPreferencesAsync();
  if (!await prefs.containsKey('notification_id')) {
    prefs.setInt('notification_id', 0);
  }
}

// Future<void> requestSmsPermission() async {
//   AwesomeNotifications().isNotificationAllowed();
//   final permission = await AwesomeNotifications().isNotificationAllowed();
//
//   // SharedPreferences prefs = await SharedPreferences.getInstance();
//
//   if (!permission) {
//     log("sms permissions: false");
//     var status = await AwesomeNotifications()
//         .requestPermissionToSendNotifications();
//     if (status) {}
//   }
//   if (permission) {
//     log("sms permissions: true");
//   }
// }

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // SystemChrome.setSystemUIOverlayStyle(
  //   SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  // );
  await dotenv.load(fileName: ".env");
  // final db = await DatabaseHelper().database;
  // db.execute('ALTER TABLE accounts ADD COLUMN anonymous INTEGER DEFAULT 0');
  // await db.execute('DELETE FROM weekly_reports');
  // await deleteDatabase(
  //   join(await getDatabasesPath(), 'budget_lite_database.db'),
  // );
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // prefs.remove("budget_lite_current_account_id");
  setUpNotificationIds();
  requestNotificationPermissions();
  AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
    null,
    [
      NotificationChannel(
        importance: NotificationImportance.Low,
        // channelGroupKey: 'service_channel_group',
        channelKey: 'service_channel',
        channelName: 'Budgetlite Service silent notifications',
        channelDescription: 'Budgetlite Service silent notifications channel',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
        enableVibration: false,
        playSound: false,
      ),
      NotificationChannel(
        // channelGroupKey: 'budgetlite_silent_group',
        channelKey: 'budgetlite_silent',
        channelName: 'Budgetlite silent notifications',
        channelDescription: 'Budgetlite silent notifications channel',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
        playSound: false,
      ),
      NotificationChannel(
        // channelGroupKey: 'basic_channel_group',
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Default Notification channel',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
        criticalAlerts: true,
      ),
    ],
    // Channel groups are only visual and are not required
    // channelGroups: [
    //   NotificationChannelGroup(
    //     channelGroupKey: 'basic_channel_group',
    //     channelGroupName: 'Basic group',
    //   ),
    // ],
    debug: kDebugMode,
  );
  // await Upgrader.clearSavedSettings();

  // await appDbInit();
  setup();
  // await SentryFlutter.init((options) {
  //   options.dsn = dotenv.env['SENTRY_DSN'];
  //   // Adds request headers and IP for users,
  //   // visit: https://docs.sentry.io/platforms/dart/data-management/data-collected/ for more info
  //   options.sendDefaultPii = true;
  // }, appRunner: () => runApp(SentryWidget(child: MyApp())));

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // final auth = FirebaseAuth.instanceFor(app: Firebase.app());
  // To change it after initialization, use `setPersistence()`:
  // await auth.setPersistence(Persistence.LOCAL);
  if (!kDebugMode) {
    bool weWantFatalErrorRecording = true;
    FlutterError.onError = (errorDetails) {
      if (weWantFatalErrorRecording) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      } else {
        FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      }
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
  MobileAds.instance.initialize();
  initializeService();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget with WatchItStatefulWidgetMixin {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final telephony = Telephony.instance;
  Future<List<TransactionObj>> unCategorizedTxs = Future.value([]);
  String newApkUrl = '';
  bool isUpdating = false;
  OtaEvent? updateEvent;
  int currentPageIndex = 0;
  late final AppLifecycleListener _listener;
  bool handleUncategorized = false;
  CategoriesModel ctm = di.get<CategoriesModel>();
  TransactionsModel txM = di.get<TransactionsModel>();
  bool isResetLoading = false;
  bool categorizing = false;
  bool shouldReset = false;
  AppcastItem? bestItem;
  static const appcastURL =
      'https://raw.githubusercontent.com/bradleygichuru/budgetlite-appcast/refs/heads/main/budgetlite_updates.xml';
  final appCast = Appcast();

  final upgrader = Upgrader(
    // durationUntilAlertAgain: Duration(minutes: 1),
    // debugLogging: kDebugMode ? true : false,
    storeController: UpgraderStoreController(
      onAndroid: () => UpgraderAppcastStore(appcastURL: appcastURL),
    ),
  );

  final GlobalKey<ScaffoldMessengerState> mainScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
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

      setState(() {
        bestItem = appCast.bestItem();
      });
      FlutterNativeSplash.remove();
    });
    super.initState();
    // initPlatformState();
  }

  // onMessageForeground(SmsMessage message) async {
  //   try {
  //     TransactionsModel txM = di.get<TransactionsModel>();
  //     WalletModel wM = di.get<WalletModel>();
  //     AuthModel aM = di.get<AuthModel>();
  //     String? currentRegion = aM.region;
  //
  //     log('from:${message.address} message:${message.body}');
  //     log('tx parsing for region: $currentRegion');
  //
  //     int? accountId = await aM.getAccountId();
  //     if (message.address == 'MPESA') {
  //       log('parsing mpesa tx message');
  //       var transaction = parseMpesa(message);
  //
  //       log('foreground_transaction:$transaction');
  //       if (transaction != null && accountId != null) {
  //         if (transaction['type'] == TxType.credit.val) {
  //           TransactionObj tx = TransactionObj(
  //             desc: transaction['desc'],
  //             type: transaction['type'],
  //             source: transaction['source'],
  //             amount: transaction['amount'],
  //             date: transaction['date'],
  //             category: 'credit',
  //           );
  //           wM.creditDefaultWallet(tx);
  //         } else if (transaction['type'] == TxType.fromSaving.val) {
  //           TransactionObj tx = TransactionObj(
  //             desc: transaction['desc'],
  //             type: transaction['type'],
  //             category: 'credit',
  //             source: transaction['source'],
  //             amount: transaction['amount'],
  //             date: transaction['date'],
  //           );
  //           wM.removeFromSavings(tx);
  //         } else if (transaction['type'] == TxType.toSaving.val) {
  //           TransactionObj tx = TransactionObj(
  //             desc: transaction['desc'],
  //             type: transaction['type'],
  //             source: transaction['source'],
  //             category: 'savings',
  //             amount: transaction['amount'],
  //             date: transaction['date'],
  //           );
  //           wM.addToSavings(tx);
  //         } else {
  //           TransactionObj tx = TransactionObj(
  //             desc: transaction['desc'],
  //             type: transaction['type'],
  //             source: transaction['source'],
  //             amount: transaction['amount'],
  //             date: transaction['date'],
  //           );
  //           txM.insertTransaction(tx);
  //         }
  //       }
  //     }
  //     if (message.address == 'NCBA_BANK') {
  //       var transaction = parseNCBA(message);
  //
  //       log('foreground_transaction:$transaction');
  //       if (transaction != null && accountId != null) {
  //         if (transaction['type'] == TxType.credit.val) {
  //           TransactionObj tx = TransactionObj(
  //             desc: transaction['desc'],
  //             type: transaction['type'],
  //             source: transaction['source'],
  //             amount: transaction['amount'],
  //             date: transaction['date'],
  //             category: 'credit',
  //           );
  //           wM.creditDefaultWallet(tx);
  //         } else if (transaction['type'] == TxType.fromSaving.val) {
  //           TransactionObj tx = TransactionObj(
  //             desc: transaction['desc'],
  //             type: transaction['type'],
  //             category: 'credit',
  //             source: transaction['source'],
  //             amount: transaction['amount'],
  //             date: transaction['date'],
  //           );
  //           wM.removeFromSavings(tx);
  //         } else if (transaction['type'] == TxType.toSaving.val) {
  //           TransactionObj tx = TransactionObj(
  //             desc: transaction['desc'],
  //             type: transaction['type'],
  //             source: transaction['source'],
  //             category: 'savings',
  //             amount: transaction['amount'],
  //             date: transaction['date'],
  //           );
  //           wM.addToSavings(tx);
  //         } else if (transaction['type'] == TxType.spend.val) {
  //           TransactionObj tx = TransactionObj(
  //             desc: transaction['desc'],
  //             type: transaction['type'],
  //             source: transaction['source'],
  //             amount: transaction['amount'],
  //             date: transaction['date'],
  //           );
  //           txM.insertTransaction(tx);
  //         }
  //       }
  //     }
  //
  //     if (message.address == 'Equity Bank') {
  //       log('parsing Equity tx message');
  //       var transaction = parseEquity(message);
  //
  //       log('foreground_transaction:$transaction');
  //       log('from:${message.address} message:${message.body}');
  //       if (transaction != null) {
  //         if (transaction['type'] == TxType.spend.val) {
  //           TransactionObj tx = TransactionObj(
  //             desc: transaction['desc'],
  //             type: transaction['type'],
  //             source: transaction['source'],
  //             amount: transaction['amount'],
  //             date: transaction['date'],
  //           );
  //           txM.insertTransaction(tx);
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     log('Error in background message', error: e);
  //   }
  // }

  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    // if (await di.get<AuthModel>().getRegion() == Country.kenya.name) {
    //   final bool? result = await telephony.requestPhoneAndSmsPermissions;
    //
    //   if (result != null && result) {
    //     telephony.listenIncomingSms(
    //       onNewMessage: onMessage,
    //       onBackgroundMessage: backgroundMessageHandler,
    //     );
    //   }
    // }

    final bool? result = await telephony.requestPhoneAndSmsPermissions;

    if (result != null && result) {
      List<SmsMessage> messages = await telephony.getInboxSms(
        columns: [SmsColumn.ADDRESS, SmsColumn.BODY],
        filter: SmsFilter.where(SmsColumn.ADDRESS).equals("MPESA"),
        sortOrder: [
          OrderBy(SmsColumn.ADDRESS, sort: Sort.ASC),
          OrderBy(SmsColumn.BODY),
        ],
      );
      for (var message in messages) {
        debugPrint(
          'messageHashCode:${message.hashCode},messageSentDate:${message.dateSent},messageId:${message.id},messageBody:${message.body}',
        );
      }
    }

    if (!mounted) return;
  }

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      log('resumed');
      int? acId = await di.get<AuthModel>().getAccountId();
      if (acId != null) {
        di.get<TransactionsModel>().getUncategorizedTx().then((txs) {
          if (txs.isNotEmpty) {
            di<TransactionsModel>().toogleCategorizationOn();
            setState(() {
              handleUncategorized = true;
              // unCategorizedTxs = Future.value(txs);

              di.get<TransactionsModel>().refreshTx();
            });
          }
        });
      }
      if (mounted) {
        di.get<TransactionsModel>().refreshTx();
        di.get<WalletModel>().refresh();
        di.get<CategoriesModel>().refreshCats();
        di.get<GoalModel>().refreshGoals();
        di.get<AuthModel>().refreshAuth();
        di.get<WeeklyReportsModel>().refresh();
        setState(() {
          shouldReset = di<AuthModel>().pendingBudgetReset;
        });
        log('Refresh Models');
      }
    });
  }

  void _onInactive() => log('inactive');

  void _onHidden() => log('hidden');

  void _onPaused() => log('paused');
  isUpdatingDialog() {
    String title = '';
    bool showProgress = false;
    if (updateEvent != null) {
      switch (updateEvent!.status) {
        case OtaStatus.DOWNLOADING:
          {
            title = 'Donwloading Apk';
            showProgress = true;
            break;
          }
        case OtaStatus.INSTALLING:
          {
            title = 'Installing apk';

            showProgress = true;
            break;
          }
        case OtaStatus.DOWNLOAD_ERROR:
          {
            title = 'Error downloading update';

            showProgress = false;
            break;
          }
        case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
          {
            title = 'Required permissons not granted';

            showProgress = false;
            break;
          }
        case OtaStatus.INTERNAL_ERROR:
          {
            title = 'An internal error occured downloading update';

            showProgress = false;
            break;
          }
        case OtaStatus.CANCELED:
          {
            title = 'Update was cancelled';

            showProgress = false;
          }
        default:
          {}
      }
    }
    return MaterialApp(
      home: Scaffold(
        body: Dialog(
          child: Column(
            children: [
              Text(title),
              showProgress
                  ? Center(child: CircularProgressIndicator())
                  : Text(''),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return (watch(di<TransactionsModel>()).handleUncategorized &&
            !watch(di<AuthModel>()).isNewUser)
        ? MaterialApp(
            theme: ThemeData(
              colorSchemeSeed: const Color.fromARGB(255, 25, 143, 240),
            ),
            navigatorKey: AppGlobal.navigatorKey,
            home: ScaffoldMessenger(
              key: mainScaffoldMessengerKey,
              child: AnnotatedRegion(
                value: SystemUiOverlayStyle(statusBarColor: Colors.transparent),
                child: Scaffold(
                  appBar: AppBar(
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        di<TransactionsModel>().toogleCategorizationOff();
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
                            future: watchPropertyValue(
                              (TransactionsModel m) => m.unCategorizedTxs,
                            ),
                            builder: (context, snapshot) {
                              Widget x = CircularProgressIndicator();
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text(
                                  "Error occured fetching transactions",
                                );
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
                                  "Pending Categorization",
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
                    future: watchPropertyValue(
                      (TransactionsModel m) => m.unCategorizedTxs,
                    ),
                    builder: (context, snapshot) {
                      final List<DropdownMenuEntry<String>> menuEntries =
                          UnmodifiableListView<DropdownMenuEntry<String>>(
                            ctm.knownCategoryEntries
                                .map<DropdownMenuEntry<String>>(
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
                                      snapshot.data?[index].type ==
                                          TxType.spend.val
                                      ? '-'
                                      : '+';
                                  final double amount =
                                      snapshot.data![index].amount;
                                  Icon iconsToUse =
                                      snapshot.data![index].type ==
                                          TxType.spend.val
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
                                                            .desc ??
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
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    "Select Category",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                                  dropdownMenuEntries:
                                                      menuEntries,
                                                ),
                                              ),
                                              FilledButton(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      WidgetStatePropertyAll<
                                                        Color
                                                      >(Colors.black),
                                                ),
                                                onPressed: categorizing
                                                    ? null
                                                    : () async {
                                                        if (category
                                                                .isNotEmpty &&
                                                            snapshot
                                                                    .data![index]
                                                                    .id !=
                                                                null) {
                                                          setState(() {
                                                            categorizing = true;
                                                          });
                                                          Result res = await ctm
                                                              .handleCatBalanceCompute(
                                                                category,
                                                                snapshot
                                                                    .data![index],
                                                              );
                                                          switch (res) {
                                                            case Ok():
                                                              {
                                                                ScaffoldMessenger.of(
                                                                  context,
                                                                ).showSnackBar(
                                                                  SnackBar(
                                                                    content: Text(
                                                                      'Tx of id ${snapshot.data![index].id} categorized',
                                                                      style: TextStyle(
                                                                        color: Colors
                                                                            .green,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                                setState(() {
                                                                  unCategorizedTxs =
                                                                      txM.getUncategorizedTx();
                                                                });
                                                                txM.refreshTx();
                                                                setState(() {
                                                                  categorizing =
                                                                      false;
                                                                });

                                                                break;
                                                              }
                                                            case Error():
                                                              {
                                                                switch (res
                                                                    .error) {
                                                                  case ErrorUpdatingCategory():
                                                                    {
                                                                      ScaffoldMessenger.of(
                                                                        context,
                                                                      ).showSnackBar(
                                                                        SnackBar(
                                                                          content: Text(
                                                                            'Error updating category',
                                                                            style: TextStyle(
                                                                              color: Colors.red,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
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
                                                                            'Error occured while categorizing transaction',
                                                                            style: TextStyle(
                                                                              color: Colors.red,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                      setState(() {
                                                                        categorizing =
                                                                            false;
                                                                      });

                                                                      break;
                                                                    }
                                                                }
                                                              }

                                                            default:
                                                              {
                                                                ScaffoldMessenger.of(
                                                                  context,
                                                                ).showSnackBar(
                                                                  SnackBar(
                                                                    content: Text(
                                                                      'Error occured',
                                                                      style: TextStyle(
                                                                        color: Colors
                                                                            .red,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                                setState(() {
                                                                  categorizing =
                                                                      false;
                                                                });
                                                                break;
                                                              }
                                                          }
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
                  return Scaffold(
                    body: LoadingOverlay(
                      isLoading:
                          snapshot.connectionState == ConnectionState.waiting
                          ? true
                          : false,
                      child: Text('loading'),
                    ),
                  );
                  // SafeArea(child: Center(child: CircularProgressIndicator()));
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    if (snapshot.requireData) {
                      return di<AuthModel>().authWidget;
                    } else {
                      return SafeArea(
                        child: Scaffold(
                          floatingActionButtonLocation: ExpandableFab.location,
                          floatingActionButton: ExpandableFab(
                            openButtonBuilder:
                                RotateFloatingActionButtonBuilder(
                                  child: const Icon(
                                    Icons.account_balance_wallet,
                                  ),
                                  fabSize: ExpandableFabSize.regular,
                                  shape: const CircleBorder(),
                                ),
                            children: [
                              FloatingActionButton.extended(
                                heroTag: 'transactions',
                                onPressed: () async {
                                  showDialog<void>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) {
                                      return Dialog.fullscreen(
                                        child: HandleBalance(),
                                      );
                                    },
                                  );
                                  // if (WidgetsBinding
                                  //         .instance
                                  //         .platformDispatcher
                                  //         .locale
                                  //         .countryCode ==
                                  //     'KE') {
                                  //   return showDialog<void>(
                                  //     context: context,
                                  //     barrierDismissible: false,
                                  //     builder: (context) {
                                  //       return AlertDialog(
                                  //         title: Text('Auto import on'),
                                  //         content: Text(
                                  //           'Transaction auto import is automatically enabled in your region.Be careful of transaction duplication on auto imported transactions',
                                  //         ),
                                  //         actions: [
                                  //           FilledButton(
                                  //             onPressed: () {
                                  //               Navigator.of(context).pop();
                                  //             },
                                  //             child: Text('Cancel'),
                                  //           ),
                                  //           FilledButton(
                                  //             onPressed: () {
                                  //               Navigator.of(context).pop();
                                  //               Navigator.push(
                                  //                 context,
                                  //                 MaterialPageRoute(
                                  //                   builder: (context) =>
                                  //                       const HandleBalance(),
                                  //                 ),
                                  //               );
                                  //             },
                                  //             child: Text('Continue'),
                                  //           ),
                                  //         ],
                                  //       );
                                  //     },
                                  //   );
                                  // } else {
                                  //   Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //       builder: (context) =>
                                  //           const HandleBalance(),
                                  //     ),
                                  //   );
                                  // }
                                },
                                label: Text('Add transaction'),
                                icon: Icon(Icons.add),
                              ),
                              FloatingActionButton.extended(
                                heroTag: 'savings',
                                onPressed: () async {
                                  showDialog<void>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) {
                                      return Dialog.fullscreen(
                                        child: HandleSavings(),
                                      );
                                    },
                                  );
                                },
                                label: Text('Record Savings'),
                                icon: Icon(Icons.add),
                              ),
                            ],
                          ),
                          appBar: AppBar(
                            actions: [
                              // IconButton(
                              //   onPressed: () {
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (context) => SettingsPage(),
                              //       ),
                              //     );
                              //   },
                              //   icon: Icon(Icons.settings),
                              // ),
                            ],

                            title: Text(
                              'Budgetlite',
                              style: GoogleFonts.robotoMono(
                                color: Colors.blue.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          bottomNavigationBar: NavigationBar(
                            onDestinationSelected: (int index) {
                              setState(() {
                                currentPageIndex = index;
                              });
                            },
                            indicatorColor: Color(0xFFE0F2FE),
                            selectedIndex: currentPageIndex,
                            destinations: <Widget>[
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
                                selectedIcon: Icon(Icons.analytics),
                                icon: Icon(Icons.analytics_outlined),
                                label: 'Reports',
                              ),

                              NavigationDestination(
                                selectedIcon: Icon(Icons.settings),
                                icon: Icon(Icons.settings_outlined),
                                label: 'Settings',
                              ),

                              // NavigationDestination(
                              //   selectedIcon: Icon(Icons.analytics),
                              //   icon: Icon(Icons.analytics_outlined),
                              //   label: 'Terms and Conditions',
                              // ),
                            ],
                          ),
                          body: ShowCaseWidget(
                            enableShowcase: di<AuthModel>().shouldShowCase,

                            globalTooltipActionConfig:
                                const TooltipActionConfig(
                                  position: TooltipActionPosition.inside,
                                  alignment: MainAxisAlignment.spaceBetween,
                                  actionGap: 20,
                                ),
                            globalTooltipActions: [
                              // Here we don't need previous action for the first showcase widget
                              // so we hide this action for the first showcase widget
                              TooltipActionButton(
                                type: TooltipDefaultActionType.previous,
                                textStyle: const TextStyle(color: Colors.white),
                                // onTap: ,
                                hideActionWidgetForShowcase: [
                                  AppGlobal.budgetOverview,
                                ],
                              ),
                              // Here we don't need next action for the last showcase widget so we
                              // hide this action for the last showcase widget
                              TooltipActionButton(
                                type: TooltipDefaultActionType.next,
                                textStyle: const TextStyle(color: Colors.white),
                                hideActionWidgetForShowcase: [
                                  AppGlobal.exportTransactions,
                                ],
                              ),
                            ],
                            builder: (context) => UpgradeAlert(
                              showIgnore: false,
                              onUpdate: bestItem != null
                                  ? () {
                                      try {
                                        if (bestItem!.fileURL != null) {
                                          setState(() {
                                            isUpdating = true;
                                          });
                                          log('isUpdating:$isUpdating');
                                          OtaUpdate()
                                              .execute(bestItem!.fileURL!)
                                              .listen(
                                                cancelOnError: true,
                                                (OtaEvent event) {
                                                  setState(() {
                                                    updateEvent = event;
                                                  });
                                                },
                                                onDone: () => setState(() {
                                                  isUpdating = false;
                                                }),
                                              );
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Error obtaining apk url',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Error occured updating app',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        );

                                        log('OtaUpdate error', error: e);
                                      }
                                      return true;
                                    }
                                  : null,
                              upgrader: upgrader,
                              child: <Widget>[
                                Dashboard(),
                                EnvelopesView(),
                                GoalsPage(),
                                ReportsScreen(),
                                SettingsPage(),
                                // TermsAndConditions(),
                                //WalletScreen(),
                                // SettingsPage(),
                              ][currentPageIndex],
                            ),
                          ),
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
