import 'package:drift/drift.dart';
import 'package:openkey_app/src/src.dart';

part 'collection_dao.g.dart';

@DriftAccessor(tables: [CollectionTable])
class CollectionDao extends DatabaseAccessor<AppDatabase>
    with _$CollectionDaoMixin {
  CollectionDao(super.db);

  Future<List<CollectionTableData>> getAll() {
    return (select(collectionTable)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  Stream<List<CollectionTableData>> watchAll() {
    return (select(collectionTable)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  Stream<List<CollectionTableData>> watchByParent(String? parentUuid) {
    final query = select(collectionTable)
      ..where((t) => t.isDeleted.equals(false));
    if (parentUuid == null) {
      query.where((t) => t.parentUuid.isNull());
    } else {
      query.where((t) => t.parentUuid.equals(parentUuid));
    }
    query.orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    return query.watch();
  }

  Future<List<CollectionTableData>> getByParent(String? parentUuid) {
    final query = select(collectionTable)
      ..where((t) => t.isDeleted.equals(false));
    if (parentUuid == null) {
      query.where((t) => t.parentUuid.isNull());
    } else {
      query.where((t) => t.parentUuid.equals(parentUuid));
    }
    query.orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    return query.get();
  }

  Future<CollectionTableData?> getByUuid(String uuid) {
    return (select(collectionTable)..where((t) => t.uuid.equals(uuid)))
        .getSingleOrNull();
  }

  Future<CollectionTableData> insert(CollectionTableCompanion companion) {
    return into(collectionTable).insertReturning(companion);
  }

  Future<CollectionTableData> updateByUuid(
    String uuid,
    CollectionTableCompanion companion,
  ) async {
    await (update(collectionTable)..where((t) => t.uuid.equals(uuid)))
        .write(companion);
    return (await getByUuid(uuid))!;
  }

  /// Reparents folders in one transaction (watchers emit once).
  Future<void> reparentMany({
    required List<String> uuids,
    String? parentUuid,
  }) async {
    if (uuids.isEmpty) return;
    final now = DateTime.now();
    await transaction(() async {
      for (final uuid in uuids) {
        final row = await getByUuid(uuid);
        if (row == null || row.isDeleted) continue;
        await (update(collectionTable)..where((t) => t.uuid.equals(uuid)))
            .write(
          CollectionTableCompanion(
            parentUuid: Value(parentUuid),
            isSynced: const Value(false),
            revision: Value(row.revision + 1),
            updatedAt: Value(now),
          ),
        );
      }
    });
  }

  Future<void> softDelete(String uuid) async {
    await (update(collectionTable)..where((t) => t.uuid.equals(uuid))).write(
      CollectionTableCompanion(
        isDeleted: const Value(true),
        isSynced: const Value(false),
        updatedAt: Value(DateTime.now()),
        revision: const Value.absent(),
      ),
    );
    final row = await getByUuid(uuid);
    if (row != null) {
      await (update(collectionTable)..where((t) => t.uuid.equals(uuid))).write(
        CollectionTableCompanion(revision: Value(row.revision + 1)),
      );
    }
  }

  Future<List<CollectionTableData>> getUnsynced() {
    return (select(collectionTable)..where((t) => t.isSynced.equals(false)))
        .get();
  }

  /// All rows including soft-deleted, optionally filtered by [updatedAt] cursor.
  Future<List<CollectionTableData>> getChangedSince(DateTime? since) {
    if (since == null) {
      return select(collectionTable).get();
    }
    return (select(collectionTable)
          ..where((t) => t.updatedAt.isBiggerOrEqualValue(since)))
        .get();
  }

  /// Applies a remote collection using last-write-wins by [revision]
  /// (same rule as the server sync upsert).
  Future<void> upsertFromSync(CollectionTableCompanion companion) async {
    final existing = await getByUuid(companion.uuid.value);
    if (existing == null) {
      await into(collectionTable).insert(companion);
      return;
    }
    final remoteRevision = companion.revision.present
        ? companion.revision.value
        : existing.revision;
    if (remoteRevision < existing.revision) return;
    await (update(collectionTable)
          ..where((t) => t.uuid.equals(companion.uuid.value)))
        .write(companion);
  }
}
