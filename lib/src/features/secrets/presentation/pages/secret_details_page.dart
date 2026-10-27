import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

class SecretDetailsPage extends StatefulWidget {
  const SecretDetailsPage({super.key, required this.uuid});

  final String uuid;

  @override
  State<SecretDetailsPage> createState() => _SecretDetailsPageState();
}

class _SecretDetailsPageState extends State<SecretDetailsPage> {
  DevSecret? _secret;
  bool _loading = true;
  bool _notFound = false;
  bool _showSecret = false;
  bool _showPassphrase = false;

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
    final result = await sl<SecretsRepository>().getSecret(widget.uuid);
    if (!mounted) return;
    result.fold(
      (_) => setState(() {
        _loading = false;
        _notFound = true;
      }),
      (secret) => setState(() {
        _secret = secret;
        _loading = false;
        _notFound = secret == null;
        _showSecret = false;
        _showPassphrase = false;
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
    await context.push('${AppRoutes.secrets.path}/${widget.uuid}/edit');
    if (mounted) await _load(silent: true);
  }

  Future<void> _moveToDevice() async {
    final secret = _secret;
    if (secret == null) return;
    final device = await MoveSecretDeviceSheet.show(
      context,
      currentDevice: secret.device,
    );
    if (device == null || !mounted) return;
    context.read<SecretsBloc>().add(
      SecretMovedToDevice(uuid: secret.uuid, device: device),
    );
    showMEToast(
      context,
      message: context.s.secretMoved,
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
        title: Text(s.deleteSecret),
        content: Text(s.deleteSecretConfirm),
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
    context.read<SecretsBloc>().add(SecretDeleted(widget.uuid));
    context.pop();
  }

  String _secretLabel(AppLocalizations s, SecretKind kind) {
    return switch (kind) {
      SecretKind.sshKey => s.privateKey,
      SecretKind.apiToken => s.apiToken,
      SecretKind.envSnippet => s.envContent,
      SecretKind.other => s.secretValue,
    };
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_loading) {
      return MESliverScaffold(
        title: s.secrets,
        leadingAppBar: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        slivers: const [
          SliverFillRemaining(child: Center(child: MELoadingIndicator())),
        ],
      );
    }

    if (_notFound || _secret == null) {
      return MESliverScaffold(
        title: s.secrets,
        leadingAppBar: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        slivers: [
          SliverFillRemaining(
            child: MEEmptyState(
              icon: Icons.terminal_rounded,
              title: Text(s.secretNotFound),
              message: Text(s.secretNotFoundMessage),
              action: MEButton.outlined(
                onPressed: () => context.pop(),
                child: Text(s.goBack),
              ),
            ),
          ),
        ],
      );
    }

    final secret = _secret!;
    final secretLabel = _secretLabel(s, secret.kind);
    final items = <Widget>[];

    void addItem({
      required String title,
      required String value,
      required IconData icon,
      Color? bg,
      Color? fg,
      bool sensitive = false,
      required bool revealed,
      VoidCallback? onToggleReveal,
      required bool isFirst,
      required bool isLast,
    }) {
      items.add(
        ActionItem(
          title: title,
          subtitle: Text(
            value.isEmpty
                ? '—'
                : (sensitive && !revealed
                      ? '•' * value.length.clamp(12, 32)
                      : value),
            style: textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              color: scheme.onSurfaceVariant,
            ),
          ),
          maxSubtitleLines: secret.kind == SecretKind.envSnippet ? 12 : 6,
          icon: SettingsIcon(
            icon,
            backgroundColor: bg ?? scheme.primaryContainer,
            foregroundColor: fg ?? scheme.onPrimaryContainer,
          ),
          trailing: value.isEmpty
              ? null
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (sensitive && onToggleReveal != null)
                      MEIconButton(
                        tooltip: revealed ? s.hidePassword : s.showPassword,
                        variant: MEButtonVariant.text,
                        size: MEButtonSize.extraSmall,
                        onPressed: onToggleReveal,
                        icon: Icon(
                          revealed
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    MEIconButton(
                      tooltip: s.copy,
                      variant: MEButtonVariant.text,
                      size: MEButtonSize.extraSmall,
                      onPressed: () => _copy(title, value),
                      icon: const Icon(Icons.copy_rounded),
                    ),
                  ],
                ),
          itemPosition: isFirst && isLast
              ? ItemPosition.alone
              : isFirst
              ? ItemPosition.top
              : isLast
              ? ItemPosition.bottom
              : ItemPosition.center,
          onTap: value.isEmpty ? null : () => _copy(title, value),
        ),
      );
    }

    final rows =
        <
          ({
            String title,
            String value,
            IconData icon,
            Color? bg,
            Color? fg,
            bool sensitive,
            bool revealed,
            VoidCallback? toggle,
          })
        >[];

    if (secret.username.isNotEmpty) {
      rows.add((
        title: s.secretUsername,
        value: secret.username,
        icon: Icons.person_outline_rounded,
        bg: scheme.secondaryContainer,
        fg: scheme.onSecondaryContainer,
        sensitive: false,
        revealed: true,
        toggle: null,
      ));
    }
    if (secret.host.isNotEmpty) {
      rows.add((
        title: secret.kind == SecretKind.apiToken
            ? s.secretEndpoint
            : s.secretHost,
        value: secret.host,
        icon: Icons.link_rounded,
        bg: scheme.tertiaryContainer,
        fg: scheme.onTertiaryContainer,
        sensitive: false,
        revealed: true,
        toggle: null,
      ));
    }
    if (secret.device.trim().isNotEmpty) {
      rows.add((
        title: s.device,
        value: secret.device,
        icon: Icons.computer_rounded,
        bg: scheme.secondaryContainer,
        fg: scheme.onSecondaryContainer,
        sensitive: false,
        revealed: true,
        toggle: null,
      ));
    }
    if (secret.kind == SecretKind.sshKey && secret.publicKey.isNotEmpty) {
      rows.add((
        title: s.publicKey,
        value: secret.publicKey,
        icon: Icons.key_outlined,
        bg: scheme.primaryContainer,
        fg: scheme.onPrimaryContainer,
        sensitive: false,
        revealed: true,
        toggle: null,
      ));
    }
    rows.add((
      title: secretLabel,
      value: secret.secret,
      icon: Icons.lock_rounded,
      bg: scheme.errorContainer,
      fg: scheme.onErrorContainer,
      sensitive: true,
      revealed: _showSecret,
      toggle: () => setState(() => _showSecret = !_showSecret),
    ));
    if (secret.kind == SecretKind.sshKey && secret.passphrase.isNotEmpty) {
      rows.add((
        title: s.passphrase,
        value: secret.passphrase,
        icon: Icons.password_rounded,
        bg: scheme.errorContainer,
        fg: scheme.onErrorContainer,
        sensitive: true,
        revealed: _showPassphrase,
        toggle: () => setState(() => _showPassphrase = !_showPassphrase),
      ));
    }
    if (secret.notes.isNotEmpty) {
      rows.add((
        title: s.notes,
        value: secret.notes,
        icon: Icons.notes_rounded,
        bg: scheme.surfaceContainerHighest,
        fg: scheme.onSurfaceVariant,
        sensitive: false,
        revealed: true,
        toggle: null,
      ));
    }

    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      addItem(
        title: row.title,
        value: row.value,
        icon: row.icon,
        bg: row.bg,
        fg: row.fg,
        sensitive: row.sensitive,
        revealed: row.revealed,
        onToggleReveal: row.toggle,
        isFirst: i == 0,
        isLast: i == rows.length - 1,
      );
    }

    return MESliverScaffold(
      title: secret.displayName,
      extendedAppBar: false,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      leadingAppBar: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => context.pop(),
      ),
      appBarActions: [
        MEIconButton(
          tooltip: s.moveToDevice,
          variant: MEButtonVariant.tonal,
          size: MEButtonSize.small,
          onPressed: _moveToDevice,
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
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                  child: Icon(
                    secret.kind.icon,
                    size: 56,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  secret.displayName,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                MEChip(
                  label: Text(secret.kind.label(context)),
                  selected: true,
                  onPressed: () {},
                ),
                const SizedBox(height: 16),
                MEButton(
                  onPressed: !secret.hasSecret
                      ? null
                      : () => _copy(secretLabel, secret.secret),
                  child: Text(s.copySecret),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              s.secretDetails,
              style: textTheme.titleSmall?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(children: [const SizedBox(height: 8), ...items]),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 20, 4, 32),
            child: Text(
              [
                s.revisionLabel(secret.revision),
                if (secret.isSynced) s.synced else s.pendingSync,
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
