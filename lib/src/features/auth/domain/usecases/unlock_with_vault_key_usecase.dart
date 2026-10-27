import 'package:cryptography/cryptography.dart';
import 'package:injectable/injectable.dart';
import 'package:openkey_app/src/src.dart';

class UnlockWithVaultKeyParams {
  const UnlockWithVaultKeyParams({
    required this.vaultKey,
    this.authHash,
  });

  final SecretKey vaultKey;
  final String? authHash;
}

@lazySingleton
class UnlockWithVaultKeyUsecase
    implements UseCase<void, UnlockWithVaultKeyParams> {
  UnlockWithVaultKeyUsecase(this._repository);

  final AuthRepository _repository;

  @override
  FutureFailureOr<void> call(UnlockWithVaultKeyParams params) {
    return _repository.unlockWithVaultKey(
      params.vaultKey,
      authHash: params.authHash,
    );
  }
}
