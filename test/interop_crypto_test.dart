import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:openkey_app/src/core/crypto/crypto_service.dart';

/// Fixture shared with openkey_extension/scripts/interop_crypto_check.ts
void main() {
  test('auth hash is unpadded and stable for zero salt', () async {
    // Argon2id can exceed the default 30s test timeout on slow CI runners.
    final crypto = CryptoService();
    final salt = Uint8List(16);
    final master = await crypto.deriveMasterKey(
      email: 'interop@example.com',
      masterPassword: 'correct horse battery staple',
      salt: salt,
    );
    final hash = await crypto.deriveAuthHash(master);
    expect(hash.contains('='), isFalse);
    expect(hash, await crypto.deriveAuthHash(master));
    // Printed for optional manual compare with the extension script output.
    // ignore: avoid_print
    print('dart authHash=$hash');
    print('dart saltB64=${CryptoService.encodeBase64Url(salt)}');
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('encode/decode base64url padding interop', () {
    final bytes = Uint8List.fromList(List<int>.generate(32, (i) => i));
    final unpadded = CryptoService.encodeBase64Url(bytes);
    expect(unpadded.contains('='), isFalse);
    expect(CryptoService.decodeBase64Url(unpadded), bytes);
    expect(CryptoService.decodeBase64Url('$unpadded=='), bytes);
  });
}
