import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:openkey_app/src/core/utils/ok_debug_log.dart';
import 'package:openkey_app/src/features/vault/domain/entities/custom_icons.dart';
import 'package:openkey_app/src/features/vault/domain/entities/entry_icons.dart';
import 'package:vector_graphics/vector_graphics.dart';

/// Rasterizes a vault [VaultEntry.icon] to a small PNG for native Autofill.
class AutofillEntryIcon {
  AutofillEntryIcon._();

  static const _edge = 64;
  static const _inset = 4.0;
  static const _bg = Color(0xFFE8DEF8);
  static const _fg = Color(0xFF1D192B);

  static final Map<String, String> _cache = {};

  /// Base64 PNG, or null when the icon cannot be drawn.
  static Future<String?> pngBase64(String iconKey) async {
    final key = iconKey.isEmpty ? EntryIcons.defaultKey : iconKey;
    final cached = _cache[key];
    if (cached != null) return cached.isEmpty ? null : cached;
    final png = await _rasterize(key);
    final b64 = png == null ? '' : base64Encode(png);
    if (_cache.length > 256) _cache.clear();
    _cache[key] = b64;
    return b64.isEmpty ? null : b64;
  }

  static Future<List<int>?> _rasterize(String key) async {
    try {
      if (CustomIcons.isCustom(key)) {
        final bytes = CustomIcons.decode(key);
        if (bytes == null || bytes.isEmpty) return null;
        final resized = CustomIcons.resizeToPngSync(
          bytes,
          maxEdge: _edge - _inset.toInt() * 2,
        );
        return await _containSquare(resized);
      }
      final brandPath = EntryIcons.brandAssetPath(key);
      if (brandPath != null) return await _brandPng(brandPath);
      return await _materialPng(key);
    } catch (e, st) {
      okDebugLog('AutofillEntryIcon.rasterize($key) failed: $e\n$st');
      return null;
    }
  }

  static Future<List<int>?> _brandPng(String assetPath) async {
    final info = await vg.loadPicture(AssetBytesLoader(assetPath), null);
    try {
      final src = info.size;
      if (src.width <= 0 || src.height <= 0) return null;
      final inner = _edge - _inset * 2;
      final scale = inner / math.max(src.width, src.height);
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        Rect.fromLTWH(0, 0, _edge.toDouble(), _edge.toDouble()),
      );
      canvas.translate(
        _inset + (inner - src.width * scale) / 2,
        _inset + (inner - src.height * scale) / 2,
      );
      canvas.scale(scale);
      canvas.drawPicture(info.picture);
      return await _pngOf(recorder.endRecording());
    } finally {
      info.picture.dispose();
    }
  }

  static Future<List<int>?> _materialPng(String key) async {
    final icon = EntryIcons.resolveMaterial(key);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final rect = Rect.fromLTWH(0, 0, _edge.toDouble(), _edge.toDouble());
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(14)),
      Paint()..color = _bg,
    );
    final glyphSize = _edge * 0.52;
    final painter = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          fontSize: glyphSize,
          color: _fg,
        ),
      )
      ..layout();
    painter.paint(
      canvas,
      Offset((_edge - painter.width) / 2, (_edge - painter.height) / 2),
    );
    return await _pngOf(recorder.endRecording());
  }

  static Future<List<int>?> _containSquare(Uint8List pngBytes) async {
    final codec = await ui.instantiateImageCodec(pngBytes);
    final frame = await codec.getNextFrame();
    final src = frame.image;
    try {
      if (src.width <= 0 || src.height <= 0) return null;
      final inner = _edge - _inset * 2;
      final scale = inner / math.max(src.width, src.height);
      final dw = src.width * scale;
      final dh = src.height * scale;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        Rect.fromLTWH(0, 0, _edge.toDouble(), _edge.toDouble()),
      );
      canvas.drawImageRect(
        src,
        Rect.fromLTWH(0, 0, src.width.toDouble(), src.height.toDouble()),
        Rect.fromLTWH(
          _inset + (inner - dw) / 2,
          _inset + (inner - dh) / 2,
          dw,
          dh,
        ),
        Paint()..filterQuality = FilterQuality.high,
      );
      return await _pngOf(recorder.endRecording());
    } finally {
      src.dispose();
    }
  }

  static Future<List<int>?> _pngOf(ui.Picture picture) async {
    try {
      final image = await picture.toImage(_edge, _edge);
      try {
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        return data?.buffer.asUint8List();
      } finally {
        image.dispose();
      }
    } finally {
      picture.dispose();
    }
  }
}
