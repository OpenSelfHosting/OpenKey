import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

/// Locks the vault after the configured time away from the app
/// ([VaultMetadataStore.lockMinutes]).
///
/// The timer starts only when the app is sent to the background without being
/// closed. In-app idle time is ignored. Force-closing the process ends the
/// in-memory session immediately.
class AutoLockLifecycle extends StatefulWidget {
  const AutoLockLifecycle({super.key, required this.child});

  final Widget child;

  @override
  State<AutoLockLifecycle> createState() => _AutoLockLifecycleState();
}

class _AutoLockLifecycleState extends State<AutoLockLifecycle>
    with WidgetsBindingObserver {
  Timer? _timer;
  DateTime? _leftAppAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _onLeftApp();
      case AppLifecycleState.resumed:
        _onReturnedToApp();
      case AppLifecycleState.detached:
        _timer?.cancel();
        _leftAppAt = null;
      case AppLifecycleState.inactive:
        break;
    }
  }

  void _onLeftApp() {
    if (!sl<VaultSession>().isUnlocked) return;
    final minutes = sl<VaultMetadataStore>().lockMinutes;
    if (minutes <= 0) return;
    _leftAppAt ??= DateTime.now();
    _timer?.cancel();
    final remaining = Duration(minutes: minutes) -
        DateTime.now().difference(_leftAppAt!);
    if (remaining <= Duration.zero) {
      _requestLock();
      return;
    }
    _timer = Timer(remaining, _requestLock);
  }

  void _onReturnedToApp() {
    _timer?.cancel();
    final leftAt = _leftAppAt;
    _leftAppAt = null;
    final minutes = sl<VaultMetadataStore>().lockMinutes;
    if (minutes <= 0 || !sl<VaultSession>().isUnlocked || leftAt == null) {
      return;
    }
    if (DateTime.now().difference(leftAt) >= Duration(minutes: minutes)) {
      _requestLock();
    }
  }

  void _requestLock() {
    _timer?.cancel();
    _leftAppAt = null;
    if (!sl<VaultSession>().isUnlocked) return;
    sl<AuthBloc>().add(const AuthLockRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, next) => prev.isUnlocked != next.isUnlocked,
      listener: (_, state) {
        if (!state.isUnlocked) {
          _timer?.cancel();
          _leftAppAt = null;
        }
      },
      child: widget.child,
    );
  }
}
