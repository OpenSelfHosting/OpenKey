import 'dart:io';

/// Whether [path] can be opened with `dart:io` [File].
///
/// Android's save dialog often returns SAF-style paths such as
/// `/document/primary:Folder/file.okbak` that are not real filesystem paths.
bool isDartIoWritablePath(String path) {
  if (path.isEmpty) return false;
  if (path.startsWith('content://')) return false;
  if (path.startsWith('/document/')) return false;
  return true;
}

Future<void> writeBytesToPath(String path, List<int> bytes) async {
  if (!isDartIoWritablePath(path)) return;
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes, flush: true);
}

/// On mobile, [FilePicker.saveFile] already writes when `bytes` is passed.
/// Only rewrite when the returned path is a real empty/missing filesystem file
/// (typical on desktop).
Future<bool> pathNeedsWrite(String path) async {
  if (!isDartIoWritablePath(path)) return false;
  final file = File(path);
  if (!await file.exists()) return true;
  return await file.length() == 0;
}
