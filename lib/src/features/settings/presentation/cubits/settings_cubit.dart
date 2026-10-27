import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:openkey_app/src/src.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._metadata, this._screenshotProtection)
    : super(SettingsState.fromStore(_metadata)) {
    _screenshotProtection.setBlocked(state.blockScreenshot);
  }

  final VaultMetadataStore _metadata;
  final ScreenshotProtectionService _screenshotProtection;

  /// Reloads vault-scoped settings after switching or adding an account.
  Future<void> hydrate() async {
    final next = SettingsState.fromStore(_metadata);
    emit(next);
    await _screenshotProtection.setBlocked(next.blockScreenshot);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _metadata.setThemeMode(value);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> setServerUrl(String url) async {
    await _metadata.setServerUrl(url);
    emit(state.copyWith(serverUrl: url.trim()));
  }

  Future<void> setLockMinutes(int minutes) async {
    await _metadata.setLockMinutes(minutes);
    emit(state.copyWith(lockMinutes: minutes));
  }

  Future<void> setBlockScreenshot(bool value) async {
    await _metadata.setBlockScreenshot(value);
    emit(state.copyWith(blockScreenshot: value));
    await _screenshotProtection.setBlocked(value);
  }

  Future<void> setAutofillRequireBiometric(bool value) async {
    await _metadata.setAutofillRequireBiometric(value);
    emit(state.copyWith(autofillRequireBiometric: value));
  }

  Future<void> setAutofillPresentation({bool? inline, bool? popup}) async {
    var nextInline = state.autofillInline;
    var nextPopup = state.autofillPopup;
    if (inline != null) {
      nextInline = inline;
      if (inline) nextPopup = false;
    }
    if (popup != null) {
      nextPopup = popup;
      if (popup) nextInline = false;
    }
    if (!nextInline && !nextPopup) {
      nextPopup = true;
    }
    await _metadata.setAutofillInline(nextInline);
    await _metadata.setAutofillPopup(nextPopup);
    emit(state.copyWith(autofillInline: nextInline, autofillPopup: nextPopup));
  }

  Future<void> setLocale(AppLocale locale) async {
    await _metadata.setLocaleCode(locale.code);
    emit(state.copyWith(locale: locale, followsDeviceLocale: false));
  }

  Future<void> setUseDynamicColors(bool value) async {
    await _metadata.setUseDynamicColors(value);
    emit(state.copyWith(useDynamicColors: value));
  }

  Future<void> setTheme(int colorIndex, int paletteIndex) async {
    await _metadata.setColorTheme(
      colorIndex: colorIndex,
      paletteIndex: paletteIndex,
    );
    await _metadata.setUseDynamicColors(true);
    emit(
      state.copyWith(
        colorIndex: colorIndex,
        paletteIndex: paletteIndex,
        useDynamicColors: true,
      ),
    );
  }

  Future<void> setUseHighContrast(bool value) async {
    await _metadata.setUseHighContrast(value);
    emit(state.copyWith(useHighContrast: value));
  }

  Future<void> setFont(AppFonts font) async {
    await _metadata.setFontIndex(font.index);
    emit(state.copyWith(font: font));
  }

  Future<void> setPasswordLength(int length) async {
    final clamped = length.clamp(8, 64);
    await _metadata.setPasswordGenerator(length: clamped);
    emit(state.copyWith(passwordLength: clamped));
  }

  Future<void> setPasswordUpper(bool value) => _setCharset(upper: value);

  Future<void> setPasswordLower(bool value) => _setCharset(lower: value);

  Future<void> setPasswordDigits(bool value) => _setCharset(digits: value);

  Future<void> setPasswordSymbols(bool value) => _setCharset(symbols: value);

  Future<void> setPasswordAvoidAmbiguous(bool value) async {
    await _metadata.setPasswordGenerator(avoidAmbiguous: value);
    emit(state.copyWith(passwordAvoidAmbiguous: value));
  }

  Future<void> _setCharset({
    bool? upper,
    bool? lower,
    bool? digits,
    bool? symbols,
  }) async {
    final next = state.copyWith(
      passwordUpper: upper,
      passwordLower: lower,
      passwordDigits: digits,
      passwordSymbols: symbols,
    );
    if (!next.hasAnyCharset) return;
    await _metadata.setPasswordGenerator(
      upper: next.passwordUpper,
      lower: next.passwordLower,
      digits: next.passwordDigits,
      symbols: next.passwordSymbols,
    );
    emit(next);
  }
}

class SettingsState extends Equatable {
  const SettingsState({
    required this.themeMode,
    required this.serverUrl,
    required this.lockMinutes,
    required this.blockScreenshot,
    required this.autofillRequireBiometric,
    required this.autofillInline,
    required this.autofillPopup,
    required this.locale,
    this.followsDeviceLocale = false,
    required this.useDynamicColors,
    required this.colorIndex,
    required this.paletteIndex,
    required this.useHighContrast,
    required this.font,
    required this.passwordLength,
    required this.passwordUpper,
    required this.passwordLower,
    required this.passwordDigits,
    required this.passwordSymbols,
    required this.passwordAvoidAmbiguous,
  });

  factory SettingsState.fromStore(VaultMetadataStore store) {
    final mode = switch (store.themeMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    return SettingsState(
      themeMode: mode,
      serverUrl: store.serverUrl ?? '',
      lockMinutes: store.lockMinutes,
      blockScreenshot: store.blockScreenshot,
      autofillRequireBiometric: store.autofillRequireBiometric,
      autofillInline: store.autofillInline && !store.autofillPopup,
      autofillPopup: store.autofillPopup || !store.autofillInline,
      locale: AppLocale.fromCode(store.localeCode),
      followsDeviceLocale:
          store.localeCode == null || store.localeCode!.isEmpty,
      useDynamicColors: store.useDynamicColors,
      colorIndex: store.colorIndex,
      paletteIndex: store.paletteIndex,
      useHighContrast: store.useHighContrast,
      font: AppFonts.fromIndex(store.fontIndex),
      passwordLength: store.passwordLength.clamp(8, 64),
      passwordUpper: store.passwordUpper,
      passwordLower: store.passwordLower,
      passwordDigits: store.passwordDigits,
      passwordSymbols: store.passwordSymbols,
      passwordAvoidAmbiguous: store.passwordAvoidAmbiguous,
    );
  }

  final ThemeMode themeMode;
  final String serverUrl;
  final int lockMinutes;
  final bool blockScreenshot;
  final bool autofillRequireBiometric;
  final bool autofillInline;
  final bool autofillPopup;
  final AppLocale locale;

  /// When true, [MaterialApp.locale] is left unset so Flutter follows the
  /// device language until the user picks one in Settings.
  final bool followsDeviceLocale;
  final bool useDynamicColors;
  final int colorIndex;
  final int paletteIndex;
  final bool useHighContrast;
  final AppFonts font;
  final int passwordLength;
  final bool passwordUpper;
  final bool passwordLower;
  final bool passwordDigits;
  final bool passwordSymbols;
  final bool passwordAvoidAmbiguous;

  bool get hasAnyCharset =>
      passwordUpper || passwordLower || passwordDigits || passwordSymbols;

  String generatePassword(CryptoService crypto) {
    return crypto.generatePassword(
      length: passwordLength,
      upper: passwordUpper,
      lower: passwordLower,
      digits: passwordDigits,
      symbols: passwordSymbols,
      avoidAmbiguous: passwordAvoidAmbiguous,
    );
  }

  String get passwordOptionsSummary {
    final parts = <String>[
      if (passwordUpper) 'A-Z',
      if (passwordLower) 'a-z',
      if (passwordDigits) '0-9',
      if (passwordSymbols) '#@!',
    ];
    return '$passwordLength · ${parts.join(' · ')}';
  }

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? serverUrl,
    int? lockMinutes,
    bool? blockScreenshot,
    bool? autofillRequireBiometric,
    bool? autofillInline,
    bool? autofillPopup,
    AppLocale? locale,
    bool? followsDeviceLocale,
    bool? useDynamicColors,
    int? colorIndex,
    int? paletteIndex,
    bool? useHighContrast,
    AppFonts? font,
    int? passwordLength,
    bool? passwordUpper,
    bool? passwordLower,
    bool? passwordDigits,
    bool? passwordSymbols,
    bool? passwordAvoidAmbiguous,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      serverUrl: serverUrl ?? this.serverUrl,
      lockMinutes: lockMinutes ?? this.lockMinutes,
      blockScreenshot: blockScreenshot ?? this.blockScreenshot,
      autofillRequireBiometric:
          autofillRequireBiometric ?? this.autofillRequireBiometric,
      autofillInline: autofillInline ?? this.autofillInline,
      autofillPopup: autofillPopup ?? this.autofillPopup,
      locale: locale ?? this.locale,
      followsDeviceLocale: followsDeviceLocale ?? this.followsDeviceLocale,
      useDynamicColors: useDynamicColors ?? this.useDynamicColors,
      colorIndex: colorIndex ?? this.colorIndex,
      paletteIndex: paletteIndex ?? this.paletteIndex,
      useHighContrast: useHighContrast ?? this.useHighContrast,
      font: font ?? this.font,
      passwordLength: passwordLength ?? this.passwordLength,
      passwordUpper: passwordUpper ?? this.passwordUpper,
      passwordLower: passwordLower ?? this.passwordLower,
      passwordDigits: passwordDigits ?? this.passwordDigits,
      passwordSymbols: passwordSymbols ?? this.passwordSymbols,
      passwordAvoidAmbiguous:
          passwordAvoidAmbiguous ?? this.passwordAvoidAmbiguous,
    );
  }

  @override
  List<Object?> get props => [
    themeMode,
    serverUrl,
    lockMinutes,
    blockScreenshot,
    autofillRequireBiometric,
    autofillInline,
    autofillPopup,
    locale,
    followsDeviceLocale,
    useDynamicColors,
    colorIndex,
    paletteIndex,
    useHighContrast,
    font,
    passwordLength,
    passwordUpper,
    passwordLower,
    passwordDigits,
    passwordSymbols,
    passwordAvoidAmbiguous,
  ];
}
