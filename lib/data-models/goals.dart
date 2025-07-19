import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/db/db.dart';
import 'package:flutter_application_1/models/auth.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class Goal {
  final int? id;
  final String name;
  final double targetAmount;
  final String targetDate;
  final double? currentAmount;
  final int? accountId;
  Goal({
    this.id,
    required this.currentAmount,
    required this.name,
    required this.targetAmount,
    required this.targetDate,
    this.accountId,
  });

  Map<String, Object> toMap() {
    return {
      "id": ?id,
      "name": name,
      "target_amount": targetAmount,
      "target_date": targetDate,
      "current_amount": ?currentAmount,
      "account_id": ?accountId,
    };
  }

  @override
  String toString() {
    return 'Goal{id:$id,name:$name,target_amount:$targetAmount,target_date:$targetDate},current_mount:$currentAmount,account_id:$accountId';
  }
}

Future<void> insertGoal(Goal goal) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final db = await getDb();
  int goalId = await db.insert("goals", goal.toMap());
  await db.rawUpdate('UPDATE goals SET account_id = ? WHERE id = ? ', [
    '${getAccountId()}',
    '$goalId',
  ]);
}

Future<List<Goal>> getGoals() async {
  List<Goal> x = [];

  final db = await getDb();
  final List<Map<String, Object?>> goalMaps = await db.query('goals');

  log("found ${goalMaps.length} goals");
  // log(goalMaps.toString());
  for (var goal in goalMaps) {
    log(
      Goal(
        id: goal['id'] as int?,
        currentAmount: goal["current_amount"] as double?,
        name: goal['name'] as String,
        targetAmount: goal['target_amount'] as double,
        targetDate: goal['target_date'] as String,
        accountId: goal['account_id'] as int,
      ).toString(),
    );
  }
  return [
    for (final {
          'id': id as int?,
          'name': name as String,
          'target_amount': targetAmount as double,
          'target_date': targetDate as String,
          'current_amount': currentAmount as double?,
          'account_id': accountId as int,
        }
        in goalMaps)
      Goal(
        id: id,
        currentAmount: currentAmount,
        name: name,
        targetAmount: targetAmount,
        targetDate: targetDate,
        accountId: accountId,
      ),
  ];
}

class GoalModel extends ChangeNotifier {
  GoalModel() {
    initGoals();
  }
  Future<List<Goal>> goals = Future.value([]);
  List<String> knownGoalNames = [];
  void initGoals() async {
    final goals = await getGoals();
    if (goals.isNotEmpty) {
      goals.forEach((goal) => this.knownGoalNames.add(goal.name));
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
    notifyListeners();
    return rowId;
  }
}

class GoalAmountError implements Exception {}
