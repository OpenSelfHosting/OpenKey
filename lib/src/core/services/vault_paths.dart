import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Filesystem layout for per-account vaults (DB, attachments, avatars).
class VaultPaths {
  VaultPaths._();

  static const dbName = 'openkey';
  static const avatarsDirName = 'avatars';
  static const attachmentsDirName = 'attachments';

  static Future<Directory> supportDir() => getApplicationSupportDirectory();

  static Future<File> databaseFile({String? accountId}) async {
    final dir = await supportDir();
    if (accountId == null || accountId.isEmpty) {
      return File(p.join(dir.path, '$dbName.sqlite'));
    }
    return File(p.join(dir.path, '${dbName}_$accountId.sqlite'));
  }

  static Future<void> deleteDatabaseFiles({String? accountId}) async {
    final file = await databaseFile(accountId: accountId);
    for (final path in [file.path, '${file.path}-wal', '${file.path}-shm']) {
      final f = File(path);
      if (await f.exists()) await f.delete();
    }
  }

  /// Renames the pre-multi-account `openkey.sqlite` to the namespaced file.
  static Future<void> migrateLegacyDatabase(String accountId) async {
    final legacy = await databaseFile();
    final target = await databaseFile(accountId: accountId);
    if (!await legacy.exists() || await target.exists()) return;
    await legacy.rename(target.path);
    for (final suffix in ['-wal', '-shm']) {
      final src = File('${legacy.path}$suffix');
      if (await src.exists()) {
        await src.rename('${target.path}$suffix');
      }
    }
  }

  static Future<Directory> attachmentsDir({String? accountId}) async {
    final root = await supportDir();
    if (accountId == null || accountId.isEmpty) {
      return Directory(p.join(root.path, attachmentsDirName));
    }
    return Directory(p.join(root.path, attachmentsDirName, accountId));
  }

  /// Moves top-level `attachments/*.bin` into `attachments/{accountId}/`.
  static Future<void> migrateLegacyAttachments(String accountId) async {
    final legacy = await attachmentsDir();
    if (!await legacy.exists()) return;
    final bins = <File>[];
    await for (final entity in legacy.list(followLinks: false)) {
      if (entity is File && p.extension(entity.path) == '.bin') {
        bins.add(entity);
      }
    }
    if (bins.isEmpty) return;
    final target = await attachmentsDir(accountId: accountId);
    await target.create(recursive: true);
    for (final file in bins) {
      await file.rename(p.join(target.path, p.basename(file.path)));
    }
  }

  static Future<File> avatarFile(String accountId, {bool ensureDir = false}) async {
    final root = await supportDir();
    final dir = Directory(p.join(root.path, avatarsDirName));
    if (ensureDir && !await dir.exists()) {
      await dir.create(recursive: true);
    }
    return File(p.join(dir.path, '$accountId.png'));
  }

  static Future<void> deleteAvatar(String accountId) async {
    final file = await avatarFile(accountId);
    if (await file.exists()) await file.delete();
  }

  static Future<void> deleteAccountFiles(String accountId) async {
    await deleteDatabaseFiles(accountId: accountId);
    final attachments = await attachmentsDir(accountId: accountId);
    if (await attachments.exists()) {
      await attachments.delete(recursive: true);
    }
    await deleteAvatar(accountId);
  }
}
