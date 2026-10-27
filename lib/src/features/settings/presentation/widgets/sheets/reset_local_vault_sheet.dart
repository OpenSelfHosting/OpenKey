import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openkey_app/src/src.dart';

class ResetLocalVaultSheet extends StatefulWidget {
  const ResetLocalVaultSheet({super.key});

  Future<void> show(BuildContext context) {
    return showMEBottomSheet<void>(
      context: context,
      builder: (_) => this,
    );
  }

  @override
  State<ResetLocalVaultSheet> createState() => _ResetLocalVaultSheetState();
}

class _ResetLocalVaultSheetState extends State<ResetLocalVaultSheet> {
  bool _resetting = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = context.s;
    return PopScope(
      canPop: !_resetting,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s.resetLocalVaultTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              s.resetLocalVaultSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            MEBanner(
              color: scheme.errorContainer,
              icon: Icon(
                Icons.warning_amber_rounded,
                color: scheme.onErrorContainer,
              ),
              content: Text(
                s.resetLocalVaultConfirm,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onErrorContainer,
                    ),
              ),
            ),
            const SizedBox(height: 20),
            MEButton.filled(
              onPressed: _resetting ? null : _submit,
              child: _resetting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(s.resetLocalVault),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _resetting = true);
    final bloc = context.read<AuthBloc>();
    bloc.add(const AuthResetLocalVaultRequested());
    final next = await bloc.stream.firstWhere(
      (state) => state.status != AuthStatus.loading,
    );
    if (!mounted) return;
    if (next.status == AuthStatus.failure) {
      setState(() => _resetting = false);
      showMEToast(
        context,
        message: next.error?.getMessage(context) ?? context.s.resetLocalVault,
        kind: METoastKind.error,
      );
      return;
    }
    Navigator.of(context).pop();
  }
}
