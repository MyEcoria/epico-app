import 'package:flutter/foundation.dart';

/// Simple logger that only outputs messages in debug mode.
class AppLogger {
  AppLogger._();

  static void log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }
}
