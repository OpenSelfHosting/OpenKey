import 'package:injectable/injectable.dart';
import 'package:openkey_app/src/src.dart';

@lazySingleton
class ResetLocalVaultUsecase implements UseCaseNoParams<void> {
  ResetLocalVaultUsecase(this._repository);

  final AuthRepository _repository;

  @override
  FutureFailureOr<void> call() {
    return _repository.resetLocalVault();
  }
}
