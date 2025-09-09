import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class AppGlobal {
  AppGlobal._();

  static GlobalKey resetBudgetEnvelope = GlobalKey();
  static GlobalKey addBudgetEnvelope = GlobalKey();
  static GlobalKey budgetOverview = GlobalKey();
  static GlobalKey parseMessage = GlobalKey();
  static GlobalKey manuallyAddTransaction = GlobalKey();
  static GlobalKey recentTransactions = GlobalKey();
  static GlobalKey addFinancialGoals = GlobalKey();

  static GlobalKey exportTransactions = GlobalKey();

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
