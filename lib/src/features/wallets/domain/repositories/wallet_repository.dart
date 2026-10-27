import 'package:openkey_app/src/src.dart';

abstract class WalletRepository {
  Stream<List<WalletCard>> watchCards();
  FutureFailureOr<List<WalletCard>> getCards();
  FutureFailureOr<WalletCard?> getCard(String uuid);
  FutureFailureOr<WalletCard> createCard(WalletCard card);
  FutureFailureOr<WalletCard> updateCard(WalletCard card);
  FutureFailureOr<void> deleteCard(String uuid);
}
