import 'dart:io';

import 'package:flutter/services.dart';
import 'package:no_screenshot/no_screenshot.dart';

/// Blocks screenshots / screen recording where the OS allows it.
///
/// - Android / iOS / macOS / Linux: via [no_screenshot]
/// - Windows: via `SetWindowDisplayAffinity(WDA_EXCLUDEFROMCAPTURE)`
class ScreenshotProtectionService {
  ScreenshotProtectionService();

  static const _windowsChannel = MethodChannel('openkey/screenshot_protection');

  final NoScreenshot _noScreenshot = NoScreenshot.instance;

  bool get isSupported {
    return Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isMacOS ||
        Platform.isLinux ||
        Platform.isWindows;
  }

  /// Linux compositors cannot enforce FLAG_SECURE-equivalent hiding.
  bool get isBestEffortOnly => Platform.isLinux;

  Future<bool> setBlocked(bool blocked) async {
    if (!isSupported) return false;
    try {
      if (Platform.isWindows) {
        final result = await _windowsChannel.invokeMethod<bool>(
          blocked ? 'screenshotOff' : 'screenshotOn',
        );
        return result ?? false;
      }
      return blocked
          ? await _noScreenshot.screenshotOff()
          : await _noScreenshot.screenshotOn();
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
