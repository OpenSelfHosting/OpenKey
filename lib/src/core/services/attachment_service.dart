import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:openkey_app/src/src.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class AttachmentService {
  AttachmentService(
    this._api,
    this._session,
    this._crypto,
    this._metadata,
  );

  final ApiClient _api;
  final VaultSession _session;
  final CryptoService _crypto;
  final VaultMetadataStore _metadata;
  final _uuid = const Uuid();

  static const maxBytes = 20 * 1024 * 1024;

  Future<Directory> _dir() async {
    final dir = await VaultPaths.attachmentsDir(
      accountId: _metadata.activeAccountId,
    );
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  FutureFailureOr<AttachmentMeta> addAttachment({
    required String entryUuid,
    required String filename,
    required Uint8List bytes,
    String? contentType,
  }) async {
    try {
      if (bytes.length > maxBytes) {
        return const Left(CommonFailures.attachmentTooLarge);
      }
      if (!_session.isUnlocked) {
        return const Left(CommonFailures.vaultLocked);
      }
      final id = _uuid.v4();
      final cipher = await _crypto.encryptBytes(
        key: _session.vaultKey,
        plaintext: bytes,
      );
      final dir = await _dir();
      final file = File(p.join(dir.path, '$id.bin'));
      await file.writeAsString(cipher);

      final url = _metadata.serverUrl;
      final token = _metadata.accessToken;
      if (url != null && token != null) {
        _api.configure(baseUrl: url, accessToken: token);
        final blobBytes = CryptoService.decodeBase64Url(cipher);
        await _api.postMultipart(
          '/attachments',
          auth: true,
          fields: {
            'uuid': id,
            'entry_uuid': entryUuid,
            'filename': filename,
            'size_bytes': '${blobBytes.length}',
            'revision': '1',
            if (contentType != null) 'content_type': contentType,
          },
          fileBytes: blobBytes,
          fileField: 'file',
          filename: filename,
          contentType: contentType,
        );
      }

      return Right(
        AttachmentMeta(id: id, name: filename, size: bytes.length, cipher: cipher),
      );
    } on ApiException catch (e) {
      return Left(FailureMessage(e.message));
    } catch (e) {
      return Left(FailureMessage(e.toString()));
    }
  }

  FutureFailureOr<Uint8List> readAttachment(AttachmentMeta meta) async {
    try {
      if (!_session.isUnlocked) {
        return const Left(CommonFailures.vaultLocked);
      }
      var cipher = meta.cipher;
      if (cipher == null) {
        cipher = await readLocalCipher(meta.id);
        if (cipher == null) {
          final url = _metadata.serverUrl;
          final token = _metadata.accessToken;
          if (url == null || token == null) {
            return const Left(CommonFailures.attachmentMissing);
          }
          _api.configure(baseUrl: url, accessToken: token);
          final blobBytes = await _api.getBytes(
            '/attachments/${meta.id}/content',
            auth: true,
          );
          cipher = CryptoService.encodeBase64Url(blobBytes);
          await saveSyncedBlob(id: meta.id, encryptedBlob: cipher);
        }
      }
      final clear = await _crypto.decryptBytes(
        key: _session.vaultKey,
        ciphertext: cipher,
      );
      return Right(clear);
    } catch (e) {
      return Left(FailureMessage(e.toString()));
    }
  }

  /// Reads ciphertext stored under the attachments directory, if present.
  Future<String?> readLocalCipher(String id) async {
    final dir = await _dir();
    final file = File(p.join(dir.path, '$id.bin'));
    if (!await file.exists()) return null;
    final cipher = await file.readAsString();
    return cipher.isEmpty ? null : cipher;
  }

  /// Persists a sync/API ciphertext blob for offline reads.
  Future<void> saveSyncedBlob({
    required String id,
    required String encryptedBlob,
  }) async {
    final dir = await _dir();
    final file = File(p.join(dir.path, '$id.bin'));
    await file.writeAsString(encryptedBlob);
  }

  Future<void> deleteLocalBlob(String id) async {
    final dir = await _dir();
    final file = File(p.join(dir.path, '$id.bin'));
    if (await file.exists()) await file.delete();
  }

  /// Builds a `/sync` attachment push item from local ciphertext.
  Map<String, dynamic>? syncPushItem({
    required String entryUuid,
    required AttachmentMeta meta,
    required String cipher,
    int revision = 1,
    bool isDeleted = false,
    String? contentType,
  }) {
    try {
      final blobBytes = CryptoService.decodeBase64Url(cipher);
      if (blobBytes.length > maxBytes) return null;
      return {
        'uuid': meta.id,
        'entry_uuid': entryUuid,
        'filename': meta.name,
        'size_bytes': blobBytes.length,
        'content_type': contentType,
        'revision': revision,
        'is_deleted': isDeleted,
        'encrypted_blob': base64Encode(blobBytes),
      };
    } catch (_) {
      return null;
    }
  }
}
