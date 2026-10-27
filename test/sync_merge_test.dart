import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openkey_app/src/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('entry LWW upsertFromSync', () {
    test('inserts when missing and accepts higher or equal revision', () async {
      const uuid = 'entry-1';
      await db.entryDao.upsertFromSync(
        EntryTableCompanion.insert(
          uuid: uuid,
          encryptedPayload: 'v1',
          revision: const Value(1),
          isSynced: const Value(true),
        ),
      );

      await db.entryDao.upsertFromSync(
        EntryTableCompanion(
          uuid: const Value(uuid),
          encryptedPayload: const Value('v1-equal'),
          revision: const Value(1),
          isSynced: const Value(true),
        ),
      );
      expect((await db.entryDao.getByUuid(uuid))!.encryptedPayload, 'v1-equal');

      await db.entryDao.upsertFromSync(
        EntryTableCompanion(
          uuid: const Value(uuid),
          encryptedPayload: const Value('v2'),
          revision: const Value(2),
          isSynced: const Value(true),
        ),
      );
      final row = await db.entryDao.getByUuid(uuid);
      expect(row!.encryptedPayload, 'v2');
      expect(row.revision, 2);
    });

    test('rejects stale remote revision', () async {
      const uuid = 'entry-2';
      await db.entryDao.upsertFromSync(
        EntryTableCompanion.insert(
          uuid: uuid,
          encryptedPayload: 'local-newer',
          revision: const Value(5),
          isSynced: const Value(false),
        ),
      );

      await db.entryDao.upsertFromSync(
        EntryTableCompanion(
          uuid: const Value(uuid),
          encryptedPayload: const Value('stale-remote'),
          revision: const Value(4),
          isSynced: const Value(true),
        ),
      );

      final row = await db.entryDao.getByUuid(uuid);
      expect(row!.encryptedPayload, 'local-newer');
      expect(row.revision, 5);
      expect(row.isSynced, isFalse);
    });
  });

  group('getChangedSince LAN cursor', () {
    test('returns every row when since is null', () async {
      await db.entryDao.insert(
        EntryTableCompanion.insert(uuid: 'e-old', encryptedPayload: 'old'),
      );
      await db.entryDao.insert(
        EntryTableCompanion.insert(uuid: 'e-new', encryptedPayload: 'new'),
      );
      final rows = await db.entryDao.getChangedSince(null);
      expect(rows.map((r) => r.uuid), containsAll(['e-old', 'e-new']));
    });

    test(
      'includes rows at or after the cursor, including soft-deletes',
      () async {
        final older = DateTime.utc(2026, 8, 1, 10);
        final newer = DateTime.utc(2026, 8, 1, 12);
        await db.entryDao.insert(
          EntryTableCompanion.insert(
            uuid: 'e-old',
            encryptedPayload: 'old',
            updatedAt: Value(older),
          ),
        );
        await db.entryDao.insert(
          EntryTableCompanion.insert(
            uuid: 'e-new',
            encryptedPayload: 'new',
            isDeleted: const Value(true),
            updatedAt: Value(newer),
          ),
        );

        final rows = await db.entryDao.getChangedSince(newer);
        expect(rows.map((r) => r.uuid), ['e-new']);
      },
    );

    test('15s LAN skew still picks up in-flight updates', () async {
      final lastSync = DateTime.utc(2026, 8, 1, 12);
      final duringFlight = lastSync.subtract(const Duration(seconds: 10));
      final tooOld = lastSync.subtract(const Duration(seconds: 20));
      await db.entryDao.insert(
        EntryTableCompanion.insert(
          uuid: 'e-inflight',
          encryptedPayload: 'during',
          updatedAt: Value(duringFlight),
        ),
      );
      await db.entryDao.insert(
        EntryTableCompanion.insert(
          uuid: 'e-stale',
          encryptedPayload: 'stale',
          updatedAt: Value(tooOld),
        ),
      );

      final cursor = lastSync.subtract(const Duration(seconds: 15));
      final rows = await db.entryDao.getChangedSince(cursor);
      expect(rows.map((r) => r.uuid), ['e-inflight']);
    });
  });

  group('collection LWW upsertFromSync', () {
    test('rejects stale remote revision', () async {
      const uuid = 'col-1';
      await db.collectionDao.upsertFromSync(
        CollectionTableCompanion.insert(
          uuid: uuid,
          encryptedName: 'local',
          revision: const Value(3),
        ),
      );

      await db.collectionDao.upsertFromSync(
        CollectionTableCompanion(
          uuid: const Value(uuid),
          encryptedName: const Value('stale'),
          revision: const Value(2),
        ),
      );

      final row = await db.collectionDao.getByUuid(uuid);
      expect(row!.encryptedName, 'local');
      expect(row.revision, 3);
    });
  });
}
