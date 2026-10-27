import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openkey_app/src/src.dart';

/// Prompt to create or rename a crypto folder group (with icon).
abstract final class CryptoFolderNameSheet {
  static Future<NamedGroup?> show(
    BuildContext context, {
    required String title,
    String? initial,
    String? initialIcon,
  }) {
    return UpsertNamedGroupSheet.show(
      context,
      title: title,
      nameLabel: context.s.folderName,
      defaultIcon: NamedGroup.defaultIcon,
      initialName: initial ?? '',
      initialIcon: initialIcon,
    );
  }
}

/// Pick a folder (or Other) to move a crypto wallet into.
abstract final class MoveCryptoFolderSheet {
  static Future<String?> show(
    BuildContext context, {
    required String currentFolder,
  }) {
    return showMEBottomSheet<String>(
      context: context,
      builder: (context) {
        final s = context.s;
        final scheme = Theme.of(context).colorScheme;
        final folders = context.read<CryptoBloc>().state.folders;
        final items = <(String, String, String)>[
          ('', s.otherFolder, NamedGroup.defaultIcon),
          ...folders.map((f) => (f.name, f.name, f.iconKey)),
        ];

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                s.moveToFolder,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < items.length; i++)
                ActionItem(
                  title: items[i].$2,
                  icon: VaultIconSurface(
                    iconKey: items[i].$3,
                    size: 40,
                    backgroundColor: scheme.primaryContainer,
                    child: CollectionIcon(
                      iconKey: items[i].$3,
                      size: VaultIconSurface.needsBackdrop(items[i].$3)
                          ? 22
                          : 28,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                  trailing: currentFolder.trim() == items[i].$1
                      ? Icon(Icons.check_rounded, color: scheme.primary)
                      : null,
                  itemPosition: ItemPosition.fromIndex(i, items.length),
                  onTap: () => Navigator.pop(context, items[i].$1),
                ),
              const SizedBox(height: 8),
              MEButton.outlined(
                onPressed: () async {
                  final group = await CryptoFolderNameSheet.show(
                    context,
                    title: s.newFolder,
                  );
                  if (group == null || !context.mounted) return;
                  context.read<CryptoBloc>().add(
                        CryptoFolderCreated(group.name, icon: group.icon),
                      );
                  Navigator.pop(context, group.name);
                },
                child: Text(s.addFolder),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Rename / delete actions for a crypto folder group.
abstract final class CryptoFolderActionsSheet {
  static Future<void> show(BuildContext context, {required String folder}) {
    return showMEBottomSheet<void>(
      context: context,
      builder: (context) {
        final s = context.s;
        final scheme = Theme.of(context).colorScheme;
        final icon = context.read<CryptoBloc>().state.iconForGroup(folder);
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(folder, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ActionItem(
                title: s.renameFolder,
                icon: SettingsIcon(
                  Icons.edit_rounded,
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                ),
                itemPosition: ItemPosition.start,
                onTap: () async {
                  Navigator.pop(context);
                  final next = await CryptoFolderNameSheet.show(
                    context,
                    title: s.renameFolder,
                    initial: folder,
                    initialIcon: icon,
                  );
                  if (next == null || !context.mounted) return;
                  context.read<CryptoBloc>().add(
                        CryptoFolderRenamed(
                          from: folder,
                          to: next.name,
                          icon: next.icon,
                        ),
                      );
                },
              ),
              ActionItem(
                title: s.deleteFolder,
                icon: SettingsIcon(
                  Icons.delete_outline_rounded,
                  backgroundColor: scheme.errorContainer,
                  foregroundColor: scheme.onErrorContainer,
                ),
                itemPosition: ItemPosition.end,
                onTap: () async {
                  Navigator.pop(context);
                  final count = context
                      .read<CryptoBloc>()
                      .state
                      .wallets
                      .where(
                        (w) =>
                            w.folder.trim().toLowerCase() ==
                            folder.toLowerCase(),
                      )
                      .length;
                  final confirmed = await showMEDialog<bool>(
                    context: context,
                    builder: (context) => MEDialog(
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      title: Text(s.deleteFolder),
                      content: Text(s.deleteFolderConfirm),
                      actions: [
                        MEButton.text(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(s.cancel),
                        ),
                        MEButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            count > 0 ? s.deleteFolderAndClear : s.delete,
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true || !context.mounted) return;
                  context.read<CryptoBloc>().add(
                        CryptoFolderDeleted(
                          folder,
                          clearWallets: count > 0,
                        ),
                      );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
