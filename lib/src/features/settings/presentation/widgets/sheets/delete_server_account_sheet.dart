import 'package:flutter/material.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

class DeleteServerAccountSheet extends StatefulWidget {
  const DeleteServerAccountSheet({super.key});

  Future<void> show(BuildContext context) {
    return showMEBottomSheet<void>(
      context: context,
      builder: (_) => this,
    );
  }

  @override
  State<DeleteServerAccountSheet> createState() =>
      _DeleteServerAccountSheetState();
}

class _DeleteServerAccountSheetState extends State<DeleteServerAccountSheet> {
  final _password = TextEditingController();
  String? _error;
  bool _deleting = false;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = context.s;
    return PopScope(
      canPop: !_deleting,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Text(
              s.deleteServerAccount,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              s.deleteServerAccountSubtitle,
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
                s.deleteServerAccountWarning,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onErrorContainer,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            MEPasswordField(
              controller: _password,
              label: s.masterPassword,
              errorText: _error,
            ),
            const SizedBox(height: 20),
            MEButton.filled(
              onPressed: _deleting ? null : _submit,
              child: _deleting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(s.deleteServerAccount),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final s = context.s;
    if (_password.text.isEmpty) {
      setState(() => _error = s.fieldRequired);
      return;
    }
    setState(() {
      _error = null;
      _deleting = true;
    });

    final result = await sl<AuthRepository>().deleteServerAccount(
      masterPassword: _password.text,
    );
    if (!mounted) return;
    setState(() => _deleting = false);
    result.fold(
      (f) => showMEToast(
        context,
        message: f.getMessage(context),
        kind: METoastKind.error,
      ),
      (_) {
        Navigator.of(context).pop();
        showMEToast(
          context,
          message: context.s.serverAccountDeleted,
          kind: METoastKind.success,
        );
      },
    );
  }
}
