// ignore_for_file: avoid_print
abstract class ConsoleLogger {
  static void info(String message) {
    print('\x1B[34m$message\x1B[0m');
  }

  static void success(String message) {
    print('\x1B[32m$message\x1B[0m');
  }

  static void warning(String message) {
    print('\x1B[33m$message\x1B[0m');
  }

  static void error(String message) {
    print('\x1B[31m$message\x1B[0m');
  }
}
