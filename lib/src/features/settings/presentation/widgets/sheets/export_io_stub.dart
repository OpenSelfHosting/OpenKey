/// Stub for web — file bytes are handled by the picker / browser download.
bool isDartIoWritablePath(String path) => false;

Future<void> writeBytesToPath(String path, List<int> bytes) async {}

Future<bool> pathNeedsWrite(String path) async => false;
