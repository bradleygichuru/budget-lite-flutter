import 'dart:developer';

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
    required this.key,
  });
  final String key;
  final int? id;
  final String fromDate;
  final String toDate;
  final String reportData;
  final int? accountId;

  Map<String, Object> toMap() {
    return {
      'key': key,
      'account_id': ?accountId,
      'report_data': reportData,
      'to_date': toDate,
      'from_date': fromDate,
      'id': ?id,
    };
  }

  @override
  String toString() {
    // TODO: implement toString
    return 'WeeklyReport{id:$id,report_data:$reportData,account_id:$accountId,from_date:$fromDate,to_date:$toDate,key:$key}';
  }
}

insertWeeklyReport(WeeklyReport wk, Transaction txn) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? accountId = prefs.getInt("budget_lite_current_account_id");
    log('inserting weeklyreport for account_id:$accountId');
    List<Map<String, Object?>> res = await txn.query(
      'weekly_reports',
      where: 'from_date = ? AND to_date = ? AND account_id = ?',
      whereArgs: [wk.fromDate, wk.toDate, accountId],
    );
    bool exists = res.isNotEmpty;
    if (!exists) {
      log('Not duplicate report');
      int wkID = await txn.insert('weekly_reports', wk.toMap());
      await txn.update(
        'weekly_reports',
        {'account_id': accountId},
        where: 'id = ?',
        whereArgs: [wkID],
      );
    } else if (exists && (res.first['report_data'] != wk.reportData)) {
      await txn.update(
        'weekly_reports',
        {'report_data': wk.reportData},
        where: 'from_date = ? AND to_date = ? AND account_id = ?',
        whereArgs: [wk.fromDate, wk.toDate, accountId],
      );
      log('Weekly report already exists');
    }
  } catch (e) {
    log('Error occurred inserting Weekly report', error: e);
  }
}
