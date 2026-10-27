import 'package:flutter/foundation.dart';

/// Debug-only logging. No-ops in profile/release so bridge/autofill noise
/// never lands in production consoles.
void okDebugLog(Object? message) {
  if (kDebugMode) {
    debugPrint('$message');
  }
}
