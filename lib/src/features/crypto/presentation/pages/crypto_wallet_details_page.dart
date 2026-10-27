import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

class CryptoWalletDetailsPage extends StatefulWidget {
  const CryptoWalletDetailsPage({super.key, required this.uuid});

  final String uuid;

  @override
  State<CryptoWalletDetailsPage> createState() =>
      _CryptoWalletDetailsPageState();
}

class _CryptoWalletDetailsPageState extends State<CryptoWalletDetailsPage> {
  CryptoWallet? _wallet;
  bool _loading = true;
  bool _notFound = false;
  bool _showPrivateKey = false;
  bool _showSeed = false;

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
    final result = await sl<CryptoRepository>().getWallet(widget.uuid);
    if (!mounted) return;
    result.fold(
      (_) => setState(() {
        _loading = false;
        _notFound = true;
      }),
      (wallet) => setState(() {
        _wallet = wallet;
        _loading = false;
        _notFound = wallet == null;
        _showPrivateKey = false;
        _showSeed = false;
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
    await context.push('${AppRoutes.crypto.path}/${widget.uuid}/edit');
    if (mounted) await _load(silent: true);
  }

  Future<void> _moveToFolder() async {
    final wallet = _wallet;
    if (wallet == null) return;
    final folder = await MoveCryptoFolderSheet.show(
      context,
      currentFolder: wallet.folder,
    );
    if (folder == null || !mounted) return;
    context.read<CryptoBloc>().add(
      CryptoMovedToFolder(uuid: wallet.uuid, folder: folder),
    );
    showMEToast(
      context,
      message: context.s.cryptoWalletMoved,
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
        title: Text(s.deleteCryptoWallet),
        content: Text(s.deleteCryptoWalletConfirm),
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
    context.read<CryptoBloc>().add(CryptoWalletDeleted(widget.uuid));
    context.pop();
  }

  IconData _networkIcon(CryptoNetwork network) => switch (network) {
    CryptoNetwork.bitcoin => Icons.currency_bitcoin,
    CryptoNetwork.ethereum => Icons.token_outlined,
    CryptoNetwork.solana => Icons.bolt_rounded,
    _ => Icons.account_balance_wallet_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_loading) {
      return MESliverScaffold(
        title: s.cryptoWallets,
        leadingAppBar: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        slivers: const [
          SliverFillRemaining(child: Center(child: MELoadingIndicator())),
        ],
      );
    }

    if (_notFound || _wallet == null) {
      return MESliverScaffold(
        title: s.cryptoWallets,
        leadingAppBar: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        slivers: [
          SliverFillRemaining(
            child: MEEmptyState(
              icon: Icons.currency_bitcoin,
              title: Text(s.cryptoWalletNotFound),
              message: Text(s.cryptoWalletNotFoundMessage),
              action: MEButton.outlined(
                onPressed: () => context.pop(),
                child: Text(s.goBack),
              ),
            ),
          ),
        ],
      );
    }

    final wallet = _wallet!;

    return MESliverScaffold(
      title: wallet.displayName,
      extendedAppBar: false,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      leadingAppBar: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => context.pop(),
      ),
      appBarActions: [
        MEIconButton(
          tooltip: s.moveToFolder,
          variant: MEButtonVariant.tonal,
          size: MEButtonSize.small,
          onPressed: _moveToFolder,
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
                MEAvatar(
                  size: 112,
                  backgroundColor: scheme.tertiaryContainer,
                  foregroundColor: scheme.onTertiaryContainer,
                  child: Icon(
                    _networkIcon(wallet.network),
                    size: 56,
                    color: scheme.onTertiaryContainer,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  wallet.displayName,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                MEChip(
                  label: Text(
                    '${wallet.network.label} · ${wallet.network.symbol}',
                  ),
                  selected: true,
                  onPressed: () {},
                ),
                const SizedBox(height: 16),
                MEButton(
                  onPressed: wallet.address.isEmpty
                      ? null
                      : () => _copy(s.walletAddress, wallet.address),
                  child: Text(s.copyAddress),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              s.cryptoDetails,
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
              if (wallet.folder.trim().isNotEmpty)
                ActionItem(
                  title: s.folder,
                  subtitle: Text(
                    wallet.folder,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  icon: SettingsIcon(
                    Icons.folder_outlined,
                    backgroundColor: scheme.secondaryContainer,
                    foregroundColor: scheme.onSecondaryContainer,
                  ),
                  itemPosition: ItemPosition.top,
                  onTap: () => _copy(s.folder, wallet.folder),
                ),
              ActionItem(
                title: s.walletAddress,
                subtitle: Text(
                  wallet.address.isEmpty ? '—' : wallet.address,
                  style: textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                maxSubtitleLines: 4,
                icon: SettingsIcon(
                  Icons.qr_code_2_rounded,
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                ),
                trailing: wallet.address.isEmpty
                    ? null
                    : MEIconButton(
                        tooltip: s.copyAddress,
                        variant: MEButtonVariant.text,
                        size: MEButtonSize.extraSmall,
                        onPressed: () => _copy(s.walletAddress, wallet.address),
                        icon: const Icon(Icons.copy_rounded),
                      ),
                itemPosition: wallet.folder.trim().isNotEmpty
                    ? ItemPosition.center
                    : ItemPosition.top,
                onTap: wallet.address.isEmpty
                    ? null
                    : () => _copy(s.walletAddress, wallet.address),
              ),
              ActionItem(
                title: s.privateKey,
                subtitle: Text(
                  wallet.privateKey.isEmpty
                      ? '—'
                      : (_showPrivateKey
                            ? wallet.privateKey
                            : '•' * wallet.privateKey.length.clamp(12, 32)),
                  style: textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                maxSubtitleLines: 4,
                icon: SettingsIcon(
                  Icons.key_rounded,
                  backgroundColor: scheme.errorContainer,
                  foregroundColor: scheme.onErrorContainer,
                ),
                trailing: wallet.privateKey.isEmpty
                    ? null
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MEIconButton(
                            tooltip: _showPrivateKey
                                ? s.hidePassword
                                : s.showPassword,
                            variant: MEButtonVariant.text,
                            size: MEButtonSize.extraSmall,
                            onPressed: () => setState(
                              () => _showPrivateKey = !_showPrivateKey,
                            ),
                            icon: Icon(
                              _showPrivateKey
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                          MEIconButton(
                            tooltip: s.copyPassword,
                            variant: MEButtonVariant.text,
                            size: MEButtonSize.extraSmall,
                            onPressed: () =>
                                _copy(s.privateKey, wallet.privateKey),
                            icon: const Icon(Icons.copy_rounded),
                          ),
                        ],
                      ),
                itemPosition: ItemPosition.center,
                onTap: wallet.privateKey.isEmpty
                    ? null
                    : () => _copy(s.privateKey, wallet.privateKey),
              ),
              ActionItem(
                title: s.seedPhrase,
                subtitle: Text(
                  wallet.seedPhrase.isEmpty
                      ? '—'
                      : (_showSeed ? wallet.seedPhrase : '•••• •••• •••• ••••'),
                  style: textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                maxSubtitleLines: 6,
                icon: SettingsIcon(
                  Icons.spa_outlined,
                  backgroundColor: scheme.tertiaryContainer,
                  foregroundColor: scheme.onTertiaryContainer,
                ),
                trailing: wallet.seedPhrase.isEmpty
                    ? null
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MEIconButton(
                            tooltip: _showSeed
                                ? s.hidePassword
                                : s.showPassword,
                            variant: MEButtonVariant.text,
                            size: MEButtonSize.extraSmall,
                            onPressed: () =>
                                setState(() => _showSeed = !_showSeed),
                            icon: Icon(
                              _showSeed
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                          MEIconButton(
                            tooltip: s.copyPassword,
                            variant: MEButtonVariant.text,
                            size: MEButtonSize.extraSmall,
                            onPressed: () =>
                                _copy(s.seedPhrase, wallet.seedPhrase),
                            icon: const Icon(Icons.copy_rounded),
                          ),
                        ],
                      ),
                itemPosition: wallet.notes.isEmpty
                    ? ItemPosition.bottom
                    : ItemPosition.center,
                onTap: wallet.seedPhrase.isEmpty
                    ? null
                    : () => _copy(s.seedPhrase, wallet.seedPhrase),
              ),
              if (wallet.notes.isNotEmpty)
                ActionItem(
                  title: s.notes,
                  subtitle: Text(
                    wallet.notes,
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
                  onTap: () => _copy(s.notes, wallet.notes),
                ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 20, 4, 32),
            child: Text(
              [
                s.revisionLabel(wallet.revision),
                if (wallet.isSynced) s.synced else s.pendingSync,
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
