import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

class WalletDetailsPage extends StatefulWidget {
  const WalletDetailsPage({super.key, required this.uuid});

  final String uuid;

  @override
  State<WalletDetailsPage> createState() => _WalletDetailsPageState();
}

class _WalletDetailsPageState extends State<WalletDetailsPage> {
  WalletCard? _card;
  bool _loading = true;
  bool _notFound = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _notFound = false;
      });
    }
    final result = await sl<WalletRepository>().getCard(widget.uuid);
    if (!mounted) return;
    result.fold(
      (_) => setState(() {
        _loading = false;
        _notFound = true;
      }),
      (card) => setState(() {
        _card = card;
        _loading = false;
        _notFound = card == null;
      }),
    );
  }

  Future<void> _copy(String label, String value) async {
    if (value.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    showMEToast(
      context,
      message: context.s.valueCopied(label),
      kind: METoastKind.success,
    );
  }

  Future<void> _edit() async {
    await context.push('${AppRoutes.wallets.path}/${widget.uuid}/edit');
    if (mounted) await _load(silent: true);
  }

  Future<void> _moveToBank() async {
    final card = _card;
    if (card == null) return;
    final bank = await MoveWalletBankSheet.show(
      context,
      currentBank: card.bank,
    );
    if (bank == null || !mounted) return;
    context.read<WalletBloc>().add(
      WalletMovedToBank(uuid: card.uuid, bank: bank),
    );
    showMEToast(
      context,
      message: context.s.cardMoved,
      kind: METoastKind.success,
    );
    await _load(silent: true);
  }

  Future<void> _confirmDelete() async {
    final s = context.s;
    final confirmed = await showMEDialog<bool>(
      context: context,
      builder: (context) => MEDialog(
        icon: Icon(
          Icons.delete_outline_rounded,
          color: Theme.of(context).colorScheme.error,
        ),
        title: Text(s.deleteCard),
        content: Text(s.deleteCardConfirm),
        actions: [
          MEButton.text(
            onPressed: () => Navigator.pop(context, false),
            child: Text(s.cancel),
          ),
          MEButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(s.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    context.read<WalletBloc>().add(WalletDeleted(widget.uuid));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_loading) {
      return MESliverScaffold(
        title: s.wallets,
        leadingAppBar: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        slivers: const [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: MELoadingIndicator()),
          ),
        ],
      );
    }

    if (_notFound || _card == null) {
      return MESliverScaffold(
        title: s.wallets,
        leadingAppBar: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        slivers: [
          SliverFillRemaining(
            child: MEEmptyState(
              icon: Icons.credit_card_off_outlined,
              title: Text(s.cardNotFound),
              message: Text(s.cardNotFoundMessage),
              action: MEButton.outlined(
                onPressed: () => context.pop(),
                child: Text(s.goBack),
              ),
            ),
          ),
        ],
      );
    }

    final card = _card!;

    return MESliverScaffold(
      extendedAppBar: false,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      leadingAppBar: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => context.pop(),
      ),
      appBarActions: [
        MEIconButton(
          tooltip: s.moveToBank,
          variant: MEButtonVariant.tonal,
          size: MEButtonSize.small,
          onPressed: _moveToBank,
          icon: const Icon(Icons.drive_file_move_outlined),
        ),
        SizedBox(width: 4),
        MEIconButton(
          tooltip: s.edit,
          variant: MEButtonVariant.tonal,
          size: MEButtonSize.small,
          onPressed: _edit,
          icon: const Icon(Icons.edit_outlined),
        ),
        SizedBox(width: 4),
        MEIconButton(
          tooltip: s.delete,
          variant: MEButtonVariant.text,
          size: MEButtonSize.small,
          onPressed: _confirmDelete,
          icon: Icon(Icons.delete_outline_rounded, color: scheme.error),
        ),
      ],
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Column(
              children: [
                MECreditCard(
                  number: card.number,
                  holder: card.holder,
                  expiry: card.expiry,
                  cvc: card.cvc,
                  bankName: card.bank,
                  brand: card.brand.name,
                  obscureNumber: false,
                  obscureCvv: false,
                ),
                const SizedBox(height: 8),
                Text(
                  s.tapCardToFlip,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: MEButton.tonal(
                        onPressed: card.number.isEmpty
                            ? null
                            : () => _copy(s.cardNumber, card.number),
                        child: Text(s.copyNumber),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MEButton(
                        onPressed: card.cvc.isEmpty
                            ? null
                            : () => _copy(s.cardCvc, card.cvc),
                        child: Text(s.copyCvc),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              s.cardDetails,
              style: textTheme.titleSmall?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 8),
              ActionItem(
                title: s.cardName,
                subtitle: Text(
                  card.name.isEmpty ? '—' : card.name,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                icon: SettingsIcon(
                  Icons.label_outline_rounded,
                  backgroundColor: scheme.secondaryContainer,
                  foregroundColor: scheme.onSecondaryContainer,
                ),
                itemPosition: ItemPosition.top,
                onTap: card.name.isEmpty
                    ? null
                    : () => _copy(s.cardName, card.name),
              ),
              if (card.bank.trim().isNotEmpty)
                ActionItem(
                  title: s.bank,
                  subtitle: Text(
                    card.bank,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  icon: SettingsIcon(
                    Icons.account_balance_rounded,
                    backgroundColor: scheme.primaryContainer,
                    foregroundColor: scheme.onPrimaryContainer,
                  ),
                  itemPosition: ItemPosition.center,
                  onTap: () => _copy(s.bank, card.bank),
                ),
              ActionItem(
                title: s.cardHolder,
                subtitle: Text(
                  card.holder.isEmpty ? '—' : card.holder,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                icon: SettingsIcon(
                  Icons.person_outline_rounded,
                  backgroundColor: scheme.tertiaryContainer,
                  foregroundColor: scheme.onTertiaryContainer,
                ),
                trailing: card.holder.isEmpty
                    ? null
                    : MEIconButton(
                        tooltip: s.copyUsername,
                        variant: MEButtonVariant.text,
                        size: MEButtonSize.extraSmall,
                        onPressed: () => _copy(s.cardHolder, card.holder),
                        icon: const Icon(Icons.copy_rounded),
                      ),
                itemPosition: ItemPosition.center,
                onTap: card.holder.isEmpty
                    ? null
                    : () => _copy(s.cardHolder, card.holder),
              ),
              ActionItem(
                title: s.cardNumber,
                subtitle: Text(
                  card.number.isEmpty ? '—' : card.spacedNumber,
                  style: textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                icon: SettingsIcon(
                  Icons.credit_card_rounded,
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                ),
                trailing: card.number.isEmpty
                    ? null
                    : MEIconButton(
                        tooltip: s.copyNumber,
                        variant: MEButtonVariant.text,
                        size: MEButtonSize.extraSmall,
                        onPressed: () => _copy(s.cardNumber, card.number),
                        icon: const Icon(Icons.copy_rounded),
                      ),
                itemPosition: ItemPosition.center,
                onTap: card.number.isEmpty
                    ? null
                    : () => _copy(s.cardNumber, card.number),
              ),
              ActionItem(
                title: s.cardExpiry,
                subtitle: Text(
                  card.expiry.isEmpty ? '—' : card.expiry,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                icon: SettingsIcon(
                  Icons.event_rounded,
                  backgroundColor: scheme.secondaryContainer,
                  foregroundColor: scheme.onSecondaryContainer,
                ),
                itemPosition: ItemPosition.center,
                onTap: card.expiry.isEmpty
                    ? null
                    : () => _copy(s.cardExpiry, card.expiry),
              ),
              ActionItem(
                title: s.cardCvc,
                subtitle: Text(
                  card.cvc.isEmpty ? '—' : card.cvc,
                  style: textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                icon: SettingsIcon(
                  Icons.password_rounded,
                  backgroundColor: scheme.errorContainer,
                  foregroundColor: scheme.onErrorContainer,
                ),
                trailing: card.cvc.isEmpty
                    ? null
                    : MEIconButton(
                        tooltip: s.copyCvc,
                        variant: MEButtonVariant.text,
                        size: MEButtonSize.extraSmall,
                        onPressed: () => _copy(s.cardCvc, card.cvc),
                        icon: const Icon(Icons.copy_rounded),
                      ),
                itemPosition: card.notes.isEmpty
                    ? ItemPosition.bottom
                    : ItemPosition.center,
                onTap: card.cvc.isEmpty
                    ? null
                    : () => _copy(s.cardCvc, card.cvc),
              ),
              if (card.notes.isNotEmpty)
                ActionItem(
                  title: s.notes,
                  subtitle: Text(
                    card.notes,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  maxSubtitleLines: 6,
                  icon: SettingsIcon(
                    Icons.notes_rounded,
                    backgroundColor: scheme.surfaceContainerHighest,
                    foregroundColor: scheme.onSurfaceVariant,
                  ),
                  itemPosition: ItemPosition.bottom,
                  onTap: () => _copy(s.notes, card.notes),
                ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 20, 4, 32),
            child: Text(
              [
                s.revisionLabel(card.revision),
                if (card.isSynced) s.synced else s.pendingSync,
              ].join(' · '),
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
