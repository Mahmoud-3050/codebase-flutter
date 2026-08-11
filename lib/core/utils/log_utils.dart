import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

class Log {
  static const MethodChannel perform = MethodChannel('x_log');

  static final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // Number of method calls to be displayed
      errorMethodCount: 5, // Number of method calls if stacktrace is provided
    ),
  );

  static void d(Object msg, {String tag = 'X-LOG'}) {
    logger.d(msg);
  }

  static void w(Object msg, {String tag = 'X-LOG'}) {
    logger.w(msg);
  }

  static void i(Object msg, {String tag = 'X-LOG'}) {
    logger.i(msg);
  }

  static void e(Object msg, {String tag = 'X-LOG'}) {
    logger.e(msg);
  }

  static void f(Object msg, {String tag = 'X-LOG'}) {
    logger.f(msg);
  }

  static void t(Object msg, {String tag = 'X-LOG'}) {
    logger.t(msg);
  }

  static void json(Object msg, {String tag = 'X-LOG'}) {
    try {
      logger.f(msg);
    } catch (e) {
      d(msg);
    }
  }
}
