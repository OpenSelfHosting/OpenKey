/// A lightweight result type shared by the OpenKey editions.
///
/// Use [Left] for failures and [Right] for successful values. This type is
/// deliberately dependency-free so it can be used by domain and data layers.
abstract class Either<L, R> {
  const Either();

  T fold<T>(T Function(L left) leftFn, T Function(R right) rightFn);

  bool get isLeft => this is Left<L, R>;
  bool get isRight => this is Right<L, R>;

  L? get left => isLeft ? (this as Left<L, R>).value : null;
  R? get right => isRight ? (this as Right<L, R>).value : null;
}

/// The failure branch of an [Either].
class Left<L, R> extends Either<L, R> {
  const Left(this.value);

  final L value;

  @override
  T fold<T>(T Function(L left) leftFn, T Function(R right) rightFn) =>
      leftFn(value);
}

/// The success branch of an [Either].
class Right<L, R> extends Either<L, R> {
  const Right(this.value);

  final R value;

  @override
  T fold<T>(T Function(L left) leftFn, T Function(R right) rightFn) =>
      rightFn(value);
}
