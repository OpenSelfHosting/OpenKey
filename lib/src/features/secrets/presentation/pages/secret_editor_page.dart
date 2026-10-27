import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';
import 'package:uuid/uuid.dart';

class SecretEditorPage extends StatefulWidget {
  const SecretEditorPage({super.key, this.uuid});

  final String? uuid;

  bool get isNew => uuid == null || uuid == 'new';

  @override
  State<SecretEditorPage> createState() => _SecretEditorPageState();
}

class _SecretEditorPageState extends State<SecretEditorPage> {
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _host = TextEditingController();
  final _publicKey = TextEditingController();
  final _secret = TextEditingController();
  final _passphrase = TextEditingController();
  final _notes = TextEditingController();

  /// Set from the open device when creating, or kept from the existing secret.
  String _device = '';
  SecretKind _kind = SecretKind.apiToken;
  bool _loading = true;
  bool _saving = false;
  DevSecret? _existing;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.isNew) {
      final currentDevice = context.read<SecretsBloc>().state.currentGroup;
      if (currentDevice != null && currentDevice.isNotEmpty) {
        _device = currentDevice;
      }
      setState(() => _loading = false);
      return;
    }
    final result = await sl<SecretsRepository>().getSecret(widget.uuid!);
    result.fold((_) {}, (secret) {
      if (secret != null) {
        _existing = secret;
        _name.text = secret.name;
        _username.text = secret.username;
        _host.text = secret.host;
        _publicKey.text = secret.publicKey;
        _secret.text = secret.secret;
        _passphrase.text = secret.passphrase;
        _notes.text = secret.notes;
        _device = secret.device;
        _kind = secret.kind;
      }
    });
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _host.dispose();
    _publicKey.dispose();
    _secret.dispose();
    _passphrase.dispose();
    _notes.dispose();
    super.dispose();
  }

  String get _secretFieldLabel {
    final s = context.s;
    return switch (_kind) {
      SecretKind.sshKey => s.privateKey,
      SecretKind.apiToken => s.apiToken,
      SecretKind.envSnippet => s.envContent,
      SecretKind.other => s.secretValue,
    };
  }

  Future<void> _save() async {
    if (_saving) return;
    final device = _device.trim();
    final secret = DevSecret(
      uuid: widget.isNew ? const Uuid().v4() : widget.uuid!,
      name: _name.text.trim(),
      kind: _kind,
      username: _username.text.trim(),
      host: _host.text.trim(),
      publicKey: _publicKey.text.trim(),
      secret: _secret.text.trim(),
      passphrase: _passphrase.text.trim(),
      notes: _notes.text,
      device: device,
      revision: _existing?.revision ?? 1,
    );

    setState(() => _saving = true);
    final result = widget.isNew
        ? await sl<SecretsRepository>().createSecret(secret)
        : await sl<SecretsRepository>().updateSecret(secret);
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
        if (device.isNotEmpty && mounted) {
          context.read<SecretsBloc>().add(SecretDeviceCreated(device));
        }
        unawaited(sl<SyncService>().syncIfConnected());
        context.pop();
      },
    );
  }

  Future<void> _pickKind() async {
    final selected = await showMEBottomSheet<SecretKind>(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.s.secretKind,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < SecretKind.values.length; i++)
                ActionItem(
                  title: SecretKind.values[i].label(context),
                  icon: SettingsIcon(
                    SecretKind.values[i].icon,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  trailing: _kind == SecretKind.values[i]
                      ? Icon(
                          Icons.check_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  itemPosition: ItemPosition.fromIndex(
                    i,
                    SecretKind.values.length,
                  ),
                  onTap: () =>
                      Navigator.pop(context, SecretKind.values[i]),
                ),
            ],
          ),
        );
      },
    );
    if (selected != null) setState(() => _kind = selected);
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
      title: widget.isNew ? s.addSecret : s.editSecret,
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
                title: s.secretKind,
                subtitle: Text(_kind.label(context)),
                icon: SettingsIcon(
                  _kind.icon,
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                itemPosition: ItemPosition.alone,
                onTap: _pickKind,
              ),
              const SizedBox(height: 12),
              METextField(controller: _name, label: s.secretName),
              const SizedBox(height: 12),
              METextField(
                controller: _username,
                label: s.secretUsername,
              ),
              const SizedBox(height: 12),
              METextField(
                controller: _host,
                label: _kind == SecretKind.apiToken
                    ? s.secretEndpoint
                    : s.secretHost,
              ),
              if (_kind == SecretKind.sshKey) ...[
                const SizedBox(height: 12),
                METextField(
                  controller: _publicKey,
                  label: s.publicKey,
                  maxLines: 4,
                ),
              ],
              const SizedBox(height: 12),
              if (_kind == SecretKind.envSnippet)
                METextField(
                  controller: _secret,
                  label: _secretFieldLabel,
                  maxLines: 8,
                )
              else
                MEPasswordField(
                  controller: _secret,
                  label: _secretFieldLabel,
                ),
              if (_kind == SecretKind.sshKey) ...[
                const SizedBox(height: 12),
                MEPasswordField(
                  controller: _passphrase,
                  label: s.passphrase,
                ),
              ],
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
                child: Text(widget.isNew ? s.addSecret : s.save),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }
}
