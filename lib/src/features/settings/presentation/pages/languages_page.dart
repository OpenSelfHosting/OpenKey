import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/src/src.dart';

class LanguagesPage extends StatelessWidget {
  const LanguagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final cubit = context.read<SettingsCubit>();
    final locales = AppLocale.values;

    return MESliverScaffold(
      title: s.language,
      leadingAppBar: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      slivers: [
        SliverToBoxAdapter(
          child: BlocBuilder<SettingsCubit, SettingsState>(
            buildWhen: (p, c) => p.locale != c.locale,
            builder: (context, state) {
              return Column(
                children: [
                  for (var i = 0; i < locales.length; i++)
                    ActionItem(
                      title: locales[i].nativeName,
                      subtitle: Text(locales[i].englishName),
                      selected: state.locale == locales[i],
                      icon: CircleAvatar(
                        radius: 18,
                        backgroundColor: state.locale == locales[i]
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                        child: Text(
                          locales[i].code.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                      trailing: state.locale == locales[i]
                          ? Icon(
                              Icons.check_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      itemPosition: ItemPosition.fromIndex(i, locales.length),
                      onTap: () => cubit.setLocale(locales[i]),
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
