import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openkey_app/src/src.dart';

class AccountSwitcherSheet extends StatefulWidget {
  const AccountSwitcherSheet({super.key});

  Future<void> show(BuildContext context) {
    return showMEBottomSheet<void>(
      context: context,
      builder: (_) => this,
    );
  }

  @override
  State<AccountSwitcherSheet> createState() => _AccountSwitcherSheetState();
}

class _AccountSwitcherSheetState extends State<AccountSwitcherSheet> {
  String? _pendingId;

  bool get _switching => _pendingId != null;

  void _select(VaultAccount account) {
    final auth = context.read<AuthBloc>().state;
    if (account.id == auth.activeAccountId) {
      Navigator.of(context).pop();
      return;
    }
    if (_switching) return;
    setState(() => _pendingId = account.id);
    context.read<AuthBloc>().add(AuthSwitchAccountRequested(account.id));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          _switching && previous.status != current.status,
      listener: (context, state) {
        if (state.status == AuthStatus.loading) return;
        if (!context.mounted) return;
        Navigator.of(context).pop();
      },
      builder: (context, auth) {
        final accounts = auth.accounts;

        return PopScope(
          canPop: !_switching,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(s.chooseAccount, style: textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      s.switchAccount,
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (var i = 0; i < accounts.length; i++) ...[
                      if (i > 0) const SizedBox(height: 4),
                      _AccountChoiceTile(
                        isUnlocked: auth.isUnlocked,
                        index: i,
                        length: accounts.length,
                        account: accounts[i],
                        selected: accounts[i].id == auth.activeAccountId,
                        pending: accounts[i].id == _pendingId,
                        enabled: !_switching,
                        onTap: () => _select(accounts[i]),
                      ),
                    ],
                    const SizedBox(height: 4),
                    if (auth.isUnlocked)
                      _AddAccountTile(onTap: () => startAddAccountFlow(context)),

                  ],
                ),
              ),
              if (_switching)
                Positioned.fill(
                  child: AbsorbPointer(
                    child: ColoredBox(
                      color: scheme.surface.withValues(alpha: 0.82),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              MELoadingIndicator(
                                size: 48,
                                contained: true,
                                color: scheme.onPrimaryContainer,
                                containerColor: scheme.primaryContainer,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                s.switchingAccount,
                                textAlign: TextAlign.center,
                                style: textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _AddAccountTile extends StatelessWidget {
  const _AddAccountTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    return MECard(
      itemPosition: ItemPosition.bottom,
      color: scheme.surfaceContainerHigh,
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      onPressed: onTap,
      child: Row(
        children: [
            SettingsIcon(Icons.add, size: 48, backgroundColor: scheme.primaryContainer, foregroundColor: scheme.onPrimaryContainer),
          const SizedBox(width: 14),
          Text(s.addAccount, style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          )),
        ],
      ),
    );
  }
}


class _AccountChoiceTile extends StatelessWidget {
  const _AccountChoiceTile({
    required this.account,
    required this.selected,
    required this.pending,
    required this.enabled,
    required this.onTap,
    required this.index,
    required this.length,
    required this.isUnlocked,
  });

  final VaultAccount account;
  final bool selected;
  final bool pending;
  final bool enabled;
  final VoidCallback onTap;
  final int index;
  final int length;
  final bool isUnlocked;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final s = context.s;

    return MECard(
      onPressed: enabled ? onTap : null,
      itemPosition: length == 1 && isUnlocked
          ? ItemPosition.top
          : index == length - 1 && isUnlocked
          ? ItemPosition.center
          : ItemPosition.fromIndex(index, length),
      color: selected ? scheme.secondaryContainer : scheme.surfaceContainerHigh,
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      
      child: Row(
        children: [
          AccountAvatar(account: account, size: 48, selected: selected),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: selected ? scheme.onSecondaryContainer : null,
                  ),
                ),
                if (selected) ...[
                  const SizedBox(height: 2),
                  Text(
                    s.currentAccount,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (pending)
            SizedBox(
              width: 24,
              height: 24,
              child: MELoadingIndicator(size: 22, color: scheme.primary),
            )
          else
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? scheme.primary : scheme.outline,
            ),
        ],
      ),
    );
  }
}

/// Locks the current vault if needed, then opens    as an extra account.
Future<void> startAddAccountFlow(BuildContext context) async {
  final auth = context.read<AuthBloc>().state;
  okDebugLog(
    '[add-account] tap startAddAccountFlow status=${auth.status} '
    'unlocked=${auth.isUnlocked} adding=${auth.addingAccount}',
  );
  context.read<AuthBloc>().add(const AuthAddAccountRequested());
}
