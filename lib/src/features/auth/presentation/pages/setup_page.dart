import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/src/src.dart';

/// First-run / add-account hub — pick how to bring a vault onto this device.
class SetupPage extends StatelessWidget {
  const SetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final addingAccount = context.watch<AuthBloc>().state.addingAccount;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    final options = [
      (
        title: s.setupChooseCreateTitle,
        subtitle: s.setupChooseCreateSubtitle,
        icon: Icons.add_rounded,
        route: AppRoutes.setupCreate.path,
      ),
      (
        title: s.setupChooseSignInTitle,
        subtitle: s.setupChooseSignInSubtitle,
        icon: Icons.login_rounded,
        route: AppRoutes.setupSignIn.path,
      ),
      (
        title: s.setupChooseRestoreTitle,
        subtitle: s.setupChooseRestoreSubtitle,
        icon: Icons.restore_rounded,
        route: AppRoutes.setupRestore.path,
      ),
    ];

    return SetupFlowScaffold(
      showBack: addingAccount,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottomInset),
        children: [
          const AuthBrandHero(compact: true),
          const SizedBox(height: 24),
          Text(
            s.setupChooserTitle,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.setupChooserSubtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          for (var i = 0; i < options.length; i++)
            ActionItem(
              title: options[i].title,
              subtitle: Text(
                options[i].subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              maxSubtitleLines: 2,
              icon: SettingsIcon(
                options[i].icon,
                backgroundColor: i == 0
                    ? scheme.primaryContainer
                    : scheme.secondaryContainer,
                foregroundColor: i == 0
                    ? scheme.onPrimaryContainer
                    : scheme.onSecondaryContainer,
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              itemPosition: ItemPosition.fromIndex(i, options.length),
              onTap: () => context.push(options[i].route),
            ),
        ],
      ),
    );
  }
}
