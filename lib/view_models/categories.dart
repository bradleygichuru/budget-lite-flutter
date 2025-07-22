import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data_models/auth_data_model.dart';
import 'package:flutter_application_1/data_models/categories_data_model.dart';
import 'package:flutter_application_1/data_models/transactions.dart';
import 'package:flutter_application_1/db/db.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoriesModel extends ChangeNotifier {
  CategoriesModel() {
    initCategories();
  }
  List<String> knownCategoryEntries = [];
  Future<List<Category>> categories = Future.value([]);

  Future<void> initCategories() async {
    final categoriesRet = await getCategories();

    if (categoriesRet.isNotEmpty) {
      List<String> newList = [];
      categoriesRet.forEach((cat) => newList.add(cat.categoryName));
      knownCategoryEntries = newList;
      categories = Future.value(categoriesRet);
    }

    notifyListeners();
  }

  void refreshCats() async {
    final categoriesRet = await getCategories();

    if (categoriesRet.isNotEmpty) {
      List<String> newList = [];
      categoriesRet.forEach((cat) => newList.add(cat.categoryName));
      knownCategoryEntries = newList;
      categories = Future.value(categoriesRet);
    }
    notifyListeners();
  }

  Future<int> editCategoryBudget(Category category, double amount) async {
    final db = await getDb();
    int count = await db.rawUpdate(
      'UPDATE categories SET budget = ? WHERE id = ? AND account_id = ?',
      ['$amount', '${category.id}', '${await getAccountId()}'],
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

  Future<int?> handleCatBalanceCompute(String cat, TransactionObj tx) async {
    try {
      int? count;
      List<Category> cts = await categories;
      Category? candidate = cts.firstWhere(
        (category) => category.categoryName == cat,
      );
      if (candidate != null) {
        if (tx.type == TxType.spend.val) {
          log('deducting from category ${candidate.toString()}');
          double update = candidate.spent + tx.amount;
          log('new spent: $update');
          final db = await getDb();

          count = await db.rawUpdate(
            'UPDATE categories SET spent = ? WHERE id = ? AND account_id = ?',
            ['$update', '${candidate.id},${await getAccountId()}'],
          );
          refreshCats();
          notifyListeners();
          return count;
        }
      } else {
        throw CategoryNotFoundError();
      }
      return count;
    } catch (e) {
      log('Error computing new spent :$e');
      rethrow;
    }
  }
}
