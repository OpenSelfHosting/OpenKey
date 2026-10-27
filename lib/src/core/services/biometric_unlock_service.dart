import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:openkey_app/src/src.dart';

/// Stores a device-bound wrapped vault key for biometric unlock.
class BiometricUnlockService {
  BiometricUnlockService({
    FlutterSecureStorage? storage,
    LocalAuthentication? auth,
    VaultMetadataStore? metadata,
  })  : _storage = storage ?? createAppSecureStorage(),
        _auth = auth ?? LocalAuthentication(),
        _metadata = metadata;

  final FlutterSecureStorage _storage;
  final LocalAuthentication _auth;
  final VaultMetadataStore? _metadata;
  final CryptoService _crypto = CryptoService();
  bool _authenticateInFlight = false;

  static const _enabledKey = 'ok_bio_enabled';
  static const _wrappedKey = 'ok_bio_wrapped_vault_key';
  static const _wrappedAuthHashKey = 'ok_bio_wrapped_auth_hash';
  static const _deviceKey = 'ok_bio_device_key';

  String _scoped(String key, [String? accountId]) {
    final id = accountId ?? _metadata?.activeAccountId;
    if (id == null || id.isEmpty) return key;
    return '${key}_$id';
  }

  Future<bool> get isSupported async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> get isEnabled async {
    try {
      final v = await _storage.read(key: _scoped(_enabledKey));
      if (v == 'true') return true;
      // Recover if keys exist but the flag was lost (e.g. partial write).
      final wrapped = await _storage.read(key: _scoped(_wrappedKey));
      final deviceKeyB64 = await _storage.read(key: _scoped(_deviceKey));
      if (wrapped != null &&
          wrapped.isNotEmpty &&
          deviceKeyB64 != null &&
          deviceKeyB64.isNotEmpty) {
        await _storage.write(key: _scoped(_enabledKey), value: 'true');
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Copies pre-multi-account biometric keys onto the active account once.
  Future<void> migrateLegacyIfNeeded() async {
    final id = _metadata?.activeAccountId;
    if (id == null || id.isEmpty) return;
    try {
      final already = await _storage.read(key: _scoped(_enabledKey, id));
      final scopedWrapped = await _storage.read(key: _scoped(_wrappedKey, id));
      if ((already != null && already.isNotEmpty) ||
          (scopedWrapped != null && scopedWrapped.isNotEmpty)) {
        return;
      }
      final legacyEnabled = await _storage.read(key: _enabledKey);
      final legacyWrapped = await _storage.read(key: _wrappedKey);
      if (legacyEnabled != 'true' &&
          (legacyWrapped == null || legacyWrapped.isEmpty)) {
        return;
      }
      for (final key in [
        _enabledKey,
        _wrappedKey,
        _wrappedAuthHashKey,
        _deviceKey,
      ]) {
        final value = await _storage.read(key: key);
        if (value != null && value.isNotEmpty) {
          await _storage.write(key: _scoped(key, id), value: value);
        }
        await _storage.delete(key: key);
      }
    } catch (e, st) {
      okDebugLog('BiometricUnlockService.migrateLegacyIfNeeded failed: $e\n$st');
    }
  }

  Future<void> disable({String? accountId}) async {
    try {
      final id = accountId ?? _metadata?.activeAccountId;
      await _storage.delete(key: _scoped(_enabledKey, id));
      await _storage.delete(key: _scoped(_wrappedKey, id));
      await _storage.delete(key: _scoped(_wrappedAuthHashKey, id));
      await _storage.delete(key: _scoped(_deviceKey, id));
    } catch (e, st) {
      okDebugLog('BiometricUnlockService.disable failed: $e\n$st');
    }
  }

  /// Vault key and server auth hash recovered after a successful biometric prompt.
  Future<bool> enable(
    SecretKey vaultKey, {
    required String authHash,
    required AppLocalizations s,
  }) async {
    try {
      final ok = await _authenticate(
        reason: s.enableBiometricUnlockReason,
        strings: s,
      );
      if (!ok) return false;
    } on PlatformException catch (e) {
      if (_isUserCanceled(e)) return false;
      rethrow;
    }

    final deviceKeyBytes = _crypto.generateVaultKey();
    final deviceKey = SecretKey(deviceKeyBytes);
    final vaultBytes = Uint8List.fromList(await vaultKey.extractBytes());
    final wrapped = await _crypto.wrapVaultKey(
      masterKey: deviceKey,
      vaultKeyBytes: vaultBytes,
    );
    final wrappedAuthHash = await _crypto.encryptString(
      key: deviceKey,
      plaintext: authHash,
    );
    await _storage.write(key: _scoped(_wrappedKey), value: wrapped);
    await _storage.write(
      key: _scoped(_wrappedAuthHashKey),
      value: wrappedAuthHash,
    );
    await _storage.write(
      key: _scoped(_deviceKey),
      value: base64Url.encode(deviceKeyBytes),
    );
    await _storage.write(key: _scoped(_enabledKey), value: 'true');
    return true;
  }

  /// Prompts for biometrics only (no vault-key unwrap). Returns `false` if canceled.
  Future<bool> authenticate({
    required String reason,
    required AppLocalizations s,
  }) async {
    try {
      return await _authenticate(reason: reason, strings: s);
    } on PlatformException catch (e) {
      if (_isUserCanceled(e)) return false;
      rethrow;
    }
  }

  /// Re-wrap vault key and auth hash for biometric unlock after a key change.
  ///
  /// No-op when biometric unlock is disabled. Clears biometrics if rewrap fails
  /// so a stale key cannot open (and previously wipe) the vault.
  Future<void> updateStoredVaultKey(
    SecretKey vaultKey, {
    required String authHash,
  }) async {
    try {
      if (!await isEnabled) return;
      final deviceKeyB64 = await _storage.read(key: _scoped(_deviceKey));
      if (deviceKeyB64 == null || deviceKeyB64.isEmpty) {
        return;
      }
      final deviceKey = SecretKey(CryptoService.decodeBase64Url(deviceKeyB64));
      final vaultBytes = Uint8List.fromList(await vaultKey.extractBytes());
      final wrapped = await _crypto.wrapVaultKey(
        masterKey: deviceKey,
        vaultKeyBytes: vaultBytes,
      );
      final wrappedAuthHash = await _crypto.encryptString(
        key: deviceKey,
        plaintext: authHash,
      );
      await _storage.write(key: _scoped(_wrappedKey), value: wrapped);
      await _storage.write(
        key: _scoped(_wrappedAuthHashKey),
        value: wrappedAuthHash,
      );
    } catch (e, st) {
      debugPrint('Biometric vault key update failed: $e');
      debugPrint('$st');
      await disable();
    }
  }

  /// Returns vault key and auth hash on success, or `null` if canceled / failed.
  Future<BiometricUnlockPayload?> unlockWithBiometrics({
    required AppLocalizations s,
  }) async {
    try {
      final enabled = await isEnabled;
      if (!enabled) return null;

      final ok = await _authenticate(
        reason: s.biometricUnlockReason,
        strings: s,
      );
      if (!ok) return null;

      final wrapped = await _storage.read(key: _scoped(_wrappedKey));
      final deviceKeyB64 = await _storage.read(key: _scoped(_deviceKey));
      if (wrapped == null || deviceKeyB64 == null) return null;

      final deviceKey = SecretKey(CryptoService.decodeBase64Url(deviceKeyB64));
      final vaultBytes = await _crypto.unwrapVaultKey(
        masterKey: deviceKey,
        wrappedVaultKey: wrapped,
      );
      final wrappedAuthHash =
          await _storage.read(key: _scoped(_wrappedAuthHashKey));
      var authHash = '';
      if (wrappedAuthHash != null && wrappedAuthHash.isNotEmpty) {
        try {
          authHash = await _crypto.decryptString(
            key: deviceKey,
            ciphertext: wrappedAuthHash,
          );
        } catch (_) {
          authHash = '';
        }
      }
      return BiometricUnlockPayload(
        vaultKey: SecretKey(vaultBytes),
        authHash: authHash,
      );
    } on PlatformException catch (e) {
      // -128 = errSecUserCanceled (Touch ID / Keychain prompt dismissed).
      if (_isUserCanceled(e)) return null;
      debugPrint('Biometric unlock PlatformException: $e');
      return null;
    } catch (e) {
      debugPrint('Biometric unlock error: $e');
      return null;
    }
  }

  Future<bool> _authenticate({
    required String reason,
    required AppLocalizations strings,
  }) async {
    if (_authenticateInFlight) return false;
    _authenticateInFlight = true;
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        authMessages: <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: strings.biometricUnlock,
            cancelButton: strings.cancel,
            signInHint: strings.biometricHint,
          ),
          IOSAuthMessages(cancelButton: strings.cancel),
        ],
        biometricOnly: true,
        persistAcrossBackgrounding: false,
      );
    } finally {
      _authenticateInFlight = false;
    }
  }

  bool _isUserCanceled(PlatformException e) {
    final code = e.code.toLowerCase();
    final message = (e.message ?? '').toLowerCase();
    return code == '-128' ||
        code == 'usercanceled' ||
        code == 'notauthenticated' ||
        code.contains('cancel') ||
        message.contains('cancel');
  }
}

/// Secrets recovered from biometric unlock (device-key wrapped).
class BiometricUnlockPayload {
  const BiometricUnlockPayload({
    required this.vaultKey,
    required this.authHash,
  });

  final SecretKey vaultKey;
  final String authHash;
}
