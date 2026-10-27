import 'package:openkey_app/src/src.dart';

abstract class CryptoRepository {
  Stream<List<CryptoWallet>> watchWallets();
  FutureFailureOr<List<CryptoWallet>> getWallets();
  FutureFailureOr<CryptoWallet?> getWallet(String uuid);
  FutureFailureOr<CryptoWallet> createWallet(CryptoWallet wallet);
  FutureFailureOr<CryptoWallet> updateWallet(CryptoWallet wallet);
  FutureFailureOr<void> deleteWallet(String uuid);
}
