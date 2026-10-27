import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/src/src.dart';

class ThemeModePage extends StatelessWidget {
  const ThemeModePage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final cubit = context.read<SettingsCubit>();
    final scheme = Theme.of(context).colorScheme;

    return MESliverScaffold(
      title: s.themeMode,
      leadingAppBar: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      slivers: [
        SliverToBoxAdapter(
          child: BlocBuilder<SettingsCubit, SettingsState>(
            buildWhen: (p, c) => p.themeMode != c.themeMode,
            builder: (context, state) {
              final modes = ThemeMode.values;
              return Column(
                children: [
                  for (var i = 0; i < modes.length; i++)
                    ActionItem(
                      title: modes[i].label(s),
                      padding: modes[i] == ThemeMode.system
                          ? 0
                          : 22,
                      subtitle: modes[i] == ThemeMode.system
                          ? Text(s.followDevice)
                          : null,
                      selected: state.themeMode == modes[i],
                      icon: SettingsIcon(
                        modes[i].icon,
                        backgroundColor: state.themeMode == modes[i]
                            ? scheme.primaryContainer
                            : scheme.surfaceContainerHighest,
                        foregroundColor: state.themeMode == modes[i]
                            ? scheme.onPrimaryContainer
                            : scheme.onSurfaceVariant,
                      ),
                      trailing: state.themeMode == modes[i]
                          ? Icon(Icons.check_rounded, color: scheme.primary)
                          : null,
                      itemPosition: ItemPosition.fromIndex(i, modes.length),
                      onTap: () => cubit.setThemeMode(modes[i]),
                    ),
                ],
              );
            },
          ),
        ),
        SliverToBoxAdapter(
          child: BlocBuilder<SettingsCubit, SettingsState>(
            buildWhen: (p, c) => p.useHighContrast != c.useHighContrast,
            builder: (context, state) {
              return ActionItem(
                title: s.highContrast,
                padding: 14,
                subtitle: Text(s.highContrastSubtitle),
                maxSubtitleLines: 2,
                icon: SettingsIcon(
                  Icons.contrast_rounded,
                  backgroundColor: scheme.secondaryContainer,
                  foregroundColor: scheme.onSecondaryContainer,
                ),
                trailing: Switch(
                  value: state.useHighContrast,
                  onChanged: cubit.setUseHighContrast,
                ),
                itemPosition: ItemPosition.alone,
                onTap: () =>
                    cubit.setUseHighContrast(!state.useHighContrast),
              );
            },
          ),
        ),
      ],
    );
  }
}
