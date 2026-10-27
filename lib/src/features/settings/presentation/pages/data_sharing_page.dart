import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/src/src.dart';

class DataSharingPage extends StatelessWidget {
  const DataSharingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        final s = context.s;
        final serverUrl = settings.serverUrl.trim();
        final showCli = TermuxCliSheet.isSupported;

        return MESliverScaffold(
          title: s.data,
          leadingAppBar: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          spacer: 4,
          slivers: [
            // Transfer & integrations
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionLabel(title: s.data),
                    ..._withPositions([
                      (pos) => ActionItem(
                        title: s.importExport,
                        subtitle: Text(
                          s.importExportSubtitle,
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        icon: SettingsIcon(
                          Icons.swap_vert_rounded,
                          backgroundColor: scheme.secondaryContainer,
                          foregroundColor: scheme.onSecondaryContainer,
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        itemPosition: pos,
                        onTap: () => const ImportExportSheet().show(context),
                      ),
                      (pos) => ActionItem(
                        title: s.localBackupRestoreTitle,
                        subtitle: Text(
                          s.localBackupRestoreSubtitle,
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        maxSubtitleLines: 2,
                        icon: SettingsIcon(
                          Icons.backup_rounded,
                          backgroundColor: scheme.primaryContainer,
                          foregroundColor: scheme.onPrimaryContainer,
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        itemPosition: pos,
                        onTap: () => const LocalBackupSheet().show(context),
                      ),

                      (pos) => ActionItem(
                        title: s.browserExtension,
                        subtitle: Text(
                          s.browserExtensionSubtitle,
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        icon: SettingsIcon(
                          Icons.extension_outlined,
                          backgroundColor: scheme.tertiaryContainer,
                          foregroundColor: scheme.onTertiaryContainer,
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        itemPosition: pos,
                        onTap: () =>
                            const BrowserExtensionSheet().show(context),
                      ),
                      if (showCli)
                        (pos) => ActionItem(
                          title: TermuxCliSheet.titleFor(s),
                          subtitle: Text(
                            TermuxCliSheet.subtitleFor(s),
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          maxSubtitleLines: 2,
                          icon: SettingsIcon(
                            Icons.terminal_rounded,
                            backgroundColor: scheme.secondaryContainer,
                            foregroundColor: scheme.onSecondaryContainer,
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          itemPosition: pos,
                          onTap: () => const TermuxCliSheet().show(context),
                        ),
                    ]),
                  ],
                ),
              ),
            ),

            // Server
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionLabel(title: s.server),
                    ActionItem(
                      title: s.server,
                      subtitle: Text(
                        serverUrl.isEmpty ? s.notConnected : serverUrl,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      maxSubtitleLines: 2,
                      icon: SettingsIcon(
                        Icons.cloud_outlined,
                        backgroundColor: scheme.primaryContainer,
                        foregroundColor: scheme.onPrimaryContainer,
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      itemPosition: ItemPosition.alone,
                      onTap: () => const ServerSheet().show(context),
                    ),
                  ],
                ),
              ),
            ),

            // Danger zone
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionLabel(
                      title: s.dangerZone,
                      accentColor: scheme.error,
                    ),
                    ActionItem(
                      title: s.resetLocalVault,
                      subtitle: Text(
                        s.resetLocalVaultSubtitle,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      maxSubtitleLines: 3,
                      icon: SettingsIcon(
                        Icons.delete_forever_rounded,
                        backgroundColor: scheme.errorContainer,
                        foregroundColor: scheme.onErrorContainer,
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      itemPosition: ItemPosition.alone,
                      onTap: () => const ResetLocalVaultSheet().show(context),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        );
      },
    );
  }
}

List<Widget> _withPositions(List<Widget Function(ItemPosition)> builders) {
  return [
    for (var i = 0; i < builders.length; i++)
      builders[i](ItemPosition.fromIndex(i, builders.length)),
  ];
}
