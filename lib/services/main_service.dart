import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:another_telephony/telephony.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cron/cron.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data_models/categories_data_model.dart'
    as Ct;
import 'package:flutter_application_1/data_models/auth_data_model.dart';
import 'package:flutter_application_1/data_models/goal_data_model.dart';
import 'package:flutter_application_1/data_models/txs_data_model.dart';
import 'package:flutter_application_1/db/db.dart';
import 'package:flutter_application_1/view_models/auth.dart';
import 'package:flutter_application_1/view_models/categories.dart';
import 'package:flutter_application_1/view_models/goals.dart';
import 'package:flutter_application_1/view_models/txs.dart';
import 'package:flutter_application_1/view_models/wallet.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

const notificationChannelId = 'service_channel';

// this will be used for notification id, So you can update your custom notification with this id.
const notificationId = 888;

Future<void> requestNotificationPermissions() async {
  AwesomeNotifications().isNotificationAllowed();
  final permission = await AwesomeNotifications().isNotificationAllowed();

  // SharedPreferences prefs = await SharedPreferences.getInstance();

  if (!permission) {
    log("sms permissions: false");
    var status = await AwesomeNotifications()
        .requestPermissionToSendNotifications();
    if (status) {}
  }
  if (permission) {
    log("sms permissions: true");
  }
}

Future<void> requestListeningPermissions() async {
  final permission = Permission.sms;
  // SharedPreferences prefs = await SharedPreferences.getInstance();

  if (await permission.isDenied) {
    log("sms permissions: false");
    // var status = await permission.request();

    await Telephony.instance.requestPhoneAndSmsPermissions;
    // if (status.isGranted) {}
  }
  if (await permission.isGranted) {
    log("sms permissions: true");
  }
}

Future<void> initializeService() async {
  // await calculateWeekInsights();
  // await requestNotificationPermissions();
  // await requestListeningPermissions();
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,
      autoStartOnBoot: true,

      // auto start service
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'service_channel',
      foregroundServiceNotificationId: 888,
      initialNotificationTitle: 'Budgetlite tx discovery service',
      // initialNotificationContent: 'Initializing',
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
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  //DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

void stopBackgroundService() {
  final service = FlutterBackgroundService();
  service.invoke("stop");

  AwesomeNotifications().dismiss(888);
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  // DartPluginRegistrant.ensureInitialized();

  final cron = Cron();
  // 0 8 * * *
  cron.schedule(Schedule.parse('0 0 * * 0'), calculateWeekInsights);
  cron.schedule(Schedule.parse('0 0 1 * *'), resetBudgets);
  cron.schedule(Schedule.parse('0 8 * * *'), dailyBudgetAlert); //every day at 8

  cron.schedule(
    Schedule.parse('0 8 * * *'),
    notifyShouldCategorize,
  ); //every day at 8
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

  // AwesomeNotifications().createNotification(
  //   content: NotificationContent(
  //     criticalAlert: false,
  //     autoDismissible: false,
  //     id: 888,
  //     channelKey: 'service_channel',
  //     actionType: ActionType.SilentBackgroundAction,
  //     title: 'Budgetlite tx discovery service',
  //     body: 'running',
  //     locked: true,
  //   ),
  // );

  // if (result != null && result) {
  //   telephony.listenIncomingSms(
  //     onNewMessage: onMessageForegroundBGH,
  //     onBackgroundMessage: backgroundMessageHandler,
  //   );
  // }

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

  Timer.periodic(kDebugMode ? Duration(minutes: 2) : Duration(hours: 1), (
    timer,
  ) async {
    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    bool isNewUser = await prefs.getBool("isNewUser") ?? true;
    bool autoImport = await prefs.getBool('auto_import') ?? false;
    debugPrint('Is new user:$isNewUser');
    int? acid = await prefs.getInt("budget_lite_current_account_id");
    debugPrint('acid:$acid');
    final smsPerms = Permission.sms;
    if (acid != null && !isNewUser && await smsPerms.isGranted && autoImport) {
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          criticalAlert: false,
          autoDismissible: false,
          id: 999,
          channelKey: 'service_channel',
          actionType: ActionType.SilentBackgroundAction,
          title: 'Retrieving transactions',
          body: 'running',
          locked: true,
        ),
      );
      // debugPrint('Running tx discovery');
      // queryMpesa();

      // queryNcba();
      // queryEquity();
      AwesomeNotifications().dismiss(999);
    } else {
      if (kDebugMode) {
        debugPrint(
          'Discovery run skipped ,sms_perm:${await smsPerms.isGranted} ,account_id:$acid ,is_new_user:$isNewUser',
        );
      }
      log(
        'Discovery run skipped ,sms_perm:${await smsPerms.isGranted} ,account_id:$acid ,is_new_user:$isNewUser',
      );
    }
  });
}

Future<void> notifyShouldCategorize() async {
  SharedPreferencesAsync prefs = SharedPreferencesAsync();

  int? acid = await prefs.getInt("budget_lite_current_account_id");
  final db = await DatabaseHelper().database;
  // final List<Map<String, Object?>> transactionMaps = await db.rawQuery(
  //   "SELECT * from transactions WHERE category is null AND account_id = ?",
  //   ['${await aM.getAccountId()}'],
  // );

  final List<Map<String, Object?>> transactionMaps = await db.query(
    'transactions',
    where: 'category is null AND account_id = ?',
    whereArgs: [acid],
    orderBy: 'DATE(date) DESC',
  );
  if (transactionMaps.isNotEmpty) {
    int? notiId = await prefs.getInt('notification_id')!;
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        notificationLayout: NotificationLayout.BigText,
        autoDismissible: false,
        id: notiId!,
        channelKey: 'basic_channel',
        actionType: ActionType.Default,
        title: 'Uncategorized transactions',
        body: 'Hey,you forgot to categorize some transactions',
      ),
    );

    await prefs.setInt('notification_id', notiId + 1);
  }
}

Future<void> dailyBudgetAlert() async {
  String body = '';

  CategoriesModel ctM = CategoriesModel();
  List<Ct.Category> categories = await ctM.getCategories();
  for (final cat in categories) {
    if (body.isEmpty) {
      body = '${cat.categoryName} ${(cat.spent / cat.budget * 100)}% spent';
      // print('New body:$body');
    } else {
      body =
          '$body, ${cat.categoryName} ${(cat.spent / cat.budget * 100)}% spent';

      // print('New body:$body');
    }
  }
  if (body.isNotEmpty) {
    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    int? notiId = await prefs.getInt('notification_id')!;
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        notificationLayout: NotificationLayout.BigText,
        autoDismissible: false,
        id: notiId!,
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
  final db = await DatabaseHelper().database;
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
    SharedPreferencesAsync prefs = SharedPreferencesAsync();
    int? notiId = await prefs.getInt('notification_id')!;
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        notificationLayout: NotificationLayout.BigText,
        autoDismissible: false,
        id: notiId!,
        channelKey: 'basic_channel',
        actionType: ActionType.Default,
        title: 'Monthly Goal report',
        body: body,
      ),
    );

    prefs.setInt('notification_id', notiId + 1);
  }
}

Future<void> resetBudgets() async {
  try {
    SharedPreferencesAsync prefs = SharedPreferencesAsync();

    int? acid = await prefs.getInt("budget_lite_current_account_id");
    if (acid != null) {
      final db = await DatabaseHelper().database;
      final List<Map<String, Object?>> categoryMaps = await db.rawQuery(
        "SELECT * FROM categories WHERE account_id = ?",
        ['$acid'],
      );
      if (categoryMaps.isNotEmpty) {
        db.transaction((txn) async {
          for (final cat in categoryMaps) {
            await txn.rawUpdate(
              'UPDATE categories SET spent = 0 WHERE category_name = ? AND account_id = ?',
              [cat['category_name'], acid],
            );
          }
        });
      }
    }
  } on Exception catch (e) {
    log('Error reseting budget', error: e);
  }
}

Future<List<Ct.Category>> getCategories() async {
  SharedPreferencesAsync prefs = SharedPreferencesAsync();

  int? acid = await prefs.getInt("budget_lite_current_account_id");
  final db = await DatabaseHelper().database;
  final List<Map<String, Object?>> categoryMaps = await db.rawQuery(
    "SELECT * FROM categories WHERE account_id = ?",
    ['$acid'],
  );
  log("found ${categoryMaps.length} categories");

  return [
    for (final {
          "id": id as int,
          "category_name": categoryName as String,
          "budget": budget as double,
          "spent": spent as double,
          'account_id': accountId as int,
        }
        in categoryMaps)
      Ct.Category(
        categoryName: categoryName,
        budget: budget,
        spent: spent,
        id: id,
        accountId: accountId,
      ),
  ];
}
