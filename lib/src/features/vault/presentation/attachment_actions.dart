import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

/// Decrypt, save, and open vault attachment bytes.
abstract final class AttachmentActions {
  static const _uuid = Uuid();

  /// Decrypts [meta] while a blocking loading dialog is shown.
  static Future<Uint8List?> decrypt(
    BuildContext context,
    AttachmentMeta meta,
  ) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    final s = context.s;
    unawaited(
      showMEDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => MEDialog(
          title: Text(s.openingAttachment),
          content: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: MELoadingIndicator(size: 56)),
          ),
        ),
      ),
    );

    final result = await sl<AttachmentService>().readAttachment(meta);
    if (navigator.canPop()) navigator.pop();

    return result.fold((failure) {
      if (context.mounted) {
        showMEToast(
          context,
          message: failure.getMessage(context),
          kind: METoastKind.error,
        );
      }
      return null;
    }, (bytes) => bytes);
  }

  static Future<void> previewInApp(
    BuildContext context,
    AttachmentMeta meta,
  ) async {
    final bytes = await decrypt(context, meta);
    if (bytes == null || !context.mounted) return;
    await AttachmentPreviewPage.show(context, name: meta.name, bytes: bytes);
  }

  static Future<void> downloadToDevice(
    BuildContext context,
    AttachmentMeta meta,
  ) async {
    final bytes = await decrypt(context, meta);
    if (bytes == null || !context.mounted) return;
    final saved = await save(
      context: context,
      name: attachmentPlaybackFileName(meta.name),
      bytes: bytes,
    );
    if (!context.mounted || !saved) return;
    showMEToast(
      context,
      message: context.s.attachmentSaved(meta.name),
      kind: METoastKind.success,
    );
  }

  /// Reads picker bytes; large videos often expose only [PlatformFile.path].
  static Future<Uint8List?> readPlatformFileBytes(PlatformFile file) async {
    if (file.bytes != null && file.bytes!.isNotEmpty) return file.bytes;
    final path = file.path;
    if (kIsWeb || path == null || path.isEmpty) return null;
    try {
      return await File(path).readAsBytes();
    } catch (_) {
      return null;
    }
  }

  /// Normalizes gallery / SAF names so video extensions are preserved.
  static String resolveFileName(PlatformFile file) =>
      ensureAttachmentFileName(file.name, pathHint: file.path);

  /// Shows a save dialog. Returns `false` if the user cancelled.
  static Future<bool> save({
    required BuildContext context,
    required String name,
    required Uint8List bytes,
  }) async {
    final path = await FilePicker.platform.saveFile(
      dialogTitle: context.s.downloadAttachment,
      fileName: _safeFileName(name),
      type: FileType.any,
      bytes: bytes,
    );
    if (path == null || path.isEmpty) return false;
    if (_needsWrite(path) && await _isEmptyOrMissing(path)) {
      await _writeBytes(path, bytes);
    }
    return true;
  }

  /// Writes [bytes] to a temp file and opens it with the system handler.
  static Future<bool> open({
    required String name,
    required Uint8List bytes,
  }) async {
    final file = await materializeTemp(name, bytes);
    return openPath(file.path);
  }

  static Future<File> materializeTemp(String name, Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final playbackName = attachmentPlaybackFileName(name);
    final file = File(
      p.join(
        dir.path,
        'openkey-att-${_uuid.v4()}-${_safeFileName(playbackName)}',
      ),
    );
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static Future<bool> openPath(String path) async {
    try {
      final launched = await launchUrl(
        Uri.file(path),
        mode: LaunchMode.externalApplication,
      );
      if (launched) return true;
    } catch (_) {}
    return _openWithProcess(path);
  }

  static Future<bool> _openWithProcess(String path) async {
    try {
      if (Platform.isLinux) {
        return (await Process.run('xdg-open', [path])).exitCode == 0;
      }
      if (Platform.isMacOS) {
        return (await Process.run('open', [path])).exitCode == 0;
      }
      if (Platform.isWindows) {
        return (await Process.run('cmd', ['/c', 'start', '', path])).exitCode ==
            0;
      }
    } catch (_) {}
    return false;
  }

  static String _safeFileName(String name) {
    final base = p.basename(name).replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    final trimmed = base.trim();
    return trimmed.isEmpty ? 'attachment' : trimmed;
  }

  static bool _needsWrite(String path) {
    if (path.isEmpty) return false;
    if (path.startsWith('content://')) return false;
    if (path.startsWith('/document/')) return false;
    return true;
  }

  static Future<bool> _isEmptyOrMissing(String path) async {
    final file = File(path);
    if (!await file.exists()) return true;
    return await file.length() == 0;
  }

  static Future<void> _writeBytes(String path, Uint8List bytes) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
  }
}
