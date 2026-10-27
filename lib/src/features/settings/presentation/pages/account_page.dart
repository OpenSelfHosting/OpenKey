import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final s = context.s;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, auth) {
        final email = auth.email ?? sl<AuthRepository>().email ?? s.localVault;
        final match = auth.accounts.where((a) => a.id == auth.activeAccountId);
        final account = match.isNotEmpty
            ? match.first.copyWith(avatarPath: auth.avatarPath)
            : VaultAccount(
                id: auth.activeAccountId ?? '',
                email: email,
                avatarPath: auth.avatarPath,
              );

        final switching = auth.status == AuthStatus.loading;

        return Stack(
          children: [
            MESliverScaffold(
              title: s.accountPageTitle,
              leadingAppBar: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: switching ? null : () => context.pop(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      AccountAvatar(
                        key: ValueKey(auth.avatarGeneration),
                        account: account,
                        size: 88,
                        onPressed: switching
                            ? null
                            : () => _changePhoto(context),
                      ),
                  const SizedBox(height: 12),
                  Text(
                    email,
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ..._withPositions([
                    (pos) => ActionItem(
                      title: s.changeAccountPhoto,
                      icon: SettingsIcon(
                        Icons.photo_camera_outlined,
                        backgroundColor: scheme.primaryContainer,
                        foregroundColor: scheme.onPrimaryContainer,
                      ),
                      itemPosition: pos,
                      onTap: () => _changePhoto(context),
                    ),
                    if (auth.avatarPath != null)
                      (pos) => ActionItem(
                        title: s.removeAccountPhoto,
                        icon: SettingsIcon(
                          Icons.hide_image_outlined,
                          backgroundColor: scheme.secondaryContainer,
                          foregroundColor: scheme.onSecondaryContainer,
                        ),
                        itemPosition: pos,
                        onTap: () => _clearPhoto(context),
                      ),
                    (pos) => ActionItem(
                      title: s.changeEmail,
                      subtitle: Text(
                        s.changeEmailSubtitle,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      maxSubtitleLines: 2,
                      icon: SettingsIcon(
                        Icons.alternate_email_rounded,
                        backgroundColor: scheme.tertiaryContainer,
                        foregroundColor: scheme.onTertiaryContainer,
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      itemPosition: pos,
                      onTap: () => const ChangeEmailSheet().show(context),
                    ),
                    (pos) => ActionItem(
                      title: s.changeMasterPassword,
                      subtitle: Text(
                        s.changeMasterPasswordSubtitle,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      maxSubtitleLines: 2,
                      icon: SettingsIcon(
                        Icons.password_rounded,
                        backgroundColor: scheme.primaryContainer,
                        foregroundColor: scheme.onPrimaryContainer,
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      itemPosition: pos,
                      onTap: () =>
                          const ChangeMasterPasswordSheet().show(context),
                    ),
                  ]),
                  if (auth.accounts.length > 1) ...[
                    const SizedBox(height: 20),
                    SectionLabel(title: s.otherAccounts),
                    ..._withPositions([
                      for (final other in auth.accounts.where(
                        (a) => a.id != auth.activeAccountId,
                      ))
                        (pos) => ActionItem(
                          title: other.email,
                          icon: AccountAvatar(account: other, size: 40),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          itemPosition: pos,
                          onTap: switching
                              ? null
                              : () {
                                  context.read<AuthBloc>().add(
                                    AuthSwitchAccountRequested(other.id),
                                  );
                                },
                        ),
                    ]),
                  ],
                  const SizedBox(height: 20),
                  ..._withPositions([
                    (pos) => ActionItem(
                      title: s.addAccount,
                      subtitle: Text(
                        s.addAccountSubtitle,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      maxSubtitleLines: 2,
                      icon: SettingsIcon(
                        Icons.person_add_alt_1_rounded,
                        backgroundColor: scheme.secondaryContainer,
                        foregroundColor: scheme.onSecondaryContainer,
                      ),
                      itemPosition: pos,
                      onTap: () {
                        okDebugLog(
                          '[add-account] account page Add account tapped',
                        );
                        startAddAccountFlow(context);
                      },
                    ),
                    (pos) => ActionItem(
                      title: s.removeAccountFromDevice,
                      subtitle: Text(
                        s.removeAccountFromDeviceSubtitle,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      maxSubtitleLines: 3,
                      icon: SettingsIcon(
                        Icons.person_remove_outlined,
                        backgroundColor: scheme.errorContainer,
                        foregroundColor: scheme.onErrorContainer,
                      ),
                      itemPosition: pos,
                      onTap: () => _confirmRemove(context, account.id),
                    ),
                  ]),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
            ),
            if (switching)
              Positioned.fill(
                child: AuthBusyOverlay(message: s.switchingAccount),
              ),
          ],
        );
      },
    );
  }

  static Future<void> _changePhoto(BuildContext context) async {
    final bytes = await CustomIcons.pickBytes();
    if (bytes == null || !context.mounted) return;
    final edited = await IconImageEditorPage.edit(
      context,
      bytes,
      heroTag: 'openkey-account-avatar',
    );
    if (edited == null || edited.isEmpty || !context.mounted) return;
    final png = await CustomIcons.resizeToPng(edited, maxEdge: 256);
    final result = await sl<AuthRepository>().setAccountAvatar(png);
    if (!context.mounted) return;
    result.fold(
      (f) => showMEToast(
        context,
        message: f.getMessage(context),
        kind: METoastKind.error,
      ),
      (_) => context.read<AuthBloc>().add(const AuthAccountsChanged()),
    );
  }

  static Future<void> _clearPhoto(BuildContext context) async {
    final result = await sl<AuthRepository>().clearAccountAvatar();
    if (!context.mounted) return;
    result.fold(
      (f) => showMEToast(
        context,
        message: f.getMessage(context),
        kind: METoastKind.error,
      ),
      (_) => context.read<AuthBloc>().add(const AuthAccountsChanged()),
    );
  }

  static Future<void> _confirmRemove(
    BuildContext context,
    String accountId,
  ) async {
    final s = context.s;
    final confirmed = await showMEDialog<bool>(
      context: context,
      builder: (context) => MEDialog(
        icon: Icon(
          Icons.person_remove_outlined,
          color: Theme.of(context).colorScheme.error,
        ),
        title: Text(s.removeAccountFromDevice),
        content: Text(s.removeAccountConfirm),
        actions: [
          MEButton.text(
            onPressed: () => Navigator.pop(context, false),
            child: Text(s.cancel),
          ),
          MEButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(s.removeAccountFromDevice),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    context.read<AuthBloc>().add(AuthRemoveAccountRequested(accountId));
  }
}

List<Widget> _withPositions(List<Widget Function(ItemPosition)> builders) {
  return [
    for (var i = 0; i < builders.length; i++)
      builders[i](ItemPosition.fromIndex(i, builders.length)),
  ];
}
