import 'package:flutter_application_1/data_models/auth_data_model.dart';
import 'package:flutter_application_1/db/db.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

class Goal {
  final int? id;
  final String name;
  final double targetAmount;
  final String targetDate;
  final double currentAmount;
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
      "current_amount": currentAmount,
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
    '${await getAccountId()}',
    '$goalId',
  ]);
}

Future<List<Goal>> getGoals() async {
  List<Goal> x = [];

  final db = await getDb();
  final List<Map<String, Object?>> goalMaps = await db.rawQuery(
    'SELECT * FROM goals WHERE account_id = ?',
    ['${await getAccountId()}'],
  );

  log("found ${goalMaps.length} goals");
  // log(goalMaps.toString());
  for (var goal in goalMaps) {
    log(
      Goal(
        id: goal['id'] as int?,
        currentAmount: goal["current_amount"] as double,
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
          'current_amount': currentAmount as double,
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

class GoalAmountError implements Exception {}

class ExceedsUnallocated implements Exception {}
