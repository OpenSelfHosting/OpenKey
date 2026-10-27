import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';
import 'package:uuid/uuid.dart';

class WalletEditorPage extends StatefulWidget {
  const WalletEditorPage({super.key, this.uuid});

  final String? uuid;

  bool get isNew => uuid == null || uuid == 'new';

  @override
  State<WalletEditorPage> createState() => _WalletEditorPageState();
}

class _WalletEditorPageState extends State<WalletEditorPage> {
  final _name = TextEditingController();
  final _holder = TextEditingController();
  final _number = TextEditingController();
  final _expiry = TextEditingController();
  final _cvc = TextEditingController();
  final _notes = TextEditingController();
  final _cvcFocus = FocusNode();

  /// Set from the open bank when creating, or kept from the existing card.
  String _bank = '';
  bool _loading = true;
  bool _saving = false;
  WalletCard? _existing;

  @override
  void initState() {
    super.initState();
    _number.addListener(() => setState(() {}));
    _holder.addListener(() => setState(() {}));
    _expiry.addListener(() => setState(() {}));
    _cvc.addListener(() => setState(() {}));
    _cvcFocus.addListener(() => setState(() {}));
    _load();
  }

  Future<void> _load() async {
    if (widget.isNew) {
      final group = context.read<WalletBloc>().state.currentGroup;
      if (group != null && group.isNotEmpty) {
        _bank = group;
      }
      if (mounted) setState(() => _loading = false);
      return;
    }
    final result = await sl<WalletRepository>().getCard(widget.uuid!);
    result.fold((_) {}, (card) {
      if (card != null) {
        _existing = card;
        _name.text = card.name;
        _holder.text = card.holder;
        _number.text = card.number;
        _expiry.text = card.expiry;
        _cvc.text = card.cvc;
        _bank = card.bank;
        _notes.text = card.notes;
      }
    });
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _name.dispose();
    _holder.dispose();
    _number.dispose();
    _expiry.dispose();
    _cvc.dispose();
    _notes.dispose();
    _cvcFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final bank = _bank.trim();
    final card = WalletCard(
      uuid: widget.isNew ? const Uuid().v4() : widget.uuid!,
      name: _name.text.trim(),
      holder: _holder.text.trim(),
      number: _number.text.replaceAll(RegExp(r'\s'), ''),
      expiry: _expiry.text.trim(),
      cvc: _cvc.text.trim(),
      brand: CardBrand.detect(_number.text),
      bank: bank,
      notes: _notes.text,
      revision: _existing?.revision ?? 1,
      isSynced: false,
    );

    setState(() => _saving = true);
    // Await the write before popping so details pages reload fresh data.
    final result = widget.isNew
        ? await sl<WalletRepository>().createCard(card)
        : await sl<WalletRepository>().updateCard(card);
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
        if (bank.isNotEmpty) {
          context.read<WalletBloc>().add(WalletBankCreated(bank));
        }
        unawaited(sl<SyncService>().syncIfConnected());
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;

    if (_loading) {
      return const Scaffold(body: Center(child: MELoadingIndicator()));
    }

    return MESliverScaffold(
      title: widget.isNew ? s.addCard : s.editCard,
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
              MECreditCard(
                number: _number.text,
                holder: _holder.text,
                expiry: _expiry.text,
                cvc: _cvc.text,
                bankName: _bank,
                brand: CardBrand.detect(_number.text).name,
                showBackView: _cvcFocus.hasFocus,
                obscureNumber: false,
                obscureCvv: false,
              ),
              const SizedBox(height: 8),
              Text(
                s.tapCardToFlip,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              METextField(controller: _name, label: s.cardName),
              const SizedBox(height: 12),
              METextField(controller: _holder, label: s.cardHolder),
              const SizedBox(height: 12),
              METextField(
                controller: _number,
                label: s.cardNumber,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: METextField(
                      controller: _expiry,
                      label: s.cardExpiry,
                      hintText: context.s.expiryHint,
                      keyboardType: TextInputType.datetime,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MEPasswordField(
                      controller: _cvc,
                      focusNode: _cvcFocus,
                      label: s.cardCvc,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              METextField(controller: _notes, label: s.notes, maxLines: 3),
              const SizedBox(height: 24),
              MEButton(
                size: MEButtonSize.large,
                onPressed: _save,
                child: Text(widget.isNew ? s.addCard : s.save),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }
}
