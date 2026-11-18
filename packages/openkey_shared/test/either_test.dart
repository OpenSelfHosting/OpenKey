import 'package:flutter_test/flutter_test.dart';
import 'package:openkey_shared/openkey_shared.dart';

void main() {
  test('Left exposes its value and folds to the failure branch', () {
    const result = Left<String, int>('error');

    expect(result.isLeft, isTrue);
    expect(result.isRight, isFalse);
    expect(result.left, 'error');
    expect(result.right, isNull);
    expect(result.fold((left) => left.length, (right) => right), 5);
  });

  test('Right exposes its value and folds to the success branch', () {
    const result = Right<String, int>(42);

    expect(result.isRight, isTrue);
    expect(result.isLeft, isFalse);
    expect(result.right, 42);
    expect(result.left, isNull);
    expect(result.fold((left) => 0, (right) => right + 1), 43);
  });
}
