import 'package:flutter_application_1/db/db.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqlite_api.dart';

class WeeklyReport {
  WeeklyReport({
    this.id,
    required this.fromDate,
    required this.toDate,
    required this.reportData,
    this.accountId,
  });

  final int? id;
  final String fromDate;
  final String toDate;
  final String reportData;
  final int? accountId;

  Map<String, Object> toMap() {
    return {
      'account_id': ?accountId,
      'report_data': reportData,
      'to_date': toDate,
      'from_date': fromDate,
      'id': ?id,
    };
  }
}

insertWeeklyReport(WeeklyReport wk) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? accountId = prefs.getInt("budget_lite_current_account_id");
  final db = await DatabaseHelper().database;
  var res = await db.query(
    'weekly_reports',
    where: 'from_date = ? AND to_date = ?',
    whereArgs: [wk.fromDate, wk.toDate],
  );
  bool exists = res.isNotEmpty;
  if (!exists) {
    await db.transaction((txn) async {
      int wkID = await txn.insert('weekly_reports', wk.toMap());
      await txn.update(
        'weekly_reports',
        {'account_id': accountId},
        where: 'id = ?',
        whereArgs: [wkID],
      );
    });
  } else {}
}
