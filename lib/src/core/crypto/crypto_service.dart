import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:cryptography/cryptography.dart';

/// Zero-knowledge crypto for OpenKey.
///
/// - Argon2id(email + master_password, salt) → master key
/// - HMAC(master_key, "auth") → auth hash (sent to server)
/// - Random vault key wrapped with AES-GCM using master key
/// - Field payloads encrypted with vault key (AES-256-GCM)
/// - X25519 sealed boxes for org/share key wrapping between users
class CryptoService {
  CryptoService();

  static const int saltLength = 16;
  static const int vaultKeyLength = 32;
  static const int argon2Memory = 65536; // KiB
  static const int argon2Iterations = 3;
  static const int argon2Parallelism = 4;

  /// Sealed-box version byte: ephemeral X25519 pubkey + AES-GCM.
  static const int sealedBoxVersion = 0x01;

  final AesGcm _aesGcm = AesGcm.with256bits();
  final X25519 _x25519 = X25519();
  final Random _random = Random.secure();

  Uint8List generateSalt([int length = saltLength]) {
    return _randomBytes(length);
  }

  Uint8List generateVaultKey() => _randomBytes(vaultKeyLength);

  SecretKey secretKeyFromBytes(List<int> bytes) => SecretKey(bytes);

  Future<SecretKey> deriveMasterKey({
    required String email,
    required String masterPassword,
    required Uint8List salt,
    Map<String, dynamic>? kdfParams,
  }) async {
    final params = kdfParams ?? defaultKdfParams();
    final memory = params['memory'] as int? ?? argon2Memory;
    final iterations = params['iterations'] as int? ?? argon2Iterations;
    final parallelism = params['parallelism'] as int? ?? argon2Parallelism;
    final hashLength = params['hashLength'] as int? ?? vaultKeyLength;

    final argon2 = Argon2id(
      parallelism: parallelism,
      memory: memory,
      iterations: iterations,
      hashLength: hashLength,
    );

    final password =
        utf8.encode('${email.trim().toLowerCase()}:$masterPassword');
    return argon2.deriveKey(
      secretKey: SecretKey(password),
      nonce: salt,
    );
  }

  Future<String> deriveAuthHash(SecretKey masterKey) async {
    final bytes = await masterKey.extractBytes();
    final hmac = crypto.Hmac(crypto.sha256, bytes);
    final digest = hmac.convert(utf8.encode('openkey-auth'));
    return encodeBase64Url(digest.bytes);
  }

  /// Unpadded base64url — must match openkey_extension `toB64Url`.
  static String encodeBase64Url(List<int> bytes) {
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  /// Accepts padded/unpadded base64 or base64url (extension + legacy app).
  static Uint8List decodeBase64Url(String encoded) {
    final normalized = encoded
        .trim()
        .replaceAll('-', '+')
        .replaceAll('_', '/')
        .replaceAll('=', '');
    final pad = (4 - normalized.length % 4) % 4;
    return Uint8List.fromList(base64.decode(normalized + ('=' * pad)));
  }

  Future<Uint8List> deriveDbKey(SecretKey vaultKey) async {
    final bytes = await vaultKey.extractBytes();
    final hmac = crypto.Hmac(crypto.sha256, bytes);
    final digest = hmac.convert(utf8.encode('openkey-db'));
    return Uint8List.fromList(digest.bytes);
  }

  Future<String> wrapVaultKey({
    required SecretKey masterKey,
    required Uint8List vaultKeyBytes,
  }) async {
    return encryptBytes(key: masterKey, plaintext: vaultKeyBytes);
  }

  Future<Uint8List> unwrapVaultKey({
    required SecretKey masterKey,
    required String wrappedVaultKey,
  }) async {
    return decryptBytes(key: masterKey, ciphertext: wrappedVaultKey);
  }

  Future<String> encryptString({
    required SecretKey key,
    required String plaintext,
  }) async {
    return encryptBytes(key: key, plaintext: utf8.encode(plaintext));
  }

  Future<String> decryptString({
    required SecretKey key,
    required String ciphertext,
  }) async {
    final bytes = await decryptBytes(key: key, ciphertext: ciphertext);
    return utf8.decode(bytes);
  }

  Future<String> encryptBytes({
    required SecretKey key,
    required List<int> plaintext,
  }) async {
    final raw = await encryptRaw(key: key, plaintext: plaintext);
    return encodeBase64Url(raw);
  }

  /// AES-GCM wire bytes: `nonce(12) | ciphertext | mac(16)`.
  Future<Uint8List> encryptRaw({
    required SecretKey key,
    required List<int> plaintext,
  }) async {
    final secretBox = await _aesGcm.encrypt(
      plaintext,
      secretKey: key,
    );
    return Uint8List.fromList([
      ...secretBox.nonce,
      ...secretBox.cipherText,
      ...secretBox.mac.bytes,
    ]);
  }

  Future<Uint8List> decryptBytes({
    required SecretKey key,
    required String ciphertext,
  }) async {
    return decryptRaw(key: key, ciphertext: decodeBase64Url(ciphertext));
  }

  Future<Uint8List> decryptRaw({
    required SecretKey key,
    required List<int> ciphertext,
  }) async {
    final combined =
        ciphertext is Uint8List ? ciphertext : Uint8List.fromList(ciphertext);
    if (combined.length < 28) {
      throw StateError('Ciphertext too short');
    }
    final nonce = combined.sublist(0, 12);
    final mac = Mac(combined.sublist(combined.length - 16));
    final cipherText = combined.sublist(12, combined.length - 16);
    final clear = await _aesGcm.decrypt(
      SecretBox(cipherText, nonce: nonce, mac: mac),
      secretKey: key,
    );
    return Uint8List.fromList(clear);
  }

  /// Seal [plaintext] for [recipientPublicKeyB64] (X25519, base64url).
  ///
  /// Wire format (base64url): `version | eph_pub(32) | nonce(12) | ct | mac(16)`.
  Future<String> sealForPublicKey({
    required String recipientPublicKeyB64,
    required List<int> plaintext,
  }) async {
    final recipientBytes = decodeBase64Url(recipientPublicKeyB64);
    if (recipientBytes.length != 32) {
      throw StateError('Invalid X25519 public key length');
    }
    final recipient = SimplePublicKey(recipientBytes, type: KeyPairType.x25519);
    final ephemeral = await _x25519.newKeyPair();
    final shared = await _x25519.sharedSecretKey(
      keyPair: ephemeral,
      remotePublicKey: recipient,
    );
    final aesKey = await _deriveSealedAesKey(shared);
    final box = await _aesGcm.encrypt(plaintext, secretKey: aesKey);
    final ephPub = await ephemeral.extractPublicKey();
    final combined = <int>[
      sealedBoxVersion,
      ...ephPub.bytes,
      ...box.nonce,
      ...box.cipherText,
      ...box.mac.bytes,
    ];
    return encodeBase64Url(combined);
  }

  /// Open a sealed box created by [sealForPublicKey].
  Future<Uint8List> openSealedBox({
    required SimpleKeyPair identityKeyPair,
    required String sealed,
  }) async {
    final combined = decodeBase64Url(sealed);
    // version(1) + eph_pub(32) + nonce(12) + mac(16) + ≥1 ct byte
    if (combined.length < 62) {
      throw StateError('Sealed box too short');
    }
    if (combined[0] != sealedBoxVersion) {
      throw StateError('Unsupported sealed box version');
    }
    final ephPub = SimplePublicKey(
      combined.sublist(1, 33),
      type: KeyPairType.x25519,
    );
    final nonce = combined.sublist(33, 45);
    final mac = Mac(combined.sublist(combined.length - 16));
    final cipherText = combined.sublist(45, combined.length - 16);
    final shared = await _x25519.sharedSecretKey(
      keyPair: identityKeyPair,
      remotePublicKey: ephPub,
    );
    final aesKey = await _deriveSealedAesKey(shared);
    final clear = await _aesGcm.decrypt(
      SecretBox(cipherText, nonce: nonce, mac: mac),
      secretKey: aesKey,
    );
    return Uint8List.fromList(clear);
  }

  Future<SecretKey> _deriveSealedAesKey(SecretKey sharedSecret) async {
    final sharedBytes = await sharedSecret.extractBytes();
    final digest = crypto.sha256.convert([
      ...utf8.encode('openkey-seal-v1'),
      ...sharedBytes,
    ]);
    return SecretKey(digest.bytes);
  }

  Map<String, dynamic> defaultKdfParams() => {
        'algorithm': 'argon2id',
        'memory': argon2Memory,
        'iterations': argon2Iterations,
        'parallelism': argon2Parallelism,
        'hashLength': vaultKeyLength,
      };

  static const _lower = 'abcdefghijklmnopqrstuvwxyz';
  static const _upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _digits = '0123456789';
  static const _symbols = r'!@#$%^&*()-_=+[]{};:,.?';
  static const _ambiguous = 'Il1O0o|';

  String generatePassword({
    int length = 20,
    bool upper = true,
    bool lower = true,
    bool digits = true,
    bool symbols = true,
    bool avoidAmbiguous = false,
  }) {
    String filter(String alphabet) {
      if (!avoidAmbiguous) return alphabet;
      return alphabet
          .split('')
          .where((c) => !_ambiguous.contains(c))
          .join();
    }

    final sets = <String>[
      if (lower) filter(_lower),
      if (upper) filter(_upper),
      if (digits) filter(_digits),
      if (symbols) filter(_symbols),
    ].where((s) => s.isNotEmpty).toList();

    if (sets.isEmpty || length < 4 || length < sets.length) {
      throw ArgumentError('Invalid password generation options');
    }

    final pool = sets.join();
    // Guarantee ≥1 char from each selected set, then fill + shuffle.
    final chars = <String>[
      for (final set in sets) set[_random.nextInt(set.length)],
      for (var i = sets.length; i < length; i++)
        pool[_random.nextInt(pool.length)],
    ];
    chars.shuffle(_random);
    return chars.join();
  }

  Uint8List _randomBytes(int length) {
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = _random.nextInt(256);
    }
    return bytes;
  }
}
