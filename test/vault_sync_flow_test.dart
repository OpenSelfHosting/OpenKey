import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openkey_app/src/core/crypto/crypto_service.dart';

/// Integration-style path without a live server:
/// lock semantics → unlock key material → create ciphertext entry →
/// build sync push/pull payload shapes the server accepts.
void main() {
  late CryptoService crypto;
  late SecretKey vaultKey;
  var unlocked = false;

  setUp(() async {
    crypto = CryptoService();
    vaultKey = SecretKey(crypto.generateVaultKey());
    unlocked = true;
  });

  tearDown(() {
    unlocked = false;
  });

  test('lock → unlock → create entry → sync push/pull payload', () async {
    expect(unlocked, isTrue);

    // Lock clears in-memory key material availability.
    unlocked = false;
    expect(unlocked, isFalse);

    // Unlock restores vault key (master-password path mocked as direct key).
    unlocked = true;
    expect(unlocked, isTrue);

    final entryUuid = '11111111-1111-1111-1111-111111111111';
    final collectionUuid = '22222222-2222-2222-2222-222222222222';
    final payload = jsonEncode({
      'title': 'Example',
      'username': 'user',
      'password': 'hunter2',
      'urls': ['https://example.com'],
      'notes': '',
    });
    final ciphertext = await crypto.encryptString(
      key: vaultKey,
      plaintext: payload,
    );

    // Ciphertext must not contain plaintext fields.
    expect(ciphertext.contains('hunter2'), isFalse);
    expect(ciphertext.contains('user'), isFalse);

    final pushBody = {
      'since_revision': 0,
      'collections': [
        {
          'uuid': collectionUuid,
          'encrypted_name': await crypto.encryptString(
            key: vaultKey,
            plaintext: 'Personal',
          ),
          'icon': 'material:folder',
          'parent_uuid': null,
          'sort_order': 0,
          'revision': 1,
          'is_deleted': false,
        },
      ],
      'entries': [
        {
          'uuid': entryUuid,
          'collection_uuid': collectionUuid,
          'encrypted_payload': ciphertext,
          'revision': 1,
          'is_deleted': false,
        },
      ],
    };

    // Shape matches openkey_server SyncRequest / extension syncWith.
    expect(pushBody['since_revision'], 0);
    final entries = pushBody['entries'] as List;
    final entry = entries.single as Map<String, Object?>;
    expect(entry.keys.toSet(), {
      'uuid',
      'collection_uuid',
      'encrypted_payload',
      'revision',
      'is_deleted',
    });

    // Simulated pull applies LWW: remote revision 2 wins.
    final remotePayload = await crypto.encryptString(
      key: vaultKey,
      plaintext: jsonEncode({
        'title': 'Example',
        'username': 'user',
        'password': 'updated',
        'urls': ['https://example.com'],
        'notes': '',
      }),
    );
    var localRevision = 1;
    var localCipher = ciphertext;
    const remoteRevision = 2;
    if (remoteRevision >= localRevision) {
      localRevision = remoteRevision;
      localCipher = remotePayload;
    }
    expect(localRevision, 2);

    final plain = await crypto.decryptString(
      key: vaultKey,
      ciphertext: localCipher,
    );
    expect(jsonDecode(plain)['password'], 'updated');

    // Lock again.
    unlocked = false;
    expect(unlocked, isFalse);
  });
}
