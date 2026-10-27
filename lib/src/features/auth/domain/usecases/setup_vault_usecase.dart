import 'package:injectable/injectable.dart';
import 'package:openkey_app/src/src.dart';

@lazySingleton
class SetupVaultUsecase implements UseCase<void, SetupVaultParams> {
  SetupVaultUsecase(this._repository);

  final AuthRepository _repository;

  @override
  FutureFailureOr<void> call(SetupVaultParams params) {
    return _repository.setupVault(
      email: params.email,
      masterPassword: params.masterPassword,
      passwordHint: params.passwordHint,
    );
  }
}

class SetupVaultParams {
  const SetupVaultParams({
    required this.email,
    required this.masterPassword,
    this.passwordHint,
  });

  final String email;
  final String masterPassword;
  final String? passwordHint;
}
