import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/src/src.dart';

const kSetupMinPasswordLength = 12;

double setupPasswordStrength(String password) {
  if (password.isEmpty) return 0;
  var score = (password.length / 12).clamp(0.0, 0.5);
  if (RegExp(r'[A-Z]').hasMatch(password)) score += 0.125;
  if (RegExp(r'[a-z]').hasMatch(password)) score += 0.125;
  if (RegExp(r'\d').hasMatch(password)) score += 0.125;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score += 0.125;
  return score.clamp(0.0, 1.0);
}

bool looksLikeUrl(String url) =>
    url.startsWith('http://') || url.startsWith('https://');

/// Shared chrome + auth navigation for first-run and add-account setup.
class SetupFlowScaffold extends StatelessWidget {
  const SetupFlowScaffold({
    super.key,
    required this.body,
    this.bottomBar,
    this.loading = false,
    this.busyMessage,
    this.showBack = true,
  });

  final Widget body;
  final Widget? bottomBar;
  final bool loading;
  final String? busyMessage;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.addingAccount != current.addingAccount ||
          previous.hasVault != current.hasVault,
      listener: _onAuth,
      builder: (context, state) {
        final addingAccount = state.addingAccount;
        final canPop = context.canPop();
        final showLeading = showBack && (canPop || addingAccount);
        final scheme = Theme.of(context).colorScheme;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppSystemUi.overlayFor(scheme),
          child: Stack(
            children: [
              Scaffold(
                backgroundColor: scheme.surface,
                appBar: AppBar(
                  toolbarHeight: showLeading ? kToolbarHeight : 0,
                  elevation: 0,
                  leading: showLeading
                      ? IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          onPressed: loading
                              ? null
                              : () => _onBack(context, addingAccount),
                        )
                      : null,
                ),
                body: AdaptiveContentWidth(
                  maxWidth: 480,
                  expandHeight: true,
                  child: body,
                ),
                bottomNavigationBar: bottomBar == null
                    ? null
                    : SafeArea(
                        child: AdaptiveContentWidth(
                          maxWidth: 480,
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                          child: bottomBar!,
                        ),
                      ),
              ),
              if (loading)
                Positioned.fill(
                  child: AuthBusyOverlay(
                    message: busyMessage ?? context.s.creatingVault,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _onBack(BuildContext context, bool addingAccount) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    if (addingAccount) {
      okDebugLog('[add-account] SetupPage back tapped');
      context.read<AuthBloc>().add(const AuthAddAccountCancelled());
    }
  }

  void _onAuth(BuildContext context, AuthState state) {
    if (state.status == AuthStatus.unlocked) {
      if (state.addingAccount) {
        okDebugLog('[add-account] SetupPage stay — unlocked but addingAccount');
        return;
      }
      if (state.error != null) {
        showMESnackBar(context, message: state.error!.getMessage(context));
      }
      context.go(AppRoutes.vault.path);
      return;
    }
    if (!state.addingAccount && state.hasVault && !state.isUnlocked) {
      okDebugLog('[add-account] SetupPage back → unlock');
      context.go(AppRoutes.unlock.path);
    }
  }
}

class SetupZeroKnowledgeBanner extends StatelessWidget {
  const SetupZeroKnowledgeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    return MEBanner(
      color: scheme.secondaryContainer,
      icon: Icon(Icons.shield_outlined, color: scheme.onSecondaryContainer),
      content: Text(
        s.setupZeroKnowledgeBanner,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: scheme.onSecondaryContainer),
      ),
    );
  }
}

class SetupAuthErrorBanner extends StatelessWidget {
  const SetupAuthErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: MEBanner(
        color: scheme.errorContainer,
        icon: Icon(Icons.error_outline_rounded, color: scheme.onErrorContainer),
        content: Text(
          message,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: scheme.onErrorContainer),
        ),
      ),
    );
  }
}

class SetupSelfHostedToggle extends StatelessWidget {
  const SetupSelfHostedToggle({
    super.key,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MECorners.large),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Row(
          children: [
            ExpressiveIconContainer(
              size: 40,
              backgroundColor: scheme.primaryContainer,
              shape: ExpressiveShape.cookie6Sided,
              child: Icon(
                Icons.dns_rounded,
                size: 20,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.setupLinkSelfHostedTitle,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s.setupLinkSelfHostedSubtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            MESwitch(value: value, onChanged: enabled ? onChanged : null),
          ],
        ),
      ),
    );
  }
}
