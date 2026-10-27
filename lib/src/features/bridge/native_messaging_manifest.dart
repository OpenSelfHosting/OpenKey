/// Pure helpers for Chromium native-messaging host JSON.
///
/// Chrome requires `allowed_origins`. Omitting the key makes Chromium report
/// "Specified native messaging host not found" even when the file exists.
library;

import 'dart:convert';

final _chromeExtensionId = RegExp(r'^[a-p]{32}$');

/// Strips `chrome-extension://` / trailing slashes and validates a Chrome ID.
String? normalizeChromeExtensionId(String raw) {
  var s = raw.trim();
  if (s.isEmpty) return null;
  const prefix = 'chrome-extension://';
  if (s.toLowerCase().startsWith(prefix)) {
    s = s.substring(prefix.length);
  }
  s = s.split('/').first.trim().toLowerCase();
  if (!_chromeExtensionId.hasMatch(s)) return null;
  return s;
}

/// Splits a stored ID blob (newlines, commas, spaces) into valid Chrome IDs.
List<String> parseChromeExtensionIds(String? raw) {
  if (raw == null || raw.trim().isEmpty) return const [];
  final ids = <String>{};
  for (final part in raw.split(RegExp(r'[\s,;]+'))) {
    final id = normalizeChromeExtensionId(part);
    if (id != null) ids.add(id);
  }
  return ids.toList();
}

bool looksLikeOpenKeyExtension(Map<dynamic, dynamic> settings) {
  final path = '${settings['path'] ?? ''}'.toLowerCase();
  if (path.contains('openkey_extension') ||
      path.contains('openkey-extension')) {
    return true;
  }
  final manifest = settings['manifest'];
  if (manifest is Map) {
    final name = '${manifest['name'] ?? ''}'.trim().toLowerCase();
    if (name == 'openkey') return true;
  }
  return false;
}

/// Reads unpacked / installed OpenKey IDs from a Chrome `Preferences` JSON.
List<String> openKeyExtensionIdsFromChromePreferences(String jsonText) {
  final ids = <String>{};
  try {
    final data = jsonDecode(jsonText);
    if (data is! Map) return const [];
    final extensions = data['extensions'];
    if (extensions is! Map) return const [];
    final settings = extensions['settings'];
    if (settings is! Map) return const [];
    settings.forEach((key, value) {
      final id = normalizeChromeExtensionId('$key');
      if (id == null || value is! Map) return;
      if (looksLikeOpenKeyExtension(value)) ids.add(id);
    });
  } catch (_) {
    return const [];
  }
  return ids.toList();
}

String buildNativeMessagingManifest({
  required String hostPath,
  required List<String> chromeExtensionIds,
}) {
  final origins = chromeExtensionIds
      .map(normalizeChromeExtensionId)
      .whereType<String>()
      .toSet()
      .toList()
    ..sort();
  final buf = StringBuffer()
    ..writeln('{')
    ..writeln('  "name": "com.openselfhosting.openkey",')
    ..writeln('  "description": "OpenKey native messaging host",')
    ..writeln('  "path": ${jsonEncode(hostPath)},')
    ..writeln('  "type": "stdio",')
    ..writeln('  "allowed_origins": [');
  for (var i = 0; i < origins.length; i++) {
    final comma = i == origins.length - 1 ? '' : ',';
    buf.writeln(
      '    ${jsonEncode('chrome-extension://${origins[i]}/')}$comma',
    );
  }
  buf
    ..writeln('  ],')
    ..writeln('  "allowed_extensions": [')
    ..writeln('    "openkey@openselfhosting.local"')
    ..writeln('  ]')
    ..writeln('}');
  return buf.toString();
}
