import 'dart:io' show Platform;

/// Picks a platform-specific value (store listings, labels, etc.).
T platformCase<T>({
  required T Function() android,
  required T Function() ios,
  T Function()? windows,
  T Function()? linux,
  T Function()? macos,
}) {
  if (Platform.isAndroid) return android();
  if (Platform.isIOS) return ios();
  if (Platform.isWindows) return windows?.call() ?? android();
  if (Platform.isLinux) return linux?.call() ?? android();
  if (Platform.isMacOS) return macos?.call() ?? ios();
  return android();
}
