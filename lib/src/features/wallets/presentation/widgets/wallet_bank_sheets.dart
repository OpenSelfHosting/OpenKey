import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openkey_app/src/src.dart';

/// Prompt to create or rename a cards bank group (with icon).
abstract final class WalletBankNameSheet {
  static Future<NamedGroup?> show(
    BuildContext context, {
    required String title,
    String? initial,
    String? initialIcon,
  }) {
    return UpsertNamedGroupSheet.show(
      context,
      title: title,
      nameLabel: context.s.bankName,
      defaultIcon: NamedGroup.bankDefaultIcon,
      initialName: initial ?? '',
      initialIcon: initialIcon,
    );
  }
}

/// Pick a bank (or Other) to move a card into.
abstract final class MoveWalletBankSheet {
  static Future<String?> show(
    BuildContext context, {
    required String currentBank,
  }) {
    return showMEBottomSheet<String>(
      context: context,
      builder: (context) {
        final s = context.s;
        final scheme = Theme.of(context).colorScheme;
        final banks = context.read<WalletBloc>().state.banks;
        final items = <(String, String, String)>[
          ('', s.otherBank, NamedGroup.defaultIcon),
          ...banks.map((b) => (b.name, b.name, b.iconKey)),
        ];

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(s.moveToBank, style: Theme.of(context).textTheme.titleLarge),
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
                  trailing: currentBank.trim() == items[i].$1
                      ? Icon(Icons.check_rounded, color: scheme.primary)
                      : null,
                  itemPosition: ItemPosition.fromIndex(i, items.length),
                  onTap: () => Navigator.pop(context, items[i].$1),
                ),
              const SizedBox(height: 8),
              MEButton.outlined(
                onPressed: () async {
                  final group = await WalletBankNameSheet.show(
                    context,
                    title: s.newBank,
                  );
                  if (group == null || !context.mounted) return;
                  context.read<WalletBloc>().add(
                        WalletBankCreated(group.name, icon: group.icon),
                      );
                  Navigator.pop(context, group.name);
                },
                child: Text(s.addBank),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Rename / delete / icon actions for a bank group.
abstract final class WalletBankActionsSheet {
  static Future<void> show(BuildContext context, {required String bank}) {
    return showMEBottomSheet<void>(
      context: context,
      builder: (context) {
        final s = context.s;
        final scheme = Theme.of(context).colorScheme;
        final icon = context.read<WalletBloc>().state.iconForGroup(bank);
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(bank, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ActionItem(
                title: s.renameBank,
                icon: SettingsIcon(
                  Icons.edit_rounded,
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                ),
                itemPosition: ItemPosition.start,
                onTap: () async {
                  Navigator.pop(context);
                  final next = await WalletBankNameSheet.show(
                    context,
                    title: s.renameBank,
                    initial: bank,
                    initialIcon: icon,
                  );
                  if (next == null || !context.mounted) return;
                  context.read<WalletBloc>().add(
                        WalletBankRenamed(
                          from: bank,
                          to: next.name,
                          icon: next.icon,
                        ),
                      );
                },
              ),
              ActionItem(
                title: s.deleteBank,
                icon: SettingsIcon(
                  Icons.delete_outline_rounded,
                  backgroundColor: scheme.errorContainer,
                  foregroundColor: scheme.onErrorContainer,
                ),
                itemPosition: ItemPosition.end,
                onTap: () async {
                  Navigator.pop(context);
                  final count = context
                      .read<WalletBloc>()
                      .state
                      .cards
                      .where(
                        (c) =>
                            c.bank.trim().toLowerCase() == bank.toLowerCase(),
                      )
                      .length;
                  final confirmed = await showMEDialog<bool>(
                    context: context,
                    builder: (context) => MEDialog(
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      title: Text(s.deleteBank),
                      content: Text(s.deleteBankConfirm),
                      actions: [
                        MEButton.text(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(s.cancel),
                        ),
                        MEButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            count > 0 ? s.deleteBankAndClear : s.delete,
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true || !context.mounted) return;
                  context.read<WalletBloc>().add(
                        WalletBankDeleted(
                          bank,
                          clearCards: count > 0,
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
