import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data_models/auth_data_model.dart';
import 'package:flutter_application_1/data_models/goal_data_model.dart';
import 'package:flutter_application_1/data_models/wallet_data_model.dart';
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

  Future<int?> addCurrentAmount(String goalName, double credit) async {
    try {
      final db = await getDb();
      List<Goal> goalsN = await getGoals();
      double totalAllocatedToGoals = 0;
      for (final goal in goalsN) {
        totalAllocatedToGoals = totalAllocatedToGoals + goal.currentAmount;
      }

      Wallet? currentWallet = await getAccountWallet();
      if (currentWallet != null) {
        if (currentWallet.savings > 0) {
          if (credit > (currentWallet.savings - totalAllocatedToGoals)) {
            throw ExceedsUnallocated();
          } else {
            Goal candidate = goalsN.firstWhere((goal) => goal.name == goalName);

            double update = candidate.currentAmount + credit;
            int count = await db.rawUpdate(
              'UPDATE goals SET current_amount = ? WHERE id = ? AND account_id ',
              ['$update', '${candidate.id}', '${await getAccountId()}'],
            );
            goals = getGoals();
            notifyListeners();
            return count;
          }
        } else {
          throw NotEnoughSavingsException();
        }
      } else {
        throw AccountWalletNotFoundException();
      }
    } catch (e) {
      log('Error adding to goal:$e');
    }
  }

  Future<int> deductCurrentAmount(String goalName, double amount) async {
    final db = await getDb();

    List<Goal> goalsN = await getGoals();
    Goal candidate = goalsN.firstWhere((goal) => goal.name == goalName);
    if (amount <= candidate.currentAmount) {
      double update = candidate.currentAmount - amount;
      int count = await db.rawUpdate(
        'UPDATE goals SET current_amount = ? WHERE id = ? AND account_id ',
        ['$update', '${candidate.id}', '${await getAccountId()}'],
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
