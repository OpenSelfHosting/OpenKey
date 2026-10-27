import 'package:flutter/material.dart';
import 'package:openkey_app/src/src.dart';

/// File picker + master password for restoring an encrypted `.okbak` backup.
class RestoreBackupFields extends StatelessWidget {
  const RestoreBackupFields({
    super.key,
    required this.passwordController,
    this.fileName,
    this.backupEmail,
    this.fileError,
    this.passwordError,
    this.enabled = true,
    this.onPickFile,
  });

  final TextEditingController passwordController;
  final String? fileName;
  final String? backupEmail;
  final String? fileError;
  final String? passwordError;
  final bool enabled;
  final VoidCallback? onPickFile;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasFile = fileName != null && fileName!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ActionItem(
          title: hasFile ? fileName! : s.setupRestoreChooseFile,
          subtitle: Text(
            backupEmail != null
                ? s.setupRestoreBackupAccount(backupEmail!)
                : s.setupRestoreChooseFileSubtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: fileError != null ? scheme.error : scheme.onSurfaceVariant,
            ),
          ),
          maxSubtitleLines: 2,
          icon: SettingsIcon(
            hasFile
                ? Icons.insert_drive_file_rounded
                : Icons.folder_open_rounded,
            backgroundColor: hasFile
                ? scheme.primaryContainer
                : scheme.secondaryContainer,
            foregroundColor: hasFile
                ? scheme.onPrimaryContainer
                : scheme.onSecondaryContainer,
          ),
          onTap: enabled ? onPickFile : null,
          itemPosition: ItemPosition.alone,
        ),
        if (fileError != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              fileError!,
              style: textTheme.bodySmall?.copyWith(color: scheme.error),
            ),
          ),
        ],
        const SizedBox(height: 16),
        MEPasswordField(
          controller: passwordController,
          label: s.masterPassword,
          errorText: passwordError,
        ),
      ],
    );
  }
}
