import 'package:flutter/material.dart';
import 'package:openkey_app/src/core/l10n/l10n.dart';

enum AppFonts {
  defaultFont('default'),
  arabic('NotoKufiArabic'),
  developer('Inconsolata'),
  technical('RobotoMono'),
  standard('OpenSans'),

  /// Google's next-gen brand typeface for Material 3 Expressive.
  googleSansFlex('GoogleSansFlex'),

  /// Material Design variable font — weight, width, optical size.
  robotoFlex('RobotoFlex'),

  /// Soft geometric companion often used with Material You.
  figtree('Figtree'),

  /// Rounded, approachable geometric sans for a friendly modern tone.
  nunito('Nunito');

  final String assetName;
  const AppFonts(this.assetName);

  static AppFonts fromIndex(int? index) {
    if (index == null || index < 0 || index >= values.length) {
      return AppFonts.defaultFont;
    }
    return values[index];
  }

  String title(AppLocalizations s) => switch (this) {
    AppFonts.defaultFont => s.defaultFont,
    AppFonts.arabic => s.arabicFont,
    AppFonts.developer => s.developerFont,
    AppFonts.technical => s.technicalFont,
    AppFonts.standard => s.standardFont,
    AppFonts.googleSansFlex => s.googleSansFlexFont,
    AppFonts.robotoFlex => s.robotoFlexFont,
    AppFonts.figtree => s.figtreeFont,
    AppFonts.nunito => s.nunitoFont,
  };

  String subtitle(AppLocalizations s) => switch (this) {
    AppFonts.defaultFont => s.defaultFontDes,
    AppFonts.arabic => s.arabicFontDes,
    AppFonts.developer => s.developerFontDes,
    AppFonts.technical => s.technicalFontDes,
    AppFonts.standard => s.standardFontDes,
    AppFonts.googleSansFlex => s.googleSansFlexFontDes,
    AppFonts.robotoFlex => s.robotoFlexFontDes,
    AppFonts.figtree => s.figtreeFontDes,
    AppFonts.nunito => s.nunitoFontDes,
  };

  /// Resolves the effective font family for [locale].
  /// Default font uses Noto Kufi for Arabic locales.
  String? resolveFamily(Locale locale) {
    if (this == AppFonts.defaultFont) {
      return locale.languageCode == 'ar' ? 'NotoKufiArabic' : null;
    }
    return assetName;
  }
}
