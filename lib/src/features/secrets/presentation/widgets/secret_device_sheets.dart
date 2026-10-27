import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openkey_app/src/src.dart';

/// Prompt to create or rename a secrets device group (with icon).
abstract final class SecretDeviceNameSheet {
  static Future<NamedGroup?> show(
    BuildContext context, {
    required String title,
    String? initial,
    String? initialIcon,
  }) {
    return UpsertNamedGroupSheet.show(
      context,
      title: title,
      nameLabel: context.s.deviceName,
      defaultIcon: NamedGroup.deviceDefaultIcon,
      initialName: initial ?? '',
      initialIcon: initialIcon,
    );
  }
}

/// Pick a device (or Other) to move a secret into.
abstract final class MoveSecretDeviceSheet {
  static Future<String?> show(
    BuildContext context, {
    required String currentDevice,
  }) {
    return showMEBottomSheet<String>(
      context: context,
      builder: (context) {
        final s = context.s;
        final scheme = Theme.of(context).colorScheme;
        final devices = context.read<SecretsBloc>().state.devices;
        final items = <(String, String, String)>[
          ('', s.otherDevice, NamedGroup.deviceDefaultIcon),
          ...devices.map((d) => (d.name, d.name, d.iconKey)),
        ];

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(s.moveToDevice, style: Theme.of(context).textTheme.titleLarge),
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
                  trailing: currentDevice.trim() == items[i].$1
                      ? Icon(Icons.check_rounded, color: scheme.primary)
                      : null,
                  itemPosition: ItemPosition.fromIndex(i, items.length),
                  onTap: () => Navigator.pop(context, items[i].$1),
                ),
              const SizedBox(height: 8),
              MEButton.outlined(
                onPressed: () async {
                  final group = await SecretDeviceNameSheet.show(
                    context,
                    title: s.newDevice,
                  );
                  if (group == null || !context.mounted) return;
                  context.read<SecretsBloc>().add(
                        SecretDeviceCreated(group.name, icon: group.icon),
                      );
                  Navigator.pop(context, group.name);
                },
                child: Text(s.addDevice),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Rename / delete actions for a device group.
abstract final class SecretDeviceActionsSheet {
  static Future<void> show(BuildContext context, {required String device}) {
    return showMEBottomSheet<void>(
      context: context,
      builder: (context) {
        final s = context.s;
        final scheme = Theme.of(context).colorScheme;
        final icon = context.read<SecretsBloc>().state.iconForGroup(device);
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(device, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ActionItem(
                title: s.renameDevice,
                icon: SettingsIcon(
                  Icons.edit_rounded,
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                ),
                itemPosition: ItemPosition.start,
                onTap: () async {
                  Navigator.pop(context);
                  final next = await SecretDeviceNameSheet.show(
                    context,
                    title: s.renameDevice,
                    initial: device,
                    initialIcon: icon,
                  );
                  if (next == null || !context.mounted) return;
                  context.read<SecretsBloc>().add(
                        SecretDeviceRenamed(
                          from: device,
                          to: next.name,
                          icon: next.icon,
                        ),
                      );
                },
              ),
              ActionItem(
                title: s.deleteDevice,
                icon: SettingsIcon(
                  Icons.delete_outline_rounded,
                  backgroundColor: scheme.errorContainer,
                  foregroundColor: scheme.onErrorContainer,
                ),
                itemPosition: ItemPosition.end,
                onTap: () async {
                  Navigator.pop(context);
                  final count = context
                      .read<SecretsBloc>()
                      .state
                      .secrets
                      .where(
                        (sec) =>
                            sec.device.trim().toLowerCase() ==
                            device.toLowerCase(),
                      )
                      .length;
                  final confirmed = await showMEDialog<bool>(
                    context: context,
                    builder: (context) => MEDialog(
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      title: Text(s.deleteDevice),
                      content: Text(s.deleteDeviceConfirm),
                      actions: [
                        MEButton.text(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(s.cancel),
                        ),
                        MEButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            count > 0 ? s.deleteDeviceAndClear : s.delete,
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true || !context.mounted) return;
                  context.read<SecretsBloc>().add(
                        SecretDeviceDeleted(
                          device,
                          clearSecrets: count > 0,
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
