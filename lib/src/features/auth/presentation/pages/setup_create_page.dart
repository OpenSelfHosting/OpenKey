import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

class SetupCreatePage extends StatefulWidget {
  const SetupCreatePage({super.key});

  @override
  State<SetupCreatePage> createState() => _SetupCreatePageState();
}

class _SetupCreatePageState extends State<SetupCreatePage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _hint = TextEditingController();
  final _serverUrl = TextEditingController();

  bool _linkSelfHosted = false;
  bool _submitting = false;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;
  String? _serverUrlError;

  @override
  void initState() {
    super.initState();
    final saved = sl<VaultMetadataStore>().serverUrl;
    if (saved != null && saved.isNotEmpty) {
      _serverUrl.text = saved;
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _hint.dispose();
    _serverUrl.dispose();
    super.dispose();
  }

  bool _validate() {
    final s = context.s;
    final password = _password.text;
    final strength = setupPasswordStrength(password);
    final url = _serverUrl.text.trim();

    setState(() {
      _emailError = _email.text.contains('@') ? null : s.invalidEmail;
      if (password.length < kSetupMinPasswordLength) {
        _passwordError = s.passwordTooShortStrong;
      } else if (strength < 0.5) {
        _passwordError = s.passwordTooWeak;
      } else {
        _passwordError = null;
      }
      _confirmError = _confirm.text == password ? null : s.passwordsDoNotMatch;
      if (_linkSelfHosted) {
        _serverUrlError = looksLikeUrl(url) ? null : s.invalidServerUrl;
      } else {
        _serverUrlError = null;
      }
    });

    return _emailError == null &&
        _passwordError == null &&
        _confirmError == null &&
        _serverUrlError == null;
  }

  Future<void> _submit(bool loading) async {
    if (loading) return;
    if (!_validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    final url = _linkSelfHosted ? _serverUrl.text.trim() : null;
    if (url != null) {
      await context.read<SettingsCubit>().setServerUrl(url);
    }
    if (!mounted) return;
    context.read<AuthBloc>().add(
      AuthSetupRequested(
        email: _email.text,
        masterPassword: _password.text,
        passwordHint: _hint.text.trim().isEmpty ? null : _hint.text.trim(),
        serverUrl: url,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final auth = context.watch<AuthBloc>().state;
    final loading = _submitting || auth.status == AuthStatus.loading;
    if (_submitting && auth.status != AuthStatus.loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _submitting) setState(() => _submitting = false);
      });
    }

    return SetupFlowScaffold(
      loading: loading,
      busyMessage: s.creatingVault,
      bottomBar: MEButton.filled(
        size: MEButtonSize.large,
        onPressed: loading ? null : () => _submit(loading),
        child: Text(loading ? s.creatingVault : s.createVault),
      ),
      body: ListView(
        physics: loading
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottomInset),
        children: [
          Text(
            s.setupChooseCreateTitle,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.setupSubtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          const SetupZeroKnowledgeBanner(),
          const SizedBox(height: 24),
          METextField(
            controller: _email,
            label: s.email,
            keyboardType: TextInputType.emailAddress,
            errorText: _emailError,
            enabled: !loading,
          ),
          const SizedBox(height: 16),
          MEPasswordField(
            controller: _password,
            label: s.masterPassword,
            showStrengthMeter: true,
            errorText: _passwordError,
            helperText: s.masterPasswordHelper,
          ),
          const SizedBox(height: 16),
          MEPasswordField(
            controller: _confirm,
            label: s.confirmMasterPassword,
            errorText: _confirmError,
          ),
          const SizedBox(height: 16),
          METextField(
            controller: _hint,
            label: s.passwordHintOptional,
            helperText: s.passwordHintHelper,
            enabled: !loading,
          ),
          const SizedBox(height: 20),
          SetupSelfHostedToggle(
            value: _linkSelfHosted,
            enabled: !loading,
            onChanged: (v) => setState(() => _linkSelfHosted = v),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            child: _linkSelfHosted
                ? Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: METextField(
                      controller: _serverUrl,
                      label: s.serverUrl,
                      hintText: s.serverUrlHint,
                      keyboardType: TextInputType.url,
                      errorText: _serverUrlError,
                      helperText: s.setupLinkServerHelper,
                      enabled: !loading,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          if (auth.status == AuthStatus.failure && auth.error != null)
            SetupAuthErrorBanner(message: auth.error!.getMessage(context)),
        ],
      ),
    );
  }
}
