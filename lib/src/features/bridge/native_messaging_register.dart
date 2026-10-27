part of 'native_messaging_host.dart';

mixin _NativeMessagingRegister on _NativeMessagingHostBase {
  /// Installs the stdio native-messaging host and browser manifests (macOS/Linux).
  @override
  Future<bool> registerBrowserNativeHost({String? chromeExtensionId}) async {
    if (_isWindows) return false;
    if (!_isDesktopUnix) return false;

    try {
      final hostPath = await _ensureNativeHostScript();
      if (hostPath == null) return false;
      final storedId = await readChromeExtensionId();
      final ids = <String>{
        ...parseChromeExtensionIds(chromeExtensionId),
        ...parseChromeExtensionIds(storedId),
        ...await _discoverInstalledOpenKeyChromeIds(),
      }.toList()
        ..sort();
      if (ids.isNotEmpty) {
        try {
          await saveChromeExtensionId(ids.join('\n'));
        } catch (e) {
          okDebugLog('NativeMessagingHost saveChromeExtensionId failed: $e');
        }
      }
      final body = buildNativeMessagingManifest(
        hostPath: hostPath,
        chromeExtensionIds: ids,
      );
      final dataDir = await openKeyDataDir();
      try {
        await File(p.join(dataDir.path, '${NativeMessagingHost.hostName}.json'))
            .writeAsString(body, flush: true);
      } catch (e) {
        okDebugLog('NativeMessagingHost canonical manifest write failed: $e');
      }

      var any = false;
      for (final dir in await _chromiumNativeHostDirs()) {
        if (await _writeFile(
          p.join(dir, '${NativeMessagingHost.hostName}.json'),
          body,
        )) {
          any = true;
        }
      }
      for (final dir in await _firefoxNativeHostDirs()) {
        if (await _writeFile(
          p.join(dir, '${NativeMessagingHost.hostName}.json'),
          body,
        )) {
          any = true;
        }
      }
      okDebugLog(
        'NativeMessagingHost registerBrowserNativeHost → $any (ids=$ids)',
      );
      return any;
    } catch (e, st) {
      okDebugLog('NativeMessagingHost registerBrowserNativeHost failed: $e\n$st');
      return false;
    }
  }

  Future<bool> isBrowserNativeHostRegistered() async {
    if (_isWindows) return false;
    for (final dir in await _chromiumNativeHostDirs()) {
      if (await File(p.join(dir, '${NativeMessagingHost.hostName}.json'))
          .exists()) {
        return true;
      }
    }
    for (final dir in await _firefoxNativeHostDirs()) {
      if (await File(p.join(dir, '${NativeMessagingHost.hostName}.json'))
          .exists()) {
        return true;
      }
    }
    return false;
  }

  Future<String?> _ensureNativeHostScript() async {
    final candidates = <Directory>[];
    try {
      candidates.add(await openKeyDataDir());
    } catch (_) {}
    candidates.add(Directory('/tmp'));

    Uint8List? bytes;
    try {
      final data = await rootBundle.load(
        'assets/native/openkey_native_host.py.txt',
      );
      bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } catch (e) {
      okDebugLog('Failed to load native host asset: $e');
    }

    for (final dir in candidates) {
      try {
        if (!await dir.exists()) await dir.create(recursive: true);
        final py = File(p.join(dir.path, 'openkey_native_host.py'));
        final sh = File(p.join(dir.path, 'openkey_native_host'));
        if (bytes != null) {
          await py.writeAsBytes(bytes, flush: true);
        } else if (!await py.exists()) {
          continue;
        }
        // Chrome launches the host with a minimal PATH — wrap python explicitly.
        final wrapper = '''#!/bin/bash
set -euo pipefail
SCRIPT_DIR="\$(cd "\$(dirname "\$0")" && pwd)"
for PY in /usr/bin/python3 /opt/homebrew/bin/python3 /usr/local/bin/python3 python3; do
  if command -v "\$PY" >/dev/null 2>&1 || [ -x "\$PY" ]; then
    exec "\$PY" "\$SCRIPT_DIR/openkey_native_host.py"
  fi
done
echo "python3 not found" >&2
exit 1
''';
        await sh.writeAsString(wrapper, flush: true);
        await Process.run('chmod', ['+x', py.path, sh.path]);
        return sh.path;
      } catch (e) {
        okDebugLog('Native host write failed under ${dir.path}: $e');
      }
    }
    return null;
  }

  Future<List<String>> _discoverInstalledOpenKeyChromeIds() async {
    final ids = <String>{};
    for (final path in await _chromiumPreferencesFiles()) {
      try {
        final text = await File(path).readAsString();
        ids.addAll(openKeyExtensionIdsFromChromePreferences(text));
      } catch (_) {}
    }
    return ids.toList();
  }

  Future<List<String>> _chromiumPreferencesFiles() async {
    final home = Platform.environment['HOME'] ?? '';
    final roots = <String>[];
    if (Platform.isMacOS) {
      final support = p.join(home, 'Library', 'Application Support');
      roots.addAll([
        p.join(support, 'Google', 'Chrome'),
        p.join(support, 'Google', 'Chrome Beta'),
        p.join(support, 'Google', 'Chrome Canary'),
        p.join(support, 'Chromium'),
        p.join(support, 'Microsoft Edge'),
        p.join(support, 'BraveSoftware', 'Brave-Browser'),
        p.join(support, 'Vivaldi'),
      ]);
    } else {
      final xdg = Platform.environment['XDG_CONFIG_HOME'];
      final config =
          (xdg != null && xdg.isNotEmpty) ? xdg : p.join(home, '.config');
      roots.addAll([
        p.join(config, 'google-chrome'),
        p.join(config, 'google-chrome-beta'),
        p.join(config, 'google-chrome-unstable'),
        p.join(config, 'chromium'),
        p.join(config, 'microsoft-edge'),
        p.join(config, 'microsoft-edge-beta'),
        p.join(config, 'BraveSoftware', 'Brave-Browser'),
        p.join(config, 'vivaldi'),
      ]);
    }
    final files = <String>[];
    for (final root in roots) {
      final dir = Directory(root);
      if (!await dir.exists()) continue;
      await for (final entity in dir.list()) {
        if (entity is! Directory) continue;
        final prefs = File(p.join(entity.path, 'Preferences'));
        if (await prefs.exists()) files.add(prefs.path);
      }
    }
    return files;
  }

  Future<bool> _writeFile(String path, String body) async {
    try {
      final file = File(path);
      await file.parent.create(recursive: true);
      await file.writeAsString(body, flush: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<String>> _chromiumNativeHostDirs() async {
    final home = Platform.environment['HOME'] ?? '';
    if (Platform.isMacOS) {
      final support = p.join(home, 'Library', 'Application Support');
      return [
        p.join(support, 'Google', 'Chrome', 'NativeMessagingHosts'),
        p.join(support, 'Google', 'Chrome Beta', 'NativeMessagingHosts'),
        p.join(support, 'Google', 'Chrome Canary', 'NativeMessagingHosts'),
        p.join(support, 'Chromium', 'NativeMessagingHosts'),
        p.join(support, 'Microsoft Edge', 'NativeMessagingHosts'),
        p.join(support, 'BraveSoftware', 'Brave-Browser', 'NativeMessagingHosts'),
        p.join(support, 'Vivaldi', 'NativeMessagingHosts'),
        p.join(support, 'Arc', 'User Data', 'NativeMessagingHosts'),
      ];
    }
    final xdg = Platform.environment['XDG_CONFIG_HOME'];
    final config =
        (xdg != null && xdg.isNotEmpty) ? xdg : p.join(home, '.config');
    return [
      p.join(config, 'google-chrome', 'NativeMessagingHosts'),
      p.join(config, 'google-chrome-beta', 'NativeMessagingHosts'),
      p.join(config, 'google-chrome-unstable', 'NativeMessagingHosts'),
      p.join(config, 'chromium', 'NativeMessagingHosts'),
      p.join(config, 'microsoft-edge', 'NativeMessagingHosts'),
      p.join(config, 'BraveSoftware', 'Brave-Browser', 'NativeMessagingHosts'),
      p.join(config, 'vivaldi', 'NativeMessagingHosts'),
    ];
  }

  Future<List<String>> _firefoxNativeHostDirs() async {
    final home = Platform.environment['HOME'] ?? '';
    if (Platform.isMacOS) {
      final support = p.join(home, 'Library', 'Application Support');
      return [
        p.join(support, 'Mozilla', 'NativeMessagingHosts'),
        p.join(home, 'Library', 'Application Support', 'librewolf',
            'NativeMessagingHosts'),
      ];
    }
    final xdg = Platform.environment['XDG_CONFIG_HOME'];
    final config =
        (xdg != null && xdg.isNotEmpty) ? xdg : p.join(home, '.config');
    return [
      p.join(home, '.mozilla', 'native-messaging-hosts'),
      p.join(home, '.librewolf', 'native-messaging-hosts'),
      p.join(config, 'mozilla', 'native-messaging-hosts'),
    ];
  }
}
