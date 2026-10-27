import 'package:flutter/material.dart';
import 'package:openkey_app/src/src.dart';

/// Identity + account switcher on the unlock screen.
class UnlockAccountHeader extends StatelessWidget {
  const UnlockAccountHeader({
    super.key,
    required this.email,
    required this.accountId,
    required this.avatarPath,
    required this.canSwitch,
    this.enabled = true,
    this.onSwitch,
  });

  final String? email;
  final String? accountId;
  final String? avatarPath;
  final bool canSwitch;
  final bool enabled;
  final VoidCallback? onSwitch;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    if (email == null) {
      return Text(
        s.unlockSubtitle,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    final account = VaultAccount(
      id: accountId ?? '',
      email: email!,
      avatarPath: avatarPath,
    );
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Column(
      children: [
        if (canSwitch) ...[
          const AuthBrandHero(compact: true, markSize: 140, iconSize: 48, textSize: 30),
          const SizedBox(height: 33),

        ],
        AnimatedSwitcher(
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: KeyedSubtree(
            key: ValueKey(account.id.isEmpty ? account.email : account.id),
            child: canSwitch
                ? _SwitchableAccountCard(
                    account: account,
                    enabled: enabled,
                    onSwitch: onSwitch,
                  )
                : _SingleAccountIdentity(account: account),
          ),
        ),
      ],
    );
  }
}

class _SingleAccountIdentity extends StatelessWidget {
  const _SingleAccountIdentity({required this.account});

  final VaultAccount account;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final s = context.s;

    return Column(
      children: [
        AccountAvatar(account: account, size: 144),
        const SizedBox(height: 12),
        Text(
          s.welcomeBackShort,
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(
          account.email,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _SwitchableAccountCard extends StatelessWidget {
  const _SwitchableAccountCard({
    required this.account,
    required this.enabled,
    required this.onSwitch,
  });

  final VaultAccount account;
  final bool enabled;
  final VoidCallback? onSwitch;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final s = context.s;

    return Semantics(
      button: true,
      enabled: enabled,
      label: '${account.email}. ${s.switchAccount}',
      child: MECard(
        onPressed: enabled ? onSwitch : null,
        color: scheme.surfaceContainerHigh,
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        child: Row(
          children: [
            AccountAvatar(account: account, size: 52),
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
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s.switchAccount,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.unfold_more_rounded, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
