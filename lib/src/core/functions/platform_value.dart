import 'dart:io' show Platform;

/// Picks a platform-specific value for mobile store configuration.
T platformValue<T>({required T android, required T ios}) {
  if (Platform.isIOS || Platform.isMacOS) return ios;
  return android;
}
