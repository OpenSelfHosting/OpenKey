import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';
import 'package:uuid/uuid.dart';

class CryptoWalletEditorPage extends StatefulWidget {
  const CryptoWalletEditorPage({super.key, this.uuid});

  final String? uuid;

  bool get isNew => uuid == null || uuid == 'new';

  @override
  State<CryptoWalletEditorPage> createState() => _CryptoWalletEditorPageState();
}

class _CryptoWalletEditorPageState extends State<CryptoWalletEditorPage> {
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _privateKey = TextEditingController();
  final _seedPhrase = TextEditingController();
  final _notes = TextEditingController();

  /// Set from the open folder when creating, or kept from the existing wallet.
  String _folder = '';
  CryptoNetwork _network = CryptoNetwork.bitcoin;
  bool _loading = true;
  bool _saving = false;
  CryptoWallet? _existing;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.isNew) {
      final currentFolder = context.read<CryptoBloc>().state.currentGroup;
      if (currentFolder != null && currentFolder.isNotEmpty) {
        _folder = currentFolder;
      }
      setState(() => _loading = false);
      return;
    }
    final result = await sl<CryptoRepository>().getWallet(widget.uuid!);
    result.fold((_) {}, (wallet) {
      if (wallet != null) {
        _existing = wallet;
        _name.text = wallet.name;
        _address.text = wallet.address;
        _privateKey.text = wallet.privateKey;
        _seedPhrase.text = wallet.seedPhrase;
        _notes.text = wallet.notes;
        _folder = wallet.folder;
        _network = wallet.network;
      }
    });
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _privateKey.dispose();
    _seedPhrase.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final folder = _folder.trim();
    final wallet = CryptoWallet(
      uuid: widget.isNew ? const Uuid().v4() : widget.uuid!,
      name: _name.text.trim(),
      network: _network,
      address: _address.text.trim(),
      privateKey: _privateKey.text.trim(),
      seedPhrase: _seedPhrase.text.trim(),
      notes: _notes.text,
      folder: folder,
      revision: _existing?.revision ?? 1,
    );

    setState(() => _saving = true);
    // Await the write before popping so details pages reload fresh data.
    final result = widget.isNew
        ? await sl<CryptoRepository>().createWallet(wallet)
        : await sl<CryptoRepository>().updateWallet(wallet);
    if (!mounted) return;
    result.fold(
      (f) {
        setState(() => _saving = false);
        showMEToast(
          context,
          message: f.getMessage(context),
          kind: METoastKind.error,
        );
      },
      (_) {
        if (folder.isNotEmpty) {
          context.read<CryptoBloc>().add(CryptoFolderCreated(folder));
        }
        unawaited(sl<SyncService>().syncIfConnected());
        context.pop();
      },
    );
  }

  Future<void> _pickNetwork() async {
    final selected = await showMEBottomSheet<CryptoNetwork>(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.s.cryptoNetwork,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < CryptoNetwork.values.length; i++)
                ActionItem(
                  title: CryptoNetwork.values[i].label,
                  subtitle: Text(CryptoNetwork.values[i].symbol),
                  icon: SettingsIcon(
                    Icons.token_outlined,
                    backgroundColor:
                        Theme.of(context).colorScheme.tertiaryContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
                  trailing: _network == CryptoNetwork.values[i]
                      ? Icon(
                          Icons.check_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  itemPosition: ItemPosition.fromIndex(
                    i,
                    CryptoNetwork.values.length,
                  ),
                  onTap: () =>
                      Navigator.pop(context, CryptoNetwork.values[i]),
                ),
            ],
          ),
        );
      },
    );
    if (selected != null) setState(() => _network = selected);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;

    if (_loading) {
      return const Scaffold(
        body: Center(child: MELoadingIndicator()),
      );
    }

    return MESliverScaffold(
      title: widget.isNew ? s.addCryptoWallet : s.editCryptoWallet,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      leadingAppBar: IconButton(
        icon: const Icon(Icons.close_rounded),
        onPressed: () => context.pop(),
      ),
      appBarActions: [
        MEIconButton(
          tooltip: s.save,
          variant: MEButtonVariant.filled,
          size: MEButtonSize.small,
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check_rounded),
        ),
      ],
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              ActionItem(
                title: s.cryptoNetwork,
                subtitle: Text('${_network.label} · ${_network.symbol}'),
                icon: SettingsIcon(
                  Icons.hub_outlined,
                  backgroundColor: scheme.tertiaryContainer,
                  foregroundColor: scheme.onTertiaryContainer,
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                itemPosition: ItemPosition.alone,
                onTap: _pickNetwork,
              ),
              const SizedBox(height: 12),
              METextField(controller: _name, label: s.cryptoWalletName),
              const SizedBox(height: 12),
              METextField(
                controller: _address,
                label: s.walletAddress,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              MEPasswordField(
                controller: _privateKey,
                label: s.privateKey,
              ),
              const SizedBox(height: 12),
              METextField(
                controller: _seedPhrase,
                label: s.seedPhrase,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              METextField(
                controller: _notes,
                label: s.notes,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              MEButton(
                size: MEButtonSize.large,
                onPressed: _saving ? null : _save,
                child: Text(widget.isNew ? s.addCryptoWallet : s.save),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }
}
