import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

class PickedBackupFile {
  const PickedBackupFile({required this.bytes, required this.name, this.email});

  final Uint8List bytes;
  final String name;
  final String? email;
}

/// File picker for encrypted `.okbak` restore on the setup screen.
class RestoreBackupFlow {
  RestoreBackupFlow._();

  static Future<PickedBackupFile?> pickFile(BuildContext context) async {
    final s = context.s;
    final picked = await FilePicker.platform.pickFiles(
      dialogTitle: s.importBackup,
      // .okbak is not a registered Android MIME; validate by magic bytes.
      type: FileType.any,
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return null;

    final file = picked.files.first;
    final bytes = await _readBytes(file);
    if (bytes == null || bytes.isEmpty) return null;

    return PickedBackupFile(
      bytes: bytes,
      name: file.name,
      email: sl<BackupRestoreService>().peekBackupEmail(bytes),
    );
  }

  static Future<Uint8List?> _readBytes(PlatformFile file) async {
    if (file.bytes != null && file.bytes!.isNotEmpty) return file.bytes;
    final path = file.path;
    if (kIsWeb || path == null || path.isEmpty) return null;
    try {
      return await File(path).readAsBytes();
    } catch (_) {
      return null;
    }
  }
}
