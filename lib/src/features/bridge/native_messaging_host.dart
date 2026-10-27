import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:openkey_app/src/src.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

part 'native_messaging_register.dart';
part 'native_messaging_handlers.dart';

/// Local bridge for the browser extension.
///
/// Listens on a Unix domain socket (macOS/Linux) or loopback TCP (Windows)
/// while the vault is unlocked. The native-messaging host
/// (`openkey_native_host` / `openkey_native_host.py`) speaks Chrome's stdio
/// framing and forwards JSON to this endpoint.
class NativeMessagingHost extends _NativeMessagingHostBase
    with _NativeMessagingRegister, _NativeMessagingHandlers {
  NativeMessagingHost({
    required VaultSession session,
    required EntryRepository entries,
    WalletRepository? wallets,
    CryptoRepository? crypto,
    SecretsRepository? secrets,
    CollectionRepository? collections,
  }) : super(
          session,
          entries,
          wallets,
          crypto,
          secrets,
          collections,
        );

  static const hostName = _NativeMessagingHostBase.hostName;
  static const defaultSocketFileName =
      _NativeMessagingHostBase.defaultSocketFileName;
  static const defaultPortFileName =
      _NativeMessagingHostBase.defaultPortFileName;
}

/// Holds Native Messaging identity, lifecycle, and socket/TCP state.
abstract class _NativeMessagingHostBase {
  _NativeMessagingHostBase(
    this._session,
    this._entries,
    this._wallets,
    this._crypto,
    this._secrets,
    this._collections,
  );

  final VaultSession _session;
  final EntryRepository _entries;
  final WalletRepository? _wallets;
  final CryptoRepository? _crypto;
  final SecretsRepository? _secrets;
  final CollectionRepository? _collections;
  ServerSocket? _socketServer;

  /// Per-unlock secret required on every native-messaging request.
  String? _bridgeAuthToken;

  static const hostName = 'com.openselfhosting.openkey';

  /// Keep the file name short: macOS `sockaddr_un.sun_path` is ~104 bytes.
  static const defaultSocketFileName = 'openkey-native.sock';
  static const defaultPortFileName = 'openkey-native.port';
  static const defaultTokenFileName = 'openkey-native.token';

  /// Reject oversized frames from a local client (DoS / memory abuse).
  static const _maxFrameBytes = 2 * 1024 * 1024;

  /// macOS AF_UNIX path limit (including NUL); leave a small margin.
  static const _maxUnixPathLength = 100;

  bool get _isDesktopUnix => Platform.isMacOS || Platform.isLinux;

  bool get _isWindows => Platform.isWindows;

  bool get _isAndroid => Platform.isAndroid;

  /// Loopback TCP for Windows, Android (Termux CLI), and similar local clients.
  bool get _usesLoopbackTcp => _isWindows || _isAndroid;

  /// Active loopback port while the bridge is listening (Windows / Android).
  int? get loopbackPort => _socketServer?.port;

  /// Per-unlock auth token for local CLI / native messaging clients.
  String? get cliBridgeAuthToken => _bridgeAuthToken;

  Future<Directory> _windowsOpenKeyDir() async {
    final local = Platform.environment['LOCALAPPDATA'];
    if (local != null && local.isNotEmpty) {
      final dir = Directory(p.join(local, 'OpenKey'));
      if (!await dir.exists()) await dir.create(recursive: true);
      return dir;
    }
    final support = await getApplicationSupportDirectory();
    final dir = Directory(p.join(support.path, 'OpenKey'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<String?> socketPath() async {
    if (!_isDesktopUnix) return null;

    final override = Platform.environment['OPENKEY_NATIVE_SOCKET'];
    if (override != null && override.isNotEmpty) return override;

    if (Platform.isLinux) {
      final runtime = Platform.environment['XDG_RUNTIME_DIR'];
      if (runtime != null && runtime.isNotEmpty) {
        return p.join(runtime, defaultSocketFileName);
      }
    }

    // Prefer Directory.systemTemp: under App Sandbox this is the container tmp
    // and bind() is allowed. Plain `/tmp` is blocked even with file exceptions.
    final tmp = Directory.systemTemp.path;
    for (final name in [defaultSocketFileName, 'ok.sock']) {
      final candidate = p.join(tmp, name);
      if (candidate.length <= _maxUnixPathLength) return candidate;
    }

    // Last resort for non-sandboxed builds.
    return p.join('/tmp', 'ok.sock');
  }

  Future<File?> _windowsPortFile() async {
    if (!_isWindows) return null;
    final dir = await _windowsOpenKeyDir();
    return File(p.join(dir.path, defaultPortFileName));
  }

  Future<File?> _tokenFileForSocket(String socketPath) async {
    return File(p.join(p.dirname(socketPath), defaultTokenFileName));
  }

  Future<File?> _windowsTokenFile() async {
    if (!_isWindows) return null;
    final dir = await _windowsOpenKeyDir();
    return File(p.join(dir.path, defaultTokenFileName));
  }

  /// Mode-0600 token file next to the socket/port so only the native host
  /// (same user) can authenticate while the vault is unlocked.
  Future<void> _writeBridgeAuthToken(File file) async {
    final token = const Uuid().v4().replaceAll('-', '') +
        const Uuid().v4().replaceAll('-', '');
    _bridgeAuthToken = token;
    await file.writeAsString(token, flush: true);
    await _chmodOwnerOnly(file.path);
  }

  Future<void> _clearBridgeAuthToken(File? file) async {
    _bridgeAuthToken = null;
    if (file == null) return;
    try {
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  bool _authTokenValid(Map<String, dynamic> msg) {
    return nativeBridgeAuthMatches(
      _bridgeAuthToken,
      msg['auth']?.toString(),
    );
  }

  Future<void> _chmodOwnerOnly(String path) async {
    if (_isWindows) {
      final user = Platform.environment['USERNAME'];
      if (user == null || user.isEmpty) return;
      try {
        // Restrict token/port files to the current user (no Everyone read).
        await Process.run('icacls', [
          path,
          '/inheritance:r',
          '/grant:r',
          '$user:F',
        ]);
      } catch (_) {}
      return;
    }
    try {
      await Process.run('chmod', ['600', path]);
    } catch (_) {}
  }

  Future<void> start() async {
    await stop();

    if (_usesLoopbackTcp) {
      await _startLoopbackTcp();
      return;
    }

    final path = await socketPath();
    if (path == null) return;

    try {
      final file = File(path);
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }
      // Clear any stale token before bind so a failed start cannot leave a
      // usable secret on disk without a live listener.
      await _clearBridgeAuthToken(await _tokenFileForSocket(path));
      _socketServer = await ServerSocket.bind(
        InternetAddress(path, type: InternetAddressType.unix),
        0,
      );
      await _chmodOwnerOnly(path);
      final tokenFile = await _tokenFileForSocket(path);
      if (tokenFile != null) {
        await _writeBridgeAuthToken(tokenFile);
      }
      _socketServer!.listen(_handleClient);
      okDebugLog('NativeMessagingHost listening on $path');
      // macOS has no C++ host registrar — install the Python bridge + manifests.
      // Linux also benefits when the packaged host binary is missing (dev runs).
      await registerBrowserNativeHost();
    } catch (e, st) {
      // Extension bridge is optional — never fail vault unlock/setup for this.
      okDebugLog('NativeMessagingHost failed to start at $path: $e\n$st');
      _socketServer = null;
      await _clearBridgeAuthToken(await _tokenFileForSocket(path));
    }
  }

  /// Application-support dir used for the host script + chrome extension id.
  Future<Directory> openKeyDataDir() async {
    if (_isWindows) return _windowsOpenKeyDir();
    if (Platform.isLinux) {
      final xdg = Platform.environment['XDG_DATA_HOME'];
      final base = (xdg != null && xdg.isNotEmpty)
          ? xdg
          : p.join(Platform.environment['HOME'] ?? '', '.local', 'share');
      final dir = Directory(p.join(base, 'OpenKey'));
      if (!await dir.exists()) await dir.create(recursive: true);
      return dir;
    }
    // macOS: prefer the real user Application Support (entitled), not the
    // App Sandbox container — Chrome must be able to exec the host script.
    final home = Platform.environment['HOME'];
    if (home != null && home.isNotEmpty) {
      final dir = Directory(
        p.join(home, 'Library', 'Application Support', 'OpenKey'),
      );
      if (!await dir.exists()) await dir.create(recursive: true);
      return dir;
    }
    final support = await getApplicationSupportDirectory();
    final dir = Directory(p.join(support.path, 'OpenKey'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<File> chromeExtensionIdFile() async {
    final dir = await openKeyDataDir();
    return File(p.join(dir.path, 'chrome_extension_id.txt'));
  }

  Future<String?> readChromeExtensionId() async {
    try {
      final file = await chromeExtensionIdFile();
      if (!await file.exists()) return null;
      final id = (await file.readAsString()).trim();
      return id.isEmpty ? null : id;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveChromeExtensionId(String id) async {
    final trimmed = id.trim();
    final file = await chromeExtensionIdFile();
    if (trimmed.isEmpty) {
      if (await file.exists()) await file.delete();
      return;
    }
    await file.writeAsString(trimmed, flush: true);
  }

  Future<void> _startLoopbackTcp() async {
    try {
      await _clearBridgeAuthToken(await _loopbackTokenFile());
      _socketServer = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = _socketServer!.port;
      final portFile = await _loopbackPortFile();
      if (portFile != null) {
        await portFile.writeAsString('$port', flush: true);
        await _chmodOwnerOnly(portFile.path);
      }
      final tokenFile = await _loopbackTokenFile();
      if (tokenFile != null) {
        await _writeBridgeAuthToken(tokenFile);
      }
      _socketServer!.listen(_handleClient);
      okDebugLog('NativeMessagingHost listening on 127.0.0.1:$port');
    } catch (e, st) {
      okDebugLog('NativeMessagingHost loopback TCP failed: $e\n$st');
      _socketServer = null;
      await _clearBridgeAuthToken(await _loopbackTokenFile());
    }
  }

  Future<File?> _loopbackPortFile() async {
    if (_isWindows) return _windowsPortFile();
    if (_isAndroid) {
      final dir = await getApplicationSupportDirectory();
      return File(p.join(dir.path, defaultPortFileName));
    }
    return null;
  }

  Future<File?> _loopbackTokenFile() async {
    if (_isWindows) return _windowsTokenFile();
    if (_isAndroid) {
      final dir = await getApplicationSupportDirectory();
      return File(p.join(dir.path, defaultTokenFileName));
    }
    return null;
  }

  Future<void> stop() async {
    final server = _socketServer;
    _socketServer = null;
    if (server == null) {
      await _clearBridgeAuthToken(await _loopbackTokenFile());
      return;
    }

    final isUnix = server.address.type == InternetAddressType.unix;
    final path = isUnix ? server.address.address : null;
    await server.close();

    if (path != null) {
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } catch (_) {}
      await _clearBridgeAuthToken(await _tokenFileForSocket(path));
    }

    if (_usesLoopbackTcp) {
      try {
        final portFile = await _loopbackPortFile();
        if (portFile != null && await portFile.exists()) {
          await portFile.delete();
        }
      } catch (_) {}
      await _clearBridgeAuthToken(await _loopbackTokenFile());
    } else {
      _bridgeAuthToken = null;
    }
  }

  void _handleClient(Socket client) {
    // Windows TCP is loopback-only. Unix sockets are local-filesystem only.
    // Refuse anything that somehow arrives from a non-loopback TCP peer.
    if (client.address.type == InternetAddressType.IPv4 ||
        client.address.type == InternetAddressType.IPv6) {
      final remote = client.remoteAddress;
      if (!remote.isLoopback) {
        okDebugLog(
          'NativeMessagingHost rejected non-loopback peer ${remote.address}',
        );
        client.destroy();
        return;
      }
    }

    final buffer = BytesBuilder(copy: false);
    // Serialize reads so overlapping socket events cannot corrupt framing.
    var chain = Future<void>.value();
    client.listen(
      (data) {
        chain = chain.then((_) async {
          buffer.add(data);
          var bytes = buffer.takeBytes();
          while (bytes.length >= 4) {
            final length =
                ByteData.sublistView(bytes).getUint32(0, Endian.little);
            // Cap frame size to limit memory abuse from a local client.
            if (length > _maxFrameBytes) {
              okDebugLog('NativeMessagingHost frame too large: $length');
              client.destroy();
              return;
            }
            if (bytes.length < 4 + length) {
              // Incomplete frame — put back once and wait for more data.
              buffer.add(bytes);
              return;
            }
            final payload = bytes.sublist(4, 4 + length);
            bytes = bytes.sublist(4 + length);
            Map<String, dynamic> response;
            try {
              final msg =
                  jsonDecode(utf8.decode(payload)) as Map<String, dynamic>;
              response = await handleMessage(msg);
            } catch (e, st) {
              okDebugLog('NativeMessagingHost message failed: $e\n$st');
              // Do not leak exception details to the extension bridge.
              response = {'ok': false, 'error': 'Request failed'};
            }
            final encoded = utf8.encode(jsonEncode(response));
            final header = ByteData(4)
              ..setUint32(0, encoded.length, Endian.little);
            client.add(header.buffer.asUint8List());
            client.add(encoded);
          }
          if (bytes.isNotEmpty) buffer.add(bytes);
        });
      },
      onError: (Object e, StackTrace st) {
        okDebugLog('NativeMessagingHost client error: $e\n$st');
        client.destroy();
      },
      onDone: () {
        client.destroy();
      },
      cancelOnError: true,
    );
  }

  // Implemented by [_NativeMessagingRegister] / [_NativeMessagingHandlers].
  Future<bool> registerBrowserNativeHost({String? chromeExtensionId});
  Future<Map<String, dynamic>> handleMessage(Map<String, dynamic> msg);
}
