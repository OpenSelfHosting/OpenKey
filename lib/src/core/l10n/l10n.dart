import 'package:flutter/material.dart';
import 'package:openkey_app/src/core/l10n/generated/app_localizations.dart';

export 'app_locale.dart';
export 'generated/app_localizations.dart';

extension AppLocalizationsX on AppLocalizations {
  /// Label for auto-lock duration; `0` means disabled.
  String lockMinutesLabel(int n) => n <= 0 ? autoLockOff : minutesLabel(n);
}

extension AppStringsX on BuildContext {
  /// Localized strings. Depends on [Localizations], so widgets rebuild when
  /// [MaterialApp.locale] changes.
  AppLocalizations get s => AppLocalizations.of(this)!;
}
