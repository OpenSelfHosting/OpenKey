import 'package:flutter_test/flutter_test.dart';
import 'package:openkey_shared/openkey_shared.dart';

void main() {
  group('FreeEditionFeatureAccess', () {
    const access = FreeEditionFeatureAccess();

    test('does not grant the Pro-only nearby sync capability', () {
      expect(access.canUse(OpenKeyFeature.nearbyDeviceSync), isFalse);
    });
  });
}
