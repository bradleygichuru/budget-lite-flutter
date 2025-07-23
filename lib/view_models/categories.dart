import 'dart:developer';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data_models/categories_data_model.dart';
import 'package:flutter_application_1/data_models/transactions.dart';
import 'package:flutter_application_1/db/db.dart';
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
      [
        '$amount',
        '${category.id}',
        '${await di.get<AuthModel>().getAccountId()}',
      ],
    );
    refreshCats();
    notifyListeners();

    return count;
  }

  void categoryScheduleNotification(String name, bool isForeground) async {
    List<Category> candidates = await categories;
    Category candidate = candidates.firstWhere(
      (cat) => cat.categoryName == name,
    );
    String localTimeZone = await AwesomeNotifications()
        .getLocalTimeZoneIdentifier();
    String utcTimeZone = await AwesomeNotifications()
        .getLocalTimeZoneIdentifier();

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'basic_channel',
        wakeUpScreen: true,
        category: NotificationCategory.Alarm,
        actionType: ActionType.Default,
        title: 'Budget Alert',
        body:
            '${candidate.categoryName} Budget is ${((candidate.spent / candidate.budget) * 100).toStringAsFixed(1)}% spent',
      ),

      schedule: NotificationInterval(
        interval: Duration(days: 1),
        timeZone: localTimeZone,
        repeats: true,
      ),
    );
  }

  void categoryUpdateNotification(String name, bool isForeground) async {
    List<Category> candidates = await categories;
    Category candidate = candidates.firstWhere(
      (cat) => cat.categoryName == name,
    );

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'basic_channel',
        actionType: ActionType.Default,
        title: 'Budget Alert',
        body:
            '${candidate.categoryName} Budget is ${((candidate.spent / candidate.budget) * 100).toStringAsFixed(1)}% spent',
      ),
    );
  }

  Future<int> handleCategoryAdd(Category category) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var rowId;
    final db = await getDb();
    int? acid = await di.get<AuthModel>().getAccountId();
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
            [
              '$update',
              '${candidate.id},${await di.get<AuthModel>().getAccountId()}',
            ],
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

  Future<int> insertCategory(Category category) async {
    final db = await getDb();
    int ctID = await db.insert("categories", category.toMap());
    await db.rawUpdate('UPDATE categories SET account_id = ? WHERE id = ?', [
      '${await di.get<AuthModel>().getAccountId()}',
      '$ctID',
    ]);

    refreshCats();
    notifyListeners();
    return ctID;
  }

  Future<List<Category>> getCategories() async {
    final db = await getDb();
    final List<Map<String, Object?>> categoryMaps = await db.rawQuery(
      "SELECT * FROM categories WHERE account_id = ?",
      ['${await di.get<AuthModel>().getAccountId()}'],
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
    final db = await getDb();
    List<int> rwIds = [];
    int? acId = await di.get<AuthModel>().getAccountId();
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
