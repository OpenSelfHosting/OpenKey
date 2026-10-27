// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_sync_dao.dart';

// ignore_for_file: type=lint
mixin _$PendingSyncDaoMixin on DatabaseAccessor<AppDatabase> {
  $PendingSyncTableTable get pendingSyncTable =>
      attachedDatabase.pendingSyncTable;
  PendingSyncDaoManager get managers => PendingSyncDaoManager(this);
}

class PendingSyncDaoManager {
  final _$PendingSyncDaoMixin _db;
  PendingSyncDaoManager(this._db);
  $$PendingSyncTableTableTableManager get pendingSyncTable =>
      $$PendingSyncTableTableTableManager(
        _db.attachedDatabase,
        _db.pendingSyncTable,
      );
}
