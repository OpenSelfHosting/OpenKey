import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

class ChangeEmailSheet extends StatefulWidget {
  const ChangeEmailSheet({super.key});

  Future<void> show(BuildContext context) {
    return showMEBottomSheet<void>(
      context: context,
      builder: (_) => this,
    );
  }

  @override
  State<ChangeEmailSheet> createState() => _ChangeEmailSheetState();
}

class _ChangeEmailSheetState extends State<ChangeEmailSheet> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  String? _emailError;
  String? _passwordError;
  bool _saving = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool _validate() {
    final s = context.s;
    setState(() {
      _emailError = _email.text.contains('@') ? null : s.invalidEmail;
      _passwordError = _password.text.isEmpty ? s.fieldRequired : null;
    });
    return _emailError == null && _passwordError == null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = context.s;
    return PopScope(
      canPop: !_saving,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(s.changeEmail, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                s.changeEmailSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              METextField(
                controller: _email,
                label: s.newEmail,
                keyboardType: TextInputType.emailAddress,
                errorText: _emailError,
              ),
              const SizedBox(height: 12),
              MEPasswordField(
                controller: _password,
                label: s.currentMasterPassword,
                errorText: _passwordError,
              ),
              const SizedBox(height: 20),
              MEButton.filled(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(s.changeEmail),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() => _saving = true);
    final result = await sl<AuthRepository>().changeEmail(
      currentPassword: _password.text,
      newEmail: _email.text,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    result.fold(
      (f) => showMEToast(
        context,
        message: f.getMessage(context),
        kind: METoastKind.error,
      ),
      (_) {
        context.read<AuthBloc>().add(const AuthAccountsChanged());
        Navigator.of(context).pop();
        showMEToast(
          context,
          message: context.s.emailChanged,
          kind: METoastKind.success,
        );
      },
    );
  }
}
