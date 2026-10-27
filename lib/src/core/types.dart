import 'package:openkey_app/src/src.dart';

typedef FailureOr<T> = Either<AppFailure, T>;
typedef FutureFailureOr<T> = Future<FailureOr<T>>;
