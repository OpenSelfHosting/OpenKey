import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:openkey_app/src/core/models/named_group.dart';
import 'package:openkey_app/src/core/models/vault_account.dart';
import 'package:openkey_app/src/core/services/secure_storage_factory.dart';
import 'package:openkey_app/src/core/services/vault_paths.dart';
import 'package:uuid/uuid.dart';

/// Account / KDF metadata stored outside the encrypted DB so unlock can work.
///
/// Sensitive unlock material (salt, wrapped key, tokens) is kept in secure
/// storage with an in-memory cache for synchronous reads after [ensureLoaded].
///
/// Device settings (theme, locale, fonts) stay global.
/// Everything else that belongs to a vault is namespaced per account.
class VaultMetadataStore {
  VaultMetadataStore(
    this._prefs, {
    FlutterSecureStorage? secureStorage,
    bool? usePrefsForSecure,
    String Function()? newAccountId,
  }) : _secure = secureStorage ?? createAppSecureStorage(),
       _usePrefsForSecure = usePrefsForSecure ?? kIsWeb,
       _newAccountId = newAccountId ?? _uuidV4;

  final SharedPreferencesLike _prefs;
  final FlutterSecureStorage _secure;
  final bool _usePrefsForSecure;
  final String Function() _newAccountId;

  static String _uuidV4() => const Uuid().v4();

  static const _accountsKey = 'ok_accounts';
  static const _activeAccountIdKey = 'ok_active_account_id';
  static const _hasVaultKey = 'ok_has_vault';

  static const _themeModeKey = 'ok_theme_mode';
  static const _lockMinutesKey = 'ok_lock_minutes';
  static const _blockScreenshotKey = 'ok_block_screenshot';
  static const _autofillRequireBiometricKey = 'ok_autofill_require_biometric';
  static const _autofillInlineKey = 'ok_autofill_inline';
  static const _autofillPopupKey = 'ok_autofill_popup';
  static const _localeKey = 'ok_locale';
  static const _useDynamicColorsKey = 'ok_use_dynamic_colors';
  static const _colorIndexKey = 'ok_color_index';
  static const _paletteIndexKey = 'ok_palette_index';
  static const _highContrastKey = 'ok_high_contrast';
  static const _fontKey = 'ok_font';
  static const _pwLengthKey = 'ok_pw_gen_length';
  static const _pwUpperKey = 'ok_pw_gen_upper';
  static const _pwLowerKey = 'ok_pw_gen_lower';
  static const _pwDigitsKey = 'ok_pw_gen_digits';
  static const _pwSymbolsKey = 'ok_pw_gen_symbols';
  static const _pwAvoidAmbiguousKey = 'ok_pw_gen_avoid_ambiguous';
  static const _pendingSubscriptionOfferKey = 'ok_pending_subscription_offer';
  static const _onboardingCompletedKey = 'ok_onboarding_completed';
  static const _reviewerProKey = 'ok_reviewer_pro';

  static const _vaultStringLeaves = [
    'email',
    'server_url',
    'server_user_id',
    'last_local_backup_path',
    'secret_devices',
    'wallet_banks',
    'crypto_folders',
  ];
  static const _vaultIntLeaves = [
    'server_revision',
    'collections_order',
    'entries_order',
    'cards_order',
    'crypto_order',
    'secrets_order',
    'lock_minutes',
    'pw_gen_length',
  ];
  static const _vaultBoolLeaves = [
    'collections_reverse_order',
    'entries_reverse_order',
    'cards_reverse_order',
    'crypto_reverse_order',
    'secrets_reverse_order',
    'block_screenshot',
    'autofill_require_biometric',
    'autofill_inline',
    'autofill_popup',
    'pw_gen_upper',
    'pw_gen_lower',
    'pw_gen_digits',
    'pw_gen_symbols',
    'pw_gen_avoid_ambiguous',
    'pending_subscription_offer',
  ];
  static const _vaultSecureLeaves = [
    'salt',
    'kdf',
    'wrapped_vault_key',
    'access_token',
    'refresh_token',
    'password_hint',
  ];

  static const _legacyEmailKey = 'ok_email';
  static const _legacySaltKey = 'ok_salt';
  static const _legacyKdfKey = 'ok_kdf';
  static const _legacyWrappedKey = 'ok_wrapped_vault_key';
  static const _legacyServerUrlKey = 'ok_server_url';
  static const _legacyAccessTokenKey = 'ok_access_token';
  static const _legacyRefreshTokenKey = 'ok_refresh_token';
  static const _legacyServerUserIdKey = 'ok_server_user_id';
  static const _legacyServerRevisionKey = 'ok_server_revision';
  static const _legacyPasswordHintKey = 'ok_password_hint';
  static const _legacyCollectionsOrderKey = 'ok_collections_order';
  static const _legacyCollectionsReverseOrderKey =
      'ok_collections_reverse_order';
  static const _legacyEntriesOrderKey = 'ok_entries_order';
  static const _legacyEntriesReverseOrderKey = 'ok_entries_reverse_order';
  static const _legacyCardsOrderKey = 'ok_cards_order';
  static const _legacyCardsReverseOrderKey = 'ok_cards_reverse_order';
  static const _legacyCryptoOrderKey = 'ok_crypto_order';
  static const _legacyCryptoReverseOrderKey = 'ok_crypto_reverse_order';
  static const _legacySecretsOrderKey = 'ok_secrets_order';
  static const _legacySecretsReverseOrderKey = 'ok_secrets_reverse_order';
  static const _legacySecretDevicesKey = 'ok_secret_devices';
  static const _legacyWalletBanksKey = 'ok_wallet_banks';
  static const _legacyCryptoFoldersKey = 'ok_crypto_folders';
  static const _legacyLastLocalBackupPathKey = 'ok_last_local_backup_path';

  bool _loaded = false;
  String? _cachedSalt;
  String? _cachedKdf;
  String? _cachedWrapped;
  String? _cachedAccessToken;
  String? _cachedRefreshToken;
  String? _cachedPasswordHint;
  final Map<String, String> _avatarAbs = {};

  /// Loads secure values, migrates a single-vault install, and warms caches.
  Future<void> ensureLoaded() async {
    if (_loaded) return;
    await migrateToAccountRegistry();
    await migrateSharedVaultPrefsToAccounts();
    await _loadActiveCaches();
    await refreshAvatarCache();
    _loaded = true;
  }

  /// Promotes a pre-multi-account vault into the account registry.
  Future<void> migrateToAccountRegistry() async {
    if (_readStoredAccounts().isNotEmpty) return;

    final hasVault = _prefs.getBool(_hasVaultKey) ?? false;
    final email = _prefs.getString(_legacyEmailKey);
    if (!hasVault && (email == null || email.isEmpty)) return;

    final id = _newAccountId();
    await _copyLegacyVaultKeysTo(id);
    final account = VaultAccount(
      id: id,
      email: (email ?? '').trim().toLowerCase(),
    );
    await _writeAccounts([account]);
    await _prefs.setString(_activeAccountIdKey, id);

    try {
      await VaultPaths.migrateLegacyDatabase(id);
      await VaultPaths.migrateLegacyAttachments(id);
    } catch (_) {}
  }

  Future<void> _copyLegacyVaultKeysTo(String id) async {
    Future<void> copyString(String legacy, String leaf) async {
      final value = _prefs.getString(legacy);
      if (value == null || value.isEmpty) return;
      await _prefs.setString(_vkFor(id, leaf), value);
      await _prefs.remove(legacy);
    }

    Future<void> copyInt(String legacy, String leaf) async {
      final value = _prefs.getInt(legacy);
      if (value == null) return;
      await _prefs.setInt(_vkFor(id, leaf), value);
      await _prefs.remove(legacy);
    }

    Future<void> copyBool(String legacy, String leaf) async {
      final value = _prefs.getBool(legacy);
      if (value == null) return;
      await _prefs.setBool(_vkFor(id, leaf), value);
      await _prefs.remove(legacy);
    }

    Future<void> copySecure(String legacy, String leaf) async {
      String? value;
      if (_usePrefsForSecure) {
        value = _prefs.getString(legacy);
      } else {
        value = await _secure.read(key: legacy);
        value ??= _prefs.getString(legacy);
      }
      if (value == null || value.isEmpty) return;
      await _writeSecure(_vkFor(id, leaf), value);
      if (!_usePrefsForSecure) {
        await _secure.delete(key: legacy);
      }
      await _prefs.remove(legacy);
    }

    await copyString(_legacyEmailKey, 'email');
    await copyString(_legacyServerUrlKey, 'server_url');
    await copyString(_legacyServerUserIdKey, 'server_user_id');
    await copyString(_legacyLastLocalBackupPathKey, 'last_local_backup_path');
    await copyString(_legacySecretDevicesKey, 'secret_devices');
    await copyString(_legacyWalletBanksKey, 'wallet_banks');
    await copyString(_legacyCryptoFoldersKey, 'crypto_folders');
    await copyInt(_legacyServerRevisionKey, 'server_revision');
    await copyInt(_legacyCollectionsOrderKey, 'collections_order');
    await copyInt(_legacyEntriesOrderKey, 'entries_order');
    await copyInt(_legacyCardsOrderKey, 'cards_order');
    await copyInt(_legacyCryptoOrderKey, 'crypto_order');
    await copyInt(_legacySecretsOrderKey, 'secrets_order');
    await copyBool(
      _legacyCollectionsReverseOrderKey,
      'collections_reverse_order',
    );
    await copyBool(_legacyEntriesReverseOrderKey, 'entries_reverse_order');
    await copyBool(_legacyCardsReverseOrderKey, 'cards_reverse_order');
    await copyBool(_legacyCryptoReverseOrderKey, 'crypto_reverse_order');
    await copyBool(_legacySecretsReverseOrderKey, 'secrets_reverse_order');
    await copySecure(_legacySaltKey, 'salt');
    await copySecure(_legacyKdfKey, 'kdf');
    await copySecure(_legacyWrappedKey, 'wrapped_vault_key');
    await copySecure(_legacyAccessTokenKey, 'access_token');
    await copySecure(_legacyRefreshTokenKey, 'refresh_token');
    await copySecure(_legacyPasswordHintKey, 'password_hint');
    await _copySharedDevicePrefsTo(id, removeLegacy: true);
  }

  /// Copies pre-namespaced lock / autofill / generator prefs onto every
  /// existing account, then drops the shared keys so later edits stay isolated.
  Future<void> migrateSharedVaultPrefsToAccounts() async {
    final accounts = _readStoredAccounts();
    if (accounts.isEmpty) return;
    final already = accounts.any(
      (a) =>
          _prefs.getInt(_vkFor(a.id, 'lock_minutes')) != null ||
          _prefs.getBool(_vkFor(a.id, 'block_screenshot')) != null ||
          _prefs.getInt(_vkFor(a.id, 'pw_gen_length')) != null,
    );
    if (already) return;
    final hasLegacy =
        _prefs.getInt(_lockMinutesKey) != null ||
        _prefs.getBool(_blockScreenshotKey) != null ||
        _prefs.getBool(_autofillRequireBiometricKey) != null ||
        _prefs.getBool(_autofillInlineKey) != null ||
        _prefs.getBool(_autofillPopupKey) != null ||
        _prefs.getInt(_pwLengthKey) != null ||
        _prefs.getBool(_pwUpperKey) != null ||
        _prefs.getBool(_pwLowerKey) != null ||
        _prefs.getBool(_pwDigitsKey) != null ||
        _prefs.getBool(_pwSymbolsKey) != null ||
        _prefs.getBool(_pwAvoidAmbiguousKey) != null ||
        _prefs.getBool(_pendingSubscriptionOfferKey) != null;
    if (!hasLegacy) return;
    for (final account in accounts) {
      await _copySharedDevicePrefsTo(account.id, removeLegacy: false);
    }
    await _copySharedDevicePrefsTo(accounts.first.id, removeLegacy: true);
  }

  Future<void> _copySharedDevicePrefsTo(
    String id, {
    required bool removeLegacy,
  }) async {
    Future<void> copyInt(String legacy, String leaf) async {
      final value = _prefs.getInt(legacy);
      if (value == null) return;
      if (_prefs.getInt(_vkFor(id, leaf)) == null) {
        await _prefs.setInt(_vkFor(id, leaf), value);
      }
      if (removeLegacy) await _prefs.remove(legacy);
    }

    Future<void> copyBool(String legacy, String leaf) async {
      final value = _prefs.getBool(legacy);
      if (value == null) return;
      if (_prefs.getBool(_vkFor(id, leaf)) == null) {
        await _prefs.setBool(_vkFor(id, leaf), value);
      }
      if (removeLegacy) await _prefs.remove(legacy);
    }

    await copyInt(_lockMinutesKey, 'lock_minutes');
    await copyInt(_pwLengthKey, 'pw_gen_length');
    await copyBool(_blockScreenshotKey, 'block_screenshot');
    await copyBool(_autofillRequireBiometricKey, 'autofill_require_biometric');
    await copyBool(_autofillInlineKey, 'autofill_inline');
    await copyBool(_autofillPopupKey, 'autofill_popup');
    await copyBool(_pwUpperKey, 'pw_gen_upper');
    await copyBool(_pwLowerKey, 'pw_gen_lower');
    await copyBool(_pwDigitsKey, 'pw_gen_digits');
    await copyBool(_pwSymbolsKey, 'pw_gen_symbols');
    await copyBool(_pwAvoidAmbiguousKey, 'pw_gen_avoid_ambiguous');
    await copyBool(_pendingSubscriptionOfferKey, 'pending_subscription_offer');
  }

  Future<void> _loadActiveCaches() async {
    _cachedSalt = await _readSecure(_vk('salt'));
    _cachedKdf = await _readSecure(_vk('kdf'));
    _cachedWrapped = await _readSecure(_vk('wrapped_vault_key'));
    _cachedAccessToken = await _readSecure(_vk('access_token'));
    _cachedRefreshToken = await _readSecure(_vk('refresh_token'));
    _cachedPasswordHint = await _readSecure(_vk('password_hint'));
  }

  void _clearMemoryCaches() {
    _cachedSalt = null;
    _cachedKdf = null;
    _cachedWrapped = null;
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    _cachedPasswordHint = null;
  }

  Future<String?> _readSecure(String key) async {
    if (key.isEmpty) return null;
    if (_usePrefsForSecure) return _prefs.getString(key);
    var value = await _secure.read(key: key);
    if (value == null || value.isEmpty) {
      final legacy = _prefs.getString(key);
      if (legacy != null && legacy.isNotEmpty) {
        await _secure.write(key: key, value: legacy);
        await _prefs.remove(key);
        value = legacy;
      }
    }
    return value;
  }

  Future<void> _writeSecure(String key, String? value) async {
    if (_usePrefsForSecure) {
      if (value == null || value.isEmpty) {
        await _prefs.remove(key);
      } else {
        await _prefs.setString(key, value);
      }
      return;
    }
    if (value == null || value.isEmpty) {
      await _secure.delete(key: key);
      await _prefs.remove(key);
    } else {
      await _secure.write(key: key, value: value);
      await _prefs.remove(key);
    }
  }

  String? get activeAccountId => _prefs.getString(_activeAccountIdKey);

  String _vk(String leaf) {
    final id = activeAccountId;
    if (id == null || id.isEmpty) return '';
    return _vkFor(id, leaf);
  }

  static String _vkFor(String accountId, String leaf) =>
      'ok.a.$accountId.$leaf';

  int _intOrLegacy(String leaf, String legacyKey, int fallback) {
    return _prefs.getInt(_vk(leaf)) ?? _prefs.getInt(legacyKey) ?? fallback;
  }

  bool _boolOrLegacy(String leaf, String legacyKey, bool fallback) {
    return _prefs.getBool(_vk(leaf)) ?? _prefs.getBool(legacyKey) ?? fallback;
  }

  Future<void> _setVaultInt(String leaf, String legacyKey, int value) {
    final key = _vk(leaf);
    return _prefs.setInt(key.isEmpty ? legacyKey : key, value);
  }

  Future<void> _setVaultBool(String leaf, String legacyKey, bool value) {
    final key = _vk(leaf);
    return _prefs.setBool(key.isEmpty ? legacyKey : key, value);
  }

  List<VaultAccount> _readStoredAccounts() {
    final raw = _prefs.getString(_accountsKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((e) => VaultAccount.fromJson(Map<String, dynamic>.from(e)))
          .where((a) => a.id.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _writeAccounts(List<VaultAccount> accounts) {
    return _prefs.setString(
      _accountsKey,
      jsonEncode(accounts.map((a) => a.toJson()).toList()),
    );
  }

  List<VaultAccount> get accounts {
    return _readStoredAccounts()
        .map(
          (a) => a.copyWith(
            avatarPath: _avatarAbs[a.id],
            clearAvatar: !_avatarAbs.containsKey(a.id),
          ),
        )
        .toList();
  }

  VaultAccount? get activeAccount {
    final id = activeAccountId;
    if (id == null) return null;
    for (final account in accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

  Future<void> refreshAvatarCache() async {
    _avatarAbs.clear();
    for (final account in _readStoredAccounts()) {
      try {
        final file = await VaultPaths.avatarFile(account.id);
        if (await file.exists()) {
          _avatarAbs[account.id] = file.path;
        }
      } catch (_) {}
    }
  }

  bool emailExists(String email, {String? excludingId}) {
    final normalized = email.trim().toLowerCase();
    return _readStoredAccounts().any(
      (a) => a.email == normalized && a.id != excludingId,
    );
  }

  /// Creates a new account, makes it active, and clears in-memory vault caches.
  Future<VaultAccount> createAccount({required String email}) async {
    final normalized = email.trim().toLowerCase();
    final account = VaultAccount(id: _newAccountId(), email: normalized);
    final list = [..._readStoredAccounts(), account];
    await _writeAccounts(list);
    await _prefs.setString(_activeAccountIdKey, account.id);
    await _prefs.setBool(_hasVaultKey, true);
    await _prefs.setString(_vk('email'), normalized);
    _clearMemoryCaches();
    return account;
  }

  Future<void> setActiveAccount(String id) async {
    final match = _readStoredAccounts().where((a) => a.id == id);
    if (match.isEmpty) {
      throw StateError('Unknown account $id');
    }
    await _prefs.setString(_activeAccountIdKey, id);
    await _loadActiveCaches();
  }

  Future<void> updateActiveEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    final id = activeAccountId;
    if (id == null) return;
    await _prefs.setString(_vk('email'), normalized);
    final updated = _readStoredAccounts()
        .map((a) => a.id == id ? a.copyWith(email: normalized) : a)
        .toList();
    await _writeAccounts(updated);
  }

  Future<void> rememberAvatar(String accountId, String absolutePath) async {
    _avatarAbs[accountId] = absolutePath;
  }

  Future<void> forgetAvatar(String accountId) async {
    _avatarAbs.remove(accountId);
  }

  Future<void> _clearAccountKeys(String id) async {
    for (final leaf in [
      ..._vaultStringLeaves,
      ..._vaultIntLeaves,
      ..._vaultBoolLeaves,
    ]) {
      await _prefs.remove(_vkFor(id, leaf));
    }
    for (final leaf in _vaultSecureLeaves) {
      await _writeSecure(_vkFor(id, leaf), null);
    }
  }

  /// Removes one account's metadata. [switchTo] selects the next active id.
  Future<void> removeAccount(String id, {String? switchTo}) async {
    await _clearAccountKeys(id);
    _avatarAbs.remove(id);
    final remaining = _readStoredAccounts().where((a) => a.id != id).toList();
    await _writeAccounts(remaining);
    if (remaining.isEmpty) {
      await _prefs.remove(_activeAccountIdKey);
      await _prefs.remove(_hasVaultKey);
      _clearMemoryCaches();
      return;
    }
    final next = switchTo != null && remaining.any((a) => a.id == switchTo)
        ? switchTo
        : remaining.first.id;
    await _prefs.setString(_activeAccountIdKey, next);
    await _loadActiveCaches();
  }

  bool get hasVault => _readStoredAccounts().isNotEmpty;

  /// First-run product tour before vault setup.
  bool get onboardingCompleted =>
      _prefs.getBool(_onboardingCompletedKey) ?? false;

  /// After first vault setup, show the subscription page once (skippable).
  bool get pendingSubscriptionOffer => _boolOrLegacy(
    'pending_subscription_offer',
    _pendingSubscriptionOfferKey,
    false,
  );

  String? get email {
    final namespaced = _prefs.getString(_vk('email'));
    if (namespaced != null && namespaced.isNotEmpty) return namespaced;
    return _prefs.getString(_legacyEmailKey);
  }

  String? get saltBase64 => _cachedSalt;
  String? get wrappedVaultKey => _cachedWrapped;
  String? get serverUrl => _prefs.getString(_vk('server_url'));
  String? get accessToken => _cachedAccessToken;
  String? get refreshToken => _cachedRefreshToken;
  String? get serverUserId => _prefs.getString(_vk('server_user_id'));

  /// Opaque sync cursor from last successful `/sync` (`server_revision`).
  int get serverRevision => _prefs.getInt(_vk('server_revision')) ?? 0;

  /// Last local OpenKey JSON backup path chosen by the user.
  String? get lastLocalBackupPath =>
      _prefs.getString(_vk('last_local_backup_path'));

  /// Store-review account: unlock Pro without a purchase (release builds).
  bool get reviewerPro => _prefs.getBool(_reviewerProKey) ?? false;

  Map<String, dynamic>? get kdfParams {
    final raw = _cachedKdf;
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  int get lockMinutes => _intOrLegacy('lock_minutes', _lockMinutesKey, 5);

  /// Defaults to off — user can enable blocking in Security settings.
  bool get blockScreenshot =>
      _boolOrLegacy('block_screenshot', _blockScreenshotKey, false);

  /// When true, Autofill asks for biometrics before filling a login.
  bool get autofillRequireBiometric => _boolOrLegacy(
    'autofill_require_biometric',
    _autofillRequireBiometricKey,
    false,
  );

  /// When true, Android Autofill suggestions appear in the keyboard strip.
  bool get autofillInline =>
      _boolOrLegacy('autofill_inline', _autofillInlineKey, false);

  /// When true, Android Autofill suggestions appear as a dropdown over the field.
  bool get autofillPopup =>
      _boolOrLegacy('autofill_popup', _autofillPopupKey, true);

  String get themeMode => _prefs.getString(_themeModeKey) ?? 'system';

  String? get localeCode => _prefs.getString(_localeKey);

  bool get useDynamicColors => _prefs.getBool(_useDynamicColorsKey) ?? false;

  int get colorIndex => _prefs.getInt(_colorIndexKey) ?? 0;

  int get paletteIndex => _prefs.getInt(_paletteIndexKey) ?? 0;

  bool get useHighContrast => _prefs.getBool(_highContrastKey) ?? false;

  int get fontIndex => _prefs.getInt(_fontKey) ?? 0;

  int get passwordLength => _intOrLegacy('pw_gen_length', _pwLengthKey, 20);

  bool get passwordUpper => _boolOrLegacy('pw_gen_upper', _pwUpperKey, true);

  bool get passwordLower => _boolOrLegacy('pw_gen_lower', _pwLowerKey, true);

  bool get passwordDigits => _boolOrLegacy('pw_gen_digits', _pwDigitsKey, true);

  bool get passwordSymbols =>
      _boolOrLegacy('pw_gen_symbols', _pwSymbolsKey, true);

  bool get passwordAvoidAmbiguous =>
      _boolOrLegacy('pw_gen_avoid_ambiguous', _pwAvoidAmbiguousKey, false);

  /// Optional local-only reminder shown after failed unlock attempts.
  /// Never sent to a server; keep it vague so it does not leak the password.
  String? get passwordHint {
    final hint = _cachedPasswordHint?.trim();
    if (hint == null || hint.isEmpty) return null;
    return hint;
  }

  Future<void> saveVaultMetadata({
    required String email,
    required String saltBase64,
    required Map<String, dynamic> kdfParams,
    required String wrappedVaultKey,
  }) async {
    if (activeAccountId == null) {
      await createAccount(email: email);
    } else {
      await updateActiveEmail(email);
    }
    await _prefs.setBool(_hasVaultKey, true);
    _cachedSalt = saltBase64;
    _cachedKdf = jsonEncode(kdfParams);
    _cachedWrapped = wrappedVaultKey;
    await _writeSecure(_vk('salt'), saltBase64);
    await _writeSecure(_vk('kdf'), _cachedKdf);
    await _writeSecure(_vk('wrapped_vault_key'), wrappedVaultKey);
  }

  Future<void> setServerUrl(String url) =>
      _prefs.setString(_vk('server_url'), url.trim());

  Future<void> setAuthTokens({
    required String? accessToken,
    String? refreshToken,
    required String? serverUserId,
  }) async {
    _cachedAccessToken = accessToken;
    _cachedRefreshToken = refreshToken;
    await _writeSecure(_vk('access_token'), accessToken);
    await _writeSecure(_vk('refresh_token'), refreshToken);
    final userKey = _vk('server_user_id');
    if (serverUserId == null) {
      await _prefs.remove(userKey);
    } else {
      await _prefs.setString(userKey, serverUserId);
    }
  }

  /// Clears server auth while keeping the local vault and optional server URL.
  Future<void> clearServerLink({bool clearServerUrl = false}) async {
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    await _writeSecure(_vk('access_token'), null);
    await _writeSecure(_vk('refresh_token'), null);
    await _prefs.remove(_vk('server_user_id'));
    await _prefs.remove(_vk('server_revision'));
    if (clearServerUrl) {
      await _prefs.remove(_vk('server_url'));
    }
  }

  Future<void> setOnboardingCompleted(bool value) =>
      _prefs.setBool(_onboardingCompletedKey, value);

  Future<void> setLastLocalBackupPath(String path) =>
      _prefs.setString(_vk('last_local_backup_path'), path);

  Future<void> setPendingSubscriptionOffer(bool value) => _setVaultBool(
    'pending_subscription_offer',
    _pendingSubscriptionOfferKey,
    value,
  );

  Future<void> clearPendingSubscriptionOffer() {
    final key = _vk('pending_subscription_offer');
    return _prefs.remove(key.isEmpty ? _pendingSubscriptionOfferKey : key);
  }

  Future<void> setServerRevision(int revision) =>
      _prefs.setInt(_vk('server_revision'), revision);

  Future<void> clearServerRevision() => _prefs.remove(_vk('server_revision'));

  Future<void> setThemeMode(String mode) =>
      _prefs.setString(_themeModeKey, mode);

  Future<void> setLockMinutes(int minutes) =>
      _setVaultInt('lock_minutes', _lockMinutesKey, minutes);

  Future<void> setBlockScreenshot(bool value) =>
      _setVaultBool('block_screenshot', _blockScreenshotKey, value);


  Future<void> setReviewerPro(bool value) =>
      _prefs.setBool(_reviewerProKey, value);

  Future<void> setAutofillRequireBiometric(bool value) => _setVaultBool(
    'autofill_require_biometric',
    _autofillRequireBiometricKey,
    value,
  );

  Future<void> setAutofillInline(bool value) =>
      _setVaultBool('autofill_inline', _autofillInlineKey, value);

  Future<void> setAutofillPopup(bool value) =>
      _setVaultBool('autofill_popup', _autofillPopupKey, value);

  Future<void> setLocaleCode(String code) => _prefs.setString(_localeKey, code);

  Future<void> setUseDynamicColors(bool value) =>
      _prefs.setBool(_useDynamicColorsKey, value);

  Future<void> setColorTheme({
    required int colorIndex,
    required int paletteIndex,
  }) async {
    await _prefs.setInt(_colorIndexKey, colorIndex);
    await _prefs.setInt(_paletteIndexKey, paletteIndex);
  }

  Future<void> setUseHighContrast(bool value) =>
      _prefs.setBool(_highContrastKey, value);

  Future<void> setFontIndex(int index) => _prefs.setInt(_fontKey, index);

  Future<void> setPasswordGenerator({
    int? length,
    bool? upper,
    bool? lower,
    bool? digits,
    bool? symbols,
    bool? avoidAmbiguous,
  }) async {
    if (length != null) {
      await _setVaultInt('pw_gen_length', _pwLengthKey, length);
    }
    if (upper != null) {
      await _setVaultBool('pw_gen_upper', _pwUpperKey, upper);
    }
    if (lower != null) {
      await _setVaultBool('pw_gen_lower', _pwLowerKey, lower);
    }
    if (digits != null) {
      await _setVaultBool('pw_gen_digits', _pwDigitsKey, digits);
    }
    if (symbols != null) {
      await _setVaultBool('pw_gen_symbols', _pwSymbolsKey, symbols);
    }
    if (avoidAmbiguous != null) {
      await _setVaultBool(
        'pw_gen_avoid_ambiguous',
        _pwAvoidAmbiguousKey,
        avoidAmbiguous,
      );
    }
  }

  Future<void> setPasswordHint(String? hint) async {
    final trimmed = hint?.trim() ?? '';
    if (trimmed.isEmpty) {
      _cachedPasswordHint = null;
      await _writeSecure(_vk('password_hint'), null);
    } else {
      _cachedPasswordHint = trimmed;
      await _writeSecure(_vk('password_hint'), trimmed);
    }
  }

  int? get collectionsOrderIndex => _prefs.getInt(_vk('collections_order'));
  bool? get collectionsReverseOrder =>
      _prefs.getBool(_vk('collections_reverse_order'));
  int? get entriesOrderIndex => _prefs.getInt(_vk('entries_order'));
  bool? get entriesReverseOrder => _prefs.getBool(_vk('entries_reverse_order'));
  int? get cardsOrderIndex => _prefs.getInt(_vk('cards_order'));
  bool? get cardsReverseOrder => _prefs.getBool(_vk('cards_reverse_order'));
  int? get cryptoOrderIndex => _prefs.getInt(_vk('crypto_order'));
  bool? get cryptoReverseOrder => _prefs.getBool(_vk('crypto_reverse_order'));
  int? get secretsOrderIndex => _prefs.getInt(_vk('secrets_order'));
  bool? get secretsReverseOrder => _prefs.getBool(_vk('secrets_reverse_order'));

  /// Named device groups inside Secrets (may be empty until secrets are moved).
  List<NamedGroup> get secretDevices {
    return _readNamedGroups(
      _vk('secret_devices'),
      fallbackIcon: NamedGroup.deviceDefaultIcon,
    );
  }

  Future<void> setSecretDevices(List<NamedGroup> devices) async {
    await _writeNamedGroups(devices, _vk('secret_devices'));
  }

  /// Named bank groups inside Cards (may be empty until cards are moved).
  List<NamedGroup> get walletBanks {
    return _readNamedGroups(
      _vk('wallet_banks'),
      fallbackIcon: NamedGroup.bankDefaultIcon,
    );
  }

  Future<void> setWalletBanks(List<NamedGroup> banks) async {
    await _writeNamedGroups(banks, _vk('wallet_banks'));
  }

  /// Named folder groups inside Crypto (may be empty until wallets are moved).
  List<NamedGroup> get cryptoFolders {
    return _readNamedGroups(
      _vk('crypto_folders'),
      fallbackIcon: NamedGroup.defaultIcon,
    );
  }

  Future<void> setCryptoFolders(List<NamedGroup> folders) async {
    await _writeNamedGroups(folders, _vk('crypto_folders'));
  }

  List<NamedGroup> _readNamedGroups(
    String prefsKey, {
    required String fallbackIcon,
  }) {
    if (prefsKey.isEmpty) return const [];
    final raw = _prefs.getString(prefsKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      final out = <NamedGroup>[];
      final seen = <String>{};
      for (final item in decoded) {
        final group = NamedGroup.fromJson(item, fallbackIcon: fallbackIcon);
        final name = group.name.trim();
        if (name.isEmpty) continue;
        final key = name.toLowerCase();
        if (seen.contains(key)) continue;
        seen.add(key);
        out.add(group.copyWith(name: name));
      }
      out.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return out;
    } catch (_) {
      return const [];
    }
  }

  Future<void> _writeNamedGroups(
    List<NamedGroup> groups,
    String prefsKey,
  ) async {
    if (prefsKey.isEmpty) return;
    final cleaned = <NamedGroup>[];
    final seen = <String>{};
    for (final g in groups) {
      final name = g.name.trim();
      if (name.isEmpty) continue;
      final key = name.toLowerCase();
      if (seen.contains(key)) continue;
      seen.add(key);
      cleaned.add(g.copyWith(name: name));
    }
    cleaned.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    await _prefs.setString(
      prefsKey,
      jsonEncode(cleaned.map((g) => g.toJson()).toList()),
    );
  }

  Future<void> setCollectionsOrder(int index) =>
      _prefs.setInt(_vk('collections_order'), index);

  Future<void> setCollectionsReverseOrder(bool value) =>
      _prefs.setBool(_vk('collections_reverse_order'), value);

  Future<void> setEntriesOrder(int index) =>
      _prefs.setInt(_vk('entries_order'), index);

  Future<void> setEntriesReverseOrder(bool value) =>
      _prefs.setBool(_vk('entries_reverse_order'), value);

  Future<void> setCardsOrder(int index) =>
      _prefs.setInt(_vk('cards_order'), index);

  Future<void> setCardsReverseOrder(bool value) =>
      _prefs.setBool(_vk('cards_reverse_order'), value);

  Future<void> setCryptoOrder(int index) =>
      _prefs.setInt(_vk('crypto_order'), index);

  Future<void> setCryptoReverseOrder(bool value) =>
      _prefs.setBool(_vk('crypto_reverse_order'), value);

  Future<void> setSecretsOrder(int index) =>
      _prefs.setInt(_vk('secrets_order'), index);

  Future<void> setSecretsReverseOrder(bool value) =>
      _prefs.setBool(_vk('secrets_reverse_order'), value);

  /// Vault-scoped preference keys to include in a backup of the active account.
  Map<String, dynamic> exportActiveVaultPreferences() {
    final id = activeAccountId;
    if (id == null) return {};
    final out = <String, dynamic>{};
    void take(String leaf, Object? value) {
      if (value != null) out['ok_$leaf'] = value;
    }

    for (final leaf in _vaultStringLeaves) {
      if (leaf == 'last_local_backup_path') continue;
      take(leaf, _prefs.getString(_vkFor(id, leaf)));
    }
    for (final leaf in _vaultIntLeaves) {
      take(leaf, _prefs.getInt(_vkFor(id, leaf)));
    }
    for (final leaf in _vaultBoolLeaves) {
      if (leaf == 'pending_subscription_offer') continue;
      take(leaf, _prefs.getBool(_vkFor(id, leaf)));
    }
    return out;
  }

  /// Applies an unprefixed `ok_*` vault-prefs map onto the active account.
  Future<void> importActiveVaultPreferences(Map<String, dynamic> data) async {
    final id = activeAccountId;
    if (id == null) return;

    Future<void> applyString(String leaf) async {
      final value = data['ok_$leaf'];
      if (value is String && value.isNotEmpty) {
        await _prefs.setString(_vkFor(id, leaf), value);
      }
    }

    Future<void> applyInt(String leaf) async {
      final value = data['ok_$leaf'];
      if (value is int) {
        await _prefs.setInt(_vkFor(id, leaf), value);
      }
    }

    Future<void> applyBool(String leaf) async {
      final value = data['ok_$leaf'];
      if (value is bool) {
        await _prefs.setBool(_vkFor(id, leaf), value);
      }
    }

    for (final leaf in _vaultStringLeaves) {
      if (leaf == 'last_local_backup_path') continue;
      await applyString(leaf);
    }
    for (final leaf in _vaultIntLeaves) {
      await applyInt(leaf);
    }
    for (final leaf in _vaultBoolLeaves) {
      if (leaf == 'pending_subscription_offer') continue;
      await applyBool(leaf);
    }
  }

  /// Wipes the active account. Remaining accounts stay; otherwise the device
  /// returns to first-run setup.
  Future<void> clearVault() async {
    final id = activeAccountId;
    if (id != null) {
      await removeAccount(id);
      return;
    }
    _clearMemoryCaches();
    await _prefs.remove(_hasVaultKey);
    await _prefs.remove(_legacyEmailKey);
    await _prefs.remove(_legacyServerUserIdKey);
    await _prefs.remove(_legacyServerRevisionKey);
    await _prefs.remove(_pendingSubscriptionOfferKey);
    await _prefs.remove(_reviewerProKey);
    for (final key in [
      _legacySaltKey,
      _legacyKdfKey,
      _legacyWrappedKey,
      _legacyAccessTokenKey,
      _legacyRefreshTokenKey,
      _legacyPasswordHintKey,
    ]) {
      await _writeSecure(key, null);
    }
  }
}

abstract class SharedPreferencesLike {
  bool? getBool(String key);
  String? getString(String key);
  int? getInt(String key);
  Future<bool> setBool(String key, bool value);
  Future<bool> setString(String key, String value);
  Future<bool> setInt(String key, int value);
  Future<bool> remove(String key);
}
