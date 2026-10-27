import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openkey_app/src/core/crypto/crypto_service.dart';

void main() {
  late CryptoService crypto;

  setUp(() {
    crypto = CryptoService();
  });

  group('password generator', () {
    test('produces requested length', () {
      expect(crypto.generatePassword(length: 24).length, 24);
    });

    test('respects charset flags', () {
      final digitsOnly = crypto.generatePassword(
        length: 32,
        upper: false,
        lower: false,
        digits: true,
        symbols: false,
      );
      expect(RegExp(r'^[0-9]+$').hasMatch(digitsOnly), isTrue);

      final ambiguousFree = crypto.generatePassword(
        length: 48,
        avoidAmbiguous: true,
      );
      expect(RegExp(r'[Il1O0o|]').hasMatch(ambiguousFree), isFalse);
    });

    test('includes every selected charset', () {
      for (var i = 0; i < 40; i++) {
        final password = crypto.generatePassword(length: 16);
        expect(RegExp(r'[A-Z]').hasMatch(password), isTrue);
        expect(RegExp(r'[a-z]').hasMatch(password), isTrue);
        expect(RegExp(r'\d').hasMatch(password), isTrue);
        expect(RegExp(r'[^A-Za-z0-9]').hasMatch(password), isTrue);
      }
    });

    test('rejects invalid options', () {
      expect(
        () => crypto.generatePassword(
          length: 8,
          upper: false,
          lower: false,
          digits: false,
          symbols: false,
        ),
        throwsArgumentError,
      );
      expect(() => crypto.generatePassword(length: 3), throwsArgumentError);
    });
  });

  group('AES-GCM vault crypto', () {
    test('encrypt/decrypt string round trip', () async {
      final vaultKey = SecretKey(crypto.generateVaultKey());
      final ciphertext = await crypto.encryptString(
        key: vaultKey,
        plaintext: 'hello vault',
      );
      final plain = await crypto.decryptString(
        key: vaultKey,
        ciphertext: ciphertext,
      );
      expect(plain, 'hello vault');
    });

    test('wrap/unwrap vault key', () async {
      final salt = crypto.generateSalt();
      final master = await crypto.deriveMasterKey(
        email: 'user@example.com',
        masterPassword: 'correct horse battery staple',
        salt: salt,
      );
      final vaultBytes = crypto.generateVaultKey();
      final wrapped = await crypto.wrapVaultKey(
        masterKey: master,
        vaultKeyBytes: vaultBytes,
      );
      final unwrapped = await crypto.unwrapVaultKey(
        masterKey: master,
        wrappedVaultKey: wrapped,
      );
      expect(unwrapped, vaultBytes);
    });

    test('rejects short ciphertext', () async {
      final vaultKey = SecretKey(crypto.generateVaultKey());
      expect(
        () => crypto.decryptString(key: vaultKey, ciphertext: 'dG9vLXNob3J0'),
        throwsA(isA<StateError>()),
      );
    });

    test('decrypts legacy padded ciphertext', () async {
      final vaultKey = SecretKey(crypto.generateVaultKey());
      final unpadded = await crypto.encryptString(
        key: vaultKey,
        plaintext: 'interop',
      );
      final raw = CryptoService.decodeBase64Url(unpadded);
      final legacyPadded = base64Url.encode(raw);
      expect(legacyPadded.contains('='), isTrue);
      final plain = await crypto.decryptString(
        key: vaultKey,
        ciphertext: legacyPadded,
      );
      expect(plain, 'interop');
    });
  });

  group('key derivation', () {
    test('auth hash is deterministic', () async {
      final salt = crypto.generateSalt();
      final master = await crypto.deriveMasterKey(
        email: 'user@example.com',
        masterPassword: 'correct horse battery staple',
        salt: salt,
      );
      final a = await crypto.deriveAuthHash(master);
      final b = await crypto.deriveAuthHash(master);
      expect(a, b);
      expect(a.isNotEmpty, isTrue);
    });

    test('email is normalized before KDF', () async {
      final salt = crypto.generateSalt();
      final a = await crypto.deriveMasterKey(
        email: 'User@Example.com',
        masterPassword: 'pw',
        salt: salt,
      );
      final b = await crypto.deriveMasterKey(
        email: 'user@example.com',
        masterPassword: 'pw',
        salt: salt,
      );
      expect(await a.extractBytes(), await b.extractBytes());
    });

    test('db key is deterministic from vault key', () async {
      final vault = SecretKey(List<int>.filled(32, 7));
      final a = await crypto.deriveDbKey(vault);
      final b = await crypto.deriveDbKey(vault);
      expect(a, b);
      expect(a.length, 32);
    });

    test('custom kdf params change derived key', () async {
      final salt = crypto.generateSalt();
      final custom = {
        'algorithm': 'argon2id',
        'memory': 32768,
        'iterations': 2,
        'parallelism': 2,
        'hashLength': CryptoService.vaultKeyLength,
      };
      final defaultKey = await crypto.deriveMasterKey(
        email: 'user@example.com',
        masterPassword: 'pw',
        salt: salt,
      );
      final customKey = await crypto.deriveMasterKey(
        email: 'user@example.com',
        masterPassword: 'pw',
        salt: salt,
        kdfParams: custom,
      );
      expect(
        await defaultKey.extractBytes(),
        isNot(await customKey.extractBytes()),
      );
    });

    test('defaultKdfParams matches constants', () {
      final params = crypto.defaultKdfParams();
      expect(params['algorithm'], 'argon2id');
      expect(params['memory'], CryptoService.argon2Memory);
      expect(params['iterations'], CryptoService.argon2Iterations);
      expect(params['parallelism'], CryptoService.argon2Parallelism);
      expect(params['hashLength'], CryptoService.vaultKeyLength);
    });
  });

  group('X25519 sealed box', () {
    test('round trip', () async {
      final recipient = await X25519().newKeyPair();
      final recipientPub = await recipient.extractPublicKey();
      final sealed = await crypto.sealForPublicKey(
        recipientPublicKeyB64: CryptoService.encodeBase64Url(recipientPub.bytes),
        plaintext: utf8.encode('org-key-bytes'),
      );
      final opened = await crypto.openSealedBox(
        identityKeyPair: recipient,
        sealed: sealed,
      );
      expect(utf8.decode(opened), 'org-key-bytes');
    });

    test('rejects invalid public key length', () async {
      expect(
        () => crypto.sealForPublicKey(
          recipientPublicKeyB64: CryptoService.encodeBase64Url([1, 2, 3]),
          plaintext: [1],
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
