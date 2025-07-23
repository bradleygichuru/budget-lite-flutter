import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data_models/auth_data_model.dart';
import 'package:flutter_application_1/data_models/goal_data_model.dart';
import 'package:flutter_application_1/data_models/wallet_data_model.dart';
import 'package:flutter_application_1/db/db.dart';
import 'package:flutter_application_1/util/result_wraper.dart';
import 'package:flutter_application_1/view_models/auth.dart';
import 'package:flutter_application_1/view_models/wallet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_it/watch_it.dart';

class GoalModel extends ChangeNotifier {
  GoalModel() {
    initGoals();
  }
  Future<List<Goal>> goals = Future.value([]);
  List<String> knownGoalNames = [];
  void initGoals() async {
    final goals = await getGoals();
    if (goals.isNotEmpty) {
      List<String> x = [];
      for (Goal goal in goals) {
        x.add(goal.name);
      }
      knownGoalNames = x;
    }
    this.goals = Future.value(goals);
    notifyListeners();
  }

  void refreshGoals() async {
    final goals = await getGoals();
    if (goals.isNotEmpty) {
      List<String> x = [];
      for (Goal goal in goals) {
        x.add(goal.name);
      }

      knownGoalNames = x;
    }
    this.goals = Future.value(goals);
    notifyListeners();
  }

  Future<Result<int>> addCurrentAmount(String goalName, double credit) async {
    try {
      int? count;
      final db = await getDb();
      List<Goal> goalsN = await getGoals();
      double totalAllocatedToGoals = 0;
      for (final goal in goalsN) {
        totalAllocatedToGoals = totalAllocatedToGoals + goal.currentAmount;
      }

      Wallet? currentWallet = await GetIt.I
          .get<WalletModel>()
          .getAccountWallet();
      if (currentWallet != null) {
        if (currentWallet.savings > 0) {
          if (credit > (currentWallet.savings - totalAllocatedToGoals)) {
            return Result.error(ExceedsUnallocated());
          } else {
            Goal candidate = goalsN.firstWhere((goal) => goal.name == goalName);

            double update = candidate.currentAmount + credit;
            count = await db.rawUpdate(
              'UPDATE goals SET current_amount = ? WHERE id = ? AND account_id = ?',
              [
                '$update',
                '${candidate.id}',
                '${await GetIt.I.get<AuthModel>().getAccountId()}',
              ],
            );
            goals = getGoals();
            refreshGoals();
            notifyListeners();
            return Result.ok(count);
          }
        } else {
          return Result.error(NotEnoughSavingsException());
        }
      } else {
        return Result.error(AccountWalletNotFoundException());
      }
    } on Exception catch (e) {
      log('error occured adding ammount to goal', error: e);
      return Result.error(e);
    }
  }

  Future<Result<int>> deductCurrentAmount(
    String goalName,
    double amount,
  ) async {
    try {
      final db = await getDb();

      List<Goal> goalsN = await getGoals();
      Goal candidate = goalsN.firstWhere((goal) => goal.name == goalName);
      if (amount <= candidate.currentAmount) {
        double update = candidate.currentAmount - amount;
        int count = await db.rawUpdate(
          'UPDATE goals SET current_amount = ? WHERE id = ? AND account_id=? ',
          [
            '$update',
            '${candidate.id}',
            '${await GetIt.I.get<AuthModel>().getAccountId()}',
          ],
        );
        goals = getGoals();

        refreshGoals();
        notifyListeners();
        return Result.ok(count);
      } else {
        throw Result.error(GoalAmountError());
      }
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<List<Goal>> getGoals() async {
    List<Goal> x = [];

    final db = await getDb();
    final List<Map<String, Object?>> goalMaps = await db.rawQuery(
      'SELECT * FROM goals WHERE account_id = ?',
      ['${await GetIt.I.get<AuthModel>().getAccountId()}'],
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

  Future<int?> insertGoal(Goal goal) async {
    var rowId;
    final db = await getDb();
    log("inserting goal ${goal.toString()}");
    await db.insert("goals", goal.toMap()).then((rwid) {
      rowId = rwid;
      goals = getGoals();
    });
    await db.rawUpdate('UPDATE goals SET account_id = ? WHERE id = ?', [
      '${await GetIt.I.get<AuthModel>().getAccountId()}',
      '$rowId',
    ]);

    notifyListeners();
    return rowId;
  }
}
