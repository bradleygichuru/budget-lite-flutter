import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:another_telephony/telephony.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cron/cron.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data_models/categories_data_model.dart'
    as Ct;
import 'package:flutter_application_1/data_models/auth_data_model.dart';
import 'package:flutter_application_1/data_models/goal_data_model.dart';
import 'package:flutter_application_1/data_models/transactions.dart';
import 'package:flutter_application_1/db/db.dart';
import 'package:flutter_application_1/view_models/auth.dart';
import 'package:flutter_application_1/view_models/categories.dart';
import 'package:flutter_application_1/view_models/goals.dart';
import 'package:flutter_application_1/view_models/txs.dart';
import 'package:flutter_application_1/view_models/wallet.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const notificationChannelId = 'service_channel';

// this will be used for notification id, So you can update your custom notification with this id.
const notificationId = 888;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,
      autoStartOnBoot: true,

      // auto start service
      autoStart: true,
      isForegroundMode: false,
      notificationChannelId: 'service_channel',
      foregroundServiceNotificationId: 888,
      initialNotificationTitle: 'Budgetlite tx discovery service',
      initialNotificationContent: 'Initializing',
      foregroundServiceTypes: [AndroidForegroundType.dataSync],
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
  // final service = FlutterBackgroundService();
  //
  // const AndroidNotificationChannel channel = AndroidNotificationChannel(
  //   notificationChannelId, // id
  //   'Budgetlite tx discovery service', // title
  //   description:
  //       'This channel is used for important notifications.', // description
  //   importance: Importance.low, // importance must be at low or higher level
  // );
  //
  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //     FlutterLocalNotificationsPlugin();
  //
  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //       AndroidFlutterLocalNotificationsPlugin
  //     >()
  //     ?.createNotificationChannel(channel);
  //
  // await service.configure(
  //   androidConfiguration: AndroidConfiguration(
  //     // this will be executed when app is in foreground or background in separated isolate
  //     onStart: onStart,
  //
  //     autoStartOnBoot: true,
  //     // auto start service
  //     autoStart: true,
  //     isForegroundMode: true,
  //
  //     notificationChannelId:
  //         notificationChannelId, // this must match with notification channel you created above.
  //     initialNotificationTitle: 'AWESOME SERVICE',
  //     initialNotificationContent: 'Initializing',
  //     foregroundServiceNotificationId: notificationId,
  //   ),
  //   iosConfiguration: IosConfiguration(
  //     // auto start service
  //     autoStart: true,
  //
  //     // this will be executed when app is in foreground in separated isolate
  //     onForeground: onStart,
  //
  //     // you have to enable background fetch capability on xcode project
  //     onBackground: onIosBackground,
  //   ),
  // );
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  //DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  // DartPluginRegistrant.ensureInitialized();

  final telephony = Telephony.backgroundInstance;
  final cron = Cron();
  cron.schedule(Schedule.parse('0 8 * * *'), dailyBudgetAlert); //every day at 8
  cron.schedule(
    Schedule.parse('0 0 1 * *'),
    monthlyGoalAlerts,
  ); //every 1st of the month
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // String? resetDate = prefs.getString('budget_reset_date');

  // cron.schedule(Schedule.parse('* * * * *'), queueResetBudget);
  // if (resetDate != null) {
  //   cron.schedule(
  //     Schedule.parse('0 9 ${int.parse(resetDate)} * *'),
  //     queueResetBudget,
  //   );
  // }

  AwesomeNotifications().createNotification(
    content: NotificationContent(
      criticalAlert: false,
      autoDismissible: false,
      id: 888,
      channelKey: 'service_channel',
      actionType: ActionType.SilentBackgroundAction,
      title: 'Budgetlite tx discovery service',
      body: 'running',
      locked: true,
    ),
  );
  final bool? result = await telephony.requestPhoneAndSmsPermissions;

  if (result != null && result) {
    telephony.listenIncomingSms(
      onNewMessage: onMessage,
      onBackgroundMessage: backgroundMessageHandler,
    );
  }

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    AwesomeNotifications().dismiss(888);
    service.stopSelf();
  });

  // bring to foreground
  // Timer.periodic(const Duration(seconds: 1), (timer) async {
  //   if (service is AndroidServiceInstance) {
  //     if (await service.isForegroundService()) {}
  //   }
  //
  //   /// you can see this log in logcat
  //   // log('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');
  //
  //   // test using external plugin
  //
  //   service.invoke('update', {
  //     "current_date": DateTime.now().toIso8601String(),
  //     "device": Platform.operatingSystem,
  //   });
  // });
}

onMessage(SmsMessage message) async {
  try {
    TransactionsModel txM = TransactionsModel();
    WalletModel wM = WalletModel();
    AuthModel aM = AuthModel();
    String? currentRegion = aM.region;

    log('from:${message.address} message:${message.body}');
    log('tx parsing for region: $currentRegion');
    // if (message.address == '0123456789' && kDebugMode) {
    //   log('parsing mpesa tx message');
    //   var transaction = parseMpesa(message);
    //
    //   int? accountId = await aM.getAccountId();
    //   log('foreground_transaction:$transaction');
    //   if (transaction != null && accountId != null) {
    //     if (transaction['type'] == TxType.credit.val) {
    //       TransactionObj tx = TransactionObj(
    //         desc: transaction['desc'],
    //         type: transaction['type'],
    //         source: transaction['source'],
    //         amount: transaction['amount'],
    //         date: transaction['date'],
    //         category: 'credit',
    //       );
    //       wM.creditDefaultWallet(tx);
    //     } else if (transaction['type'] == TxType.fromSaving.val) {
    //       TransactionObj tx = TransactionObj(
    //         desc: transaction['desc'],
    //         type: transaction['type'],
    //         category: 'credit',
    //         source: transaction['source'],
    //         amount: transaction['amount'],
    //         date: transaction['date'],
    //       );
    //       wM.removeFromSavings(tx);
    //     } else if (transaction['type'] == TxType.toSaving.val) {
    //       TransactionObj tx = TransactionObj(
    //         desc: transaction['desc'],
    //         type: transaction['type'],
    //         source: transaction['source'],
    //         category: 'savings',
    //         amount: transaction['amount'],
    //         date: transaction['date'],
    //       );
    //       wM.addToSavings(tx);
    //     } else {
    //       TransactionObj tx = TransactionObj(
    //         desc: transaction['desc'],
    //         type: transaction['type'],
    //         source: transaction['source'],
    //         amount: transaction['amount'],
    //         date: transaction['date'],
    //       );
    //       txM.insertTransaction(tx);
    //     }
    //   }
    // }
    if (message.address == 'MPESA') {
      log('parsing mpesa tx message');
      var transaction = parseMpesa(message);

      int? accountId = await aM.getAccountId();
      log('foreground_transaction:$transaction');
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
    if (message.address == 'Equity Bank') {
      log('parsing Equity tx message');
      var transaction = parseEquity(message);
      log('from:${message.address} message:${message.body}');
      if (transaction != null) {
        if (transaction['type'] == TxType.spend.val) {
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

@pragma('vm:entry-point')
backgroundMessageHandler(SmsMessage message) async {
  //Handle background message
  try {
    TransactionsModel txM = TransactionsModel();
    WalletModel wM = WalletModel();
    AuthModel aM = AuthModel();
    String? currentRegion = aM.region;

    int? accountId = await aM.getAccountId();
    log('from:${message.address} message:${message.body}');

    log('tx parsing for region: $currentRegion');
    // if (message.address == '0123456789' && kDebugMode) {
    //   log('parsing mpesa tx message in debug');
    //   var transaction = parseMpesa(message);
    //
    //   int? accountId = await aM.getAccountId();
    //   log('foreground_transaction:$transaction');
    //   if (transaction != null && accountId != null) {
    //     if (transaction['type'] == TxType.credit.val) {
    //       TransactionObj tx = TransactionObj(
    //         desc: transaction['desc'],
    //         type: transaction['type'],
    //         source: transaction['source'],
    //         amount: transaction['amount'],
    //         date: transaction['date'],
    //         category: 'credit',
    //       );
    //       wM.creditDefaultWallet(tx);
    //     } else if (transaction['type'] == TxType.fromSaving.val) {
    //       TransactionObj tx = TransactionObj(
    //         desc: transaction['desc'],
    //         type: transaction['type'],
    //         category: 'credit',
    //         source: transaction['source'],
    //         amount: transaction['amount'],
    //         date: transaction['date'],
    //       );
    //       wM.removeFromSavings(tx);
    //     } else if (transaction['type'] == TxType.toSaving.val) {
    //       TransactionObj tx = TransactionObj(
    //         desc: transaction['desc'],
    //         type: transaction['type'],
    //         source: transaction['source'],
    //         category: 'savings',
    //         amount: transaction['amount'],
    //         date: transaction['date'],
    //       );
    //       wM.addToSavings(tx);
    //     } else {
    //       TransactionObj tx = TransactionObj(
    //         desc: transaction['desc'],
    //         type: transaction['type'],
    //         source: transaction['source'],
    //         amount: transaction['amount'],
    //         date: transaction['date'],
    //       );
    //       txM.insertTransaction(tx);
    //     }
    //   }
    // }
    if (message.address == 'MPESA') {
      var transaction = parseMpesa(message);
      log('from:${message.address} message:${message.body}');

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
    if (message.address == 'NCBA_BANK') {
      var transaction = parseNCBA(message);
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
        } else if (transaction['type'] == TxType.spend.val) {
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

    if (message.address == 'Equity Bank') {
      var transaction = parseEquity(message);
      log('from:${message.address} message:${message.body}');
      if (transaction != null && accountId != null) {
        if (transaction['type'] == TxType.spend.val) {
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

Future<void> dailyBudgetAlert() async {
  String body = '';

  CategoriesModel ctM = CategoriesModel();
  List<Ct.Category> categories = await ctM.getCategories();
  for (final cat in categories) {
    if (body.isEmpty) {
      body = '${cat.categoryName} ${(cat.spent / cat.budget * 100)}% spent';
      print('New body:$body');
    } else {
      body =
          '$body, ${cat.categoryName} ${(cat.spent / cat.budget * 100)}% spent';

      print('New body:$body');
    }
  }
  if (body.isNotEmpty) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int notiId = prefs.getInt('notification_id')!;
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        notificationLayout: NotificationLayout.BigText,
        autoDismissible: false,
        id: notiId,
        channelKey: 'basic_channel',
        actionType: ActionType.Default,
        title: 'Daily budget report',
        body: body,
      ),
    );

    prefs.setInt('notification_id', notiId + 1);
  }
}

Future<void> queueResetBudget() async {
  final db = await getDb();
  print('Queueing reset');
  await db.rawUpdate('UPDATE accounts SET resetPending = 1 WHERE id = ?', [
    '${await AuthModel().getAccountId()}',
  ]);
}

Future<void> monthlyGoalAlerts() async {
  String body = '';

  GoalModel gM = GoalModel();
  List<Goal> goals = await gM.getGoals();
  for (final goal in goals) {
    if (body.isEmpty) {
      body =
          '${goal.name} ${(goal.currentAmount / goal.targetAmount * 100)}% achieved';
      print('New body:$body');
    } else {
      body =
          '$body, ${goal.name} ${(goal.currentAmount / goal.targetAmount * 100)}% achieved';

      print('New body:$body');
    }
  }
  if (body.isNotEmpty) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int notiId = prefs.getInt('notification_id')!;
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        notificationLayout: NotificationLayout.BigText,
        autoDismissible: false,
        id: notiId,
        channelKey: 'basic_channel',
        actionType: ActionType.Default,
        title: 'Monthly Goal report',
        body: body,
      ),
    );

    prefs.setInt('notification_id', notiId + 1);
  }
}
