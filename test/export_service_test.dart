import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:openkey_app/src/core/services/totp_service.dart';
import 'package:openkey_app/src/core/types.dart';
import 'package:openkey_app/src/core/usecases/either.dart';
import 'package:openkey_app/src/features/import/data/export_service.dart';
import 'package:openkey_app/src/features/import/data/import_service.dart';
import 'package:openkey_app/src/features/vault/domain/entities/vault_collection.dart';
import 'package:openkey_app/src/features/vault/domain/entities/vault_entry.dart';
import 'package:openkey_app/src/features/vault/domain/repositories/vault_repositories.dart';

class _FakeCollections implements CollectionRepository {
  _FakeCollections(this.items);
  final List<VaultCollection> items;

  @override
  FutureFailureOr<List<VaultCollection>> getCollections() async =>
      Right(items);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('not used');
}

class _FakeEntries implements EntryRepository {
  _FakeEntries(this.items);
  final List<VaultEntry> items;

  @override
  FutureFailureOr<List<VaultEntry>> getEntries({
    String? collectionUuid,
  }) async =>
      Right(items);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('not used');
}

Uint8List _expectBytes(FailureOr<Uint8List> result) {
  late Uint8List bytes;
  var ok = false;
  result.fold(
    (f) => fail('export failed: $f'),
    (b) {
      bytes = b;
      ok = true;
    },
  );
  expect(ok, isTrue);
  return bytes;
}

void main() {
  const work = VaultCollection(uuid: 'c-work', name: 'Work');
  final sample = VaultEntry(
    uuid: 'e1',
    title: 'GitHub',
    collectionUuid: 'c-work',
    username: 'octocat',
    password: 'p@ss',
    urls: const ['https://github.com'],
    notes: 'n',
    totp: const TotpConfig(secret: 'JBSWY3DPEHPK3PXP'),
  );

  late ExportService exporter;
  late ImportService importer;

  setUp(() {
    exporter = ExportService(
      _FakeCollections([work]),
      _FakeEntries([sample]),
    );
    importer = ImportService(
      _FakeCollections([]),
      _FakeEntries([]),
      TotpService(),
    );
  });

  group('LastPass CSV export', () {
    test('round-trips through LastPass import parser', () async {
      final bytes = _expectBytes(
        await exporter.buildExport(ExportFormat.lastPassCsv),
      );
      final items = importer.parseLastPassCsv(utf8.decode(bytes));
      expect(items, hasLength(1));
      expect(items.single.title, 'GitHub');
      expect(items.single.username, 'octocat');
      expect(items.single.password, 'p@ss');
      expect(items.single.urls, ['https://github.com']);
      expect(items.single.notes, 'n');
      expect(items.single.folder, 'Work');
      expect(items.single.totp?.secret, 'JBSWY3DPEHPK3PXP');
    });

    test('uses lastpass file extension', () {
      expect(exporter.extension(ExportFormat.lastPassCsv), 'csv');
      expect(exporter.fileName(ExportFormat.lastPassCsv), contains('lastpass'));
    });
  });

  group('KeePass KDBX export', () {
    test('round-trips through KeePass import parser', () async {
      const password = 'export-pass';
      final bytes = _expectBytes(
        await exporter.buildExport(
          ExportFormat.keePassKdbx,
          keePassPassword: password,
        ),
      );
      expect(bytes, isNotEmpty);

      final items = await importer.parseKeePassKdbx(
        data: bytes,
        password: password,
      );
      expect(items, hasLength(1));
      expect(items.single.title, 'GitHub');
      expect(items.single.username, 'octocat');
      expect(items.single.password, 'p@ss');
      expect(items.single.urls, ['https://github.com']);
      expect(items.single.notes, 'n');
      expect(items.single.folder, 'Work');
      expect(items.single.totp?.secret, 'JBSWY3DPEHPK3PXP');
    });

    test('uses kdbx file extension', () {
      expect(exporter.extension(ExportFormat.keePassKdbx), 'kdbx');
      expect(exporter.fileName(ExportFormat.keePassKdbx), contains('keepass'));
    });
  });
}
