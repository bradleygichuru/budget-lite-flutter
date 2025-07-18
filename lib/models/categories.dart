import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data-models/transactions.dart';
import 'package:flutter_application_1/db/db.dart';
import 'package:flutter_application_1/models/auth.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class CategoriesModel extends ChangeNotifier {
  CategoriesModel() {
    initCategories();
  }
  List<String> knownCategoryEntries = [];
  Future<List<Category>> categories = Future.value([]);

  Future<void> initCategories() async {
    final categoriesRet = await getCategories();

    if (categoriesRet.isEmpty) {
      categories = Future.value([]);
    } else {
      List<String> newList = [];
      categoriesRet.forEach((cat) => newList.add(cat.categoryName));
      knownCategoryEntries = newList;
      categories = Future.value(categoriesRet);
    }
    notifyListeners();
  }

  void refreshCats() {
    categories = getCategories();
    notifyListeners();
  }

  Future<int> editCategoryBudget(Category category, double amount) async {
    final db = await getDb();
    int count = await db.rawUpdate(
      'UPDATE categories SET budget = ? WHERE id = ? AND account_id = ?',
      ['$amount', '${category.id}', '${getAccountId()}'],
    );
    refreshCats();
    notifyListeners();

    return count;
  }

  Future<int> handleCategoryAdd(Category category) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var rowId;
    final db = await getDb();
    int? acid = await getAccountId();
    await insertCategory(category).then((rowID) {
      rowId = rowID;
      db.rawUpdate('UPDATE categories SET account_id = ? WHERE id = ?', [
        '$acid',
        '$rowID',
      ]);
      categories = getCategories();
    });
    notifyListeners();
    return rowId;
  }

  handleCatBalanceCompute(String cat, TransactionObj tx) async {
    double update = 0;
    List<Category> cts = await categories;
    Category candidate = cts.firstWhere(
      (category) => category.categoryName == cat,
    );
    if (tx.type == "spend") {
      update = candidate.spent + tx.amount;
    }

    final db = await getDb();

    int count = await db.rawUpdate(
      'UPDATE categories SET spent = ? WHERE id = ? AND account_id = ?',
      ['$update', '${candidate.id},${getAccountId()}'],
    );
    refreshCats();
    notifyListeners();
    return count;
  }
}

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

Future<int> insertCategory(Category category) async {
  final db = await getDb();
  int ctID = await db.insert("categories", category.toMap());
  await db.rawUpdate('UPDATE categories SET account_id = ? WHERE id = ?', [
    '${getAccountId()}',
    '$ctID',
  ]);
  return ctID;
}

Future<List<Category>> getCategories() async {
  final db = await getDb();
  final List<Map<String, Object?>> categoryMaps = await db.rawQuery(
    "SELECT * FROM categories WHERE account_id = ?",
    ['${getAccountId()}'],
  );
  log("found ${categoryMaps.length} categories");
  return [
    for (final {
          "id": id as int,
          "category_name": categoryName as String,
          "budget": budget as double,
          "spent": spent as double,
          'account_id': accountId as int,
        }
        in categoryMaps)
      Category(
        categoryName: categoryName,
        budget: budget,
        spent: spent,
        id: id,
        accountId: accountId,
      ),
  ];
}

Future<List<int>> insertCategories(List<Category> categories) async {
  final db = await getDb();
  List<int> rwIds = [];
  int? acId = await getAccountId();
  await db
      .transaction((tx) async {
        for (Category cat in categories) {
          var rwid = await tx.insert("categories", cat.toMap());
          rwIds.add(rwid);
        }
      })
      .whenComplete(() async {
        await db.transaction((tx) async {
          for (int id in rwIds) {
            // var rwid = await tx.("categories", cat.toMap());
            await tx.rawUpdate(
              'UPDATE categories SET account_id = ? WHERE id = ?',
              ['$acId', '$id'],
            );
          }
        });
      });

  return rwIds;
}
