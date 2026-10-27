import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

class SetupSignInPage extends StatefulWidget {
  const SetupSignInPage({super.key});

  @override
  State<SetupSignInPage> createState() => _SetupSignInPageState();
}

class _SetupSignInPageState extends State<SetupSignInPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _serverUrl = TextEditingController();

  bool _submitting = false;
  String? _emailError;
  String? _passwordError;
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
    _serverUrl.dispose();
    super.dispose();
  }

  bool _validate() {
    final s = context.s;
    final url = _serverUrl.text.trim();
    setState(() {
      _emailError = _email.text.contains('@') ? null : s.invalidEmail;
      _passwordError = _password.text.isEmpty ? s.passwordTooShortStrong : null;
      _serverUrlError = looksLikeUrl(url) ? null : s.invalidServerUrl;
    });
    return _emailError == null &&
        _passwordError == null &&
        _serverUrlError == null;
  }

  Future<void> _submit(bool loading) async {
    if (loading) return;
    if (!_validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    final url = _serverUrl.text.trim();
    await context.read<SettingsCubit>().setServerUrl(url);
    if (!mounted) return;
    context.read<AuthBloc>().add(
      AuthRestoreFromServerRequested(
        serverUrl: url,
        email: _email.text,
        masterPassword: _password.text,
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
      busyMessage: s.setupSigningIn,
      bottomBar: MEButton.filled(
        size: MEButtonSize.large,
        onPressed: loading ? null : () => _submit(loading),
        child: Text(loading ? s.setupSigningIn : s.setupSignInAction),
      ),
      body: ListView(
        physics: loading
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottomInset),
        children: [
          Text(
            s.setupChooseSignInTitle,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.setupSignInSubtitle,
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
            errorText: _passwordError,
          ),
          const SizedBox(height: 16),
          METextField(
            controller: _serverUrl,
            label: s.serverUrl,
            hintText: s.serverUrlHint,
            keyboardType: TextInputType.url,
            errorText: _serverUrlError,
            helperText: s.setupSignInServerHelper,
            enabled: !loading,
          ),
          if (auth.status == AuthStatus.failure && auth.error != null)
            SetupAuthErrorBanner(message: auth.error!.getMessage(context)),
        ],
      ),
    );
  }
}
