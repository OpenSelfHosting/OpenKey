import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';
import 'package:uuid/uuid.dart';

void _scheduleVaultSync() {
  if (sl.isRegistered<SyncService>()) {
    unawaited(sl<SyncService>().syncIfConnected());
  }
}

@LazySingleton(as: CollectionRepository)
class CollectionRepositoryImpl implements CollectionRepository {
  CollectionRepositoryImpl(this._dbManager, this._session, this._crypto);

  final DatabaseManager _dbManager;
  final VaultSession _session;
  final CryptoService _crypto;
  final _uuid = const Uuid();

  @override
  Stream<List<VaultCollection>> watchCollections() {
    if (!_dbManager.isOpen) {
      return const Stream.empty();
    }
    final controller = StreamController<List<VaultCollection>>();
    var epoch = 0;
    late final StreamSubscription<List<CollectionTableData>> sub;
    sub = _dbManager.db.collectionDao.watchAll().listen(
      (rows) async {
        final myEpoch = ++epoch;
        try {
          final visible = rows
              .where((r) => !ReservedCollections.isReserved(r.uuid))
              .toList();
          final items = await Future.wait(visible.map(_decrypt));
          if (myEpoch != epoch || controller.isClosed) return;
          controller.add(items);
        } catch (e, st) {
          okDebugLog(
            'CollectionRepository.watchCollections decrypt failed: $e\n$st',
          );
        }
      },
      onError: (e, st) {
        okDebugLog(
          'CollectionRepository.watchCollections stream error: $e\n$st',
        );
      },
      onDone: () {
        if (!controller.isClosed) controller.close();
      },
    );
    controller.onCancel = () {
      detachWatch(sub);
    };
    return controller.stream;
  }

  @override
  FutureFailureOr<List<VaultCollection>> getCollections() async {
    try {
      final rows = await _dbManager.db.collectionDao.getAll();
      final visible = rows.where(
        (r) => !ReservedCollections.isReserved(r.uuid),
      );
      final items = await Future.wait(visible.map(_decrypt));
      return Right(items);
    } catch (e) {
      return const Left(CommonFailures.failedToGetCollections);
    }
  }

  @override
  FutureFailureOr<VaultCollection> createCollection(
    CreateCollectionParams params,
  ) async {
    try {
      final uuid = _uuid.v4();
      final encryptedName = await _crypto.encryptString(
        key: _session.vaultKey,
        plaintext: params.name,
      );
      final row = await _dbManager.db.collectionDao.insert(
        CollectionTableCompanion.insert(
          uuid: uuid,
          encryptedName: encryptedName,
          icon: Value(params.icon),
          color: Value(params.color),
          parentUuid: Value(params.parentUuid),
        ),
      );
      _scheduleVaultSync();
      return Right(await _decrypt(row));
    } catch (e) {
      return const Left(CommonFailures.failedToCreateCollection);
    }
  }

  @override
  FutureFailureOr<VaultCollection> updateCollection(
    VaultCollection collection,
  ) async {
    try {
      final encryptedName = await _crypto.encryptString(
        key: _session.vaultKey,
        plaintext: collection.name,
      );
      final existing = await _dbManager.db.collectionDao.getByUuid(
        collection.uuid,
      );
      if (existing == null) {
        return const Left(CommonFailures.notFound);
      }
      final row = await _dbManager.db.collectionDao.updateByUuid(
        collection.uuid,
        CollectionTableCompanion(
          encryptedName: Value(encryptedName),
          icon: Value(collection.icon),
          color: Value(collection.color),
          parentUuid: Value(collection.parentUuid),
          sortOrder: Value(collection.sortOrder),
          revision: Value(existing.revision + 1),
          isSynced: const Value(false),
          updatedAt: Value(DateTime.now()),
        ),
      );
      _scheduleVaultSync();
      return Right(await _decrypt(row));
    } catch (e) {
      return const Left(CommonFailures.failedToUpdateCollection);
    }
  }

  @override
  FutureFailureOr<void> moveCollections({
    required List<String> uuids,
    String? parentUuid,
  }) async {
    try {
      await _dbManager.db.collectionDao.reparentMany(
        uuids: uuids,
        parentUuid: parentUuid,
      );
      _scheduleVaultSync();
      return const Right(null);
    } catch (e) {
      return const Left(CommonFailures.failedToUpdateCollection);
    }
  }

  @override
  FutureFailureOr<void> deleteCollection(String uuid) async {
    try {
      if (ReservedCollections.isReserved(uuid)) {
        return const Left(CommonFailures.notFound);
      }
      final all = await _dbManager.db.collectionDao.getAll();
      final target = all.where((c) => c.uuid == uuid).firstOrNull;
      final parent = target?.parentUuid;
      // Reparent children to the deleted folder's parent (flat orphan fix).
      for (final child in all.where((c) => c.parentUuid == uuid)) {
        await _dbManager.db.collectionDao.updateByUuid(
          child.uuid,
          CollectionTableCompanion(
            parentUuid: Value(parent),
            isSynced: const Value(false),
            revision: Value(child.revision + 1),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
      await _dbManager.db.entryDao.unassignCollection(uuid);
      await _dbManager.db.collectionDao.softDelete(uuid);
      _scheduleVaultSync();
      return const Right(null);
    } catch (e) {
      return const Left(CommonFailures.failedToDeleteCollection);
    }
  }

  Future<VaultCollection> _decrypt(CollectionTableData row) async {
    final name = await _crypto.decryptString(
      key: _session.vaultKey,
      ciphertext: row.encryptedName,
    );
    return VaultCollection(
      uuid: row.uuid,
      name: name,
      icon: row.icon,
      color: row.color,
      parentUuid: row.parentUuid,
      sortOrder: row.sortOrder,
      revision: row.revision,
      isSynced: row.isSynced,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}

@LazySingleton(as: EntryRepository)
class EntryRepositoryImpl implements EntryRepository {
  EntryRepositoryImpl(this._dbManager, this._session, this._crypto);

  final DatabaseManager _dbManager;
  final VaultSession _session;
  final CryptoService _crypto;
  final _uuid = const Uuid();

  @override
  Stream<List<VaultEntry>> watchEntries({String? collectionUuid}) {
    if (!_dbManager.isOpen) {
      return const Stream.empty();
    }
    late final Stream<List<EntryTableData>> stream;
    if (collectionUuid == null || collectionUuid == kVaultRootScope) {
      stream = _dbManager.db.entryDao.watchByCollection(null);
    } else if (collectionUuid == '__all__') {
      stream = _dbManager.db.entryDao.watchAll();
    } else {
      stream = _dbManager.db.entryDao.watchByCollection(collectionUuid);
    }

    // Decrypt can lag behind rapid DB writes (moves). Run decrypts concurrently
    // and drop superseded snapshots so the UI never reverts to a pre-move list.
    final controller = StreamController<List<VaultEntry>>();
    var epoch = 0;
    late final StreamSubscription<List<EntryTableData>> sub;
    sub = stream.listen(
      (rows) async {
        final myEpoch = ++epoch;
        final decrypted = <VaultEntry>[];
        for (var i = 0; i < rows.length; i++) {
          if (myEpoch != epoch) return;
          try {
            final entry = await _decryptMaybe(rows[i]);
            if (entry != null) decrypted.add(entry);
          } catch (e, st) {
            okDebugLog('EntryRepository.watchEntries decrypt failed: $e\n$st');
          }
          // Keep the event loop alive while decrypting large vaults
          // (e.g. right after a bulk import).
          if (i % 40 == 39) {
            await Future<void>.delayed(Duration.zero);
            if (myEpoch != epoch) return;
          }
        }
        if (myEpoch != epoch || controller.isClosed) return;
        controller.add(decrypted);
      },
      onError: (e, st) {
        okDebugLog('EntryRepository.watchEntries stream error: $e\n$st');
      },
      onDone: () {
        if (!controller.isClosed) controller.close();
      },
    );
    controller.onCancel = () {
      detachWatch(sub);
    };
    return controller.stream;
  }

  @override
  FutureFailureOr<List<VaultEntry>> getEntries({String? collectionUuid}) async {
    try {
      late final List<EntryTableData> rows;
      if (collectionUuid == null || collectionUuid == kVaultRootScope) {
        rows = await _dbManager.db.entryDao.getByCollection(null);
      } else if (collectionUuid == '__all__') {
        rows = await _dbManager.db.entryDao.getAll();
      } else {
        rows = await _dbManager.db.entryDao.getByCollection(collectionUuid);
      }
      final decrypted = <VaultEntry>[];
      for (final row in rows) {
        try {
          final entry = await _decryptMaybe(row);
          if (entry != null) decrypted.add(entry);
        } catch (e, st) {
          okDebugLog('EntryRepository.getEntries decrypt failed: $e\n$st');
        }
      }
      return Right(decrypted);
    } catch (e) {
      return const Left(CommonFailures.failedToGetEntries);
    }
  }

  @override
  FutureFailureOr<VaultEntry?> getEntry(String uuid) async {
    try {
      final row = await _dbManager.db.entryDao.getByUuid(uuid);
      if (row == null || row.isDeleted) return const Right(null);
      return Right(await _decryptMaybe(row));
    } catch (e) {
      return const Left(CommonFailures.failedToGetEntries);
    }
  }

  @override
  FutureFailureOr<VaultEntry> createEntry(VaultEntry entry) async {
    try {
      if (!_dbManager.isOpen) {
        return const Left(CommonFailures.vaultLocked);
      }
      if (!_session.isUnlocked) {
        return const Left(CommonFailures.vaultLocked);
      }
      final uuid = entry.uuid.isEmpty ? _uuid.v4() : entry.uuid;
      final collectionUuid = _normalizeCollectionUuid(entry.collectionUuid);
      final encrypted = await _crypto.encryptString(
        key: _session.vaultKey,
        plaintext: jsonEncode(
          entry
              .copyWith(uuid: uuid, collectionUuid: collectionUuid)
              .toPayload(),
        ),
      );
      final row = await _dbManager.db.entryDao.insert(
        EntryTableCompanion.insert(
          uuid: uuid,
          encryptedPayload: encrypted,
          collectionUuid: Value(collectionUuid),
        ),
      );
      _scheduleVaultSync();
      return Right(await _decrypt(row));
    } catch (e, st) {
      debugPrint('EntryRepository.createEntry failed: $e\n$st');
      return Left(FailureMessage(e.toString()));
    }
  }

  @override
  FutureFailureOr<int> createEntries(
    List<VaultEntry> entries, {
    void Function(int done, int total)? onProgress,
  }) async {
    try {
      if (entries.isEmpty) return const Right(0);
      final total = entries.length;
      final companions = <EntryTableCompanion>[];
      for (var i = 0; i < total; i++) {
        final entry = entries[i];
        final uuid = entry.uuid.isEmpty ? _uuid.v4() : entry.uuid;
        final collectionUuid = _normalizeCollectionUuid(entry.collectionUuid);
        final encrypted = await _crypto.encryptString(
          key: _session.vaultKey,
          plaintext: jsonEncode(
            entry
                .copyWith(uuid: uuid, collectionUuid: collectionUuid)
                .toPayload(),
          ),
        );
        companions.add(
          EntryTableCompanion.insert(
            uuid: uuid,
            encryptedPayload: encrypted,
            collectionUuid: Value(collectionUuid),
          ),
        );
        onProgress?.call(i + 1, total);
        // Yield so the import sheet can paint and Android doesn't ANR.
        if (i % 20 == 19) {
          await Future<void>.delayed(Duration.zero);
        }
      }
      await _dbManager.db.entryDao.insertAll(companions);
      _scheduleVaultSync();
      return Right(companions.length);
    } catch (e) {
      return const Left(CommonFailures.failedToCreateEntry);
    }
  }

  /// Treat empty / sentinel scope ids as "no folder" (SQL NULL).
  static String? _normalizeCollectionUuid(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value == kVaultRootScope || value == '__all__') return null;
    return value;
  }

  @override
  FutureFailureOr<VaultEntry> updateEntry(VaultEntry entry) async {
    try {
      final existing = await _dbManager.db.entryDao.getByUuid(entry.uuid);
      if (existing == null) {
        return const Left(CommonFailures.notFound);
      }
      final collectionUuid = _normalizeCollectionUuid(entry.collectionUuid);
      final normalized = entry.copyWith(
        collectionUuid: collectionUuid,
        clearCollection: collectionUuid == null,
      );
      final encrypted = await _crypto.encryptString(
        key: _session.vaultKey,
        plaintext: jsonEncode(normalized.toPayload()),
      );
      final row = await _dbManager.db.entryDao.updateByUuid(
        entry.uuid,
        EntryTableCompanion(
          collectionUuid: Value(collectionUuid),
          encryptedPayload: Value(encrypted),
          revision: Value(existing.revision + 1),
          isSynced: const Value(false),
          updatedAt: Value(DateTime.now()),
        ),
      );
      _scheduleVaultSync();
      return Right(await _decrypt(row));
    } catch (e) {
      return const Left(CommonFailures.failedToUpdateEntry);
    }
  }

  @override
  FutureFailureOr<void> moveEntries({
    required List<String> uuids,
    String? collectionUuid,
  }) async {
    try {
      await _dbManager.db.entryDao.reassignCollection(
        uuids: uuids,
        collectionUuid: _normalizeCollectionUuid(collectionUuid),
      );
      _scheduleVaultSync();
      return const Right(null);
    } catch (e) {
      return const Left(CommonFailures.failedToUpdateEntry);
    }
  }

  @override
  FutureFailureOr<void> deleteEntry(String uuid) async {
    try {
      await _dbManager.db.entryDao.softDelete(uuid);
      _scheduleVaultSync();
      return const Right(null);
    } catch (e) {
      return const Left(CommonFailures.failedToDeleteEntry);
    }
  }

  /// Returns null for wallet/card rows so they stay out of the password vault.
  Future<VaultEntry?> _decryptMaybe(EntryTableData row) async {
    if (ReservedCollections.isReserved(row.collectionUuid)) {
      return null;
    }
    final json = await _crypto.decryptString(
      key: _session.vaultKey,
      ciphertext: row.encryptedPayload,
    );
    final payload = jsonDecode(json) as Map<String, dynamic>;
    if (payload['type']?.toString() == 'card' ||
        payload['type']?.toString() == 'crypto') {
      return null;
    }
    return VaultEntry.fromPayload(
      uuid: row.uuid,
      collectionUuid: row.collectionUuid,
      payload: payload,
      revision: row.revision,
      isSynced: row.isSynced,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  Future<VaultEntry> _decrypt(EntryTableData row) async {
    final entry = await _decryptMaybe(row);
    if (entry == null) {
      throw StateError('Unexpected wallet card in password entry flow');
    }
    return entry;
  }
}
