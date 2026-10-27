import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kpasslib/kpasslib.dart';
import 'package:openkey_app/src/core/services/totp_service.dart';
import 'package:openkey_app/src/features/import/data/export_service.dart';
import 'package:openkey_app/src/features/import/data/import_service.dart';
import 'package:openkey_app/src/features/vault/domain/repositories/vault_repositories.dart';

class _UnusedCollections implements CollectionRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('not used in parser tests');
}

class _UnusedEntries implements EntryRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('not used in parser tests');
}

void main() {
  late ImportService import;

  setUp(() {
    import = ImportService(
      _UnusedCollections(),
      _UnusedEntries(),
      TotpService(),
    );
  });

  group('parseBitwardenJson', () {
    test('imports login items and folders', () {
      const raw = '''
{
  "folders": [{"id": "f1", "name": "Work"}],
  "items": [
    {
      "type": 1,
      "name": "GitHub",
      "folderId": "f1",
      "notes": "n",
      "login": {
        "username": "octocat",
        "password": "p@ss",
        "uris": [{"uri": "https://github.com"}],
        "totp": "otpauth://totp/GitHub:octocat?secret=JBSWY3DPEHPK3PXP&issuer=GitHub"
      }
    },
    {"type": 2, "name": "note-only", "notes": "skip me"}
  ]
}
''';
      final items = import.parseBitwardenJson(raw);
      expect(items, hasLength(1));
      expect(items.single.title, 'GitHub');
      expect(items.single.username, 'octocat');
      expect(items.single.password, 'p@ss');
      expect(items.single.folder, 'Work');
      expect(items.single.urls, ['https://github.com']);
      expect(items.single.totp?.secret, 'JBSWY3DPEHPK3PXP');
    });
  });

  group('parseChromeCsv', () {
    test('maps chrome password manager columns', () {
      const raw = '''name,url,username,password,note
Example,https://example.com,user,secret,hello
,https://no-name.test,a,b,
''';
      final items = import.parseChromeCsv(raw);
      expect(items, hasLength(2));
      expect(items[0].title, 'Example');
      expect(items[0].urls, ['https://example.com']);
      expect(items[0].notes, 'hello');
      expect(items[1].title, 'https://no-name.test');
    });
  });

  group('parseOnePasswordCsv', () {
    test('maps common 1Password export columns', () {
      const raw = '''Title,Username,Password,URL,Notes,OTPAuth
Bank,me,pw,https://bank.test,keep,otpauth://totp/Bank?secret=ABCD2345&digits=6
''';
      final items = import.parseOnePasswordCsv(raw);
      expect(items, hasLength(1));
      expect(items.single.title, 'Bank');
      expect(items.single.username, 'me');
      expect(items.single.password, 'pw');
      expect(items.single.urls, ['https://bank.test']);
      expect(items.single.totp?.secret, 'ABCD2345');
    });
  });

  group('parseLastPassCsv', () {
    test('maps LastPass export columns including folder and totp', () {
      const raw = '''url,username,password,totp,extra,name,grouping,fav
https://github.com,octocat,p@ss,otpauth://totp/GitHub:octocat?secret=JBSWY3DPEHPK3PXP&issuer=GitHub,,GitHub,Work,0
http://sn,,,,"secure note body",My Note,Notes,0
,,,,,,,
''';
      final items = import.parseLastPassCsv(raw);
      expect(items, hasLength(2));
      expect(items[0].title, 'GitHub');
      expect(items[0].username, 'octocat');
      expect(items[0].password, 'p@ss');
      expect(items[0].urls, ['https://github.com']);
      expect(items[0].folder, 'Work');
      expect(items[0].totp?.secret, 'JBSWY3DPEHPK3PXP');
      expect(items[1].title, 'My Note');
      expect(items[1].urls, ['http://sn']);
      expect(items[1].notes, 'secure note body');
      expect(items[1].folder, 'Notes');
    });
  });

  group('parseKeePassKdbx', () {
    Future<Uint8List> buildFixture() async {
      const password = 'test-pass';
      final creds = KdbxCredentials(
        password: ProtectedData.fromString(password),
      );
      final db = KdbxDatabase.create(credentials: creds, name: 'Demo');
      final work = db.createGroup(parent: db.root, name: 'Work');
      final entry = db.createEntry(parent: work);
      entry.fields['Title'] = KdbxTextField.fromText(text: 'GitHub');
      entry.fields['UserName'] = KdbxTextField.fromText(text: 'octocat');
      entry.fields['Password'] =
          KdbxTextField.fromText(text: 'p@ss', protected: true);
      entry.fields['URL'] =
          KdbxTextField.fromText(text: 'https://github.com');
      entry.fields['Notes'] = KdbxTextField.fromText(text: 'n');
      entry.fields['otp'] = KdbxTextField.fromText(
        text:
            'otpauth://totp/GitHub:octocat?secret=JBSWY3DPEHPK3PXP&issuer=GitHub',
      );
      final saved = await db.save();
      return Uint8List.fromList(saved);
    }

    test('maps groups, fields, and totp', () async {
      final bytes = await buildFixture();
      final items = await import.parseKeePassKdbx(
        data: bytes,
        password: 'test-pass',
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

    test('rejects wrong password', () async {
      final bytes = await buildFixture();
      await expectLater(
        import.parseKeePassKdbx(data: bytes, password: 'wrong'),
        throwsA(isA<KdbxError>()),
      );
    });
  });

  group('parseOpenKeyJson', () {
    test('round-trips OpenKey backup format', () {
      final raw = '''
{
  "format": "${ExportService.openKeyFormat}",
  "version": 1,
  "collections": [
    {"uuid": "c1", "name": "Personal", "icon": "folder", "sortOrder": 0}
  ],
  "entries": [
    {
      "title": "Site",
      "username": "u",
      "password": "p",
      "urls": ["https://site.test"],
      "notes": "",
      "collectionUuid": "c1",
      "tags": ["a"],
      "totp": {"secret": "SECRET1", "period": 30, "digits": 6, "algorithm": "SHA1"}
    }
  ]
}
''';
      final data = import.parseOpenKeyJson(raw);
      expect(data.collections, hasLength(1));
      expect(data.collections.single.uuid, 'c1');
      expect(data.entries, hasLength(1));
      expect(data.entries.single.title, 'Site');
      expect(data.entries.single.collectionUuid, 'c1');
      expect(data.entries.single.tags, ['a']);
      expect(data.entries.single.totp?.secret, 'SECRET1');
    });

    test('rejects non-OpenKey JSON', () {
      expect(
        () => import.parseOpenKeyJson('{"format":"bitwarden"}'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
