import 'package:injectable/injectable.dart';
import 'package:openkey_app/src/src.dart';

@lazySingleton
class RestoreVaultFromServerUsecase
    implements UseCase<void, RestoreVaultFromServerParams> {
  RestoreVaultFromServerUsecase(this._repository);

  final AuthRepository _repository;

  @override
  FutureFailureOr<void> call(RestoreVaultFromServerParams params) {
    return _repository.restoreVaultFromServer(
      serverUrl: params.serverUrl,
      email: params.email,
      masterPassword: params.masterPassword,
    );
  }
}

class RestoreVaultFromServerParams {
  const RestoreVaultFromServerParams({
    required this.serverUrl,
    required this.email,
    required this.masterPassword,
  });

  final String serverUrl;
  final String email;
  final String masterPassword;
}
