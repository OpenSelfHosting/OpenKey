import 'package:cryptography/cryptography.dart';
import 'package:openkey_app/src/src.dart';

abstract class AuthRepository {
  bool get hasVault;
  bool get isUnlocked;
  String? get email;
  String? get activeAccountId;
  List<VaultAccount> get accounts;

  FutureFailureOr<void> setupVault({
    required String email,
    required String masterPassword,
    String? passwordHint,
  });

  FutureFailureOr<void> unlock({
    required String masterPassword,
  });

  /// Resume an unlocked vault from a vault key recovered via biometrics.
  FutureFailureOr<void> unlockWithVaultKey(
    SecretKey vaultKey, {
    String? authHash,
  });

  FutureFailureOr<void> lock();

  /// Wipes the active local vault so another account can take its place.
  FutureFailureOr<void> resetLocalVault();

  /// Bootstrap a local vault from an existing self-hosted account.
  FutureFailureOr<void> restoreVaultFromServer({
    required String serverUrl,
    required String email,
    required String masterPassword,
  });

  FutureFailureOr<void> registerWithServer({
    required String serverUrl,
  });

  FutureFailureOr<void> loginWithServer({
    required String serverUrl,
  });

  /// Re-wraps the vault key under a new master password (local + server if linked).
  FutureFailureOr<void> changeMasterPassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Re-wraps the vault key under a new email (local + server if linked).
  FutureFailureOr<void> changeEmail({
    required String currentPassword,
    required String newEmail,
  });

  FutureFailureOr<void> switchAccount(String accountId);

  /// Removes a local vault from this device. Does not delete a server account.
  FutureFailureOr<void> removeAccount(String accountId);

  FutureFailureOr<void> setAccountAvatar(List<int> pngBytes);

  FutureFailureOr<void> clearAccountAvatar();

  /// Deletes the linked server account. Local vault data is kept.
  FutureFailureOr<void> deleteServerAccount({
    required String masterPassword,
  });

  /// Salt + wrapped key for linking the browser extension.
  Map<String, String>? extensionLinkPayload();
}
