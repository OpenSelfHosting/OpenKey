// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry_dao.dart';

// ignore_for_file: type=lint
mixin _$EntryDaoMixin on DatabaseAccessor<AppDatabase> {
  $EntryTableTable get entryTable => attachedDatabase.entryTable;
  EntryDaoManager get managers => EntryDaoManager(this);
}

class EntryDaoManager {
  final _$EntryDaoMixin _db;
  EntryDaoManager(this._db);
  $$EntryTableTableTableManager get entryTable =>
      $$EntryTableTableTableManager(_db.attachedDatabase, _db.entryTable);
}
