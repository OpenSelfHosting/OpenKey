import 'package:drift/drift.dart';
import 'package:openkey_app/src/src.dart';

part 'pending_sync_dao.g.dart';

@DriftAccessor(tables: [PendingSyncTable])
class PendingSyncDao extends DatabaseAccessor<AppDatabase>
    with _$PendingSyncDaoMixin {
  PendingSyncDao(super.db);

  Future<List<PendingSyncTableData>> getAll() {
    return (select(pendingSyncTable)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<int> enqueue(PendingSyncTableCompanion companion) {
    return into(pendingSyncTable).insert(companion);
  }

  Future<void> remove(int id) {
    return (delete(pendingSyncTable)..where((t) => t.id.equals(id))).go();
  }

  Future<void> clear() => delete(pendingSyncTable).go();
}
