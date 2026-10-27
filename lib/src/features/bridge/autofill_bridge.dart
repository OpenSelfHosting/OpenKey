import 'dart:io';

import 'package:flutter/services.dart';
import 'package:openkey_app/src/src.dart';
import 'package:uuid/uuid.dart';

/// Bridges the unlocked vault to native Autofill (Android) /
/// Credential Provider (iOS / macOS) /
/// Browser Native Messaging (Windows / Linux).
class AutofillBridge {
  AutofillBridge({
    required VaultSession session,
    required EntryRepository entries,
    required VaultMetadataStore metadata,
  })  : _session = session,
        _entries = entries,
        _metadata = metadata;

  static const _channel = MethodChannel('openkey/autofill');

  final VaultSession _session;
  final EntryRepository _entries;
  final VaultMetadataStore _metadata;

  VoidCallback? _onAutofillIntent;
  bool _listening = false;
  AutofillSaveRequest? _heldSave;

  bool get isAndroid => Platform.isAndroid;

  bool get isIOS => Platform.isIOS;

  bool get isMacOS => Platform.isMacOS;

  bool get isWindows => Platform.isWindows;

  bool get isLinux => Platform.isLinux;

  /// Apple platforms that hand off Save via App Group + URL (like Android intents).
  bool get isAppleAutofill => isIOS || isMacOS;

  /// Desktop platforms that fill via the browser extension + native messaging.
  bool get isBrowserAutofill => isWindows || isLinux;

  /// Platforms with a native system / browser password autofill integration.
  bool get isSupported =>
      isAndroid || isIOS || isMacOS || isWindows || isLinux;

  /// Called when the native side receives an autofill unlock/save intent.
  void setIntentHandler(VoidCallback? handler) {
    _onAutofillIntent = handler;
    if (!isSupported) return;
    if (handler != null && !_listening) {
      _channel.setMethodCallHandler(_onMethodCall);
      _listening = true;
    } else if (handler == null) {
      _channel.setMethodCallHandler(null);
      _listening = false;
    }
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onAutofillIntent':
        _onAutofillIntent?.call();
        return null;
      case 'updatePasskeySignCount':
        return _handleUpdatePasskeySignCount(call.arguments);
      case 'savePasskeyFromAutofill':
        return _handleSavePasskeyFromAutofill(call.arguments);
      default:
        return null;
    }
  }

  void holdSave(AutofillSaveRequest request) => _heldSave = request;

  AutofillSaveRequest? takeHeldSave() {
    final value = _heldSave;
    _heldSave = null;
    return value;
  }

  Future<void> syncCredentials() async {
    if (!isSupported) return;
    if (!_session.isUnlocked) {
      await clearCredentials();
      return;
    }
    // Include every vault login (root + all collections), not only the root folder.
    final result = await _entries.getEntries(collectionUuid: '__all__');
    await result.fold(
      (_) async {},
      (entries) async {
        final payload = await Future.wait(
          entries.where((e) => e.isAutofillFillable).map((e) async {
            final iconPng = await AutofillEntryIcon.pngBase64(e.icon);
            return {
              'uuid': e.uuid,
              'title': e.title,
              'username': e.username,
              'password': e.password,
              'urls': e.urls,
              if (e.passkey != null) 'passkey': e.passkey!.toJson(),
              if (iconPng != null) 'iconPng': iconPng,
            };
          }),
        );
        try {
          await _channel.invokeMethod<void>('syncCredentials', payload);
          await setRequireBiometric(_metadata.autofillRequireBiometric);
          await syncPresentation();
        } catch (e, st) {
          okDebugLog('AutofillBridge.syncCredentials failed: $e\n$st');
        }
      },
    );
  }

  Future<void> clearCredentials() async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod<void>('clearCredentials');
    } catch (e, st) {
      okDebugLog('AutofillBridge.clearCredentials failed: $e\n$st');
    }
  }

  Future<bool> isAutofillEnabled() async {
    if (!isSupported) return false;
    try {
      return await _channel.invokeMethod<bool>('isAutofillEnabled') ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> openAutofillSettings() async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod<void>('openAutofillSettings');
    } catch (e, st) {
      okDebugLog('AutofillBridge.openAutofillSettings failed: $e\n$st');
    }
  }

  /// Enable or disable the platform Autofill / Credential Provider.
  ///
  /// On Android, enabling still requires the system confirmation sheet;
  /// disabling turns off the system Autofill service when possible.
  /// Other platforms open system settings so the user can change the provider.
  Future<void> setAutofillEnabled(bool enabled) async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod<void>('setAutofillEnabled', enabled);
    } catch (e, st) {
      okDebugLog('AutofillBridge.setAutofillEnabled failed: $e\n$st');
      await openAutofillSettings();
    }
  }

  /// Persist whether Autofill should prompt for biometrics before filling.
  Future<void> setRequireBiometric(bool value) async {
    if (!isAndroid && !isAppleAutofill) return;
    try {
      await _channel.invokeMethod<void>('setRequireBiometric', value);
    } catch (e, st) {
      okDebugLog('AutofillBridge.setRequireBiometric failed: $e\n$st');
    }
  }

  /// Persist Android Autofill UI: keyboard chips and/or dropdown over the field.
  Future<void> syncPresentation() async {
    if (!isAndroid) return;
    try {
      await _channel.invokeMethod<void>('setAutofillPresentation', {
        'inline': _metadata.autofillInline,
        'popup': _metadata.autofillPopup,
      });
    } catch (e, st) {
      okDebugLog('AutofillBridge.syncPresentation failed: $e\n$st');
    }
  }

  Future<AutofillSaveRequest?> takePendingSave() async {
    if (!isAndroid && !isAppleAutofill) return null;
    try {
      final raw = await _channel.invokeMethod<dynamic>('takePendingSave');
      if (raw is! Map) return null;
      final map = Map<Object?, Object?>.from(raw);
      final iconRaw = map['iconBase64'];
      final iconBase64 = iconRaw is String ? iconRaw : iconRaw?.toString();
      okDebugLog(
        'AutofillBridge.takePendingSave package=${map['package']} '
        'iconLen=${iconBase64?.length ?? 0}',
      );
      return AutofillSaveRequest(
        username: map['username']?.toString() ?? '',
        password: map['password']?.toString() ?? '',
        uri: map['uri']?.toString() ?? '',
        packageName: map['package']?.toString() ?? '',
        title: map['title']?.toString(),
        iconBase64: (iconBase64 == null ||
                iconBase64.isEmpty ||
                iconBase64 == 'null')
            ? null
            : iconBase64,
      );
    } catch (e, st) {
      okDebugLog('AutofillBridge.takePendingSave failed: $e\n$st');
      return null;
    }
  }

  Future<bool> takePendingUnlock() async {
    if (!isAndroid && !isAppleAutofill) return false;
    try {
      return await _channel.invokeMethod<bool>('takePendingUnlock') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Drain passkey creates / sign-count bumps queued by native credential providers.
  Future<void> drainPendingPasskeyWork() async {
    if (!isAndroid && !isAppleAutofill) return;
    if (!_session.isUnlocked) return;

    try {
      final saves = await _channel.invokeMethod<List<dynamic>>(
        'takePendingPasskeySaves',
      );
      if (saves != null) {
        for (final raw in saves) {
          if (raw is Map) {
            await _handleSavePasskeyFromAutofill(Map<dynamic, dynamic>.from(raw));
          }
        }
      }
    } catch (e, st) {
      okDebugLog('AutofillBridge.takePendingPasskeySaves failed: $e\n$st');
    }

    try {
      final bumps = await _channel.invokeMethod<List<dynamic>>(
        'takePendingSignCountUpdates',
      );
      if (bumps != null) {
        for (final raw in bumps) {
          if (raw is Map) {
            await _handleUpdatePasskeySignCount(Map<dynamic, dynamic>.from(raw));
          }
        }
      }
    } catch (e, st) {
      okDebugLog('AutofillBridge.takePendingSignCountUpdates failed: $e\n$st');
    }
  }

  Future<bool> _handleUpdatePasskeySignCount(dynamic arguments) async {
    if (!_session.isUnlocked) return false;
    final map = arguments is Map
        ? Map<String, dynamic>.from(arguments)
        : <String, dynamic>{};
    final uuid = map['uuid']?.toString() ?? '';
    final count = map['signCount'] is int
        ? map['signCount'] as int
        : int.tryParse(map['signCount']?.toString() ?? '');
    if (uuid.isEmpty || count == null) return false;

    final saved = await bumpPasskeySignCount(
      _entries,
      uuid: uuid,
      signCount: count,
    );
    if (saved == null) return false;
    await syncCredentials();
    return true;
  }

  Future<bool> _handleSavePasskeyFromAutofill(dynamic arguments) async {
    if (!_session.isUnlocked) return false;
    final map = arguments is Map
        ? Map<String, dynamic>.from(arguments)
        : <String, dynamic>{};
    final passkeyRaw = map['passkey'];
    if (passkeyRaw is! Map) return false;
    final passkey = PasskeyPayload.fromJson(
      Map<String, dynamic>.from(passkeyRaw),
    );
    if (passkey.credentialId.isEmpty ||
        passkey.rpId.isEmpty ||
        (passkey.privateKeyCipher?.isEmpty ?? true)) {
      return false;
    }

    final uuid = map['uuid']?.toString() ?? '';
    if (uuid.isNotEmpty) {
      final existingResult = await _entries.getEntry(uuid);
      final existing = existingResult.fold((_) => null, (e) => e);
      if (existing != null) {
        final updated = existing.copyWith(passkey: passkey);
        final result = await _entries.updateEntry(updated);
        final ok = result.fold((_) => false, (_) => true);
        if (ok) await syncCredentials();
        return ok;
      }
    }

    // Deduplicate by credentialId if already in vault.
    final all = await _entries.getEntries(collectionUuid: '__all__');
    final list = all.fold((_) => <VaultEntry>[], (e) => e);
    final existingByCred = list.where(
      (e) => e.passkey?.credentialId == passkey.credentialId,
    );
    if (existingByCred.isNotEmpty) {
      final first = existingByCred.first;
      final updated = first.copyWith(passkey: passkey);
      final result = await _entries.updateEntry(updated);
      final ok = result.fold((_) => false, (_) => true);
      if (ok) await syncCredentials();
      return ok;
    }

    final title = (map['title']?.toString() ?? '').trim();
    final username = (map['username']?.toString() ?? '').trim();
    final urlsRaw = map['urls'];
    final urls = urlsRaw is List
        ? urlsRaw.map((e) => e.toString()).where((u) => u.isNotEmpty).toList()
        : <String>[
            if (passkey.rpId.isNotEmpty) 'https://${passkey.rpId}',
          ];
    final entry = VaultEntry(
      uuid: uuid.isEmpty ? const Uuid().v4() : uuid,
      title: title.isEmpty ? passkey.rpId : title,
      username: username.isEmpty ? (passkey.userName ?? '') : username,
      password: '',
      urls: urls,
      passkey: passkey,
    );
    final result = await _entries.createEntry(entry);
    final ok = result.fold((_) => false, (_) => true);
    if (ok) await syncCredentials();
    return ok;
  }
}

class AutofillSaveRequest {
  const AutofillSaveRequest({
    required this.username,
    required this.password,
    required this.uri,
    required this.packageName,
    this.title,
    this.iconBase64,
  });

  final String username;
  final String password;
  final String uri;
  final String packageName;
  final String? title;

  /// PNG of the calling Android app icon (Base64), when available.
  final String? iconBase64;

  static const browserPackages = {
    'com.android.chrome',
    'com.chrome.beta',
    'com.chrome.dev',
    'com.chrome.canary',
    'org.mozilla.firefox',
    'org.mozilla.firefox_beta',
    'org.mozilla.focus',
    'com.microsoft.emmx',
    'com.brave.browser',
    'com.opera.browser',
    'com.opera.mini.native',
    'com.sec.android.app.sbrowser',
    'com.duckduckgo.mobile.android',
    'com.vivaldi.browser',
    'com.kiwibrowser.browser',
  };

  bool get isBrowserPackage =>
      browserPackages.contains(packageName.trim());

  /// Native installed app (not a browser). May still include a webDomain URI.
  bool get isNativeAppSave {
    final pkg = packageName.trim();
    return pkg.isNotEmpty && !isBrowserPackage;
  }

  String get androidAppUrl {
    final pkg = packageName.trim();
    if (pkg.isEmpty || isBrowserPackage) return '';
    return 'androidapp://$pkg';
  }

  String get suggestedUrl {
    // Prefer the androidapp:// link for native apps so autofill matching and
    // icon resolution stay tied to the package (even when a webDomain exists).
    final appUrl = androidAppUrl;
    if (appUrl.isNotEmpty) return appUrl;
    if (uri.trim().isNotEmpty) return uri.trim();
    return '';
  }

  /// Website URI when the save also captured a domain (native WebView / browser).
  String get websiteUrl {
    final value = uri.trim();
    if (value.isEmpty) return '';
    if (value.startsWith('androidapp://')) return '';
    return value;
  }

  String get suggestedTitle {
    final explicit = title?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;
    if (uri.trim().isNotEmpty) {
      try {
        final host = Uri.parse(uri).host;
        if (host.isNotEmpty) return host;
      } catch (_) {}
    }
    final pkg = packageName.trim();
    if (pkg.isNotEmpty) {
      final parts = pkg.split('.');
      return parts.isNotEmpty ? parts.last : pkg;
    }
    return username.isNotEmpty ? username : 'Login';
  }
}
