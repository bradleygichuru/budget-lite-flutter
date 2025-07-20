import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data_models/auth_data_model.dart';
import 'package:flutter_application_1/data_models/goal_data_model.dart';
import 'package:flutter_application_1/db/db.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class GoalModel extends ChangeNotifier {
  GoalModel() {
    initGoals();
  }
  Future<List<Goal>> goals = Future.value([]);
  List<String> knownGoalNames = [];
  void initGoals() async {
    final goals = await getGoals();
    if (goals.isNotEmpty) {
      for (Goal goal in goals) {
        knownGoalNames.add(goal.name);
      }
    }
    this.goals = Future.value(goals);
    notifyListeners();
  }

  void refreshGoals() async {
    final goals = await getGoals();
    if (goals.isNotEmpty) {
      for (Goal goal in goals) {
        knownGoalNames.add(goal.name);
      }
    }
    this.goals = Future.value(goals);
    notifyListeners();
  }

  Future<int> addCurrentAmount(Goal goal, double credit) async {
    final db = await getDb();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    double update = goal.currentAmount != null
        ? goal.currentAmount! + credit
        : credit;
    int count = await db.rawUpdate(
      'UPDATE goals SET current_amount = ? WHERE id = ?,account_id ',
      ['$update', '${goal.id}', '${await getAccountId()}'],
    );
    goals = getGoals();
    notifyListeners();
    return count;
  }

  Future<int> deductCurrentAmount(Goal goal, double amount) async {
    final db = await getDb();
    if (goal.currentAmount != 0 && amount <= goal.currentAmount!) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      double update = goal.currentAmount != null
          ? goal.currentAmount! + amount
          : amount;
      int count = await db.rawUpdate(
        'UPDATE goals SET current_amount = ? WHERE id = ?,account_id ',
        ['$update', '${goal.id}', '${await getAccountId()}'],
      );
      goals = getGoals();
      notifyListeners();
      return count;
    } else {
      throw GoalAmountError();
    }
  }

  Future<int?> insertGoal(Goal goal) async {
    var rowId;
    final db = await getDb();
    log("inserting goal ${goal.toString()}");
    await db.insert("goals", goal.toMap()).then((rwid) {
      rowId = rwid;
      goals = getGoals();
    });
    await db.rawUpdate('UPDATE goals SET account_id = ? WHERE id = ?', [
      '${await getAccountId()}',
      '$rowId',
    ]);

    notifyListeners();
    return rowId;
  }
}
