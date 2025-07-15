import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Goal {
  final int? id;
  final String name;
  final double targetAmount;
  final String targetDate;
  final double initialAmount;
  Goal({
    this.id,
    required this.initialAmount,
    required this.name,
    required this.targetAmount,
    required this.targetDate,
  });

  Map<String, Object> toMap() {
    return {
      "id": ?id,
      "name": name,
      "target_amount": targetAmount,
      "target_date": targetDate,
      "initial_amount": initialAmount,
    };
  }

  @override
  String toString() {
    return 'Goal{id:$id,name:$name,target_amount:$targetAmount,target_date:$targetDate}';
  }
}

Future<void> insertGoal(Goal goal) async {
  final db = await openDatabase(
    join(await getDatabasesPath(), 'budget_lite_database.db'),
    version: 1,
  );
  await db.insert("goals", goal.toMap());
}

Future<List<Goal>> getGoals() async {
  List<Goal> x = [];

  final db = await openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'budget_lite_database.db'),

    // When the database is first created, create a table to store dogs.
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );
  final List<Map<String, Object?>> goalMaps = await db.query('goals');

  log("found ${goalMaps.length} goals");
  if (goalMaps.isNotEmpty) {
    for (final {
          'id': id as int,
          'name': name as String,
          'targetAmount': targetAmount as double,
          'targetDate': targetDate as String,
          'initial_amount': initialAmount as double,
        }
        in goalMaps) {
      x.add(
        Goal(
          id: id,
          initialAmount: initialAmount,
          name: name,
          targetAmount: targetAmount,
          targetDate: targetDate,
        ),
      );
    }
  }
  return x;
}

class GoalModel extends ChangeNotifier {
  GoalModel() {
    initGoals();
  }
  Future<List<Goal>> goals = Future.value([]);
  void initGoals() {
    goals = getGoals();
  }

  Future<int?> insertGoal(Goal goal) async {
    var rowId;
    final db = await openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'budget_lite_database.db'),

      // When the database is first created, create a table to store dogs.
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
    log("inserting goal");
    await db.insert("goals", goal.toMap()).then((rwid) {
      rowId = rwid;
      goals = getGoals();
    });
    notifyListeners();
    return rowId;
  }
}
