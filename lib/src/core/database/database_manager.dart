import 'dart:typed_data';

import 'package:openkey_app/src/src.dart';

/// Manages the encrypted database lifecycle (open on unlock, close on lock).
class DatabaseManager {
  DatabaseManager();

  /// Wraps an already-open database (in-memory in tests).
  DatabaseManager.forTesting(AppDatabase database) : _db = database;

  AppDatabase? _db;
  String? _accountId;

  String? get accountId => _accountId;

  AppDatabase get db {
    final database = _db;
    if (database == null) {
      throw StateError('Database is not open. Unlock the vault first.');
    }
    return database;
  }

  bool get isOpen => _db != null;

  Future<void> open(Uint8List dbKey, {String? accountId}) async {
    await close();
    _accountId = accountId;
    _db = await AppDatabase.openEncrypted(dbKey, accountId: accountId);
  }

  Future<void> close() async {
    final database = _db;
    if (database != null) {
      await database.close();
      _db = null;
    }
  }

  /// Closes and deletes the local encrypted database files.
  Future<void> deleteLocalFiles({String? accountId}) async {
    await close();
    final id = accountId ?? _accountId;
    await AppDatabase.deleteDatabaseFile(accountId: id);
    _accountId = null;
  }
}
