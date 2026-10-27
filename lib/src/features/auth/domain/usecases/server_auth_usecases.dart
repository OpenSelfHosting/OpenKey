import 'package:injectable/injectable.dart';
import 'package:openkey_app/src/src.dart';

@lazySingleton
class RegisterServerUsecase implements UseCase<void, String> {
  RegisterServerUsecase(this._repository);

  final AuthRepository _repository;

  @override
  FutureFailureOr<void> call(String serverUrl) {
    return _repository.registerWithServer(serverUrl: serverUrl);
  }
}

@lazySingleton
class LoginServerUsecase implements UseCase<void, String> {
  LoginServerUsecase(this._repository);

  final AuthRepository _repository;

  @override
  FutureFailureOr<void> call(String serverUrl) {
    return _repository.loginWithServer(serverUrl: serverUrl);
  }
}
