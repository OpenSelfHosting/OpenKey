import 'package:openkey_app/src/src.dart';

abstract class UseCase<RT, PT> {
  FutureFailureOr<RT> call(PT params);
}

abstract class UseCaseNoParams<RT> {
  FutureFailureOr<RT> call();
}
