import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openkey_app/src/src.dart';

class SchemeSheet extends StatelessWidget {
  const SchemeSheet({super.key});

  Future<void> show(BuildContext context) {
    return showMEBottomSheet<void>(
      context: context,
      builder: (_) => this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = context.s;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        buildWhen: (p, c) =>
            p.colorIndex != c.colorIndex || p.paletteIndex != c.paletteIndex,
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(s.colorScheme, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                s.colorSchemeSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (var i = 0; i < AppColorSchemes.seedArgb.length; i++)
                    _ColorDot(
                      color: Color(AppColorSchemes.seedArgb[i]),
                      selected: state.colorIndex == i,
                      onTap: () => context.read<SettingsCubit>().setTheme(
                            i,
                            state.paletteIndex,
                          ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < AppColorSchemes.variants.length; i++)
                    FilterChip(
                      selected: state.paletteIndex == i,
                      label: Text(
                        AppColorSchemes.variantLabel(
                          AppColorSchemes.variants[i],
                        ),
                      ),
                      onSelected: (_) => context.read<SettingsCubit>().setTheme(
                            state.colorIndex,
                            i,
                          ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.onSurface
                : Colors.transparent,
            width: 3,
          ),
        ),
        child: selected
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
            : null,
      ),
    );
  }
}
