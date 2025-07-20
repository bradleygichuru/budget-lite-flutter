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

  handleCatBalanceCompute(String cat, TransactionObj tx) async {
    double update = 0;
    List<Category> cts = await categories;
    Category candidate = cts.firstWhere(
      (category) => category.categoryName == cat,
    );
    if (tx.type == TxType.spend.val) {
      update = candidate.spent + tx.amount;
    }

    final db = await getDb();

    int count = await db.rawUpdate(
      'UPDATE categories SET spent = ? WHERE id = ? AND account_id = ?',
      ['$update', '${candidate.id},${await getAccountId()}'],
    );
    refreshCats();
    notifyListeners();
    return count;
  }
}
