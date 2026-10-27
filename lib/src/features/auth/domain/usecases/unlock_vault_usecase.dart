import 'package:injectable/injectable.dart';
import 'package:openkey_app/src/src.dart';

@lazySingleton
class UnlockVaultUsecase implements UseCase<void, String> {
  UnlockVaultUsecase(this._repository);

  final AuthRepository _repository;

  @override
  FutureFailureOr<void> call(String masterPassword) {
    return _repository.unlock(masterPassword: masterPassword);
  }
}
