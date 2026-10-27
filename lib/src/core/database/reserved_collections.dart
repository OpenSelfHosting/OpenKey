/// Virtual collection namespaces for payment cards, crypto wallets, and secrets.
///
/// Entries under these ids sync via [SyncService] like any other ciphertext.
/// Matching [CollectionTable] sentinel rows may also sync, but must stay hidden
/// from the password-vault folder UI.
abstract final class ReservedCollections {
  static const wallets = '__wallets__';
  static const crypto = '__crypto_wallets__';
  static const secrets = '__dev_secrets__';

  static const all = <String>{wallets, crypto, secrets};

  static bool isReserved(String? id) => id != null && all.contains(id);
}
