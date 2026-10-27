import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:openkey_app/src/src.dart';
import 'package:uuid/uuid.dart';

class WalletRepositoryImpl implements WalletRepository {
  WalletRepositoryImpl(
    this._dbManager,
    this._session,
    this._crypto,
  );

  final DatabaseManager _dbManager;
  final VaultSession _session;
  final CryptoService _crypto;
  final _uuid = const Uuid();

  @override
  Stream<List<WalletCard>> watchCards() async* {
    if (!_dbManager.isOpen) return;
    try {
      await for (final rows in _dbManager.db.entryDao
          .watchByCollection(WalletIds.collectionUuid)) {
        yield await Future.wait(rows.map(_decrypt));
      }
    } catch (_) {
      // DB isolate closed (lock / hot restart) while a watch was active.
    }
  }

  @override
  FutureFailureOr<List<WalletCard>> getCards() async {
    try {
      final rows = await _dbManager.db.entryDao
          .getByCollection(WalletIds.collectionUuid);
      return Right(await Future.wait(rows.map(_decrypt)));
    } catch (_) {
      return const Left(CommonFailures.failedToGetEntries);
    }
  }

  @override
  FutureFailureOr<WalletCard?> getCard(String uuid) async {
    try {
      final row = await _dbManager.db.entryDao.getByUuid(uuid);
      if (row == null ||
          row.isDeleted ||
          row.collectionUuid != WalletIds.collectionUuid) {
        return const Right(null);
      }
      return Right(await _decrypt(row));
    } catch (_) {
      return const Left(CommonFailures.failedToGetEntries);
    }
  }

  @override
  FutureFailureOr<WalletCard> createCard(WalletCard card) async {
    try {
      await _ensureReservedCollection();
      final uuid = card.uuid.isEmpty ? _uuid.v4() : card.uuid;
      final withBrand = card.copyWith(
        uuid: uuid,
        brand: card.brand == CardBrand.other
            ? CardBrand.detect(card.number)
            : card.brand,
      );
      final encrypted = await _crypto.encryptString(
        key: _session.vaultKey,
        plaintext: jsonEncode(withBrand.toPayload()),
      );
      final row = await _dbManager.db.entryDao.insert(
        EntryTableCompanion.insert(
          uuid: uuid,
          encryptedPayload: encrypted,
          collectionUuid: const Value(WalletIds.collectionUuid),
        ),
      );
      return Right(await _decrypt(row));
    } catch (_) {
      return const Left(CommonFailures.failedToCreateEntry);
    }
  }

  @override
  FutureFailureOr<WalletCard> updateCard(WalletCard card) async {
    try {
      await _ensureReservedCollection();
      final existing = await _dbManager.db.entryDao.getByUuid(card.uuid);
      if (existing == null ||
          existing.collectionUuid != WalletIds.collectionUuid) {
        return const Left(CommonFailures.notFound);
      }
      final withBrand = card.copyWith(
        brand: CardBrand.detect(card.number),
      );
      final encrypted = await _crypto.encryptString(
        key: _session.vaultKey,
        plaintext: jsonEncode(withBrand.toPayload()),
      );
      final row = await _dbManager.db.entryDao.updateByUuid(
        card.uuid,
        EntryTableCompanion(
          collectionUuid: const Value(WalletIds.collectionUuid),
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
  FutureFailureOr<void> deleteCard(String uuid) async {
    try {
      final existing = await _dbManager.db.entryDao.getByUuid(uuid);
      if (existing == null ||
          existing.collectionUuid != WalletIds.collectionUuid) {
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
        await _dbManager.db.collectionDao.getByUuid(WalletIds.collectionUuid);
    if (existing != null && !existing.isDeleted) return;
    final encryptedName = await _crypto.encryptString(
      key: _session.vaultKey,
      plaintext: 'Wallets',
    );
    if (existing == null) {
      await _dbManager.db.collectionDao.insert(
        CollectionTableCompanion.insert(
          uuid: WalletIds.collectionUuid,
          encryptedName: encryptedName,
          icon: const Value('material:account_balance_wallet'),
        ),
      );
      return;
    }
    await _dbManager.db.collectionDao.updateByUuid(
      WalletIds.collectionUuid,
      CollectionTableCompanion(
        encryptedName: Value(encryptedName),
        icon: const Value('material:account_balance_wallet'),
        isDeleted: const Value(false),
        isSynced: const Value(false),
        revision: Value(existing.revision + 1),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<WalletCard> _decrypt(EntryTableData row) async {
    final json = await _crypto.decryptString(
      key: _session.vaultKey,
      ciphertext: row.encryptedPayload,
    );
    final payload = jsonDecode(json) as Map<String, dynamic>;
    return WalletCard.fromPayload(
      uuid: row.uuid,
      payload: payload,
      revision: row.revision,
      isSynced: row.isSynced,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
