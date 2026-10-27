import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/src/src.dart';

class FontsPage extends StatelessWidget {
  const FontsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final fonts = AppFonts.values;
    final scheme = Theme.of(context).colorScheme;

    return MESliverScaffold(
      title: s.fonts,
      leadingAppBar: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      slivers: [
        SliverToBoxAdapter(
          child: BlocBuilder<SettingsCubit, SettingsState>(
            buildWhen: (p, c) => p.font != c.font,
            builder: (context, state) {
              return Column(
                children: [
                  for (var i = 0; i < fonts.length; i++)
                    Builder(
                      builder: (context) {
                        final font = fonts[i];
                        final previewFamily = font == AppFonts.defaultFont
                            ? null
                            : font.assetName;
                        return ActionItem(
                          title: Text(
                            font.title(s),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontFamily: previewFamily),
                          ),
                          subtitle: Text(
                            font.subtitle(s),
                            style: TextStyle(fontFamily: previewFamily),
                          ),
                          maxSubtitleLines: 2,
                          selected: state.font == font,
                          icon: SettingsIcon(
                            Icons.text_fields_rounded,
                            backgroundColor: state.font == font
                                ? scheme.primaryContainer
                                : scheme.surfaceContainerHighest,
                            foregroundColor: state.font == font
                                ? scheme.onPrimaryContainer
                                : scheme.onSurfaceVariant,
                          ),
                          trailing: state.font == font
                              ? Icon(Icons.check_rounded, color: scheme.primary)
                              : null,
                          itemPosition:
                              ItemPosition.fromIndex(i, fonts.length),
                          onTap: () =>
                              context.read<SettingsCubit>().setFont(font),
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
