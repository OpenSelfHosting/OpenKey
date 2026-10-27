import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        final s = context.s;
        final auth = context.watch<AuthBloc>().state;
        final email = auth.email ?? sl<AuthRepository>().email;

        return MESliverScaffold(
          title: s.settings,
          extendedAppBar: false,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          spacer: 4,
          slivers: [
            // ── Account ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionLabel(title: s.account),
                    ..._withPositions([
                      (pos) => ActionItem(
                        title: email ?? s.localVault,
                        subtitle: Text(
                          s.aboutPrivacy,
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        icon: AccountAvatar(
                          key: ValueKey(auth.avatarGeneration),
                          account: VaultAccount(
                            id: auth.activeAccountId ?? '',
                            email: email ?? '',
                            avatarPath: auth.avatarPath,
                          ),
                          size: 48,
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        itemPosition: pos,
                        onTap: () => context.push(AppRoutes.account.path),
                      ),
                    ]),
                  ],
                ),
              ),
            ),

            // ── Preferences ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionLabel(title: s.tools),
                    ..._withPositions([
                      (pos) => ActionItem(
                        title: s.appearance,
                        subtitle: Text(
                          '${settings.themeMode.label(s)} · ${settings.locale.nativeName}',
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        maxSubtitleLines: 2,
                        icon: SettingsIcon(
                          Icons.palette_outlined,
                          backgroundColor: scheme.primaryContainer,
                          foregroundColor: scheme.onPrimaryContainer,
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        itemPosition: pos,
                        onTap: () => context.push(AppRoutes.appearance.path),
                      ),
                      (pos) => ActionItem(
                        title: s.security,
                        subtitle: Text(
                          s.securitySubtitle,
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        maxSubtitleLines: 2,
                        icon: SettingsIcon(
                          Icons.shield_outlined,
                          backgroundColor: scheme.secondaryContainer,
                          foregroundColor: scheme.onSecondaryContainer,
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        itemPosition: pos,
                        onTap: () => context.push(AppRoutes.security.path),
                      ),
                      (pos) => ActionItem(
                        title: s.generatorTitle,
                        subtitle: Text(
                          s.generatorSubtitle,
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        maxSubtitleLines: 2,
                        icon: SettingsIcon(
                          Icons.password_rounded,
                          backgroundColor: scheme.tertiaryContainer,
                          foregroundColor: scheme.onTertiaryContainer,
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        itemPosition: pos,
                        onTap: () =>
                            context.push(AppRoutes.passwordGenerator.path),
                      ),
                      (pos) => ActionItem(
                        title: s.data,
                        subtitle: Text(
                          s.dataSubtitle,
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
                        itemPosition: pos,
                        onTap: () => context.push(AppRoutes.dataSharing.path),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionLabel(title: s.help),
                    ..._withPositions([
                      (pos) => ActionItem(
                        title: s.contact,
                        subtitle: Text(
                          s.contactSubtitle,
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        icon: SettingsIcon(
                          Icons.support_agent_rounded,
                          backgroundColor: scheme.tertiaryContainer,
                          foregroundColor: scheme.onTertiaryContainer,
                        ),
                        itemPosition: pos,
                        onTap: () => const ContactSheet().show(context),
                      ),
                      (pos) => ActionItem(
                        title: s.faq,
                        subtitle: Text(
                          s.faqSubtitle,
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        icon: SettingsIcon(
                          Icons.help_outline_rounded,
                          backgroundColor: scheme.secondaryContainer,
                          foregroundColor: scheme.onSecondaryContainer,
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        itemPosition: pos,
                        onTap: () => context.push(AppRoutes.faq.path),
                      ),
                      (pos) => ActionItem(
                        title: s.aboutApp,
                        subtitle: Text(
                          s.aboutAppSubtitle,
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        icon: SettingsIcon(
                          Icons.info_outline_rounded,
                          backgroundColor: scheme.surfaceContainerHighest,
                          foregroundColor: scheme.onSurfaceVariant,
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        itemPosition: pos,
                        onTap: () => context.push(AppRoutes.aboutApp.path),
                      ),
                    ]),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 16, 8, 32),
                      child: Text(
                        s.aboutPrivacy,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
