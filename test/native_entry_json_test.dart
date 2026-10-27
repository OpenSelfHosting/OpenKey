import 'package:flutter_test/flutter_test.dart';
import 'package:openkey_app/src/features/bridge/native_entry_json.dart';
import 'package:openkey_app/src/features/vault/domain/entities/vault_entry.dart';

void main() {
  test('list JSON keeps favicons and drops attachment ciphertext', () {
    const entry = VaultEntry(
      uuid: 'e1',
      title: 'GitHub',
      collectionUuid: 'folder-1',
      username: 'ada',
      password: 'secret',
      urls: ['https://github.com'],
      icon: 'custom:favicon:png:AAAA',
      attachments: [
        AttachmentMeta(id: 'a1', name: 'note.txt', size: 12, cipher: 'BLOB'),
      ],
      passkey: PasskeyPayload(
        rpId: 'github.com',
        credentialId: 'cred',
        privateKeyCipher: 'pk',
      ),
    );

    final full = nativeEntryJson(entry);
    expect(full['icon'], 'custom:favicon:png:AAAA');
    expect((full['attachments'] as List).first['cipher'], 'BLOB');
    expect((full['passkey'] as Map)['privateKeyCipher'], 'pk');

    final list = nativeEntryJson(entry, list: true);
    expect(list['icon'], 'custom:favicon:png:AAAA');
    expect(list['collectionUuid'], 'folder-1');
    expect(list['password'], 'secret');
    expect((list['attachments'] as List).first.containsKey('cipher'), isFalse);
    expect((list['passkey'] as Map)['privateKeyCipher'], 'pk');
  });

  test('list JSON drops oversized custom photos', () {
    final huge = VaultEntry(
      uuid: 'e3',
      title: 'Photo',
      icon: 'custom:png:${'A' * (13 * 1024)}',
    );
    expect(nativeEntryJson(huge, list: true).containsKey('icon'), isFalse);
    expect(nativeEntryJson(huge)['icon'], startsWith('custom:png:'));
  });

  test('list JSON keeps brand icons', () {
    const entry = VaultEntry(
      uuid: 'e2',
      title: 'GitHub',
      icon: 'brands/github.svg',
    );
    expect(nativeEntryJson(entry, list: true)['icon'], 'brands/github.svg');
  });
}
