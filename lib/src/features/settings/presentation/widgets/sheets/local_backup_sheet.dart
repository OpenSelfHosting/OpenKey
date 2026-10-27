import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';
import 'package:path_provider/path_provider.dart';

import 'export_io.dart' if (dart.library.html) 'export_io_stub.dart' as export_io;

/// Encrypted full-vault backup / restore (local file).
class LocalBackupSheet extends StatefulWidget {
  const LocalBackupSheet({super.key});

  Future<void> show(BuildContext context) {
    return showMEBottomSheet<void>(
      context: context,
      builder: (_) => this,
    );
  }

  @override
  State<LocalBackupSheet> createState() => _LocalBackupSheetState();
}

class _LocalBackupSheetState extends State<LocalBackupSheet> {
  BackupProgress? _progress;
  bool _confirmRestore = false;
  final _restorePassword = TextEditingController();
  String? _restorePasswordError;
  String? _lastPath;

  @override
  void initState() {
    super.initState();
    _lastPath = sl<VaultMetadataStore>().lastLocalBackupPath;
  }

  @override
  void dispose() {
    _restorePassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final busy = _progress?.showSpinner == true ||
        _progress?.showLinearProgress == true;

    return PopScope(
      canPop: !busy,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _progress?.title ?? s.localBackupRestoreTitle,
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (_progress != null)
                BackupProgressContent(
                  progress: _progress!,
                  showTitle: false,
                  onDismiss: () {
                    final shouldClose = _progress?.actionLabel != null &&
                        !_progress!.showSpinner &&
                        !_progress!.showLinearProgress;
                    setState(() => _progress = null);
                    if (shouldClose && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                )
              else if (_confirmRestore)
                _buildRestoreConfirmation(context)
              else ...[
                Text(
                  s.localBackupRestoreSubtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                ActionItem(
                  title: s.exportBackup,
                  subtitle: Text(
                    _lastPath == null
                        ? s.exportBackupSubtitleEmpty
                        : s.exportBackupSubtitleLatest(_lastPath!),
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  maxSubtitleLines: 2,
                  icon: SettingsIcon(
                    Icons.upload_rounded,
                    backgroundColor: scheme.primaryContainer,
                    foregroundColor: scheme.onPrimaryContainer,
                  ),
                  onTap: _exportBackup,
                  itemPosition: ItemPosition.top,
                ),
                ActionItem(
                  title: s.importBackup,
                  subtitle: Text(
                    s.importBackupSubtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  maxSubtitleLines: 2,
                  icon: SettingsIcon(
                    Icons.restore_rounded,
                    backgroundColor: scheme.secondaryContainer,
                    foregroundColor: scheme.onSecondaryContainer,
                  ),
                  onTap: () {
                    _restorePassword.clear();
                    setState(() {
                      _confirmRestore = true;
                      _restorePasswordError = null;
                    });
                  },
                  itemPosition: ItemPosition.bottom,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestoreConfirmation(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MEBanner(
          color: scheme.errorContainer,
          icon: Icon(
            Icons.warning_amber_rounded,
            color: scheme.onErrorContainer,
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.confirmRestore,
                style: textTheme.titleMedium?.copyWith(
                  color: scheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                s.confirmRestoreMessage,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onErrorContainer,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        MEPasswordField(
          controller: _restorePassword,
          label: s.masterPassword,
          errorText: _restorePasswordError,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() {
                  _confirmRestore = false;
                  _restorePasswordError = null;
                }),
                child: Text(s.cancel),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: () async {
                  if (_restorePassword.text.isEmpty) {
                    setState(() => _restorePasswordError = s.fieldRequired);
                    return;
                  }
                  final password = _restorePassword.text;
                  setState(() {
                    _confirmRestore = false;
                    _restorePasswordError = null;
                  });
                  await _importBackup(password);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.errorContainer,
                  foregroundColor: scheme.onErrorContainer,
                ),
                child: Text(s.ok),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _exportBackup() async {
    final s = context.s;
    setState(() {
      _progress = BackupProgress(
        title: s.creatingBackup,
        body: s.creatingBackupBody,
        icon: Icons.save_alt_rounded,
        showSpinner: true,
      );
    });

    try {
      final backup = sl<BackupRestoreService>();
      final bytes = await backup.createEncryptedBackupBytes();
      if (!mounted) return;

      final name = backup.suggestedBackupFileName();
      final path = await FilePicker.platform.saveFile(
        dialogTitle: s.exportBackup,
        fileName: name,
        // Android has no MIME for .okbak; FileType.any avoids the filter warning.
        type: FileType.any,
        bytes: bytes,
      );

      if (!mounted) return;

      var savedPath = path;
      if (path != null && path.isNotEmpty) {
        if (await export_io.pathNeedsWrite(path)) {
          await export_io.writeBytesToPath(path, bytes);
        } else if (!export_io.isDartIoWritablePath(path)) {
          // Mobile SAF: bytes were written by FilePicker; keep a friendly label.
          savedPath = name;
        }
      } else if (path == null) {
        final dir = await getApplicationDocumentsDirectory();
        savedPath = '${dir.path}/$name';
        await export_io.writeBytesToPath(savedPath, bytes);
      }

      if (!mounted) return;
      if (savedPath == null) {
        setState(() => _progress = null);
        return;
      }

      await sl<VaultMetadataStore>().setLastLocalBackupPath(savedPath);
      setState(() {
        _lastPath = savedPath;
        _progress = BackupProgress(
          title: s.backupComplete,
          body: s.backupCompleteLocalBody,
          icon: Icons.check_circle_rounded,
          actionLabel: s.done,
          detailTitle: name,
          detailSubtitle: s.backupCompleteLocalDetail,
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _progress = BackupProgress(
          title: s.backupError,
          body: e is BackupRestoreException ? e.message : e.toString(),
          icon: Icons.error_outline_rounded,
          actionLabel: s.done,
        );
      });
    }
  }

  Future<void> _importBackup(String masterPassword) async {
    final s = context.s;
    final picked = await FilePicker.platform.pickFiles(
      dialogTitle: s.importBackup,
      // .okbak is not a registered Android MIME; filter by magic bytes instead.
      type: FileType.any,
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return;
    if (!mounted) return;

    setState(() {
      _progress = BackupProgress(
        title: s.restoringBackupProgress,
        body: s.restoringBackupBody,
        icon: Icons.download_rounded,
        showSpinner: true,
      );
    });

    final bytes = picked.files.first.bytes;
    if (bytes == null || bytes.isEmpty) {
      setState(() {
        _progress = BackupProgress(
          title: s.backupError,
          body: s.unknownFailureMsg,
          icon: Icons.error_outline_rounded,
          actionLabel: s.done,
        );
      });
      return;
    }

    await _commitEncryptedBackup(bytes, masterPassword);
  }

  Future<void> _commitEncryptedBackup(
    List<int> bytes,
    String masterPassword,
  ) async {
    final s = context.s;

    void setStage(BackupRestoreStage stage) {
      if (!mounted) return;
      final body = switch (stage) {
        BackupRestoreStage.verifyingPassword => s.restoringBackupVerifying,
        BackupRestoreStage.decrypting => s.restoringBackupDecrypting,
        BackupRestoreStage.writingVault => s.restoringBackupWriting,
        BackupRestoreStage.unlocking => s.restoringBackupUnlocking,
      };
      setState(() {
        _progress = BackupProgress(
          title: s.restoringBackupProgress,
          body: body,
          icon: Icons.download_rounded,
          showSpinner: true,
        );
      });
    }

    setStage(BackupRestoreStage.verifyingPassword);

    final bloc = context.read<AuthBloc>();
    final done = Completer<AuthState>();
    late final StreamSubscription<AuthState> sub;
    var sawLoading = false;
    sub = bloc.stream.listen((state) {
      if (state.status == AuthStatus.loading) {
        sawLoading = true;
        return;
      }
      if (!sawLoading) return;
      if (state.status == AuthStatus.unlocked ||
          state.status == AuthStatus.failure ||
          state.status == AuthStatus.locked) {
        if (!done.isCompleted) done.complete(state);
      }
    });

    bloc.add(
      AuthRestoreFromBackupRequested(
        bytes: bytes,
        masterPassword: masterPassword,
        onProgress: setStage,
      ),
    );

    final result = await done.future;
    await sub.cancel();
    if (!mounted) return;

    final failed = result.status == AuthStatus.failure ||
        result.status == AuthStatus.locked ||
        result.error != null;
    if (failed) {
      setState(() {
        _progress = BackupProgress(
          title: s.backupError,
          body: result.error?.getMessage(context) ?? s.unknownFailureMsg,
          icon: Icons.error_outline_rounded,
          actionLabel: s.done,
        );
      });
      return;
    }

    setState(() {
      _progress = BackupProgress(
        title: s.restoreCompleted,
        body: s.restoreCompletedBody,
        icon: Icons.check_circle_rounded,
        actionLabel: s.done,
      );
    });
  }
}
