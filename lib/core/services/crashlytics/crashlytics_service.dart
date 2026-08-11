import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

abstract class CrashlyticsService{
  static void init(){
    FlutterError.onError = (FlutterErrorDetails errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    PlatformDispatcher.instance.onError = (Object error, StackTrace stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
      return true;
    };
  }

  static void recordError(dynamic exception, StackTrace stackTrace) {
    FirebaseCrashlytics.instance.recordError(exception, stackTrace);
  }
}