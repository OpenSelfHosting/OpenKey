import 'package:flutter_test/flutter_test.dart';
import 'package:openkey_app/src/features/bridge/passkey_sign_count.dart';

void main() {
  group('nativeBridgeAuthMatches', () {
    test('accepts equal tokens', () {
      expect(nativeBridgeAuthMatches('abc123', 'abc123'), isTrue);
    });

    test('rejects missing expected or got', () {
      expect(nativeBridgeAuthMatches(null, 'abc'), isFalse);
      expect(nativeBridgeAuthMatches('', 'abc'), isFalse);
      expect(nativeBridgeAuthMatches('abc', null), isFalse);
      expect(nativeBridgeAuthMatches('abc', ''), isFalse);
    });

    test('rejects unequal length or content', () {
      expect(nativeBridgeAuthMatches('abc', 'ab'), isFalse);
      expect(nativeBridgeAuthMatches('abc', 'abd'), isFalse);
    });
  });
}
