import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:openkey_app/src/core/crypto/identity_generator.dart';

void main() {
  late IdentityGenerator generator;

  setUp(() {
    generator = IdentityGenerator(random: Random(42));
  });

  group('username', () {
    test('word style is adjective + noun', () {
      final value = generator.username(includeDigits: false, capitalize: false);
      expect(RegExp(r'^[a-z]+[a-z]+$').hasMatch(value), isTrue);
      expect(IdentityGenerator.adjectives.any(value.startsWith), isTrue);
    });

    test('capitalize uses PascalCase', () {
      final value = generator.username(includeDigits: false, capitalize: true);
      expect(RegExp(r'^[A-Z][a-z]+[A-Z][a-z]+$').hasMatch(value), isTrue);
    });

    test('digits suffix is 2–3 digits without a leading zero', () {
      for (var i = 0; i < 30; i++) {
        final value = generator.username(includeDigits: true);
        expect(RegExp(r'[1-9]\d{1,2}$').hasMatch(value), isTrue);
      }
    });

    test('separators sit between the two words', () {
      final underscored = generator.username(
        includeDigits: false,
        capitalize: false,
        separator: UsernameSeparator.underscore,
      );
      expect(underscored.contains('_'), isTrue);
      expect(underscored.split('_'), hasLength(2));
    });

    test('random style honors length and leading letter', () {
      final value = generator.username(
        style: UsernameStyle.random,
        length: 16,
        includeDigits: true,
        capitalize: true,
      );
      expect(value.length, 16);
      expect(RegExp(r'^[A-Za-z][A-Za-z0-9]{15}$').hasMatch(value), isTrue);
    });
  });

  group('email', () {
    test('random local-part on the given domain', () {
      final value = generator.email(
        domain: 'OpenKey.app',
        includeDigits: false,
      );
      expect(value.endsWith('@openkey.app'), isTrue);
      expect(value, equals(value.toLowerCase()));
      expect(value.contains('@'), isTrue);
    });

    test('plus-addressing inserts a unique tag', () {
      final value = generator.email(plusEmail: 'Ada+old@Gmail.com');
      expect(value.startsWith('ada+'), isTrue);
      expect(value.endsWith('@gmail.com'), isTrue);
      expect(value.contains('+old'), isFalse);
    });

    test('falls back when plus email is incomplete', () {
      final value = generator.email(
        domain: 'example.com',
        plusEmail: 'not-an-email',
      );
      expect(value.endsWith('@example.com'), isTrue);
    });
  });
}
