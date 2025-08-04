import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class AppGlobal {
  AppGlobal._();
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
