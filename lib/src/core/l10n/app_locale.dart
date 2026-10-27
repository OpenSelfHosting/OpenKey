import 'dart:io';

import 'package:flutter/material.dart';

/// Top 10 most spoken languages worldwide (by total speakers).
enum AppLocale {
  english('en', 'English', 'English'),
  chinese('zh', 'Chinese', '中文'),
  hindi('hi', 'Hindi', 'हिन्दी'),
  spanish('es', 'Spanish', 'Español'),
  french('fr', 'French', 'Français'),
  arabic('ar', 'Arabic', 'العربية'),
  bengali('bn', 'Bengali', 'বাংলা'),
  portuguese('pt', 'Portuguese', 'Português'),
  russian('ru', 'Russian', 'Русский'),
  urdu('ur', 'Urdu', 'اردو');

  const AppLocale(this.code, this.englishName, this.nativeName);

  final String code;
  final String englishName;
  final String nativeName;

  Locale get locale => Locale(code);

  bool get isRtl => this == AppLocale.arabic || this == AppLocale.urdu;

  static List<Locale> get supportedLocales =>
      values.map((e) => e.locale).toList();

  static AppLocale get deviceOrEnglish {
    try {
      final code = Platform.localeName.split(RegExp('[_-]')).first;
      return values.firstWhere(
        (e) => e.code == code,
        orElse: () => AppLocale.english,
      );
    } catch (_) {
      return AppLocale.english;
    }
  }

  static AppLocale fromCode(String? code) {
    if (code == null || code.isEmpty) return deviceOrEnglish;
    return values.firstWhere(
      (e) => e.code == code,
      orElse: () => deviceOrEnglish,
    );
  }
}
