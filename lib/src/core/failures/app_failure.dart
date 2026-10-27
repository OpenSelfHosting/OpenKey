import 'package:flutter/widgets.dart';
import 'package:openkey_app/src/core/l10n/l10n.dart';

abstract class AppFailure {
  const AppFailure();

  String getMessage(BuildContext context);
}

class FailureMessage extends AppFailure {
  const FailureMessage(this.message);

  final String message;

  @override
  String getMessage(BuildContext context) => message;
}

enum CommonFailures implements AppFailure {
  unknown,
  network,
  unauthorized,
  notFound,
  server,
  invalidCredentials,
  vaultLocked,
  vaultAlreadyExists,
  decryptionFailed,
  syncFailed,
  failedToCreateCollection,
  failedToUpdateCollection,
  failedToDeleteCollection,
  failedToGetCollections,
  failedToCreateEntry,
  failedToUpdateEntry,
  failedToDeleteEntry,
  failedToGetEntries,
  noVault,
  connectServerFirst,
  attachmentTooLarge,
  attachmentMissing,
  accountEmailExists;

  @override
  String getMessage(BuildContext context) {
    final s = context.s;
    return switch (this) {
      unknown => s.failureUnknown,
      network => s.failureNetwork,
      unauthorized => s.failureUnauthorized,
      notFound => s.failureNotFound,
      server => s.failureServer,
      invalidCredentials => s.failureInvalidCredentials,
      vaultLocked => s.failureVaultLocked,
      vaultAlreadyExists => s.failureVaultAlreadyExists,
      decryptionFailed => s.failureDecryptionFailed,
      syncFailed => s.failureSyncFailed,
      failedToCreateCollection => s.failureCreateCollection,
      failedToUpdateCollection => s.failureUpdateCollection,
      failedToDeleteCollection => s.failureDeleteCollection,
      failedToGetCollections => s.failureGetCollections,
      failedToCreateEntry => s.failureCreateEntry,
      failedToUpdateEntry => s.failureUpdateEntry,
      failedToDeleteEntry => s.failureDeleteEntry,
      failedToGetEntries => s.failureGetEntries,
      noVault => s.failureNoVault,
      connectServerFirst => s.failureConnectServerFirst,
      attachmentTooLarge => s.failureAttachmentTooLarge,
      attachmentMissing => s.failureAttachmentMissing,
      accountEmailExists => s.failureAccountEmailExists,
    };
  }
}
