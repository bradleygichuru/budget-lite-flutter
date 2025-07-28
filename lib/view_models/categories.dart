import 'dart:developer';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data_models/categories_data_model.dart';
import 'package:flutter_application_1/data_models/transactions.dart';
import 'package:flutter_application_1/db/db.dart';
import 'package:flutter_application_1/util/result_wraper.dart';
import 'package:flutter_application_1/view_models/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_it/watch_it.dart';

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

  Future<Result<String>> addBudgetResetDate(String date) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('budget_reset_date', date);

      String? x = prefs.getString('budget_reset_date');
      if (x != null) {
        return Result.ok(x);
      } else {
        return Result.error(Exception('Error setting budget reset date'));
      }
    } on Exception catch (e) {
      return Result.error(e);
    }
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
    AuthModel aM;
    if (!di.isRegistered<AuthModel>()) {
      aM = AuthModel();
    } else {
      aM = di<AuthModel>();
    }
    final db = await getDb();
    int count = await db.rawUpdate(
      'UPDATE categories SET budget = ? WHERE id = ? AND account_id = ?',
      ['$amount', '${category.id}', '${await aM.getAccountId()}'],
    );
    refreshCats();
    notifyListeners();

    return count;
  }

  Future<int> handleCategoryAdd(Category category) async {
    AuthModel aM;
    if (!di.isRegistered<AuthModel>()) {
      aM = AuthModel();
    } else {
      aM = di<AuthModel>();
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var rowId;
    final db = await getDb();
    int? acid = await aM.getAccountId();
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
      AuthModel aM;
      if (!di.isRegistered<AuthModel>()) {
        aM = AuthModel();
      } else {
        aM = di<AuthModel>();
      }
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
            ['$update', '${candidate.id},${await aM.getAccountId()}'],
          );

          refreshCats();
          notifyListeners();
          if (count > 0) {
            List<Category> newCats = await categories;
            Category candidate = newCats.firstWhere(
              (category) => category.categoryName == cat,
            );
            SharedPreferences prefs = await SharedPreferences.getInstance();
            AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: prefs.getInt('notification_id')!,
                displayOnForeground: true,
                channelKey: 'basic_channel',
                actionType: ActionType.Default,
                title: 'Budget Alert',
                body:
                    '${candidate.categoryName} ${((candidate.spent / candidate.budget) * 100)}% used',
              ),
            );

            prefs.setInt(
              'notification_id',
              prefs.getInt('notification_id')! + 1,
            );
          }

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

  Future<int> insertCategory(Category category) async {
    AuthModel aM;
    if (!di.isRegistered<AuthModel>()) {
      aM = AuthModel();
    } else {
      aM = di<AuthModel>();
    }
    final db = await getDb();
    int ctID = await db.insert("categories", category.toMap());
    await db.rawUpdate('UPDATE categories SET account_id = ? WHERE id = ?', [
      '${await aM.getAccountId()}',
      '$ctID',
    ]);

    refreshCats();
    notifyListeners();
    return ctID;
  }

  Future<List<Category>> getCategories() async {
    AuthModel aM;
    if (!di.isRegistered<AuthModel>()) {
      aM = AuthModel();
    } else {
      aM = di<AuthModel>();
    }
    final db = await getDb();
    final List<Map<String, Object?>> categoryMaps = await db.rawQuery(
      "SELECT * FROM categories WHERE account_id = ?",
      ['${await aM.getAccountId()}'],
    );
    log("found ${categoryMaps.length} categories");

    categoryMaps.forEach((cat) {
      log(
        Category(
          categoryName: cat['category_name'] as String,
          budget: cat['budget'] as double,
          spent: cat['spent'] as double,
          id: cat['id'] as int,
          accountId: cat['account_id'] as int,
        ).toString(),
      );
    });

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
    AuthModel aM;
    if (!di.isRegistered<AuthModel>()) {
      aM = AuthModel();
    } else {
      aM = di<AuthModel>();
    }
    final db = await getDb();
    List<int> rwIds = [];
    int? acId = await aM.getAccountId();
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

    refreshCats();
    notifyListeners();

    return rwIds;
  }
}
