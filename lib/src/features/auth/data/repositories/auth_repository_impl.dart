import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._crypto,
    this._session,
    this._metadata,
    this._dbManager,
    this._api,
    this._remote,
  );

  final CryptoService _crypto;
  final VaultSession _session;
  final VaultMetadataStore _metadata;
  final DatabaseManager _dbManager;
  final ApiClient _api;
  final AuthRemoteDataSource _remote;
  @override
  bool get hasVault => _metadata.hasVault;

  @override
  bool get isUnlocked => _session.isUnlocked;

  @override
  String? get email => _metadata.email;

  @override
  String? get activeAccountId => _metadata.activeAccountId;

  @override
  List<VaultAccount> get accounts => _metadata.accounts;

  Future<void> _openActiveDb(Uint8List dbKey) {
    return _dbManager.open(dbKey, accountId: _metadata.activeAccountId);
  }

  Future<void> _discardNewAccount({
    required String accountId,
    String? previousId,
  }) async {
    await _dbManager.deleteLocalFiles(accountId: accountId);
    try {
      await VaultPaths.deleteAccountFiles(accountId);
    } catch (_) {}
    try {
      await sl<BiometricUnlockService>().disable(accountId: accountId);
    } catch (_) {}
    await _metadata.removeAccount(accountId, switchTo: previousId);
  }

  @override
  FutureFailureOr<void> setupVault({
    required String email,
    required String masterPassword,
    String? passwordHint,
  }) async {
    final previousId = _metadata.activeAccountId;
    String? createdId;
    try {
      final normalized = email.trim().toLowerCase();
      if (_metadata.emailExists(normalized)) {
        return const Left(CommonFailures.accountEmailExists);
      }

      final account = await _metadata.createAccount(email: normalized);
      createdId = account.id;

      final salt = _crypto.generateSalt();
      final masterKey = await _crypto.deriveMasterKey(
        email: normalized,
        masterPassword: masterPassword,
        salt: salt,
        kdfParams: _crypto.defaultKdfParams(),
      );
      final authHash = await _crypto.deriveAuthHash(masterKey);
      final vaultKeyBytes = _crypto.generateVaultKey();
      final vaultKey = SecretKey(vaultKeyBytes);
      final wrapped = await _crypto.wrapVaultKey(
        masterKey: masterKey,
        vaultKeyBytes: vaultKeyBytes,
      );
      final dbKey = await _crypto.deriveDbKey(vaultKey);
      final kdfParams = _crypto.defaultKdfParams();
      final saltB64 = CryptoService.encodeBase64Url(salt);

      // Open encrypted DB first so a failed open does not leave a half-created vault.
      await _openActiveDb(dbKey);
      await _dbManager.db.accountDao.upsertAccount(
        AccountTableCompanion.insert(
          email: normalized,
          salt: saltB64,
          kdfParams: jsonEncode(kdfParams),
          wrappedVaultKey: wrapped,
        ),
      );

      await _metadata.saveVaultMetadata(
        email: normalized,
        saltBase64: saltB64,
        kdfParams: kdfParams,
        wrappedVaultKey: wrapped,
      );
      await _metadata.setPasswordHint(passwordHint);

      _session.unlock(
        email: normalized,
        vaultKey: vaultKey,
        authHash: authHash,
        wrappedVaultKey: wrapped,
        dbKey: dbKey,
        kdfParams: kdfParams,
        saltBase64: saltB64,
      );

      return const Right(null);
    } catch (e) {
      if (createdId != null) {
        await _discardNewAccount(accountId: createdId, previousId: previousId);
      }
      _session.lock();
      return Left(FailureMessage(e.toString()));
    }
  }

  @override
  FutureFailureOr<void> resetLocalVault() async {
    try {
      final id = _metadata.activeAccountId;
      _session.lock();
      await _dbManager.deleteLocalFiles(accountId: id);
      if (id != null) {
        try {
          await VaultPaths.deleteAccountFiles(id);
        } catch (_) {}
        try {
          await sl<BiometricUnlockService>().disable(accountId: id);
        } catch (_) {}
        await _metadata.removeAccount(id);
      } else {
        await _metadata.clearVault();
      }
      return const Right(null);
    } catch (e) {
      return Left(FailureMessage(e.toString()));
    }
  }

  @override
  FutureFailureOr<void> restoreVaultFromServer({
    required String serverUrl,
    required String email,
    required String masterPassword,
  }) async {
    final previousId = _metadata.activeAccountId;
    String? createdId;
    try {
      final normalized = email.trim().toLowerCase();
      if (_metadata.emailExists(normalized)) {
        return const Left(CommonFailures.accountEmailExists);
      }
      final url = serverUrl.trim();
      if (url.isEmpty) {
        return Left(FailureMessage('Enter a server URL.'));
      }

      final account = await _metadata.createAccount(email: normalized);
      createdId = account.id;

      _api.configure(baseUrl: url);
      await _metadata.setServerUrl(url);

      final prelogin = await _remote.prelogin(email: normalized);
      final saltB64 = prelogin['salt'] as String?;
      final kdfRaw = prelogin['kdf_params'];
      if (saltB64 == null || saltB64.isEmpty) {
        throw const _AccountSetupException(
          'Server did not return unlock salt.',
        );
      }
      final kdfParams = kdfRaw is Map
          ? Map<String, dynamic>.from(kdfRaw)
          : _crypto.defaultKdfParams();

      final salt = CryptoService.decodeBase64Url(saltB64);
      final masterKey = await _crypto.deriveMasterKey(
        email: normalized,
        masterPassword: masterPassword,
        salt: Uint8List.fromList(salt),
        kdfParams: kdfParams,
      );
      final authHash = await _crypto.deriveAuthHash(masterKey);

      final login = await _remote.login(email: normalized, authHash: authHash);
      final token = login['access_token'] as String?;
      final refresh = login['refresh_token'] as String?;
      final userId = login['user_id']?.toString();
      if (token == null || token.isEmpty) {
        throw const _AccountSetupFailure(CommonFailures.invalidCredentials);
      }

      _api.configure(
        baseUrl: url,
        accessToken: token,
        onUnauthorized: _tryRefreshAccessToken,
      );
      await _metadata.setAuthTokens(
        accessToken: token,
        refreshToken: refresh,
        serverUserId: userId,
      );

      final me = await _remote.me();
      final wrapped = me['encrypted_vault_key'] as String?;
      final meSalt = (me['salt'] as String?) ?? saltB64;
      final meKdfRaw = me['kdf_params'];
      final meKdf = meKdfRaw is Map
          ? Map<String, dynamic>.from(meKdfRaw)
          : kdfParams;
      if (wrapped == null || wrapped.isEmpty) {
        throw const _AccountSetupException(
          'Server did not return a vault key.',
        );
      }

      late final Uint8List vaultKeyBytes;
      try {
        vaultKeyBytes = await _crypto.unwrapVaultKey(
          masterKey: masterKey,
          wrappedVaultKey: wrapped,
        );
      } catch (_) {
        throw const _AccountSetupFailure(CommonFailures.invalidCredentials);
      }

      final vaultKey = SecretKey(vaultKeyBytes);
      final dbKey = await _crypto.deriveDbKey(vaultKey);

      await _openActiveDb(dbKey);
      await _dbManager.db.accountDao.upsertAccount(
        AccountTableCompanion.insert(
          email: normalized,
          salt: meSalt,
          kdfParams: jsonEncode(meKdf),
          wrappedVaultKey: wrapped,
          serverUserId: userId == null ? const Value.absent() : Value(userId),
          accessToken: Value(token),
        ),
      );

      await _metadata.saveVaultMetadata(
        email: normalized,
        saltBase64: meSalt,
        kdfParams: meKdf,
        wrappedVaultKey: wrapped,
      );

      _session.unlock(
        email: normalized,
        vaultKey: vaultKey,
        authHash: authHash,
        wrappedVaultKey: wrapped,
        dbKey: dbKey,
        kdfParams: meKdf,
        saltBase64: meSalt,
      );

      return const Right(null);
    } on _AccountSetupFailure catch (e) {
      if (createdId != null) {
        await _discardNewAccount(accountId: createdId, previousId: previousId);
      }
      _session.lock();
      return Left(e.failure);
    } on _AccountSetupException catch (e) {
      if (createdId != null) {
        await _discardNewAccount(accountId: createdId, previousId: previousId);
      }
      _session.lock();
      return Left(FailureMessage(e.message));
    } on ApiException catch (e) {
      if (createdId != null) {
        await _discardNewAccount(accountId: createdId, previousId: previousId);
      }
      _session.lock();
      return Left(FailureMessage(e.message));
    } catch (e) {
      if (createdId != null) {
        await _discardNewAccount(accountId: createdId, previousId: previousId);
      }
      _session.lock();
      return Left(FailureMessage(e.toString()));
    }
  }

  @override
  FutureFailureOr<void> unlock({required String masterPassword}) async {
    try {
      if (!_metadata.hasVault) {
        return const Left(CommonFailures.noVault);
      }

      final email = _metadata.email!;
      final salt = CryptoService.decodeBase64Url(_metadata.saltBase64!);
      final wrapped = _metadata.wrappedVaultKey!;
      final kdfParams = _metadata.kdfParams ?? _crypto.defaultKdfParams();

      final masterKey = await _crypto.deriveMasterKey(
        email: email,
        masterPassword: masterPassword,
        salt: Uint8List.fromList(salt),
        kdfParams: kdfParams,
      );

      late final Uint8List vaultKeyBytes;
      try {
        vaultKeyBytes = await _crypto.unwrapVaultKey(
          masterKey: masterKey,
          wrappedVaultKey: wrapped,
        );
      } catch (_) {
        return const Left(CommonFailures.invalidCredentials);
      }

      final vaultKey = SecretKey(vaultKeyBytes);
      final authHash = await _crypto.deriveAuthHash(masterKey);
      final dbKey = await _crypto.deriveDbKey(vaultKey);

      await _openActiveDb(dbKey);
      await _ensureAccountRow(
        email: email,
        saltB64: _metadata.saltBase64!,
        kdfParams: kdfParams,
        wrapped: wrapped,
      );

      _session.unlock(
        email: email,
        vaultKey: vaultKey,
        authHash: authHash,
        wrappedVaultKey: wrapped,
        dbKey: dbKey,
        kdfParams: kdfParams,
        saltBase64: _metadata.saltBase64!,
      );

      final token = _metadata.accessToken;
      final url = _metadata.serverUrl;
      if (url != null) {
        _api.configure(
          baseUrl: url,
          accessToken: token,
          onUnauthorized: _tryRefreshAccessToken,
        );
      }

      await sl<BiometricUnlockService>().updateStoredVaultKey(
        vaultKey,
        authHash: authHash,
      );

      return const Right(null);
    } catch (e) {
      return Left(FailureMessage(e.toString()));
    }
  }

  @override
  FutureFailureOr<void> unlockWithVaultKey(
    SecretKey vaultKey, {
    String? authHash,
  }) async {
    try {
      if (!_metadata.hasVault) {
        return const Left(CommonFailures.noVault);
      }
      final email = _metadata.email!;
      final wrapped = _metadata.wrappedVaultKey!;
      final kdfParams = _metadata.kdfParams ?? _crypto.defaultKdfParams();
      final saltB64 = _metadata.saltBase64!;
      final dbKey = await _crypto.deriveDbKey(vaultKey);
      await _openActiveDb(dbKey);
      await _ensureAccountRow(
        email: email,
        saltB64: saltB64,
        kdfParams: kdfParams,
        wrapped: wrapped,
      );

      _session.unlock(
        email: email,
        vaultKey: vaultKey,
        authHash: authHash ?? '',
        wrappedVaultKey: wrapped,
        dbKey: dbKey,
        kdfParams: kdfParams,
        saltBase64: saltB64,
      );

      final token = _metadata.accessToken;
      final url = _metadata.serverUrl;
      if (url != null) {
        _api.configure(
          baseUrl: url,
          accessToken: token,
          onUnauthorized: _tryRefreshAccessToken,
        );
      }
      return const Right(null);
    } catch (e) {
      return Left(FailureMessage(e.toString()));
    }
  }

  @override
  Map<String, String>? extensionLinkPayload() {
    if (!_metadata.hasVault) return null;
    return {
      'email': _metadata.email ?? '',
      'saltB64': _metadata.saltBase64 ?? '',
      'wrappedVaultKey': _metadata.wrappedVaultKey ?? '',
      'kdfParams': jsonEncode(
        _metadata.kdfParams ?? _crypto.defaultKdfParams(),
      ),
    };
  }

  @override
  FutureFailureOr<void> lock() async {
    try {
      _session.lock();
      await _dbManager.close();
      return const Right(null);
    } catch (e) {
      return Left(FailureMessage(e.toString()));
    }
  }

  @override
  FutureFailureOr<void> registerWithServer({required String serverUrl}) async {
    try {
      if (!_session.isUnlocked) {
        return const Left(CommonFailures.vaultLocked);
      }

      _api.configure(baseUrl: serverUrl);
      await _metadata.setServerUrl(serverUrl);

      final response = await _remote.register(
        email: _session.email,
        authHash: _session.authHash,
        encryptedVaultKey: _session.wrappedVaultKey,
        kdfParams: _session.kdfParams,
        salt: _session.saltBase64,
      );

      final token = response['access_token'] as String?;
      final refresh = response['refresh_token'] as String?;
      final userId = response['user_id']?.toString();
      _api.configure(
        accessToken: token,
        onUnauthorized: _tryRefreshAccessToken,
      );
      await _metadata.setAuthTokens(
        accessToken: token,
        refreshToken: refresh,
        serverUserId: userId,
      );

      if (_dbManager.isOpen) {
        await _dbManager.db.accountDao.updateTokens(
          serverUserId: userId,
          accessToken: token,
        );
      }

      return const Right(null);
    } on ApiException catch (e) {
      return Left(FailureMessage(e.message));
    } catch (e) {
      return Left(FailureMessage(e.toString()));
    }
  }

  @override
  FutureFailureOr<void> loginWithServer({required String serverUrl}) async {
    try {
      if (!_session.isUnlocked) {
        return const Left(CommonFailures.vaultLocked);
      }

      _api.configure(baseUrl: serverUrl);
      await _metadata.setServerUrl(serverUrl);

      final response = await _remote.login(
        email: _session.email,
        authHash: _session.authHash,
      );

      final token = response['access_token'] as String?;
      final refresh = response['refresh_token'] as String?;
      final userId = response['user_id']?.toString();
      _api.configure(
        accessToken: token,
        onUnauthorized: _tryRefreshAccessToken,
      );
      await _metadata.setAuthTokens(
        accessToken: token,
        refreshToken: refresh,
        serverUserId: userId,
      );

      if (_dbManager.isOpen) {
        await _dbManager.db.accountDao.updateTokens(
          serverUserId: userId,
          accessToken: token,
        );
      }

      return const Right(null);
    } on ApiException catch (e) {
      return Left(FailureMessage(e.message));
    } catch (e) {
      return Left(FailureMessage(e.toString()));
    }
  }

  @override
  FutureFailureOr<void> changeMasterPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (!_session.isUnlocked) {
        return const Left(CommonFailures.vaultLocked);
      }
      if (!_metadata.hasVault) {
        return const Left(CommonFailures.noVault);
      }

      final email = _session.email;
      final salt = CryptoService.decodeBase64Url(_session.saltBase64);
      final currentMasterKey = await _crypto.deriveMasterKey(
        email: email,
        masterPassword: currentPassword,
        salt: Uint8List.fromList(salt),
        kdfParams: _session.kdfParams,
      );

      try {
        await _crypto.unwrapVaultKey(
          masterKey: currentMasterKey,
          wrappedVaultKey: _session.wrappedVaultKey,
        );
      } catch (_) {
        return const Left(CommonFailures.invalidCredentials);
      }

      final vaultKeyBytes = Uint8List.fromList(
        await _session.vaultKey.extractBytes(),
      );
      final newMasterKey = await _crypto.deriveMasterKey(
        email: email,
        masterPassword: newPassword,
        salt: Uint8List.fromList(salt),
        kdfParams: _session.kdfParams,
      );
      final newAuthHash = await _crypto.deriveAuthHash(newMasterKey);
      final newWrapped = await _crypto.wrapVaultKey(
        masterKey: newMasterKey,
        vaultKeyBytes: vaultKeyBytes,
      );
      final currentAuthHash = await _crypto.deriveAuthHash(currentMasterKey);

      final token = _metadata.accessToken;
      final serverUrl = _metadata.serverUrl;
      if (token != null &&
          token.isNotEmpty &&
          serverUrl != null &&
          serverUrl.isNotEmpty) {
        _api.configure(baseUrl: serverUrl, accessToken: token);
        await _remote.rekey(
          currentAuthHash: currentAuthHash,
          authHash: newAuthHash,
          encryptedVaultKey: newWrapped,
          salt: _session.saltBase64,
          kdfParams: _session.kdfParams,
        );
      }

      await _metadata.saveVaultMetadata(
        email: email,
        saltBase64: _session.saltBase64,
        kdfParams: _session.kdfParams,
        wrappedVaultKey: newWrapped,
      );

      if (_dbManager.isOpen) {
        await _dbManager.db.accountDao.upsertAccount(
          AccountTableCompanion(
            salt: Value(_session.saltBase64),
            kdfParams: Value(jsonEncode(_session.kdfParams)),
            wrappedVaultKey: Value(newWrapped),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }

      _session.updateWrapping(
        authHash: newAuthHash,
        wrappedVaultKey: newWrapped,
      );

      await sl<BiometricUnlockService>().updateStoredVaultKey(
        _session.vaultKey,
        authHash: newAuthHash,
      );

      return const Right(null);
    } on ApiException catch (e) {
      return Left(FailureMessage(e.message));
    } catch (e) {
      return Left(FailureMessage(e.toString()));
    }
  }

  @override
  FutureFailureOr<void> deleteServerAccount({
    required String masterPassword,
  }) async {
    try {
      if (!_session.isUnlocked) {
        return const Left(CommonFailures.vaultLocked);
      }

      final token = _metadata.accessToken;
      final serverUrl = _metadata.serverUrl;
      if (token == null ||
          token.isEmpty ||
          serverUrl == null ||
          serverUrl.isEmpty) {
        return Left(FailureMessage('Not connected to a server account.'));
      }

      final salt = CryptoService.decodeBase64Url(_session.saltBase64);
      final masterKey = await _crypto.deriveMasterKey(
        email: _session.email,
        masterPassword: masterPassword,
        salt: Uint8List.fromList(salt),
        kdfParams: _session.kdfParams,
      );

      try {
        await _crypto.unwrapVaultKey(
          masterKey: masterKey,
          wrappedVaultKey: _session.wrappedVaultKey,
        );
      } catch (_) {
        return const Left(CommonFailures.invalidCredentials);
      }

      final authHash = await _crypto.deriveAuthHash(masterKey);
      _api.configure(baseUrl: serverUrl, accessToken: token);
      await _remote.deleteAccount(authHash: authHash);

      await _metadata.clearServerLink();
      _api.accessToken = null;
      if (_dbManager.isOpen) {
        await _dbManager.db.accountDao.updateTokens(
          serverUserId: null,
          accessToken: null,
        );
      }

      return const Right(null);
    } on ApiException catch (e) {
      return Left(FailureMessage(e.message));
    } catch (e) {
      return Left(FailureMessage(e.toString()));
    }
  }

  Future<bool> _tryRefreshAccessToken() async {
    final refresh = _metadata.refreshToken;
    final url = _metadata.serverUrl;
    if (refresh == null || refresh.isEmpty || url == null || url.isEmpty) {
      return false;
    }
    try {
      _api.configure(baseUrl: url);
      final response = await _remote.refresh(refreshToken: refresh);
      final token = response['access_token'] as String?;
      final nextRefresh = response['refresh_token'] as String?;
      final userId = response['user_id']?.toString() ?? _metadata.serverUserId;
      if (token == null || token.isEmpty) return false;
      _api.configure(accessToken: token);
      await _metadata.setAuthTokens(
        accessToken: token,
        refreshToken: nextRefresh ?? refresh,
        serverUserId: userId,
      );
      if (_dbManager.isOpen) {
        await _dbManager.db.accountDao.updateTokens(
          serverUserId: userId,
          accessToken: token,
        );
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// After a quarantined/recreated DB (or empty account table), restore the
  /// local account row from SharedPreferences vault metadata.
  Future<void> _ensureAccountRow({
    required String email,
    required String saltB64,
    required Map<String, dynamic> kdfParams,
    required String wrapped,
  }) async {
    if (!_dbManager.isOpen) return;
    final existing = await _dbManager.db.accountDao.getAccount();
    if (existing != null && !AppDatabase.lastOpenRecreatedDatabase) return;
    await _dbManager.db.accountDao.upsertAccount(
      AccountTableCompanion.insert(
        email: email,
        salt: saltB64,
        kdfParams: jsonEncode(kdfParams),
        wrappedVaultKey: wrapped,
        serverUserId: Value(_metadata.serverUserId),
        accessToken: Value(_metadata.accessToken),
      ),
    );
  }

  @override
  FutureFailureOr<void> changeEmail({
    required String currentPassword,
    required String newEmail,
  }) async {
    try {
      if (!_session.isUnlocked) {
        return const Left(CommonFailures.vaultLocked);
      }
      if (!_metadata.hasVault) {
        return const Left(CommonFailures.noVault);
      }

      final normalized = newEmail.trim().toLowerCase();
      if (!normalized.contains('@')) {
        return Left(FailureMessage('Enter a valid email.'));
      }
      if (normalized == _session.email) {
        return Left(FailureMessage('That is already this account’s email.'));
      }
      if (_metadata.emailExists(
        normalized,
        excludingId: _metadata.activeAccountId,
      )) {
        return const Left(CommonFailures.accountEmailExists);
      }

      final currentEmail = _session.email;
      final salt = CryptoService.decodeBase64Url(_session.saltBase64);
      final currentMasterKey = await _crypto.deriveMasterKey(
        email: currentEmail,
        masterPassword: currentPassword,
        salt: Uint8List.fromList(salt),
        kdfParams: _session.kdfParams,
      );

      try {
        await _crypto.unwrapVaultKey(
          masterKey: currentMasterKey,
          wrappedVaultKey: _session.wrappedVaultKey,
        );
      } catch (_) {
        return const Left(CommonFailures.invalidCredentials);
      }

      final vaultKeyBytes = Uint8List.fromList(
        await _session.vaultKey.extractBytes(),
      );
      final newMasterKey = await _crypto.deriveMasterKey(
        email: normalized,
        masterPassword: currentPassword,
        salt: Uint8List.fromList(salt),
        kdfParams: _session.kdfParams,
      );
      final newAuthHash = await _crypto.deriveAuthHash(newMasterKey);
      final newWrapped = await _crypto.wrapVaultKey(
        masterKey: newMasterKey,
        vaultKeyBytes: vaultKeyBytes,
      );
      final currentAuthHash = await _crypto.deriveAuthHash(currentMasterKey);

      final token = _metadata.accessToken;
      final serverUrl = _metadata.serverUrl;
      if (token != null &&
          token.isNotEmpty &&
          serverUrl != null &&
          serverUrl.isNotEmpty) {
        _api.configure(baseUrl: serverUrl, accessToken: token);
        await _remote.changeEmail(
          currentAuthHash: currentAuthHash,
          email: normalized,
          authHash: newAuthHash,
          encryptedVaultKey: newWrapped,
          salt: _session.saltBase64,
          kdfParams: _session.kdfParams,
        );
      }

      await _metadata.saveVaultMetadata(
        email: normalized,
        saltBase64: _session.saltBase64,
        kdfParams: _session.kdfParams,
        wrappedVaultKey: newWrapped,
      );

      if (_dbManager.isOpen) {
        await _dbManager.db.accountDao.upsertAccount(
          AccountTableCompanion(
            email: Value(normalized),
            salt: Value(_session.saltBase64),
            kdfParams: Value(jsonEncode(_session.kdfParams)),
            wrappedVaultKey: Value(newWrapped),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }

      _session.updateWrapping(
        authHash: newAuthHash,
        wrappedVaultKey: newWrapped,
        email: normalized,
      );

      await sl<BiometricUnlockService>().updateStoredVaultKey(
        _session.vaultKey,
        authHash: newAuthHash,
      );

      return const Right(null);
    } on ApiException catch (e) {
      return Left(FailureMessage(e.message));
    } catch (e) {
      return Left(FailureMessage(e.toString()));
    }
  }

  @override
  FutureFailureOr<void> switchAccount(String accountId) async {
    try {
      if (accountId == _metadata.activeAccountId) {
        return const Right(null);
      }
      if (!_metadata.accounts.any((a) => a.id == accountId)) {
        return const Left(CommonFailures.notFound);
      }
      if (_session.isUnlocked) {
        _session.lock();
        await _dbManager.close();
      }
      await _metadata.setActiveAccount(accountId);
      final url = _metadata.serverUrl;
      final token = _metadata.accessToken;
      if (url != null && url.isNotEmpty) {
        _api.configure(
          baseUrl: url,
          accessToken: token,
          onUnauthorized: _tryRefreshAccessToken,
        );
      } else {
        _api.accessToken = null;
      }
      return const Right(null);
    } catch (e) {
      return Left(FailureMessage(e.toString()));
    }
  }

  @override
  FutureFailureOr<void> removeAccount(String accountId) async {
    try {
      if (!_metadata.accounts.any((a) => a.id == accountId)) {
        return const Left(CommonFailures.notFound);
      }
      final removingActive = accountId == _metadata.activeAccountId;
      if (removingActive && _session.isUnlocked) {
        _session.lock();
        await _dbManager.close();
      }
      await _dbManager.deleteLocalFiles(accountId: accountId);
      try {
        await VaultPaths.deleteAccountFiles(accountId);
      } catch (_) {}
      try {
        await sl<BiometricUnlockService>().disable(accountId: accountId);
      } catch (_) {}
      await _metadata.removeAccount(accountId);
      if (removingActive) {}
      return const Right(null);
    } catch (e) {
      return Left(FailureMessage(e.toString()));
    }
  }

  @override
  FutureFailureOr<void> setAccountAvatar(List<int> pngBytes) async {
    try {
      final id = _metadata.activeAccountId;
      if (id == null) return const Left(CommonFailures.noVault);
      final file = await VaultPaths.avatarFile(id, ensureDir: true);
      await file.writeAsBytes(pngBytes, flush: true);
      await _metadata.rememberAvatar(id, file.path);
      return const Right(null);
    } catch (e) {
      return Left(FailureMessage(e.toString()));
    }
  }

  @override
  FutureFailureOr<void> clearAccountAvatar() async {
    try {
      final id = _metadata.activeAccountId;
      if (id == null) return const Left(CommonFailures.noVault);
      await VaultPaths.deleteAvatar(id);
      await _metadata.forgetAvatar(id);
      return const Right(null);
    } catch (e) {
      return Left(FailureMessage(e.toString()));
    }
  }
}

class _AccountSetupFailure implements Exception {
  const _AccountSetupFailure(this.failure);
  final AppFailure failure;
}

class _AccountSetupException implements Exception {
  const _AccountSetupException(this.message);
  final String message;
}
