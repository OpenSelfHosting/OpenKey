import 'dart:async';

/// Drops a Drift [QueryStream] without awaiting cancel.
///
/// Awaiting [StreamSubscription.cancel] from an [AuthBloc] event deadlocks:
/// the SQLCipher isolate waits to deliver the last event to the UI isolate,
/// while the UI isolate is blocked in the bloc handler waiting for cancel.
void detachWatch<T>(StreamSubscription<T>? subscription) {
  if (subscription == null) return;
  unawaited(subscription.cancel());
}
