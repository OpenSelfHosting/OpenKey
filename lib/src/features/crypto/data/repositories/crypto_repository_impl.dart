import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:openkey_app/src/src.dart';
import 'package:uuid/uuid.dart';

class CryptoRepositoryImpl implements CryptoRepository {
  CryptoRepositoryImpl(
    this._dbManager,
    this._session,
    this._crypto,
  );

  final DatabaseManager _dbManager;
  final VaultSession _session;
  final CryptoService _crypto;
  final _uuid = const Uuid();

  @override
  Stream<List<CryptoWallet>> watchWallets() async* {
    if (!_dbManager.isOpen) return;
    try {
      await for (final rows in _dbManager.db.entryDao
          .watchByCollection(CryptoIds.collectionUuid)) {
        yield await Future.wait(rows.map(_decrypt));
      }
    } catch (_) {
      // DB isolate closed (lock / hot restart) while a watch was active.
    }
  }

  @override
  FutureFailureOr<List<CryptoWallet>> getWallets() async {
    try {
      final rows = await _dbManager.db.entryDao
          .getByCollection(CryptoIds.collectionUuid);
      return Right(await Future.wait(rows.map(_decrypt)));
    } catch (_) {
      return const Left(CommonFailures.failedToGetEntries);
    }
  }

  @override
  FutureFailureOr<CryptoWallet?> getWallet(String uuid) async {
    try {
      final row = await _dbManager.db.entryDao.getByUuid(uuid);
      if (row == null ||
          row.isDeleted ||
          row.collectionUuid != CryptoIds.collectionUuid) {
        return const Right(null);
      }
      return Right(await _decrypt(row));
    } catch (_) {
      return const Left(CommonFailures.failedToGetEntries);
    }
  }

  @override
  FutureFailureOr<CryptoWallet> createWallet(CryptoWallet wallet) async {
    try {
      await _ensureReservedCollection();
      final uuid = wallet.uuid.isEmpty ? _uuid.v4() : wallet.uuid;
      final next = wallet.copyWith(uuid: uuid);
      final encrypted = await _crypto.encryptString(
        key: _session.vaultKey,
        plaintext: jsonEncode(next.toPayload()),
      );
      final row = await _dbManager.db.entryDao.insert(
        EntryTableCompanion.insert(
          uuid: uuid,
          encryptedPayload: encrypted,
          collectionUuid: const Value(CryptoIds.collectionUuid),
        ),
      );
      return Right(await _decrypt(row));
    } catch (_) {
      return const Left(CommonFailures.failedToCreateEntry);
    }
  }

  @override
  FutureFailureOr<CryptoWallet> updateWallet(CryptoWallet wallet) async {
    try {
      await _ensureReservedCollection();
      final existing = await _dbManager.db.entryDao.getByUuid(wallet.uuid);
      if (existing == null ||
          existing.collectionUuid != CryptoIds.collectionUuid) {
        return const Left(CommonFailures.notFound);
      }
      final encrypted = await _crypto.encryptString(
        key: _session.vaultKey,
        plaintext: jsonEncode(wallet.toPayload()),
      );
      final row = await _dbManager.db.entryDao.updateByUuid(
        wallet.uuid,
        EntryTableCompanion(
          collectionUuid: const Value(CryptoIds.collectionUuid),
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
  FutureFailureOr<void> deleteWallet(String uuid) async {
    try {
      final existing = await _dbManager.db.entryDao.getByUuid(uuid);
      if (existing == null ||
          existing.collectionUuid != CryptoIds.collectionUuid) {
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
        await _dbManager.db.collectionDao.getByUuid(CryptoIds.collectionUuid);
    if (existing != null && !existing.isDeleted) return;
    final encryptedName = await _crypto.encryptString(
      key: _session.vaultKey,
      plaintext: 'Crypto',
    );
    if (existing == null) {
      await _dbManager.db.collectionDao.insert(
        CollectionTableCompanion.insert(
          uuid: CryptoIds.collectionUuid,
          encryptedName: encryptedName,
          icon: const Value('material:currency_bitcoin'),
        ),
      );
      return;
    }
    await _dbManager.db.collectionDao.updateByUuid(
      CryptoIds.collectionUuid,
      CollectionTableCompanion(
        encryptedName: Value(encryptedName),
        icon: const Value('material:currency_bitcoin'),
        isDeleted: const Value(false),
        isSynced: const Value(false),
        revision: Value(existing.revision + 1),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<CryptoWallet> _decrypt(EntryTableData row) async {
    final json = await _crypto.decryptString(
      key: _session.vaultKey,
      ciphertext: row.encryptedPayload,
    );
    final payload = jsonDecode(json) as Map<String, dynamic>;
    return CryptoWallet.fromPayload(
      uuid: row.uuid,
      payload: payload,
      revision: row.revision,
      isSynced: row.isSynced,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
