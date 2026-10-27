class BackupRestoreException implements Exception {
  const BackupRestoreException(this.message);

  final String message;

  @override
  String toString() => message;
}
