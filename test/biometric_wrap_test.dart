import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openkey_app/src/core/crypto/crypto_service.dart';

/// Biometric unlock wraps the vault key with a random device key
/// (see [BiometricUnlockService.enable] / unlockWithBiometrics).
void main() {
  late CryptoService crypto;

  setUp(() {
    crypto = CryptoService();
  });

  test('device-key wrap/unwrap recovers vault key bytes', () async {
    final vaultKeyBytes = crypto.generateVaultKey();
    final deviceKeyBytes = crypto.generateVaultKey();
    final deviceKey = SecretKey(deviceKeyBytes);

    final wrapped = await crypto.wrapVaultKey(
      masterKey: deviceKey,
      vaultKeyBytes: vaultKeyBytes,
    );

    final unwrapped = await crypto.unwrapVaultKey(
      masterKey: deviceKey,
      wrappedVaultKey: wrapped,
    );

    expect(unwrapped, vaultKeyBytes);
  });

  test('device key encrypts and decrypts auth hash', () async {
    final deviceKey = SecretKey(crypto.generateVaultKey());
    const authHash = 'sample-auth-hash-b64';
    final cipher = await crypto.encryptString(key: deviceKey, plaintext: authHash);
    final plain = await crypto.decryptString(key: deviceKey, ciphertext: cipher);
    expect(plain, authHash);
  });

  test('wrong device key fails to unwrap', () async {
    final vaultKeyBytes = crypto.generateVaultKey();
    final deviceKey = SecretKey(crypto.generateVaultKey());
    final otherKey = SecretKey(crypto.generateVaultKey());

    final wrapped = await crypto.wrapVaultKey(
      masterKey: deviceKey,
      vaultKeyBytes: vaultKeyBytes,
    );

    await expectLater(
      crypto.unwrapVaultKey(masterKey: otherKey, wrappedVaultKey: wrapped),
      throwsA(anything),
    );
  });
}
