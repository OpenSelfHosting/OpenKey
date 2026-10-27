import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:openkey_app/src/src.dart';

@lazySingleton
class SyncService {
  SyncService(
    this._remote,
    this._api,
    this._dbManager,
    this._metadata,
    this._session,
    this._crypto,
    this._attachments,
  );

  final VaultRemoteDataSource _remote;
  final ApiClient _api;
  final DatabaseManager _dbManager;
  final VaultMetadataStore _metadata;
  final VaultSession _session;
  final CryptoService _crypto;
  final AttachmentService _attachments;

  bool _syncRunning = false;

  bool get isConfigured {
    final url = _metadata.serverUrl;
    final token = _metadata.accessToken;
    return url != null && url.isNotEmpty && token != null && token.isNotEmpty;
  }

  /// Push/pull when a server account is linked.
  Future<void> syncIfConnected() async {
    if (isConfigured && _dbManager.isOpen && _session.isUnlocked) {
      unawaited(syncNow());
    }
  }

  /// Syncs all unsynced collections and entries — including payment cards and
  /// crypto wallets (reserved collection namespaces).
  FutureFailureOr<void> syncNow() async {
    if (_syncRunning) return const Right(null);
    _syncRunning = true;
    try {
      return await _syncNowImpl();
    } finally {
      _syncRunning = false;
    }
  }

  FutureFailureOr<void> _syncNowImpl() async {
    try {
      final url = _metadata.serverUrl;
      final token = _metadata.accessToken;
      if (url == null || url.isEmpty || token == null || token.isEmpty) {
        return const Left(CommonFailures.connectServerFirst);
      }
      if (!_dbManager.isOpen) {
        return const Left(CommonFailures.vaultLocked);
      }

      _api.configure(baseUrl: url, accessToken: token);

      // Ensure reserved namespaces exist as collection rows so their entries
      // sync with a stable collection_uuid on every device.
      if (_session.isUnlocked) {
        await _ensureReservedCollections();
      }

      final unsyncedCollections = await _dbManager.db.collectionDao
          .getUnsynced();
      final unsyncedEntries = await _dbManager.db.entryDao.getUnsynced();
      final pushAttachments = await _collectPushAttachments(unsyncedEntries);

      final response = await _remote.sync(
        sinceRevision: _metadata.serverRevision,
        collections: unsyncedCollections
            .map(
              (c) => {
                'uuid': c.uuid,
                'encrypted_name': c.encryptedName,
                'icon': c.icon,
                'color': c.color,
                'parent_uuid': c.parentUuid,
                'sort_order': c.sortOrder,
                'revision': c.revision,
                'is_deleted': c.isDeleted,
              },
            )
            .toList(),
        entries: unsyncedEntries
            .map(
              (e) => {
                'uuid': e.uuid,
                'collection_uuid': e.collectionUuid,
                'encrypted_payload': e.encryptedPayload,
                'revision': e.revision,
                'is_deleted': e.isDeleted,
              },
            )
            .toList(),
        attachments: pushAttachments,
      );

      final remoteCollections =
          (response['collections'] as List?)?.cast<Map<String, dynamic>>() ??
          [];
      final remoteEntries =
          (response['entries'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final remoteAttachments =
          (response['attachments'] as List?)?.cast<Map<String, dynamic>>() ??
          [];

      for (final c in remoteCollections) {
        await _dbManager.db.collectionDao.upsertFromSync(
          CollectionTableCompanion(
            uuid: Value(c['uuid'] as String),
            encryptedName: Value(c['encrypted_name'] as String),
            icon: Value(c['icon'] as String? ?? 'folder'),
            color: Value(c['color'] as int?),
            parentUuid: Value(c['parent_uuid'] as String?),
            sortOrder: Value(c['sort_order'] as int? ?? 0),
            revision: Value(c['revision'] as int? ?? 1),
            isSynced: const Value(true),
            isDeleted: Value(c['is_deleted'] as bool? ?? false),
            updatedAt: Value(
              DateTime.tryParse(c['updated_at']?.toString() ?? '') ??
                  DateTime.now(),
            ),
          ),
        );
      }

      for (final e in remoteEntries) {
        await _dbManager.db.entryDao.upsertFromSync(
          EntryTableCompanion(
            uuid: Value(e['uuid'] as String),
            collectionUuid: Value(e['collection_uuid'] as String?),
            encryptedPayload: Value(e['encrypted_payload'] as String),
            revision: Value(e['revision'] as int? ?? 1),
            isSynced: const Value(true),
            isDeleted: Value(e['is_deleted'] as bool? ?? false),
            updatedAt: Value(
              DateTime.tryParse(e['updated_at']?.toString() ?? '') ??
                  DateTime.now(),
            ),
          ),
        );
      }

      await _applyRemoteAttachments(remoteAttachments);

      final previousRevision = _metadata.serverRevision;
      final hadLocalChanges =
          unsyncedCollections.isNotEmpty || unsyncedEntries.isNotEmpty;

      int? newRevision;
      final serverRevision = response['server_revision'];
      if (serverRevision is int && serverRevision >= 0) {
        newRevision = serverRevision;
      } else if (serverRevision is num) {
        newRevision = serverRevision.toInt();
      }

      if (hadLocalChanges &&
          (newRevision == null || newRevision <= previousRevision)) {
        return Left(FailureMessage('Server did not accept local changes.'));
      }

      // Mark pushed items as synced
      for (final c in unsyncedCollections) {
        await _dbManager.db.collectionDao.updateByUuid(
          c.uuid,
          const CollectionTableCompanion(isSynced: Value(true)),
        );
      }
      for (final e in unsyncedEntries) {
        await _dbManager.db.entryDao.updateByUuid(
          e.uuid,
          const EntryTableCompanion(isSynced: Value(true)),
        );
      }

      if (newRevision != null && newRevision >= 0) {
        await _metadata.setServerRevision(newRevision);
      }

      await _dbManager.db.pendingSyncDao.clear();

      return const Right(null);
    } on ApiException catch (e) {
      await _recordSyncFailure(e.message);
      return Left(FailureMessage(e.message));
    } catch (e) {
      return Left(FailureMessage(e.toString()));
    }
  }

  /// Pushes ciphertext blobs for attachments on unsynced entries (offline creates).
  Future<List<Map<String, dynamic>>> _collectPushAttachments(
    List<EntryTableData> unsyncedEntries,
  ) async {
    if (!_session.isUnlocked || unsyncedEntries.isEmpty) return const [];

    final pushed = <Map<String, dynamic>>[];
    for (final row in unsyncedEntries) {
      if (row.isDeleted) continue;
      List<AttachmentMeta> metas;
      try {
        final json = await _crypto.decryptString(
          key: _session.vaultKey,
          ciphertext: row.encryptedPayload,
        );
        final payload = jsonDecode(json) as Map<String, dynamic>;
        final attachmentsJson = payload['attachments'] as List?;
        metas =
            attachmentsJson
                ?.whereType<Map>()
                .map(
                  (e) => AttachmentMeta.fromJson(Map<String, dynamic>.from(e)),
                )
                .where((a) => a.id.isNotEmpty)
                .toList() ??
            const [];
      } catch (_) {
        continue;
      }

      for (final meta in metas) {
        var cipher = meta.cipher;
        cipher ??= await _attachments.readLocalCipher(meta.id);
        if (cipher == null || cipher.isEmpty) continue;
        final item = _attachments.syncPushItem(
          entryUuid: row.uuid,
          meta: meta,
          cipher: cipher,
        );
        if (item != null) pushed.add(item);
      }
    }
    return pushed;
  }

  Future<void> _applyRemoteAttachments(
    List<Map<String, dynamic>> remoteAttachments,
  ) async {
    for (final a in remoteAttachments) {
      final id = a['uuid']?.toString();
      if (id == null || id.isEmpty) continue;
      final deleted = a['is_deleted'] as bool? ?? false;
      if (deleted) {
        await _attachments.deleteLocalBlob(id);
        continue;
      }
      final blob = a['encrypted_blob']?.toString();
      if (blob == null || blob.isEmpty) continue;
      await _attachments.saveSyncedBlob(id: id, encryptedBlob: blob);
    }
  }

  Future<void> _ensureReservedCollections() async {
    await _ensureReservedCollection(
      uuid: ReservedCollections.wallets,
      plaintextName: 'Wallets',
      icon: 'material:account_balance_wallet',
    );
    await _ensureReservedCollection(
      uuid: ReservedCollections.crypto,
      plaintextName: 'Crypto',
      icon: 'material:currency_bitcoin',
    );
    await _ensureReservedCollection(
      uuid: ReservedCollections.secrets,
      plaintextName: 'Secrets',
      icon: 'material:terminal',
    );
  }

  Future<void> _ensureReservedCollection({
    required String uuid,
    required String plaintextName,
    required String icon,
  }) async {
    final existing = await _dbManager.db.collectionDao.getByUuid(uuid);
    if (existing != null && !existing.isDeleted) return;

    final encryptedName = await _crypto.encryptString(
      key: _session.vaultKey,
      plaintext: plaintextName,
    );

    if (existing == null) {
      await _dbManager.db.collectionDao.insert(
        CollectionTableCompanion.insert(
          uuid: uuid,
          encryptedName: encryptedName,
          icon: Value(icon),
        ),
      );
      return;
    }

    await _dbManager.db.collectionDao.updateByUuid(
      uuid,
      CollectionTableCompanion(
        encryptedName: Value(encryptedName),
        icon: Value(icon),
        isDeleted: const Value(false),
        isSynced: const Value(false),
        revision: Value(existing.revision + 1),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> _recordSyncFailure(String message) async {
    if (!_dbManager.isOpen) return;
    await _dbManager.db.pendingSyncDao.enqueue(
      PendingSyncTableCompanion.insert(
        entityType: 'sync',
        operationType: 'failed',
        entityUuid: '',
        payload: jsonEncode({
          'message': message,
          'revision': _metadata.serverRevision,
          'at': DateTime.now().toIso8601String(),
        }),
      ),
    );
  }
}
