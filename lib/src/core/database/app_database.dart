import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:openkey_app/src/src.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3_lib;

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    AccountTable,
    CollectionTable,
    EntryTable,
    PendingSyncTable,
  ],
  daos: [
    AccountDao,
    CollectionDao,
    EntryDao,
    PendingSyncDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  static const String name = 'openkey';

  /// Set when [openEncrypted] created a brand-new DB file (no prior vault).
  static bool lastOpenRecreatedDatabase = false;

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) async => await migrator.createAll(),
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.addColumn(
              collectionTable,
              collectionTable.parentUuid,
            );
          }
        },
      );

  /// Opens an encrypted Drift database via SQLite3MultipleCiphers.
  static Future<AppDatabase> openEncrypted(
    Uint8List dbKey, {
    String? accountId,
  }) async {
    lastOpenRecreatedDatabase = false;
    final hexKey = _toHex(dbKey);
    final file = await databaseFile(accountId: accountId);

    final strategies = <_KeyStrategy>[
      // Canonical for binary 256-bit keys (SQLite3MC docs).
      _KeyStrategy('hexkey', (db) {
        db.execute("PRAGMA hexkey = '$hexKey'");
      }),
      // Legacy OpenKey format (SQLCipher-style raw key blob literal).
      _KeyStrategy('key-x-hex', (db) {
        db.execute("PRAGMA key = \"x'$hexKey'\"");
      }),
      // Explicit SQLCipher compatibility mode + raw key.
      _KeyStrategy('sqlcipher-x-hex', (db) {
        db.execute("PRAGMA cipher = 'sqlcipher'");
        db.execute('PRAGMA legacy = 4');
        db.execute("PRAGMA key = \"x'$hexKey'\"");
      }),
      // Treat hex string as a passphrase (KDF).
      _KeyStrategy('key-passphrase-hex', (db) {
        db.execute("PRAGMA key = '$hexKey'");
      }),
    ];

    Object? lastError;
    for (final strategy in strategies) {
      try {
        final db = await _openAndVerify(file, strategy);
        debugPrint('AppDatabase opened with strategy=${strategy.name}');
        return db;
      } catch (e) {
        lastError = e;
        debugPrint('AppDatabase strategy=${strategy.name} failed: $e');
      }
    }

    // Never silently quarantine+recreate an existing vault: a wrong key
    // (e.g. stale biometric after vault-link adopt) would wipe user data.
    // Callers that intentionally reset must delete the file first.
    if (await file.exists()) {
      throw StateError(
        'Could not decrypt the vault database. If biometric unlock was '
        'enabled before a vault-key change, unlock with your master password '
        'and re-enable biometrics. ($lastError)',
      );
    }

    final fresh = await _openAndVerify(file, strategies.first);
    lastOpenRecreatedDatabase = true;
    debugPrint('AppDatabase created fresh encrypted database');
    return fresh;
  }

  static Future<AppDatabase> _openAndVerify(
    File file,
    _KeyStrategy strategy,
  ) async {
    final executor = NativeDatabase(
      file,
      setup: (db) {
        final cipher = db.select('PRAGMA cipher');
        if (cipher.isEmpty) {
          throw UnsupportedError(
            'Encrypted SQLite (sqlite3multipleciphers) is not available. '
            'Remove sqlite3_flutter_libs / drift_flutter so the sqlite3mc '
            'hook can load, then run flutter clean && flutter run.',
          );
        }
        strategy.apply(db);
        db.execute('SELECT count(*) FROM sqlite_master');
      },
    );

    final database = AppDatabase(executor);
    try {
      await database.customSelect('SELECT 1').get();
      return database;
    } catch (e) {
      await database.close();
      rethrow;
    }
  }

  static Future<File> databaseFile({String? accountId}) {
    return VaultPaths.databaseFile(accountId: accountId);
  }

  /// Deletes the local encrypted database file (and WAL/SHM sidecars).
  static Future<void> deleteDatabaseFile({String? accountId}) {
    return VaultPaths.deleteDatabaseFiles(accountId: accountId);
  }

  static String _toHex(Uint8List bytes) {
    final buffer = StringBuffer();
    for (final b in bytes) {
      buffer.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}

class _KeyStrategy {
  const _KeyStrategy(this.name, this.apply);

  final String name;
  final void Function(sqlite3_lib.Database db) apply;
}
