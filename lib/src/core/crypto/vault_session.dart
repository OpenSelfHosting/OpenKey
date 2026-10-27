import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// In-memory session holding unlocked vault secrets.
/// Cleared on lock — never persisted.
class VaultSession {
  VaultSession();

  SecretKey? _vaultKey;
  String? _email;
  String? _authHash;
  String? _wrappedVaultKey;
  Uint8List? _dbKey;
  Map<String, dynamic>? _kdfParams;
  String? _saltBase64;

  bool get isUnlocked => _vaultKey != null;

  SecretKey get vaultKey {
    final key = _vaultKey;
    if (key == null) {
      throw StateError('Vault is locked');
    }
    return key;
  }

  String get email {
    final value = _email;
    if (value == null) throw StateError('Vault is locked');
    return value;
  }

  String get authHash {
    final value = _authHash;
    if (value == null) throw StateError('Vault is locked');
    return value;
  }

  String get wrappedVaultKey {
    final value = _wrappedVaultKey;
    if (value == null) throw StateError('Vault is locked');
    return value;
  }

  Uint8List get dbKey {
    final value = _dbKey;
    if (value == null) throw StateError('Vault is locked');
    return value;
  }

  Map<String, dynamic> get kdfParams {
    final value = _kdfParams;
    if (value == null) throw StateError('Vault is locked');
    return value;
  }

  String get saltBase64 {
    final value = _saltBase64;
    if (value == null) throw StateError('Vault is locked');
    return value;
  }

  void unlock({
    required String email,
    required SecretKey vaultKey,
    required String authHash,
    required String wrappedVaultKey,
    required Uint8List dbKey,
    required Map<String, dynamic> kdfParams,
    required String saltBase64,
  }) {
    _email = email;
    _vaultKey = vaultKey;
    _authHash = authHash;
    _wrappedVaultKey = wrappedVaultKey;
    _dbKey = dbKey;
    _kdfParams = kdfParams;
    _saltBase64 = saltBase64;
  }

  /// Updates wrapping credentials after a master-password or email rekey.
  /// The vault key and DB key stay the same.
  void updateWrapping({
    required String authHash,
    required String wrappedVaultKey,
    String? email,
  }) {
    if (!isUnlocked) {
      throw StateError('Vault is locked');
    }
    _authHash = authHash;
    _wrappedVaultKey = wrappedVaultKey;
    if (email != null) _email = email;
  }

  void lock() {
    _email = null;
    _vaultKey = null;
    _authHash = null;
    _wrappedVaultKey = null;
    _dbKey = null;
    _kdfParams = null;
    _saltBase64 = null;
  }
}
