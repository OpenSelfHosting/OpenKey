import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Shared [FlutterSecureStorage] options for OpenKey.
///
/// On Android, `resetOnError` must stay **false** for biometric unlock keys:
/// backgrounding the app can surface transient KeyStore / EncryptedSharedPreferences
/// errors; the plugin's default (`true` in v10+) wipes all entries and biometric
/// unlock appears "deleted" after suspending the app.
FlutterSecureStorage createAppSecureStorage() {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: false,
    ),
    mOptions: MacOsOptions(useDataProtectionKeyChain: kReleaseMode),
  );
}
