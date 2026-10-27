import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

/// Listens for Autofill intents (Android / iOS / macOS) and routes to unlock / save UI.
class AutofillLifecycle extends StatefulWidget {
  const AutofillLifecycle({super.key, required this.child});

  final Widget child;

  @override
  State<AutofillLifecycle> createState() => _AutofillLifecycleState();
}

class _AutofillLifecycleState extends State<AutofillLifecycle> {
  @override
  void initState() {
    super.initState();
    final bridge = sl<AutofillBridge>();
    if (!bridge.isSupported) return;
    bridge.setIntentHandler(_handleIntent);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        bridge.setRequireBiometric(
          sl<VaultMetadataStore>().autofillRequireBiometric,
        ),
      );
      unawaited(bridge.syncPresentation());
      unawaited(_handleIntent());
    });
  }

  @override
  void dispose() {
    if (sl<AutofillBridge>().isSupported) {
      sl<AutofillBridge>().setIntentHandler(null);
    }
    super.dispose();
  }

  Future<void> _handleIntent() async {
    final bridge = sl<AutofillBridge>();
    if (!bridge.isSupported || !mounted) return;

    await bridge.takePendingUnlock();

    if (sl<AuthBloc>().state.isUnlocked) {
      await bridge.drainPendingPasskeyWork();
    }

    final pending = await bridge.takePendingSave();
    if (pending != null) {
      final auth = sl<AuthBloc>().state;
      if (!auth.isUnlocked) {
        bridge.holdSave(pending);
        return;
      }
      _goSave(pending);
      return;
    }

    final held = bridge.takeHeldSave();
    if (held != null && sl<AuthBloc>().state.isUnlocked) {
      _goSave(held);
    }
  }

  void _goSave(AutofillSaveRequest request) {
    if (!mounted) return;
    final router = AppRouter.routes;
    router.go(AppRoutes.autofillSave.path, extra: request);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, next) =>
          !prev.isUnlocked && next.isUnlocked,
      listener: (context, state) {
        unawaited(_handleIntent());
      },
      child: widget.child,
    );
  }
}
