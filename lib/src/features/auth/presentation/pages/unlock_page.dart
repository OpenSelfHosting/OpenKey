import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

class UnlockPage extends StatefulWidget {
  const UnlockPage({super.key});

  @override
  State<UnlockPage> createState() => _UnlockPageState();
}

class _UnlockPageState extends State<UnlockPage> {
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _error;
  bool _bioAvailable = false;
  bool _autoBioPrompted = false;
  String? _autoBioAccountId;

  @override
  void initState() {
    super.initState();
    _autoBioAccountId = sl<AuthBloc>().state.activeAccountId;
    _refreshBio(prompt: true);
  }

  /// Claims the auto-prompt slot immediately so overlapping calls cannot
  /// dispatch a second [AuthBiometricUnlockRequested].
  Future<void> _refreshBio({required bool prompt}) async {
    if (prompt) {
      if (_autoBioPrompted) return;
      _autoBioPrompted = true;
      _autoBioAccountId = context.mounted
          ? context.read<AuthBloc>().state.activeAccountId
          : _autoBioAccountId;
    }

    final bio = sl<BiometricUnlockService>();
    final supported = await bio.isSupported;
    final enabled = await bio.isEnabled;
    final available = supported && enabled;
    if (!mounted) return;
    setState(() => _bioAvailable = available);

    if (!prompt || !available) {
      if (prompt && !available) _autoBioPrompted = false;
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<AuthBloc>().state;
      if (state.status == AuthStatus.loading ||
          state.status == AuthStatus.unlocked) {
        return;
      }
      context.read<AuthBloc>().add(const AuthBiometricUnlockRequested());
    });
  }

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return AppSystemUiScope(
      child: Scaffold(
        backgroundColor: scheme.surface,
        appBar: AppBar(
          toolbarHeight: 0,
          elevation: 0,
          backgroundColor: scheme.surface,
          surfaceTintColor: Colors.transparent,
        ),
        body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            previous.status != current.status ||
            previous.hasVault != current.hasVault ||
            previous.activeAccountId != current.activeAccountId,
        listener: (context, state) {
          if (state.status == AuthStatus.unlocked) {
            context.go(AppRoutes.vault.path);
          }
          if (!state.hasVault && state.status != AuthStatus.loading) {
            context.go(AppRoutes.setup.path);
          }
          final switchedAccount =
              state.activeAccountId != null &&
              state.activeAccountId != _autoBioAccountId;
          if (!switchedAccount) return;
          if (state.status == AuthStatus.unlocked ||
              state.status == AuthStatus.loading) {
            return;
          }
          _password.clear();
          _autoBioAccountId = state.activeAccountId;
          _autoBioPrompted = false;
          _refreshBio(prompt: true);
        },
        builder: (context, state) {
          final loading = state.status == AuthStatus.loading;
          final showFailure =
              state.status == AuthStatus.failure && state.error != null;

          return AdaptiveContentWidth(
            maxWidth: 480,
            expandHeight: true,
            child: Form(
              key: _formKey,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
                children: [
                  // const AuthBrandHero(compact: true),
                  const SizedBox(height: 28),
                  UnlockAccountHeader(
                    email: state.email,
                    accountId: state.activeAccountId,
                    avatarPath: state.avatarPath,
                    canSwitch: state.accounts.length > 1,
                    enabled: !loading,
                    onSwitch: () => const AccountSwitcherSheet().show(context),
                  ),
                  const SizedBox(height: 28),
                  MEPasswordField(
                    controller: _password,
                    label: s.masterPassword,
                    errorText: _error,
                    onSubmitted: (_) => _unlock(context),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    child: state.shouldShowPasswordHint
                        ? Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: MEBanner(
                              color: scheme.tertiaryContainer,
                              icon: Icon(
                                Icons.lightbulb_outline_rounded,
                                color: scheme.onTertiaryContainer,
                              ),
                              content: Text(
                                s.passwordHintReveal(state.passwordHint!),
                                style: textTheme.bodyMedium?.copyWith(
                                  color: scheme.onTertiaryContainer,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    child: showFailure
                        ? Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: MEBanner(
                              color: scheme.errorContainer,
                              icon: Icon(
                                Icons.error_outline_rounded,
                                color: scheme.onErrorContainer,
                              ),
                              content: Text(
                                state.error!.getMessage(context),
                                style: textTheme.bodyMedium?.copyWith(
                                  color: scheme.onErrorContainer,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  if (_bioAvailable) ...[
                    const SizedBox(height: 24),
                    Material(
                      color: scheme.secondaryContainer.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(24),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: loading
                            ? null
                            : () => context.read<AuthBloc>().add(
                                const AuthBiometricUnlockRequested(),
                              ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: scheme.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.fingerprint_rounded,
                                  size: 28,
                                  color: scheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s.biometricUnlock,
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      s.unlockSubtitle,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: scheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Material(
        color: scheme.surface,
        child: SafeArea(
          top: false,
          child: AdaptiveContentWidth(
            maxWidth: 480,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: BlocBuilder<AuthBloc, AuthState>(
              buildWhen: (p, c) => p.status != c.status,
              builder: (context, state) {
                final loading = state.status == AuthStatus.loading;
                return MEButton.filled(
                  size: MEButtonSize.large,
                  onPressed: loading ? null : () => _unlock(context),
                  child: loading
                      ? MELoadingIndicator(size: 24, color: scheme.onPrimary)
                      : Text(s.unlock.toUpperCase()),
                );
              },
            ),
          ),
        ),
      ),
      ),
    );
  }

  void _unlock(BuildContext context) {
    final s = context.s;
    if (_password.text.isEmpty) {
      setState(() => _error = s.fieldRequired);
      return;
    }
    setState(() => _error = null);
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
      AuthUnlockRequested(masterPassword: _password.text),
    );
  }
}
