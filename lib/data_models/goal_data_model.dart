import 'package:flutter_application_1/data_models/auth_data_model.dart';
import 'package:flutter_application_1/db/db.dart';
import 'package:flutter_application_1/view_models/auth.dart';
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

class GoalAmountError implements Exception {}

class ExceedsUnallocated implements Exception {}
