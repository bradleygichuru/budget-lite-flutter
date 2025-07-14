import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data-models/transactions.dart';
import 'package:path/path.dart';
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

  void refreshTx() {
    categories = getCategories();
    notifyListeners();
  }

  Future<int> handleCategoryAdd(Category category) async {
    var rowId;
    await insertCategory(category).then((rowID) {
      categories = getCategories();
      rowId = rowID;
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

    int count = await db.rawUpdate(
      'UPDATE categories SET spent = ? WHERE id = ?',
      ['$update', '${candidate.id}'],
    );
    refreshTx();
    notifyListeners();
    return count;
  }
}

class Category {
  final int? id;
  final String categoryName;
  final double budget;
  final double spent;

  Category({
    this.id,
    required this.categoryName,
    required this.budget,
    required this.spent,
  });

  Map<String, Object> toMap() {
    return {
      "id": ?id,
      "category_name": categoryName,
      "budget": budget,
      "spent": spent,
    };
  }

  @override
  String toString() {
    return "Category{id:$id,category_name:$categoryName,budget:$budget,spent:$spent}";
  }
}

Future<int> insertCategory(Category category) async {
  final db = await openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'budget_lite_database.db'),
    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      return db.execute(
        'CREATE TABLE transactions(id INTEGER PRIMARY KEY, type TEXT,source TEXT, amount REAL,date TEXT)',
      );
    },

    // When the database is first created, create a table to store dogs.
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );
  return await db.insert("categories", category.toMap());
}

Future<List<Category>> getCategories() async {
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
  final List<Map<String, Object?>> categoryMaps = await db.query("categories");
  log("found ${categoryMaps.length} categories");
  return [
    for (final {
          "id": id as int,
          "category_name": categoryName as String,
          "budget": budget as double,
          "spent": spent as double,
        }
        in categoryMaps)
      Category(
        categoryName: categoryName,
        budget: budget,
        spent: spent,
        id: id,
      ),
  ];
}

insertCategories(List<Category> categories) async {
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
  List<int> rwIds = [];
  await db.transaction((tx) async {
    for (Category cat in categories) {
      var rwid = await tx.insert("categories", cat.toMap());
      rwIds.add(rwid);
    }
  });
  return rwIds;
}
