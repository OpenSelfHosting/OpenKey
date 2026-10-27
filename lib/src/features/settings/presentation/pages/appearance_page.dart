import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/src/src.dart';

class AppearancePage extends StatelessWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = context.s;
    final cubit = context.read<SettingsCubit>();

    return MESliverScaffold(
      title: s.appearance,
      leadingAppBar: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      slivers: [
        SliverToBoxAdapter(
          child: BlocBuilder<SettingsCubit, SettingsState>(
            buildWhen: (p, c) =>
                p.themeMode != c.themeMode ||
                p.useDynamicColors != c.useDynamicColors ||
                p.useHighContrast != c.useHighContrast,
            builder: (context, state) {
              final showScheme = state.useDynamicColors;
              return Column(
                children: [
                  ActionItem(
                    title: s.themeMode,
                    subtitle: Text(state.themeMode.label(s)),
                    icon: SettingsIcon(
                      state.themeMode.icon,
                      backgroundColor: scheme.primaryContainer,
                      foregroundColor: scheme.onPrimaryContainer,
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    itemPosition: ItemPosition.top,
                    onTap: () => context.push(AppRoutes.themeMode.path),
                  ),
                  ActionItem(
                    title: s.highContrast,
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
                    itemPosition: ItemPosition.center,
                    onTap: () =>
                        cubit.setUseHighContrast(!state.useHighContrast),
                  ),
                  ActionItem(
                    title: s.dynamicColors,
                    subtitle: Text(s.dynamicColorsSubtitle),
                    maxSubtitleLines: 2,
                    icon: SettingsIcon(
                      Icons.color_lens_outlined,
                      backgroundColor: scheme.tertiaryContainer,
                      foregroundColor: scheme.onTertiaryContainer,
                    ),
                    trailing: Switch(
                      value: state.useDynamicColors,
                      onChanged: cubit.setUseDynamicColors,
                    ),
                    itemPosition:
                        showScheme ? ItemPosition.center : ItemPosition.bottom,
                    onTap: () =>
                        cubit.setUseDynamicColors(!state.useDynamicColors),
                  ),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 250),
                    crossFadeState: showScheme
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: ActionItem(
                      title: s.colorScheme,
                      subtitle: Text(s.colorSchemeSubtitle),
                      maxSubtitleLines: 2,
                      icon: SettingsIcon(
                        Icons.palette_rounded,
                        backgroundColor: scheme.primaryContainer,
                        foregroundColor: scheme.onPrimaryContainer,
                      ),
                      itemPosition: ItemPosition.bottom,
                      onTap: () => const SchemeSheet().show(context),
                    ),
                    secondChild: const SizedBox(width: double.infinity),
                  ),
                ],
              );
            },
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              BlocBuilder<SettingsCubit, SettingsState>(
                buildWhen: (p, c) => p.font != c.font,
                builder: (context, state) {
                  return ActionItem(
                    title: s.displayFont,
                    subtitle: Text(state.font.title(s)),
                    icon: SettingsIcon(
                      Icons.text_fields_rounded,
                      backgroundColor: scheme.tertiaryContainer,
                      foregroundColor: scheme.onTertiaryContainer,
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    itemPosition: ItemPosition.top,
                    onTap: () => context.push(AppRoutes.fonts.path),
                  );
                },
              ),
              BlocBuilder<SettingsCubit, SettingsState>(
                buildWhen: (p, c) => p.locale != c.locale,
                builder: (context, state) {
                  return ActionItem(
                    title: s.language,
                    subtitle: Text(state.locale.nativeName),
                    icon: SettingsIcon(
                      Icons.language_rounded,
                      backgroundColor: scheme.primaryContainer,
                      foregroundColor: scheme.onPrimaryContainer,
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    itemPosition: ItemPosition.bottom,
                    onTap: () => context.push(AppRoutes.language.path),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
