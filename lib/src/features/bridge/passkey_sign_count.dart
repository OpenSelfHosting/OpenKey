import 'package:openkey_app/src/src.dart';

/// Shared passkey counter bump for AutofillBridge and NativeMessagingHost.
///
/// Returns the saved entry, or null when the entry/passkey is missing, the
/// update fails, or [signCount] is not strictly greater than the stored value
/// (WebAuthn counters must be monotonic).
Future<VaultEntry?> bumpPasskeySignCount(
  EntryRepository entries, {
  required String uuid,
  required int signCount,
}) async {
  if (uuid.isEmpty || signCount < 0) return null;
  final existingResult = await entries.getEntry(uuid);
  final existing = existingResult.fold((_) => null, (e) => e);
  if (existing == null || existing.passkey == null) return null;
  final pk = existing.passkey!;
  final previous = pk.signCount ?? 0;
  if (signCount <= previous) return null;
  final updated = existing.copyWith(
    passkey: PasskeyPayload(
      rpId: pk.rpId,
      credentialId: pk.credentialId,
      userHandle: pk.userHandle,
      privateKeyCipher: pk.privateKeyCipher,
      publicKey: pk.publicKey,
      alg: pk.alg,
      signCount: signCount,
      userName: pk.userName,
      displayName: pk.displayName,
    ),
  );
  final result = await entries.updateEntry(updated);
  return result.fold((_) => null, (saved) => saved);
}

/// Constant-time string compare for native-messaging bridge auth tokens.
bool nativeBridgeAuthMatches(String? expected, String? got) {
  if (expected == null || expected.isEmpty) return false;
  final actual = got ?? '';
  if (actual.length != expected.length) return false;
  var diff = 0;
  for (var i = 0; i < expected.length; i++) {
    diff |= expected.codeUnitAt(i) ^ actual.codeUnitAt(i);
  }
  return diff == 0;
}
