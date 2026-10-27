import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openkey_app/src/src.dart';

class SetupRestorePage extends StatefulWidget {
  const SetupRestorePage({super.key});

  @override
  State<SetupRestorePage> createState() => _SetupRestorePageState();
}

class _SetupRestorePageState extends State<SetupRestorePage> {
  final _password = TextEditingController();

  bool _submitting = false;
  String? _passwordError;
  String? _restoreFileError;
  PickedBackupFile? _restoreFile;
  BackupRestoreStage? _restoreStage;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  bool _validate() {
    final s = context.s;
    setState(() {
      _restoreFileError = _restoreFile == null ? s.setupRestoreNeedFile : null;
      _passwordError = _password.text.isEmpty ? s.fieldRequired : null;
    });
    return _restoreFileError == null && _passwordError == null;
  }

  Future<void> _pickFile() async {
    final picked = await RestoreBackupFlow.pickFile(context);
    if (!mounted || picked == null) return;
    setState(() {
      _restoreFile = picked;
      _restoreFileError = null;
    });
  }

  Future<void> _submit(bool loading) async {
    if (loading) return;
    if (!_validate()) return;
    final file = _restoreFile;
    if (file == null) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _restoreStage = BackupRestoreStage.verifyingPassword;
    });
    context.read<AuthBloc>().add(
      AuthRestoreFromBackupRequested(
        bytes: file.bytes,
        masterPassword: _password.text,
        onProgress: (stage) {
          if (!mounted) return;
          setState(() => _restoreStage = stage);
        },
      ),
    );
  }

  String _busyMessage(AppLocalizations s) {
    return switch (_restoreStage) {
      BackupRestoreStage.verifyingPassword => s.restoringBackupVerifying,
      BackupRestoreStage.decrypting => s.restoringBackupDecrypting,
      BackupRestoreStage.writingVault => s.restoringBackupWriting,
      BackupRestoreStage.unlocking => s.restoringBackupUnlocking,
      null => s.restoringBackupProgress,
    };
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
      busyMessage: _busyMessage(s),
      bottomBar: MEButton.filled(
        size: MEButtonSize.large,
        onPressed: loading ? null : () => _submit(loading),
        child: Text(loading ? s.restoringBackupProgress : s.setupRestoreAction),
      ),
      body: ListView(
        physics: loading
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottomInset),
        children: [
          Text(
            s.setupChooseRestoreTitle,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.setupRestoreSubtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          const SetupZeroKnowledgeBanner(),
          const SizedBox(height: 24),
          RestoreBackupFields(
            passwordController: _password,
            fileName: _restoreFile?.name,
            backupEmail: _restoreFile?.email,
            fileError: _restoreFileError,
            passwordError: _passwordError,
            enabled: !loading,
            onPickFile: _pickFile,
          ),
          if (auth.status == AuthStatus.failure && auth.error != null)
            SetupAuthErrorBanner(message: auth.error!.getMessage(context)),
        ],
      ),
    );
  }
}
