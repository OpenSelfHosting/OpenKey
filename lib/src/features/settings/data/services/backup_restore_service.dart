import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:openkey_app/src/core/crypto/crypto_service.dart';
import 'package:openkey_app/src/core/database/app_database.dart';
import 'package:openkey_app/src/core/database/database_manager.dart';
import 'package:openkey_app/src/core/services/vault_metadata_store.dart';
import 'package:openkey_app/src/core/services/vault_paths.dart';
import 'package:openkey_app/src/core/crypto/vault_session.dart';
import 'package:openkey_app/src/features/settings/data/services/backup_restore_exception.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

/// Stages reported while restoring an encrypted vault backup.
enum BackupRestoreStage {
  verifyingPassword,
  decrypting,
  writingVault,
  unlocking,
}

/// Full-vault backup: zip (sqlite + prefs + attachments) encrypted with vault key.
///
/// Wire format (`.okbak`):
/// `OKBK01` + u32be(headerLen) + headerJson + AES-GCM(nonce|ct|mac)
class BackupRestoreService {
  BackupRestoreService({
    required DatabaseManager databaseManager,
    required VaultSession session,
    required VaultMetadataStore metadata,
    required CryptoService crypto,
    required SharedPreferences preferences,
  }) : _dbManager = databaseManager,
       _session = session,
       _metadata = metadata,
       _crypto = crypto,
       _preferences = preferences;

  static const formatId = 'openkey-vault-backup';
  static const formatVersion = 1;
  static const fileExtension = 'okbak';
  static const magic = 'OKBK01';

  static const _dbEntryName = 'openkey.sqlite';
  static const _prefsEntryName = 'preferences.json';
  static const _manifestEntryName = 'manifest.json';
  static const _attachmentsPrefix = 'attachments/';

  final DatabaseManager _dbManager;
  final VaultSession _session;
  final VaultMetadataStore _metadata;
  final CryptoService _crypto;
  final SharedPreferences _preferences;

  String suggestedBackupFileName() {
    final stamp = DateTime.now().toUtc().toIso8601String().split('T').first;
    return 'openkey-backup-$stamp.$fileExtension';
  }

  /// Creates an encrypted full-vault backup. Vault must be unlocked.
  Future<Uint8List> createEncryptedBackupBytes() async {
    if (!_session.isUnlocked) {
      throw const BackupRestoreException('Unlock the vault before backing up.');
    }
    if (!_dbManager.isOpen) {
      throw const BackupRestoreException('Database is not open.');
    }

    final email = _metadata.email;
    final salt = _metadata.saltBase64;
    final wrapped = _metadata.wrappedVaultKey;
    final kdf = _metadata.kdfParams ?? _crypto.defaultKdfParams();
    if (email == null || salt == null || wrapped == null) {
      throw const BackupRestoreException('Vault metadata is incomplete.');
    }

    final zipBytes = await _createZipBytes();
    final ciphertext = await _crypto.encryptRaw(
      key: _session.vaultKey,
      plaintext: zipBytes,
    );

    PackageInfo? info;
    try {
      info = await PackageInfo.fromPlatform();
    } catch (_) {}

    final header = utf8.encode(
      jsonEncode({
        'format': formatId,
        'version': formatVersion,
        'email': email,
        'salt': salt,
        'kdf': kdf,
        'wrappedVaultKey': wrapped,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        if (info != null) 'appVersion': '${info.version}+${info.buildNumber}',
      }),
    );

    final magicBytes = utf8.encode(magic);
    final headerLen = ByteData(4)..setUint32(0, header.length);
    final out = BytesBuilder(copy: false)
      ..add(magicBytes)
      ..add(headerLen.buffer.asUint8List())
      ..add(header)
      ..add(ciphertext);
    return out.takeBytes();
  }

  /// Restores a full vault from an encrypted `.okbak` backup.
  ///
  /// Decrypts and validates the backup **before** closing the live database.
  /// Returns the vault key so the caller can unlock without a second Argon2.
  ///
  /// Caller should stop Drift watchers first; this method closes the DB only
  /// after the password has been verified and the archive decrypted.
  Future<SecretKey> restoreEncryptedBackupBytes({
    required List<int> bytes,
    required String masterPassword,
    void Function(BackupRestoreStage stage)? onProgress,
  }) async {
    void progress(BackupRestoreStage stage) => onProgress?.call(stage);

    progress(BackupRestoreStage.verifyingPassword);
    final parsed = _parseEnvelope(bytes);
    final email = parsed.email;
    final salt = CryptoService.decodeBase64Url(parsed.saltBase64);
    final masterKey = await _crypto.deriveMasterKey(
      email: email,
      masterPassword: masterPassword,
      salt: salt,
      kdfParams: parsed.kdf ?? _crypto.defaultKdfParams(),
    );

    late final Uint8List vaultKeyBytes;
    try {
      vaultKeyBytes = await _crypto.unwrapVaultKey(
        masterKey: masterKey,
        wrappedVaultKey: parsed.wrappedVaultKey,
      );
    } catch (_) {
      throw const BackupRestoreException(
        'Wrong master password, or the backup is corrupt.',
      );
    }

    progress(BackupRestoreStage.decrypting);
    final vaultKey = SecretKey(vaultKeyBytes);
    late final Uint8List zipBytes;
    try {
      zipBytes = await _crypto.decryptRaw(
        key: vaultKey,
        ciphertext: parsed.ciphertext,
      );
    } catch (_) {
      throw const BackupRestoreException(
        'Could not decrypt the backup. Wrong password or corrupt file.',
      );
    }

    final archive = ZipDecoder().decodeBytes(zipBytes);
    final manifestFile = archive.findFile(_manifestEntryName);
    if (manifestFile == null || !manifestFile.isFile) {
      throw const BackupRestoreException('Backup manifest is missing.');
    }
    final manifest =
        jsonDecode(utf8.decode(manifestFile.content)) as Map<String, dynamic>;
    if (manifest['format'] != formatId) {
      throw const BackupRestoreException('Unsupported backup format.');
    }

    final dbFile = archive.findFile(_dbEntryName);
    if (dbFile == null || !dbFile.isFile) {
      throw const BackupRestoreException('Backup database is missing.');
    }

    final prefsFile = archive.findFile(_prefsEntryName);
    if (prefsFile == null || !prefsFile.isFile) {
      throw const BackupRestoreException('Backup preferences are missing.');
    }

    // Password verified and archive decrypted — safe to replace the live vault.
    progress(BackupRestoreStage.writingVault);
    final replacing = _session.isUnlocked;
    if (_metadata.emailExists(
      email,
      excludingId: replacing ? _metadata.activeAccountId : null,
    )) {
      throw const BackupRestoreException(
        'That email already has a vault on this device.',
      );
    }

    if (_dbManager.isOpen) {
      await _dbManager.close();
    }
    _session.lock();

    final previousId = _metadata.activeAccountId;
    String? createdId;
    if (!replacing) {
      final account = await _metadata.createAccount(email: email);
      createdId = account.id;
    }

    try {
      await AppDatabase.deleteDatabaseFile(
        accountId: _metadata.activeAccountId,
      );
      final targetDb = await AppDatabase.databaseFile(
        accountId: _metadata.activeAccountId,
      );
      await targetDb.writeAsBytes(dbFile.content, flush: true);

      await _restoreAttachments(archive);
      await _restorePreferences(
        jsonDecode(utf8.decode(prefsFile.content)) as Map<String, dynamic>,
      );
      await _preferences.reload();
      // Prefer header crypto fields so unlock always matches the decrypted vault,
      // even if an older backup's preferences.json was incomplete.
      await _metadata.saveVaultMetadata(
        email: email,
        saltBase64: parsed.saltBase64,
        kdfParams: parsed.kdf ?? _crypto.defaultKdfParams(),
        wrappedVaultKey: parsed.wrappedVaultKey,
      );
      return vaultKey;
    } catch (e) {
      if (createdId != null) {
        try {
          await VaultPaths.deleteAccountFiles(createdId);
        } catch (_) {}
        await _metadata.removeAccount(createdId, switchTo: previousId);
      }
      rethrow;
    }
  }

  /// Reads unlock email from a backup without decrypting the vault payload.
  String? peekBackupEmail(List<int> bytes) {
    try {
      return _parseEnvelope(bytes).email;
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List> _createZipBytes() async {
    await _dbManager.db.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');

    final archive = Archive();
    PackageInfo? info;
    try {
      info = await PackageInfo.fromPlatform();
    } catch (_) {}

    archive.addFile(
      ArchiveFile.string(
        _manifestEntryName,
        const JsonEncoder.withIndent('  ').convert({
          'format': formatId,
          'version': formatVersion,
          'createdAt': DateTime.now().toUtc().toIso8601String(),
          if (info != null) 'appVersion': '${info.version}+${info.buildNumber}',
        }),
      ),
    );

    final dbFile = await AppDatabase.databaseFile(
      accountId: _metadata.activeAccountId,
    );
    if (!await dbFile.exists()) {
      throw const BackupRestoreException('Database file was not found.');
    }
    archive.addFile(
      ArchiveFile(
        _dbEntryName,
        await dbFile.length(),
        await dbFile.readAsBytes(),
      ),
    );

    archive.addFile(
      ArchiveFile.string(
        _prefsEntryName,
        const JsonEncoder.withIndent('  ').convert(_exportPreferences()),
      ),
    );

    await _addAttachments(archive);
    return ZipEncoder().encodeBytes(archive);
  }

  Future<void> _addAttachments(Archive archive) async {
    final dir = await VaultPaths.attachmentsDir(
      accountId: _metadata.activeAccountId,
    );
    if (!await dir.exists()) return;

    await for (final entity in dir.list(followLinks: false)) {
      if (entity is! File) continue;
      final name = p.basename(entity.path);
      if (name.startsWith('.')) continue;
      final bytes = await entity.readAsBytes();
      archive.addFile(
        ArchiveFile('$_attachmentsPrefix$name', bytes.length, bytes),
      );
    }
  }

  Future<void> _restoreAttachments(Archive archive) async {
    final dir = await VaultPaths.attachmentsDir(
      accountId: _metadata.activeAccountId,
    );
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
    await dir.create(recursive: true);

    for (final file in archive.files) {
      if (!file.isFile) continue;
      final name = file.name;
      if (!name.startsWith(_attachmentsPrefix)) continue;
      final base = name.substring(_attachmentsPrefix.length);
      if (base.isEmpty || base.contains('/') || base.contains('\\')) continue;
      final out = File(p.join(dir.path, base));
      await out.writeAsBytes(file.content, flush: true);
    }
  }

  Map<String, dynamic> _exportPreferences() {
    return _metadata.exportActiveVaultPreferences();
  }

  Future<void> _restorePreferences(Map<String, dynamic> data) async {
    await _metadata.importActiveVaultPreferences(data);
  }

  _BackupEnvelope _parseEnvelope(List<int> bytes) {
    final data = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
    final magicBytes = utf8.encode(magic);
    if (data.length < magicBytes.length + 4) {
      throw const BackupRestoreException('Backup file is too short.');
    }
    for (var i = 0; i < magicBytes.length; i++) {
      if (data[i] != magicBytes[i]) {
        throw const BackupRestoreException(
          'Not an OpenKey encrypted vault backup (.okbak).',
        );
      }
    }
    final headerLen = ByteData.sublistView(
      data,
      magicBytes.length,
      magicBytes.length + 4,
    ).getUint32(0);
    final headerStart = magicBytes.length + 4;
    final headerEnd = headerStart + headerLen;
    if (headerEnd > data.length) {
      throw const BackupRestoreException('Backup header is truncated.');
    }
    final header =
        jsonDecode(utf8.decode(data.sublist(headerStart, headerEnd)))
            as Map<String, dynamic>;
    if (header['format'] != formatId) {
      throw const BackupRestoreException('Unsupported backup format.');
    }
    final email = header['email'] as String?;
    final salt = header['salt'] as String?;
    final wrapped = header['wrappedVaultKey'] as String?;
    if (email == null || salt == null || wrapped == null) {
      throw const BackupRestoreException('Backup header is incomplete.');
    }
    return _BackupEnvelope(
      email: email,
      saltBase64: salt,
      wrappedVaultKey: wrapped,
      kdf: (header['kdf'] as Map?)?.cast<String, dynamic>(),
      ciphertext: data.sublist(headerEnd),
    );
  }
}

class _BackupEnvelope {
  const _BackupEnvelope({
    required this.email,
    required this.saltBase64,
    required this.wrappedVaultKey,
    required this.ciphertext,
    this.kdf,
  });

  final String email;
  final String saltBase64;
  final String wrappedVaultKey;
  final Map<String, dynamic>? kdf;
  final Uint8List ciphertext;
}
