import 'package:flutter/material.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

class ChangeMasterPasswordSheet extends StatefulWidget {
  const ChangeMasterPasswordSheet({super.key});

  Future<void> show(BuildContext context) {
    return showMEBottomSheet<void>(
      context: context,
      builder: (_) => this,
    );
  }

  @override
  State<ChangeMasterPasswordSheet> createState() =>
      _ChangeMasterPasswordSheetState();
}

class _ChangeMasterPasswordSheetState extends State<ChangeMasterPasswordSheet> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();

  String? _currentError;
  String? _nextError;
  String? _confirmError;
  bool _saving = false;

  static const _minLength = 12;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  static double _strengthOf(String password) {
    if (password.isEmpty) return 0;
    var score = (password.length / 12).clamp(0.0, 0.5);
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 0.125;
    if (RegExp(r'[a-z]').hasMatch(password)) score += 0.125;
    if (RegExp(r'\d').hasMatch(password)) score += 0.125;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score += 0.125;
    return score.clamp(0.0, 1.0);
  }

  bool _validate() {
    final s = context.s;
    final next = _next.text;
    final strength = _strengthOf(next);
    setState(() {
      _currentError =
          _current.text.isEmpty ? s.fieldRequired : null;
      if (next.length < _minLength) {
        _nextError = s.passwordTooShortStrong;
      } else if (strength < 0.5) {
        _nextError = s.passwordTooWeak;
      } else if (next == _current.text) {
        _nextError = s.masterPasswordUnchanged;
      } else {
        _nextError = null;
      }
      _confirmError =
          _confirm.text == next ? null : s.passwordsDoNotMatch;
    });
    return _currentError == null &&
        _nextError == null &&
        _confirmError == null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = context.s;
    return PopScope(
      canPop: !_saving,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                s.changeMasterPassword,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                s.changeMasterPasswordSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              MEPasswordField(
                controller: _current,
                label: s.currentMasterPassword,
                errorText: _currentError,
              ),
              const SizedBox(height: 12),
              MEPasswordField(
                controller: _next,
                label: s.newMasterPassword,
                showStrengthMeter: true,
                errorText: _nextError,
                helperText: s.masterPasswordHelper,
              ),
              const SizedBox(height: 12),
              MEPasswordField(
                controller: _confirm,
                label: s.confirmMasterPassword,
                errorText: _confirmError,
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
                    : Text(s.changeMasterPassword),
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
    final result = await sl<AuthRepository>().changeMasterPassword(
      currentPassword: _current.text,
      newPassword: _next.text,
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
        Navigator.of(context).pop();
        showMEToast(
          context,
          message: context.s.masterPasswordChanged,
          kind: METoastKind.success,
        );
      },
    );
  }
}
