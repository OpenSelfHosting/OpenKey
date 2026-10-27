import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:in_app_review/in_app_review.dart';
import 'package:openkey_app/src/core/services/vault_metadata_store.dart';

/// Asks for a store rating once the user has enough vault entries.
class AppReviewService {
  AppReviewService(this._prefs);

  final SharedPreferencesLike _prefs;

  static const _requestedKey = 'ok_app_review_requested';
  static const entryThreshold = 5;

  bool get isSupported {
    return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
  }

  bool get hasRequested => _prefs.getBool(_requestedKey) ?? false;

  /// Requests a native in-app review when [entryCount] reaches the threshold
  /// and a prompt has not been shown yet. Safe to call after every create.
  Future<void> maybeRequestAfterEntryCount(int entryCount) async {
    if (!isSupported || hasRequested || entryCount < entryThreshold) return;

    // Let navigation / toasts settle before the system dialog appears.
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (hasRequested) return;

    try {
      final review = InAppReview.instance;
      if (!await review.isAvailable()) return;
      await review.requestReview();
      await _prefs.setBool(_requestedKey, true);
    } catch (e, st) {
      debugPrint('AppReviewService.requestReview failed: $e\n$st');
    }
  }
}
