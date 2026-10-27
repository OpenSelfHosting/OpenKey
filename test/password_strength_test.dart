import 'package:flutter_test/flutter_test.dart';
import 'package:openkey_app/src/core/utils/password_strength.dart';

void main() {
  group('passwordStrengthScore / isWeakPassword', () {
    test('empty is not weak', () {
      expect(passwordStrengthScore(''), 0);
      expect(isWeakPassword(''), isFalse);
    });

    test('short passwords are weak', () {
      expect(isWeakPassword('abc'), isTrue);
      expect(isWeakPassword('Abcdef1!'), isFalse);
    });
  });
}
