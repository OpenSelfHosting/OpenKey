import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openkey_app/src/src.dart';

class AutoLockSheet extends StatelessWidget {
  const AutoLockSheet({super.key});

  /// `0` disables auto-lock.
  static const _options = [0, 1, 5, 15, 30];

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
        buildWhen: (p, c) => p.lockMinutes != c.lockMinutes,
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                s.autoLock,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                s.autoLockSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 18),
              ActionItem(
                title: s.lockMinutesLabel(0),
                padding: 24,
                icon: SettingsIcon(
                  Icons.timer_off_outlined,
                  backgroundColor: scheme.secondaryContainer,
                  foregroundColor: scheme.onSecondaryContainer,
                ),
                itemPosition: ItemPosition.alone,
                onTap: () {
                    context.read<SettingsCubit>().setLockMinutes(0);
                    Navigator.of(context).pop();
                  },
              ),
              const SizedBox(height: 12),
              for (var i = 1; i < _options.length; i++)
                ActionItem(
                  title: s.lockMinutesLabel(_options[i]),
                  padding: 22,
                  icon: SettingsIcon(
                    Icons.timer_outlined,
                    backgroundColor: scheme.secondaryContainer,
                    foregroundColor: scheme.onSecondaryContainer,
                  ),
                  trailing: state.lockMinutes == _options[i]
                      ? Icon(Icons.check_rounded, color: scheme.primary)
                      : null,
                  itemPosition: ItemPosition.fromIndex(i - 1, _options.length - 1),
                  onTap: () {
                    context.read<SettingsCubit>().setLockMinutes(_options[i]);
                    Navigator.of(context).pop();
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
