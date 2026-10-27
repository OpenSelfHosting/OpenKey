import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// How an attachment should be previewed from its file name.
enum AttachmentKind { image, video, audio, text, other }

/// Whether [video_player] can decode attachments on this platform.
bool get attachmentInAppVideoSupported {
  if (kIsWeb) return false;
  if (Platform.environment.containsKey('FLUTTER_TEST')) return false;
  return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
}

const _imageExts = {
  'png',
  'jpg',
  'jpeg',
  'gif',
  'webp',
  'bmp',
  'heic',
  'heif',
  'ico',
  'wbmp',
};

const _videoExts = {
  'mp4',
  'mov',
  'm4v',
  'webm',
  'mkv',
  'avi',
  '3gp',
  'mpeg',
  'mpg',
};

const _audioExts = {'mp3', 'wav', 'm4a', 'aac', 'ogg', 'flac', 'opus', 'oga'};

const _textExts = {
  'txt',
  'md',
  'json',
  'csv',
  'log',
  'yaml',
  'yml',
  'xml',
  'html',
  'htm',
  'css',
  'js',
  'ts',
  'dart',
  'env',
  'ini',
  'conf',
  'sh',
  'py',
  'rs',
  'toml',
};

const Map<String, IconData> attachmentIcons = {
  'pdf': Icons.picture_as_pdf_outlined,
  'doc': Icons.description_outlined,
  'docx': Icons.description_outlined,
  'txt': Icons.notes_outlined,
  'md': Icons.notes_outlined,
  'xls': Icons.table_chart_outlined,
  'xlsx': Icons.table_chart_outlined,
  'csv': Icons.table_chart_outlined,
  'ppt': Icons.slideshow_outlined,
  'pptx': Icons.slideshow_outlined,
  'zip': Icons.folder_zip_outlined,
  'rar': Icons.folder_zip_outlined,
  'gz': Icons.folder_zip_outlined,
  'png': Icons.image_outlined,
  'jpg': Icons.image_outlined,
  'jpeg': Icons.image_outlined,
  'gif': Icons.gif_box_outlined,
  'svg': Icons.image_outlined,
  'webp': Icons.image_outlined,
  'mp3': Icons.audio_file_outlined,
  'wav': Icons.audio_file_outlined,
  'mp4': Icons.video_file_outlined,
  'mov': Icons.video_file_outlined,
  'webm': Icons.video_file_outlined,
  'dart': Icons.code_outlined,
  'js': Icons.code_outlined,
  'ts': Icons.code_outlined,
  'py': Icons.code_outlined,
  'json': Icons.data_object_outlined,
  'yaml': Icons.data_object_outlined,
  'yml': Icons.data_object_outlined,
};

/// File extension without the leading dot, lowercased. Empty if none.
String attachmentExtension(String fileName) {
  final base = fileName.split(RegExp(r'[\\/]')).last;
  final dot = base.lastIndexOf('.');
  if (dot < 0 || dot == base.length - 1) return '';
  return base.substring(dot + 1).toLowerCase();
}

AttachmentKind attachmentKindFor(String fileName) {
  final ext = attachmentExtension(fileName);
  if (_imageExts.contains(ext)) return AttachmentKind.image;
  if (_videoExts.contains(ext)) return AttachmentKind.video;
  if (_audioExts.contains(ext)) return AttachmentKind.audio;
  if (_textExts.contains(ext)) return AttachmentKind.text;
  return AttachmentKind.other;
}

IconData attachmentIconFor(String fileName) {
  final ext = attachmentExtension(fileName);
  if (ext.isNotEmpty && attachmentIcons.containsKey(ext)) {
    return attachmentIcons[ext]!;
  }
  return switch (attachmentKindFor(fileName)) {
    AttachmentKind.image => Icons.image_outlined,
    AttachmentKind.video => Icons.videocam_outlined,
    AttachmentKind.audio => Icons.audiotrack_outlined,
    AttachmentKind.text => Icons.article_outlined,
    AttachmentKind.other => Icons.insert_drive_file_outlined,
  };
}

String formatAttachmentSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

/// Ensures [name] has a file extension, optionally borrowing one from [pathHint].
String ensureAttachmentFileName(String name, {String? pathHint}) {
  var resolved = name.trim();
  if (resolved.isEmpty && pathHint != null && pathHint.isNotEmpty) {
    resolved = pathHint.split(RegExp(r'[\\/]')).last;
  }
  if (resolved.isEmpty) return 'attachment';
  if (attachmentExtension(resolved).isNotEmpty) return resolved;

  final pathExt = pathHint == null ? '' : attachmentExtension(pathHint);
  if (pathExt.isNotEmpty) {
    final base = resolved.contains('.')
        ? resolved.substring(0, resolved.lastIndexOf('.'))
        : resolved;
    return '$base.$pathExt';
  }

  return switch (attachmentKindFor(resolved)) {
    AttachmentKind.video => '$resolved.mp4',
    AttachmentKind.audio => '$resolved.m4a',
    AttachmentKind.image => '$resolved.jpg',
    _ => resolved,
  };
}

/// MIME type for sync uploads and playback hints.
String attachmentContentType(String fileName) {
  return switch (attachmentExtension(fileName)) {
    'mp4' || 'm4v' => 'video/mp4',
    'mov' => 'video/quicktime',
    'webm' => 'video/webm',
    'mkv' => 'video/x-matroska',
    'avi' => 'video/x-msvideo',
    '3gp' => 'video/3gpp',
    'mpeg' || 'mpg' => 'video/mpeg',
    'mp3' => 'audio/mpeg',
    'wav' => 'audio/wav',
    'm4a' => 'audio/mp4',
    'aac' => 'audio/aac',
    'ogg' || 'oga' => 'audio/ogg',
    'flac' => 'audio/flac',
    'opus' => 'audio/opus',
    'png' => 'image/png',
    'jpg' || 'jpeg' => 'image/jpeg',
    'gif' => 'image/gif',
    'webp' => 'image/webp',
    'pdf' => 'application/pdf',
    'txt' => 'text/plain',
    'json' => 'application/json',
    _ => 'application/octet-stream',
  };
}

/// File name with an extension suitable for OS / [VideoPlayerController] playback.
String attachmentPlaybackFileName(String name) =>
    ensureAttachmentFileName(name);

/// Short text snippet for list previews, or `null` when not text-like.
String? attachmentTextPreview(Uint8List bytes, {int maxChars = 160}) {
  final probe = bytes.length > 4096 ? bytes.sublist(0, 4096) : bytes;
  if (probe.contains(0)) return null;
  final decoded = utf8.decode(
    bytes.length > maxChars * 4 ? bytes.sublist(0, maxChars * 4) : bytes,
    allowMalformed: true,
  );
  final trimmed = decoded.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed.length <= maxChars) return trimmed;
  return '${trimmed.substring(0, maxChars).trim()}…';
}
