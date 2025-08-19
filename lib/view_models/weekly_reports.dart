import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/data_models/weekly_reports_data_model.dart';
import 'package:flutter_application_1/db/db.dart';
import 'package:flutter_application_1/view_models/auth.dart';
import 'package:intl/intl.dart';
import 'package:watch_it/watch_it.dart';

class WeeklyReportsModel extends ChangeNotifier {
  WeeklyReportsModel() {
    initWeeklyReports();
  }
  List<WeeklyReport> currentReports = [];
  List<String> weeks = [];
  String firstDropDownValue = '';

  Future<void> refresh() async {
    // DateTime today = DateTime.now();
    // DateTime startOfCurrentWeek = today.subtract(Duration(days: today.weekday));
    // DateTime startOfCurrentWeekMidnight = DateTime(
    //   startOfCurrentWeek.year,
    //   startOfCurrentWeek.month,
    //   startOfCurrentWeek.day,
    // );
    // // Subtract 7 days to get the start of last week
    // DateTime startOfLastWeek = startOfCurrentWeek.subtract(Duration(days: 7));
    // DateTime startOfLastWeekMidnight = DateTime(
    //   startOfLastWeek.year,
    //   startOfLastWeek.month,
    //   startOfLastWeek.day,
    // );
    final db = await DatabaseHelper().database;
    List<Map<String, dynamic>> weeklyCurReports = await db.query(
      'weekly_reports',
      where: 'account_id = ?',
      whereArgs: [await di<AuthModel>().getAccountId()],
      orderBy: 'DATE(from_date) DESC',
    );
    log('Current reports found:${weeklyCurReports.length}');
    if (weeklyCurReports.isNotEmpty) {
      for (final x in weeklyCurReports) {
        log('Report:${x.toString()}');
      }
    }
    List<WeeklyReport> x = [];

    if (weeklyCurReports.isNotEmpty) {
      for (final report in weeklyCurReports) {
        x.add(
          WeeklyReport(
            key:
                '${DateTime.parse(report['from_date']).day} ${DateFormat('MMM').format(DateTime.parse(report['from_date']))} - ${DateTime.parse(report['to_date']).day} ${DateFormat('MMM').format(DateTime.parse(report['to_date']))}',
            fromDate: report['from_date'],
            toDate: report['to_date'],
            reportData: report['report_data'],
            id: report['id'],
            accountId: report['account_id'],
          ),
        );
      }
    }
    if (x.isNotEmpty) {
      List<String> z = [];
      for (final y in x) {
        // log('Report:${y.toString()}');
        String dropdownTitle =
            '${DateTime.parse(y.fromDate).day} ${DateFormat('MMM').format(DateTime.parse(y.fromDate))} - ${DateTime.parse(y.toDate).day} ${DateFormat('MMM').format(DateTime.parse(y.toDate))}';
        z.add(dropdownTitle);
      }
      weeks = z;

      currentReports = x;
      firstDropDownValue = z.first;
    } else {
      weeks = [];
      currentReports = [];
      firstDropDownValue = '';
      log('Reports empty');
    }

    notifyListeners();
  }

  Future<void> initWeeklyReports() async {
    // DateTime today = DateTime.now();
    // DateTime startOfCurrentWeek = today.subtract(Duration(days: today.weekday));
    // DateTime startOfCurrentWeekMidnight = DateTime(
    //   startOfCurrentWeek.year,
    //   startOfCurrentWeek.month,
    //   startOfCurrentWeek.day,
    // );
    // // Subtract 7 days to get the start of last week
    // DateTime startOfLastWeek = startOfCurrentWeek.subtract(Duration(days: 7));
    // DateTime startOfLastWeekMidnight = DateTime(
    //   startOfLastWeek.year,
    //   startOfLastWeek.month,
    //   startOfLastWeek.day,
    // );
    final db = await DatabaseHelper().database;
    List<Map<String, dynamic>> weeklyCurReports = await db.query(
      'weekly_reports',
      where: 'account_id = ?',
      whereArgs: [await di<AuthModel>().getAccountId()],
      orderBy: 'DATE(from_date) DESC',
    );
    log('Current reports found:${weeklyCurReports.length}');
    if (weeklyCurReports.isNotEmpty) {
      for (final x in weeklyCurReports) {
        log('Report:${x.toString()}');
      }
    }
    List<WeeklyReport> x = [];

    if (weeklyCurReports.isNotEmpty) {
      for (final report in weeklyCurReports) {
        x.add(
          WeeklyReport(
            key:
                '${DateTime.parse(report['from_date']).day} ${DateFormat('MMM').format(DateTime.parse(report['from_date']))} - ${DateTime.parse(report['to_date']).day} ${DateFormat('MMM').format(DateTime.parse(report['to_date']))}',
            fromDate: report['from_date'],
            toDate: report['to_date'],
            reportData: report['report_data'],
            id: report['id'],
            accountId: report['account_id'],
          ),
        );
      }
    }
    if (x.isNotEmpty) {
      List<String> z = [];
      for (final y in x) {
        // log('Report:${y.toString()}');
        String dropdownTitle =
            '${DateTime.parse(y.fromDate).day} ${DateFormat('MMM').format(DateTime.parse(y.fromDate))} - ${DateTime.parse(y.toDate).day} ${DateFormat('MMM').format(DateTime.parse(y.toDate))}';
        z.add(dropdownTitle);
      }
      weeks = z;

      currentReports = x;

      firstDropDownValue = z.first;
    } else {
      weeks = [];
      currentReports = [];

      firstDropDownValue = '';
      log('Reports empty');
    }

    notifyListeners();
  }
}
