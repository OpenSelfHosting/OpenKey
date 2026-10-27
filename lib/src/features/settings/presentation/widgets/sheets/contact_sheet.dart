import 'package:flutter/material.dart';
import 'package:openkey_app/src/src.dart';

class ContactSheet extends StatelessWidget {
  const ContactSheet({super.key});

  Future<void> show(BuildContext context) {
    return showMEBottomSheet<void>(
      context: context,
      builder: (_) => this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(s.contact, style: textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            s.contactSubtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ActionItem(
            title: s.telegram,
            subtitle: Text(
              AppContact.telegram,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            icon: SettingsIcon(
              Icons.telegram,
              backgroundColor: scheme.primaryContainer,
              foregroundColor: scheme.onPrimaryContainer,
            ),
            onTap: () {
              AppContact.openTelegram();
              Navigator.of(context).pop();
            },
            itemPosition: ItemPosition.top,
          ),
          ActionItem(
            title: s.email,
            subtitle: Text(
              AppContact.email,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            icon: SettingsIcon(
              Icons.email_outlined,
              backgroundColor: scheme.tertiaryContainer,
              foregroundColor: scheme.onTertiaryContainer,
            ),
            onTap: () async {
              final launched = await AppContact.openEmail();
              if (!context.mounted) return;
              Navigator.of(context).pop();
              if (!launched) {
                showMEToast(
                  context,
                  message: context.s.unknownFailureMsg,
                  kind: METoastKind.error,
                );
              }
            },
            itemPosition: ItemPosition.bottom,
          ),
        ],
      ),
    );
  }
}
