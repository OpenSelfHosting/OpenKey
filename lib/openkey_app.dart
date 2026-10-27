import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

class OpenKeyApp extends StatelessWidget {
  const OpenKeyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) =>
          previous.themeMode != current.themeMode ||
          previous.locale != current.locale ||
          previous.followsDeviceLocale != current.followsDeviceLocale ||
          previous.useDynamicColors != current.useDynamicColors ||
          previous.colorIndex != current.colorIndex ||
          previous.paletteIndex != current.paletteIndex ||
          previous.useHighContrast != current.useHighContrast ||
          previous.font != current.font ||
          previous.blockScreenshot != current.blockScreenshot,
      builder: (context, settings) {
        sl<ScreenshotProtectionService>().setBlocked(settings.blockScreenshot);

        final light = AppColorSchemes.build(
          useDynamicColors: settings.useDynamicColors,
          colorIndex: settings.colorIndex,
          paletteIndex: settings.paletteIndex,
          brightness: Brightness.light,
          useHighContrast: settings.useHighContrast,
        );
        final dark = AppColorSchemes.build(
          useDynamicColors: settings.useDynamicColors,
          colorIndex: settings.colorIndex,
          paletteIndex: settings.paletteIndex,
          brightness: Brightness.dark,
          useHighContrast: settings.useHighContrast,
        );

        final fontFamily = settings.font.resolveFamily(settings.locale.locale);

        return MaterialApp.router(
          title: lookupAppLocalizations(settings.locale.locale).appName,
          debugShowCheckedModeBanner: false,
          routerConfig: AppRouter.routes,
          themeMode: settings.themeMode,
          locale: settings.followsDeviceLocale ? null : settings.locale.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.build(colorScheme: light, fontFamily: fontFamily),
          darkTheme: AppTheme.build(colorScheme: dark, fontFamily: fontFamily),
          builder: (_, child) {
            return AppSystemUiScope(
              child: DesktopWindowFrame(
                child: METheme(
                  data: METhemeData.expressive,
                  child: AutoLockLifecycle(
                    child: AutofillLifecycle(
                      child: child ?? const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
