import 'package:drift/drift.dart';
import 'package:openkey_app/src/src.dart';

part 'entry_dao.g.dart';

@DriftAccessor(tables: [EntryTable])
class EntryDao extends DatabaseAccessor<AppDatabase> with _$EntryDaoMixin {
  EntryDao(super.db);

  Future<List<EntryTableData>> getAll() {
    return (select(entryTable)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  Stream<List<EntryTableData>> watchAll() {
    return (select(entryTable)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  Expression<bool> _scope(EntryTable t, String? collectionUuid) {
    final alive = t.isDeleted.equals(false);
    if (collectionUuid == null) {
      return alive & t.collectionUuid.isNull();
    }
    return alive & t.collectionUuid.equals(collectionUuid);
  }

  Future<List<EntryTableData>> getByCollection(String? collectionUuid) {
    return (select(entryTable)
          ..where((t) => _scope(t, collectionUuid))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  Stream<List<EntryTableData>> watchByCollection(String? collectionUuid) {
    return (select(entryTable)
          ..where((t) => _scope(t, collectionUuid))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  Future<EntryTableData?> getByUuid(String uuid) {
    return (select(
      entryTable,
    )..where((t) => t.uuid.equals(uuid))).getSingleOrNull();
  }

  Future<EntryTableData> insert(EntryTableCompanion companion) {
    return into(entryTable).insertReturning(companion);
  }

  /// Bulk insert in one batch so table watchers emit a single update.
  Future<void> insertAll(List<EntryTableCompanion> companions) async {
    if (companions.isEmpty) return;
    await batch((b) {
      b.insertAll(entryTable, companions);
    });
  }

  Future<EntryTableData> updateByUuid(
    String uuid,
    EntryTableCompanion companion,
  ) async {
    await (update(
      entryTable,
    )..where((t) => t.uuid.equals(uuid))).write(companion);
    return (await getByUuid(uuid))!;
  }

  Future<void> softDelete(String uuid) async {
    final row = await getByUuid(uuid);
    if (row == null) return;
    await (update(entryTable)..where((t) => t.uuid.equals(uuid))).write(
      EntryTableCompanion(
        isDeleted: const Value(true),
        isSynced: const Value(false),
        revision: Value(row.revision + 1),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Detaches entries from a collection without deleting them.
  Future<void> unassignCollection(String collectionUuid) async {
    final rows = await getByCollection(collectionUuid);
    await reassignCollection(
      uuids: rows.map((r) => r.uuid).toList(),
      collectionUuid: null,
    );
  }

  /// Moves entries between folders by updating only [collectionUuid]
  /// (no payload re-encrypt). Runs in one transaction so watchers emit once.
  Future<void> reassignCollection({
    required List<String> uuids,
    String? collectionUuid,
  }) async {
    if (uuids.isEmpty) return;
    final now = DateTime.now();
    await transaction(() async {
      for (final uuid in uuids) {
        final row = await getByUuid(uuid);
        if (row == null || row.isDeleted) continue;
        await (update(entryTable)..where((t) => t.uuid.equals(uuid))).write(
          EntryTableCompanion(
            collectionUuid: Value(collectionUuid),
            isSynced: const Value(false),
            revision: Value(row.revision + 1),
            updatedAt: Value(now),
          ),
        );
      }
    });
  }

  Future<List<EntryTableData>> getUnsynced() {
    return (select(entryTable)..where((t) => t.isSynced.equals(false))).get();
  }

  /// All rows including soft-deleted, optionally filtered by [updatedAt] cursor.
  Future<List<EntryTableData>> getChangedSince(DateTime? since) {
    if (since == null) {
      return select(entryTable).get();
    }
    return (select(entryTable)
          ..where((t) => t.updatedAt.isBiggerOrEqualValue(since)))
        .get();
  }

  /// Applies a remote entry using last-write-wins by [revision]
  /// (same rule as the server sync upsert).
  Future<void> upsertFromSync(EntryTableCompanion companion) async {
    final existing = await getByUuid(companion.uuid.value);
    if (existing == null) {
      await into(entryTable).insert(companion);
      return;
    }
    final remoteRevision = companion.revision.present
        ? companion.revision.value
        : existing.revision;
    if (remoteRevision < existing.revision) return;
    await (update(
      entryTable,
    )..where((t) => t.uuid.equals(companion.uuid.value))).write(companion);
  }

  Future<void> clearCollection(String collectionUuid) async {
    final rows = await getByCollection(collectionUuid);
    for (final row in rows) {
      await softDelete(row.uuid);
    }
  }
}
