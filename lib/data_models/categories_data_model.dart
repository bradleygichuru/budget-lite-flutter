import 'package:flutter_application_1/data_models/auth_data_model.dart';
import 'package:flutter_application_1/db/db.dart';
import 'dart:developer';

class CategoryWithClickState extends Category {
  bool clicked = false;
  CategoryWithClickState({
    required this.clicked,
    required super.categoryName,
    required super.budget,
    required super.spent,
    required super.accountId,
    super.id,
  });
}

class Category {
  final int? id;
  final String categoryName;
  final double budget;
  final double spent;
  final int? accountId;

  Category({
    this.id,
    required this.categoryName,
    required this.budget,
    required this.spent,
    this.accountId,
  });

  Map<String, Object> toMap() {
    return {
      "id": ?id,
      "category_name": categoryName,
      "budget": budget,
      "spent": spent,
      'account_id': ?accountId,
    };
  }

  @override
  String toString() {
    return "Category{id:$id,category_name:$categoryName,budget:$budget,spent:$spent.account_id:$accountId}";
  }
}

class CategoryNotFoundError implements Exception {
  String errMsg() => "Category not found";
}
