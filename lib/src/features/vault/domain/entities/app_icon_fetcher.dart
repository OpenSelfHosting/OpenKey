import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:openkey_app/src/features/vault/domain/entities/custom_icons.dart';

/// Loads installed Android app icons via the native autofill channel.
class AppIconFetcher {
  AppIconFetcher._();

  static const _channel = MethodChannel('openkey/autofill');
  static final Map<String, String?> _memory = {};
  static final Map<String, Future<String?>> _inflight = {};

  static bool get isSupported => Platform.isAndroid;

  /// Drops in-memory package → icon mappings after an account switch.
  static void clearMemory() {
    _memory.clear();
    _inflight.clear();
  }

  /// Normalize `androidapp://pkg` or bare package names.
  static String? packageOf(String raw) {
    var text = raw.trim();
    if (text.isEmpty) return null;
    if (text.startsWith('androidapp://')) {
      text = text.substring('androidapp://'.length);
    }
    text = text.trim();
    if (text.isEmpty || !text.contains('.')) return null;
    return text;
  }

  /// Returns a `custom:favicon:png:…` key for [packageOrUri], or null.
  static Future<String?> iconKeyFor(String packageOrUri) async {
    final packageName = packageOf(packageOrUri);
    if (packageName == null || !isSupported) return null;

    if (_memory.containsKey(packageName)) return _memory[packageName];
    final pending = _inflight[packageName];
    if (pending != null) return pending;

    final future = _load(packageName);
    _inflight[packageName] = future;
    try {
      final key = await future;
      _memory[packageName] = key;
      return key;
    } finally {
      _inflight.remove(packageName);
    }
  }

  /// Encode raw PNG/base64 bytes from a pending autofill save.
  ///
  /// Stored as `custom:favicon:png:…` so it persists on the entry like site
  /// favicons (entry-local, synced with the vault payload).
  static Future<String?> iconKeyFromBase64(String? base64) async {
    if (base64 == null || base64.isEmpty) return null;
    // Guard against the literal "null" string from bad native bridging.
    if (base64 == 'null' || base64 == 'undefined') return null;
    try {
      final bytes = base64Decode(base64);
      if (bytes.isEmpty) return null;
      final raw = Uint8List.fromList(bytes);
      try {
        return await CustomIcons.fromFaviconBytes(raw);
      } catch (e) {
        debugPrint('AppIconFetcher: resize failed, using raw PNG ($e)');
        if (raw.lengthInBytes > CustomIcons.maxEncodedBytes) return null;
        return CustomIcons.encodeFaviconPng(raw);
      }
    } catch (e, st) {
      debugPrint('AppIconFetcher.iconKeyFromBase64 failed: $e\n$st');
      return null;
    }
  }

  static Future<String?> _load(String packageName) async {
    try {
      final b64 = await _channel.invokeMethod<String>(
        'getAppIcon',
        packageName,
      );
      return await iconKeyFromBase64(b64);
    } catch (e, st) {
      debugPrint('AppIconFetcher.getAppIcon($packageName) failed: $e\n$st');
      return null;
    }
  }
}
