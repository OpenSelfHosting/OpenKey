import 'package:flutter_test/flutter_test.dart';
import 'package:openkey_app/src/features/vault/domain/entities/vault_entry.dart';

void main() {
  group('VaultEntry.isAutofillFillable', () {
    test('true when username, password, or passkey present', () {
      expect(
        const VaultEntry(uuid: '1', title: 'a', username: 'u').isAutofillFillable,
        isTrue,
      );
      expect(
        const VaultEntry(uuid: '1', title: 'a', password: 'p').isAutofillFillable,
        isTrue,
      );
      expect(
        VaultEntry(
          uuid: '1',
          title: 'a',
          passkey: const PasskeyPayload(
            rpId: 'example.com',
            credentialId: 'cid',
            privateKeyCipher: 'pk',
          ),
        ).isAutofillFillable,
        isTrue,
      );
    });

    test('false for note-only entries', () {
      expect(
        const VaultEntry(uuid: '1', title: 'note', notes: 'x').isAutofillFillable,
        isFalse,
      );
    });
  });
}
