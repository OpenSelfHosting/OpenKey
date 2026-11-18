import 'package:flutter_test/flutter_test.dart';
import 'package:openkey_shared/openkey_shared.dart';

void main() {
  group('VaultEntry payload compatibility', () {
    test('round-trips the complete vault entry payload', () {
      final entry = VaultEntry(
        uuid: 'entry-1',
        collectionUuid: 'collection-1',
        title: 'Example login',
        username: 'user@example.test',
        password: 'not-a-real-password',
        urls: const ['https://example.test'],
        notes: 'fixture only',
        tags: const ['work', 'test'],
        fields: const [
          EntryExtraField(type: 'email', value: 'user@example.test'),
          EntryExtraField(type: 'phone', value: '+10000000000'),
        ],
        fieldOrder: const ['username', 'email', 'phone'],
        icon: 'material:key',
        totp: const TotpConfig(
          secret: 'EXAMPLE-TOTP-SECRET',
          period: 45,
          digits: 8,
          algorithm: 'SHA256',
        ),
        attachments: const [
          AttachmentMeta(
            id: 'attachment-1',
            name: 'fixture.txt',
            size: 123,
            cipher: 'encrypted-fixture',
          ),
        ],
        passkey: const PasskeyPayload(
          rpId: 'example.test',
          credentialId: 'fixture-credential',
          userHandle: 'fixture-user',
          privateKeyCipher: 'encrypted-fixture-key',
          publicKey: 'fixture-public-key',
          alg: -7,
          signCount: 4,
          userName: 'user@example.test',
          displayName: 'Example User',
        ),
        revision: 7,
        isSynced: true,
      );

      final payload = entry.toPayload();
      expect(payload, {
        'title': 'Example login',
        'username': 'user@example.test',
        'password': 'not-a-real-password',
        'urls': ['https://example.test'],
        'notes': 'fixture only',
        'tags': ['work', 'test'],
        'fields': [
          {'type': 'email', 'value': 'user@example.test'},
          {'type': 'phone', 'value': '+10000000000'},
        ],
        'fieldOrder': ['username', 'email', 'phone'],
        'icon': 'material:key',
        'totp': {
          'secret': 'EXAMPLE-TOTP-SECRET',
          'period': 45,
          'digits': 8,
          'algorithm': 'SHA256',
        },
        'attachments': [
          {
            'id': 'attachment-1',
            'name': 'fixture.txt',
            'size': 123,
            'cipher': 'encrypted-fixture',
          },
        ],
        'passkey': {
          'rpId': 'example.test',
          'credentialId': 'fixture-credential',
          'userHandle': 'fixture-user',
          'privateKeyCipher': 'encrypted-fixture-key',
          'publicKey': 'fixture-public-key',
          'alg': -7,
          'signCount': 4,
          'userName': 'user@example.test',
          'displayName': 'Example User',
        },
      });

      final restored = VaultEntry.fromPayload(
        uuid: entry.uuid,
        collectionUuid: entry.collectionUuid,
        payload: payload,
        revision: entry.revision,
        isSynced: entry.isSynced,
      );

      expect(restored, entry);
      expect(restored.toPayload(), payload);
      expect(restored.isAutofillFillable, isTrue);
      expect(restored.fieldValue('email'), 'user@example.test');
      expect(restored.fieldValue('missing'), isNull);
    });

    test('keeps legacy payload defaults when optional fields are absent', () {
      final entry = VaultEntry.fromPayload(
        uuid: 'legacy-entry',
        payload: const {
          'title': 'Legacy login',
          'username': 'legacy-user',
          'password': 'legacy-secret',
        },
      );

      expect(entry.uuid, 'legacy-entry');
      expect(entry.title, 'Legacy login');
      expect(entry.urls, isEmpty);
      expect(entry.tags, isEmpty);
      expect(entry.fields, isEmpty);
      expect(entry.fieldOrder, isEmpty);
      expect(entry.icon, isEmpty);
      expect(entry.totp, isNull);
      expect(entry.attachments, isEmpty);
      expect(entry.passkey, isNull);
      expect(entry.revision, 1);
      expect(entry.isSynced, isFalse);
      expect(entry.toPayload(), {
        'title': 'Legacy login',
        'username': 'legacy-user',
        'password': 'legacy-secret',
        'urls': <String>[],
        'notes': '',
      });
    });

    test('keeps optional metadata defaults for nested values', () {
      expect(
        TotpConfig.fromJson(null),
        const TotpConfig(secret: ''),
      );
      expect(
        AttachmentMeta.fromJson(const {'id': 'a'}),
        const AttachmentMeta(id: 'a', name: '', size: 0),
      );
      expect(
        PasskeyPayload.fromJson(const {
          'rpId': 'example.test',
          'credentialId': 'id',
        }),
        const PasskeyPayload(
          rpId: 'example.test',
          credentialId: 'id',
        ),
      );
    });
  });
}
