import 'package:flutter/material.dart';
import 'package:openkey_app/src/src.dart';

/// Wraps a widget in the app's Material and localization setup for UI tests.
Widget screenshotMaterialApp({
  required Brightness brightness,
  required Size surfaceSize,
  required Widget child,
}) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF1B6B4A),
    brightness: brightness,
  );

  return MaterialApp(
    theme: ThemeData(colorScheme: colorScheme, useMaterial3: true),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: MediaQuery(
      data: MediaQueryData(size: surfaceSize),
      child: child,
    ),
  );
}
