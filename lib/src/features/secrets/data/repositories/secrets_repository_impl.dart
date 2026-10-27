import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:openkey_app/src/src.dart';
import 'package:uuid/uuid.dart';

class SecretsRepositoryImpl implements SecretsRepository {
  SecretsRepositoryImpl(
    this._dbManager,
    this._session,
    this._crypto,
  );

  final DatabaseManager _dbManager;
  final VaultSession _session;
  final CryptoService _crypto;
  final _uuid = const Uuid();

  @override
  Stream<List<DevSecret>> watchSecrets() async* {
    if (!_dbManager.isOpen) return;
    try {
      await for (final rows in _dbManager.db.entryDao
          .watchByCollection(SecretIds.collectionUuid)) {
        yield await Future.wait(rows.map(_decrypt));
      }
    } catch (_) {
      // DB isolate closed (lock / hot restart) while a watch was active.
    }
  }

  @override
  FutureFailureOr<List<DevSecret>> getSecrets() async {
    try {
      final rows = await _dbManager.db.entryDao
          .getByCollection(SecretIds.collectionUuid);
      return Right(await Future.wait(rows.map(_decrypt)));
    } catch (_) {
      return const Left(CommonFailures.failedToGetEntries);
    }
  }

  @override
  FutureFailureOr<DevSecret?> getSecret(String uuid) async {
    try {
      final row = await _dbManager.db.entryDao.getByUuid(uuid);
      if (row == null ||
          row.isDeleted ||
          row.collectionUuid != SecretIds.collectionUuid) {
        return const Right(null);
      }
      return Right(await _decrypt(row));
    } catch (_) {
      return const Left(CommonFailures.failedToGetEntries);
    }
  }

  @override
  FutureFailureOr<DevSecret> createSecret(DevSecret secret) async {
    try {
      await _ensureReservedCollection();
      final uuid = secret.uuid.isEmpty ? _uuid.v4() : secret.uuid;
      final next = secret.copyWith(uuid: uuid);
      final encrypted = await _crypto.encryptString(
        key: _session.vaultKey,
        plaintext: jsonEncode(next.toPayload()),
      );
      final row = await _dbManager.db.entryDao.insert(
        EntryTableCompanion.insert(
          uuid: uuid,
          encryptedPayload: encrypted,
          collectionUuid: const Value(SecretIds.collectionUuid),
        ),
      );
      return Right(await _decrypt(row));
    } catch (_) {
      return const Left(CommonFailures.failedToCreateEntry);
    }
  }

  @override
  FutureFailureOr<DevSecret> updateSecret(DevSecret secret) async {
    try {
      await _ensureReservedCollection();
      final existing = await _dbManager.db.entryDao.getByUuid(secret.uuid);
      if (existing == null ||
          existing.collectionUuid != SecretIds.collectionUuid) {
        return const Left(CommonFailures.notFound);
      }
      final encrypted = await _crypto.encryptString(
        key: _session.vaultKey,
        plaintext: jsonEncode(secret.toPayload()),
      );
      final row = await _dbManager.db.entryDao.updateByUuid(
        secret.uuid,
        EntryTableCompanion(
          collectionUuid: const Value(SecretIds.collectionUuid),
          encryptedPayload: Value(encrypted),
          revision: Value(existing.revision + 1),
          isSynced: const Value(false),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return Right(await _decrypt(row));
    } catch (_) {
      return const Left(CommonFailures.failedToUpdateEntry);
    }
  }

  @override
  FutureFailureOr<void> deleteSecret(String uuid) async {
    try {
      final existing = await _dbManager.db.entryDao.getByUuid(uuid);
      if (existing == null ||
          existing.collectionUuid != SecretIds.collectionUuid) {
        return const Left(CommonFailures.notFound);
      }
      await _dbManager.db.entryDao.softDelete(uuid);
      return const Right(null);
    } catch (_) {
      return const Left(CommonFailures.failedToDeleteEntry);
    }
  }

  Future<void> _ensureReservedCollection() async {
    final existing =
        await _dbManager.db.collectionDao.getByUuid(SecretIds.collectionUuid);
    if (existing != null && !existing.isDeleted) return;
    final encryptedName = await _crypto.encryptString(
      key: _session.vaultKey,
      plaintext: 'Secrets',
    );
    if (existing == null) {
      await _dbManager.db.collectionDao.insert(
        CollectionTableCompanion.insert(
          uuid: SecretIds.collectionUuid,
          encryptedName: encryptedName,
          icon: const Value('material:terminal'),
        ),
      );
      return;
    }
    await _dbManager.db.collectionDao.updateByUuid(
      SecretIds.collectionUuid,
      CollectionTableCompanion(
        encryptedName: Value(encryptedName),
        icon: const Value('material:terminal'),
        isDeleted: const Value(false),
        isSynced: const Value(false),
        revision: Value(existing.revision + 1),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<DevSecret> _decrypt(EntryTableData row) async {
    final json = await _crypto.decryptString(
      key: _session.vaultKey,
      ciphertext: row.encryptedPayload,
    );
    final payload = jsonDecode(json) as Map<String, dynamic>;
    return DevSecret.fromPayload(
      uuid: row.uuid,
      payload: payload,
      revision: row.revision,
      isSynced: row.isSynced,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
