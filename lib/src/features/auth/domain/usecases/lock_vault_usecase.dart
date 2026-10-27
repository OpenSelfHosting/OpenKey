import 'package:injectable/injectable.dart';
import 'package:openkey_app/src/src.dart';

@lazySingleton
class LockVaultUsecase implements UseCaseNoParams<void> {
  LockVaultUsecase(this._repository);

  final AuthRepository _repository;

  @override
  FutureFailureOr<void> call() => _repository.lock();
}
