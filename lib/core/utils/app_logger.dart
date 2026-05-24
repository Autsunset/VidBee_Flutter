import 'package:flutter/foundation.dart';

class AppLogger {
  const AppLogger._();

  static void debug(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  static void error(String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint(error == null ? message : '$message: $error');
    }
  }
}
