import 'package:flutter_test/flutter_test.dart';
import 'package:openkey_shared/openkey_shared.dart';

void main() {
  group('passwordStrengthScore', () {
    test('returns zero for an empty password', () {
      expect(passwordStrengthScore(''), 0);
    });

    test('retains the existing character-class and length heuristic', () {
      expect(passwordStrengthScore('abc'), closeTo(0.375, 0.000001));
      expect(passwordStrengthScore('Abcdef1!'), 1);
      expect(passwordStrengthScore('Abcdefgh123!'), 1);
    });
  });

  group('isWeakPassword', () {
    test('does not mark an empty value as weak', () {
      expect(isWeakPassword(''), isFalse);
    });

    test('marks short passwords as weak', () {
      expect(isWeakPassword('abc'), isTrue);
    });

    test('accepts a password at the existing score threshold', () {
      expect(isWeakPassword('Abcdef1!'), isFalse);
    });
  });
}
