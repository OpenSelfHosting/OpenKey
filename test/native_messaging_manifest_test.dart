import 'package:flutter_test/flutter_test.dart';
import 'package:openkey_app/src/features/bridge/native_messaging_manifest.dart';

void main() {
  group('normalizeChromeExtensionId', () {
    test('accepts a raw 32-char Chrome id', () {
      expect(
        normalizeChromeExtensionId('kmknejnfglbgpfgglhfkkbljcmcekndb'),
        'kmknejnfglbgpfgglhfkkbljcmcekndb',
      );
    });

    test('strips chrome-extension origin', () {
      expect(
        normalizeChromeExtensionId(
          'chrome-extension://kmknejnfglbgpfgglhfkkbljcmcekndb/',
        ),
        'kmknejnfglbgpfgglhfkkbljcmcekndb',
      );
    });

    test('rejects invalid ids', () {
      expect(normalizeChromeExtensionId('abc'), isNull);
      expect(normalizeChromeExtensionId('openkey@openselfhosting.local'), isNull);
    });
  });

  group('buildNativeMessagingManifest', () {
    test('always emits allowed_origins so Chrome can load the host', () {
      final json = buildNativeMessagingManifest(
        hostPath: '/tmp/openkey_native_host',
        chromeExtensionIds: const [],
      );
      expect(json, contains('"allowed_origins": ['));
      expect(json, contains('"allowed_extensions"'));
      expect(json, isNot(contains('chrome-extension://')));
    });

    test('lists chrome origins with trailing slash', () {
      final json = buildNativeMessagingManifest(
        hostPath: '/tmp/openkey_native_host',
        chromeExtensionIds: const ['kmknejnfglbgpfgglhfkkbljcmcekndb'],
      );
      expect(
        json,
        contains('"chrome-extension://kmknejnfglbgpfgglhfkkbljcmcekndb/"'),
      );
    });
  });

  group('openKeyExtensionIdsFromChromePreferences', () {
    test('finds unpacked OpenKey by install path', () {
      const prefs = '''
{
  "extensions": {
    "settings": {
      "kmknejnfglbgpfgglhfkkbljcmcekndb": {
        "path": "/home/asim/Projects/OpenKey_extension/dist",
        "location": 4
      },
      "nngceckbapebfimnlniiiahkandclblb": {
        "path": "/opt/google/chrome/extensions/bitwarden",
        "manifest": {"name": "Bitwarden"}
      }
    }
  }
}
''';
      expect(
        openKeyExtensionIdsFromChromePreferences(prefs),
        ['kmknejnfglbgpfgglhfkkbljcmcekndb'],
      );
    });

    test('finds store/unpacked installs named OpenKey', () {
      const prefs = '''
{
  "extensions": {
    "settings": {
      "abcdefghijklmnopabcdefghijklmnop": {
        "manifest": {"name": "OpenKey"}
      }
    }
  }
}
''';
      expect(
        openKeyExtensionIdsFromChromePreferences(prefs),
        ['abcdefghijklmnopabcdefghijklmnop'],
      );
    });
  });
}
