import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:openkey_app/src/core/l10n/l10n.dart';

/// Seed colors + Material dynamic scheme variants for OpenKey themes.
abstract final class AppColorSchemes {
  static final List<int> seedArgb = _generateSeeds();

  static List<int> _generateSeeds() {
    final hues = List<double>.generate(7, (i) => (i + 4) * 35.0) +
        List<double>.generate(3, (i) => (i + 1) * 35.0);
    return [
      const Color(0xFF1B6B4A).toARGB32(),
      ...hues.map((hue) => Hct.from(hue, 40, 40).toInt()),
    ];
  }

  static const variants = <DynamicSchemeVariant>[
    DynamicSchemeVariant.tonalSpot,
    DynamicSchemeVariant.neutral,
    DynamicSchemeVariant.vibrant,
    DynamicSchemeVariant.expressive,
    DynamicSchemeVariant.fruitSalad,
  ];

  static String variantLabel(DynamicSchemeVariant v) => switch (v) {
        DynamicSchemeVariant.tonalSpot => 'Tonal',
        DynamicSchemeVariant.neutral => 'Neutral',
        DynamicSchemeVariant.vibrant => 'Vibrant',
        DynamicSchemeVariant.expressive => 'Expressive',
        DynamicSchemeVariant.fruitSalad => 'Fruit',
        _ => v.name,
      };

  static ColorScheme build({
    required bool useDynamicColors,
    required int colorIndex,
    required int paletteIndex,
    required Brightness brightness,
    required bool useHighContrast,
  }) {
    final seed = Color(
      seedArgb[colorIndex.clamp(0, seedArgb.length - 1)],
    );
    if (!useDynamicColors) {
      return ColorScheme.fromSeed(
        seedColor: const Color(0xFF1B6B4A),
        brightness: brightness,
        contrastLevel: useHighContrast ? 1.0 : 0.0,
      );
    }
    final variant = variants[paletteIndex.clamp(0, variants.length - 1)];
    return ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      dynamicSchemeVariant: variant,
      contrastLevel: useHighContrast ? 1.0 : 0.0,
    );
  }
}

extension ThemeModeX on ThemeMode {
  IconData get icon => switch (this) {
        ThemeMode.system => Icons.brightness_auto_rounded,
        ThemeMode.light => Icons.light_mode_outlined,
        ThemeMode.dark => Icons.dark_mode_outlined,
      };

  String label(AppLocalizations s) => switch (this) {
        ThemeMode.system => s.system,
        ThemeMode.light => s.light,
        ThemeMode.dark => s.dark,
      };
}
