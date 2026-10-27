import 'package:flutter/material.dart';
import 'package:openkey_app/src/src.dart';

class BackupProgress {
  const BackupProgress({
    required this.title,
    required this.icon,
    this.body,
    this.actionLabel,
    this.detailTitle,
    this.detailSubtitle,
    this.showSpinner = false,
    this.showLinearProgress = false,
    this.linearProgressValue,
  });

  final String title;
  final IconData icon;
  final String? body;
  final String? actionLabel;
  final String? detailTitle;
  final String? detailSubtitle;
  final bool showSpinner;
  final bool showLinearProgress;
  final double? linearProgressValue;
}

class BackupProgressContent extends StatelessWidget {
  const BackupProgressContent({
    super.key,
    required this.progress,
    this.onDismiss,
    this.showTitle = true,
  });

  final BackupProgress progress;
  final VoidCallback? onDismiss;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (progress.showSpinner)
          const MELoadingIndicator(size: 72)
        else
          SettingsIcon(
            progress.icon,
            size: 56,
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.onPrimaryContainer,
          ),
        if (showTitle) ...[
          const SizedBox(height: 20),
          Text(
            progress.title,
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
        if (progress.body != null) ...[
          const SizedBox(height: 8),
          Text(
            progress.body!,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
        if (progress.showLinearProgress) ...[
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.linearProgressValue,
              minHeight: 8,
            ),
          ),
        ],
        if (progress.detailTitle != null) ...[
          const SizedBox(height: 16),
          ActionItem(
            title: progress.detailTitle!,
            subtitle: Text(
              progress.detailSubtitle ?? '',
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            maxSubtitleLines: 2,
            icon: SettingsIcon(
              Icons.attach_file_rounded,
              backgroundColor: scheme.surfaceContainerHighest,
              foregroundColor: scheme.onSurfaceVariant,
            ),
            itemPosition: ItemPosition.alone,
          ),
        ],
        if (progress.actionLabel != null) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onDismiss,
              child: Text(progress.actionLabel!),
            ),
          ),
        ],
      ],
    );
  }
}
