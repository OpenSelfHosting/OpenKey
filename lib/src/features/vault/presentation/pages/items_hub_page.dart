import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/src/src.dart';

/// Hub for secondary vault sections (cards, crypto, secrets).
///
/// Keeps the bottom navigation to three tabs: Vault · Items · Settings.
class ItemsHubPage extends StatelessWidget {
  const ItemsHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return MESliverScaffold(
      title: s.items,
      extendedAppBar: false,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 16),
            child: Text(
              s.itemsHubSubtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              BlocBuilder<WalletBloc, WalletState>(
                buildWhen: (p, c) => p.cards.length != c.cards.length,
                builder: (context, state) {
                  return ActionItem(
                    title: s.paymentCards,
                    subtitle: Text(
                      state.cards.isEmpty
                          ? s.itemsCardsSubtitle
                          : s.itemsCountLabel(state.cards.length),
                    ),
                    icon: SettingsIcon(
                      Icons.credit_card_rounded,
                      backgroundColor: scheme.primaryContainer,
                      foregroundColor: scheme.onPrimaryContainer,
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    itemPosition: ItemPosition.start,
                    onTap: () => context.push(AppRoutes.wallets.path),
                  );
                },
              ),
              BlocBuilder<CryptoBloc, CryptoState>(
                buildWhen: (p, c) => p.wallets.length != c.wallets.length,
                builder: (context, state) {
                  return ActionItem(
                    title: s.cryptoWallets,
                    subtitle: Text(
                      state.wallets.isEmpty
                          ? s.itemsCryptoSubtitle
                          : s.itemsCountLabel(state.wallets.length),
                    ),
                    icon: SettingsIcon(
                      Icons.currency_bitcoin,
                      backgroundColor: scheme.tertiaryContainer,
                      foregroundColor: scheme.onTertiaryContainer,
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    itemPosition: ItemPosition.center,
                    onTap: () => context.push(AppRoutes.crypto.path),
                  );
                },
              ),
              BlocBuilder<SecretsBloc, SecretsState>(
                buildWhen: (p, c) => p.secrets.length != c.secrets.length,
                builder: (context, state) {
                  return ActionItem(
                    title: s.secrets,
                    subtitle: Text(
                      state.secrets.isEmpty
                          ? s.itemsSecretsSubtitle
                          : s.itemsCountLabel(state.secrets.length),
                    ),
                    icon: SettingsIcon(
                      Icons.terminal_rounded,
                      backgroundColor: scheme.secondaryContainer,
                      foregroundColor: scheme.onSecondaryContainer,
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    itemPosition: ItemPosition.end,
                    onTap: () => context.push(AppRoutes.secrets.path),
                  );
                },
              ),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}
