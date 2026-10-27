import 'package:flutter_test/flutter_test.dart';
import 'package:openkey_app/src/core/usecases/either.dart';

void main() {
  test('Left exposes value and folds to left branch', () {
    const either = Left<String, int>('err');
    expect(either.isLeft, isTrue);
    expect(either.isRight, isFalse);
    expect(either.left, 'err');
    expect(either.right, isNull);
    expect(either.fold((l) => l.length, (r) => r), 3);
  });

  test('Right exposes value and folds to right branch', () {
    const either = Right<String, int>(42);
    expect(either.isRight, isTrue);
    expect(either.isLeft, isFalse);
    expect(either.right, 42);
    expect(either.left, isNull);
    expect(either.fold((l) => 0, (r) => r + 1), 43);
  });
}
