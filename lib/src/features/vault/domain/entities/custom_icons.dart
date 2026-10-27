import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

/// Custom (device) icons stored inline on the icon key string.
///
/// Formats:
/// - `custom:png:<base64>` — image picked from the device
/// - `custom:favicon:png:<base64>` — website favicon (auto-suggested)
class CustomIcons {
  CustomIcons._();

  static const prefix = 'custom:';
  static const faviconPrefix = 'custom:favicon:';
  static const maxEdge = 256;
  static const maxEncodedBytes = 200 * 1024;

  static final Map<String, Uint8List> _decodeCache = {};

  /// Drops decoded custom-icon bytes so a newly active vault cannot reuse them.
  static void clearDecodeCache() {
    _decodeCache.clear();
  }

  static bool isCustom(String key) => key.startsWith(prefix);

  static bool isFavicon(String key) => key.startsWith(faviconPrefix);

  static String encodePng(Uint8List pngBytes) =>
      '$prefix${'png:'}${base64Encode(pngBytes)}';

  static String encodeFaviconPng(Uint8List pngBytes) =>
      '$faviconPrefix${'png:'}${base64Encode(pngBytes)}';

  static Uint8List? decode(String key) {
    if (!isCustom(key)) return null;
    final cached = _decodeCache[key];
    if (cached != null) return cached;

    String b64;
    if (key.startsWith(faviconPrefix)) {
      final rest = key.substring(faviconPrefix.length);
      b64 = rest.startsWith('png:') ? rest.substring(4) : rest;
    } else {
      final rest = key.substring(prefix.length);
      if (rest.startsWith('png:')) {
        b64 = rest.substring(4);
      } else if (rest.startsWith('data:image/')) {
        final comma = rest.indexOf(',');
        if (comma < 0) return null;
        b64 = rest.substring(comma + 1);
      } else {
        b64 = rest;
      }
    }

    try {
      final bytes = base64Decode(b64);
      if (_decodeCache.length > 64) _decodeCache.clear();
      _decodeCache[key] = bytes;
      return bytes;
    } catch (_) {
      return null;
    }
  }

  /// Opens the system image picker and returns raw image bytes.
  static Future<Uint8List?> pickBytes() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
      allowMultiple: false,
    );
    if (picked == null || picked.files.isEmpty) return null;
    final bytes = picked.files.first.bytes;
    if (bytes == null || bytes.isEmpty) return null;
    return bytes;
  }

  /// Compresses edited bytes into a `custom:png:…` icon key.
  static Future<String> fromEditedBytes(Uint8List edited) async {
    var bytes = await resizeToPng(edited, maxEdge: maxEdge);
    var key = encodePng(bytes);
    if (key.length > maxEncodedBytes * 2) {
      bytes = await resizeToPng(edited, maxEdge: 128);
      key = encodePng(bytes);
    }
    return key;
  }

  /// Compresses favicon bytes into a `custom:favicon:png:…` icon key.
  ///
  /// Decode/resize runs on dedicated background isolates (see
  /// [_FaviconCodecPool]) so bulk vault loads do not stall the UI.
  static Future<String> fromFaviconBytes(Uint8List edited) async {
    final prepared = await _FaviconCodecPool.resize(
      edited,
      maxEdge: maxEdge,
      maxEncodedBytes: maxEncodedBytes,
    );
    return encodeFaviconPng(prepared);
  }

  /// Sync variant for workers that are already running off the UI isolate.
  static String fromFaviconBytesSync(Uint8List edited) {
    final prepared = faviconPngBytesSync(
      edited,
      maxEdge: maxEdge,
      maxEncodedBytes: maxEncodedBytes,
    );
    return encodeFaviconPng(prepared);
  }

  /// Decode + resize with `package:image` (no Flutter binding).
  static Uint8List faviconPngBytesSync(
    Uint8List source, {
    int maxEdge = maxEdge,
    int maxEncodedBytes = maxEncodedBytes,
  }) {
    var bytes = resizeToPngSync(source, maxEdge: maxEdge);
    if (encodeFaviconPng(bytes).length > maxEncodedBytes * 2) {
      bytes = resizeToPngSync(source, maxEdge: 128);
    }
    return bytes;
  }

  /// CPU-bound PNG resize safe to call from a background isolate.
  static Uint8List resizeToPngSync(Uint8List source, {int maxEdge = maxEdge}) {
    final decoded = img.decodeImage(source);
    if (decoded == null) return source;

    img.Image out = decoded;
    final w = decoded.width;
    final h = decoded.height;
    if (w > maxEdge || h > maxEdge) {
      if (w >= h) {
        out = img.copyResize(
          decoded,
          width: maxEdge,
          interpolation: img.Interpolation.average,
        );
      } else {
        out = img.copyResize(
          decoded,
          height: maxEdge,
          interpolation: img.Interpolation.average,
        );
      }
    }
    return Uint8List.fromList(img.encodePng(out, level: 6));
  }

  static Future<Uint8List> resizeToPng(
    Uint8List source, {
    int maxEdge = maxEdge,
  }) async {
    final probe = await ui.instantiateImageCodec(source);
    final probeFrame = await probe.getNextFrame();
    final src = probeFrame.image;
    final w = src.width;
    final h = src.height;
    src.dispose();

    int? targetW;
    int? targetH;
    if (w >= h && w > maxEdge) {
      targetW = maxEdge;
    } else if (h > w && h > maxEdge) {
      targetH = maxEdge;
    } else if (w == h && w > maxEdge) {
      targetW = maxEdge;
    }

    final codec = await ui.instantiateImageCodec(
      source,
      targetWidth: targetW,
      targetHeight: targetH,
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) return source;
      return data.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }
}

/// Persistent background isolates for favicon decode/resize.
///
/// HTTP downloads stay fully concurrent on the UI isolate; only the CPU-heavy
/// codec work is farmed out here so the list stays responsive.
class _FaviconCodecPool {
  _FaviconCodecPool._();

  static final List<SendPort> _workers = [];
  static final Map<int, Completer<Uint8List>> _pending = {};
  static Future<void>? _starting;
  static int _nextId = 0;
  static int _rr = 0;

  static Future<Uint8List> resize(
    Uint8List source, {
    required int maxEdge,
    required int maxEncodedBytes,
  }) async {
    await _ensureStarted();
    final id = _nextId++;
    final completer = Completer<Uint8List>();
    _pending[id] = completer;
    final worker = _workers[_rr++ % _workers.length];
    worker.send(_FaviconJob(id, source, maxEdge, maxEncodedBytes));
    return completer.future;
  }

  static Future<void> _ensureStarted() {
    if (_workers.isNotEmpty) return Future.value();
    return _starting ??= _start();
  }

  static Future<void> _start() async {
    final count = Platform.numberOfProcessors.clamp(2, 4);
    final ready = <Completer<SendPort>>[
      for (var i = 0; i < count; i++) Completer<SendPort>(),
    ];

    for (var i = 0; i < count; i++) {
      final completer = ready[i];
      final reply = ReceivePort();
      reply.listen((message) {
        if (message is SendPort) {
          if (!completer.isCompleted) completer.complete(message);
          return;
        }
        if (message is _FaviconResult) {
          final pending = _pending.remove(message.id);
          if (pending == null || pending.isCompleted) return;
          if (message.error != null) {
            pending.completeError(message.error!);
          } else {
            pending.complete(message.bytes!);
          }
        }
      });
      await Isolate.spawn(_faviconWorkerMain, reply.sendPort);
    }

    for (final c in ready) {
      _workers.add(await c.future);
    }
    _starting = null;
  }
}

class _FaviconJob {
  const _FaviconJob(this.id, this.bytes, this.maxEdge, this.maxEncodedBytes);
  final int id;
  final Uint8List bytes;
  final int maxEdge;
  final int maxEncodedBytes;
}

class _FaviconResult {
  const _FaviconResult(this.id, {this.bytes, this.error});
  final int id;
  final Uint8List? bytes;
  final Object? error;
}

void _faviconWorkerMain(SendPort replyTo) {
  final inbox = ReceivePort();
  replyTo.send(inbox.sendPort);
  inbox.listen((message) {
    if (message is! _FaviconJob) return;
    try {
      final out = CustomIcons.faviconPngBytesSync(
        message.bytes,
        maxEdge: message.maxEdge,
        maxEncodedBytes: message.maxEncodedBytes,
      );
      replyTo.send(_FaviconResult(message.id, bytes: out));
    } catch (e) {
      replyTo.send(_FaviconResult(message.id, error: e));
    }
  });
}

/// Renders a custom device icon key, or a fallback icon when missing/invalid.
class CustomIconImage extends StatelessWidget {
  const CustomIconImage({
    super.key,
    required this.iconKey,
    this.size = 24,
    this.fallback = Icons.image_rounded,
    this.fallbackColor,
    this.borderRadius,
  });

  final String iconKey;
  final double size;
  final IconData fallback;
  final Color? fallbackColor;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final bytes = CustomIcons.decode(iconKey);
    if (bytes == null) {
      return Icon(fallback, size: size * 0.85, color: fallbackColor);
    }
    final px = (size * MediaQuery.devicePixelRatioOf(context)).round().clamp(
      16,
      512,
    );
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(size * 0.2),
      child: Image.memory(
        bytes,
        width: size,
        height: size,
        fit: BoxFit.cover,
        // Decode at display size so list rows stay cheap on the UI isolate.
        cacheWidth: px,
        cacheHeight: px,
        filterQuality: FilterQuality.medium,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) =>
            Icon(fallback, size: size * 0.85, color: fallbackColor),
      ),
    );
  }
}
