import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

/// Read-only password entry details, built with Material 3 Expressive widgets.
class PasswordDetailsPage extends StatefulWidget {
  const PasswordDetailsPage({super.key, required this.uuid});

  final String uuid;

  @override
  State<PasswordDetailsPage> createState() => _PasswordDetailsPageState();
}

class _PasswordDetailsPageState extends State<PasswordDetailsPage> {
  VaultEntry? _entry;
  bool _loading = true;
  bool _notFound = false;
  bool _passwordVisible = false;
  bool _attachmentBusy = false;
  String? _totpCode;
  double _totpProgress = 0;
  Timer? _totpTimer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _totpTimer?.cancel();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _notFound = false;
      });
    }
    final result = await sl<GetEntryUsecase>()(widget.uuid);
    if (!mounted) return;
    result.fold(
      (_) => setState(() {
        _loading = false;
        _notFound = true;
      }),
      (entry) {
        if (entry == null) {
          setState(() {
            _loading = false;
            _notFound = true;
          });
          return;
        }
        setState(() {
          _entry = entry;
          _loading = false;
          _passwordVisible = false;
        });
        _startTotpTicker(entry.totp);
      },
    );
  }

  void _startTotpTicker(TotpConfig? config) {
    _totpTimer?.cancel();
    _totpCode = null;
    _totpProgress = 0;
    if (config == null || config.secret.isEmpty) return;

    void tick() {
      final period = config.period <= 0 ? 30 : config.period;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final remaining = period - (now % period);
      setState(() {
        _totpCode = sl<TotpService>().generate(config);
        _totpProgress = remaining / period;
      });
    }

    tick();
    _totpTimer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
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
    await context.push('${AppRoutes.vault.path}/entry/${widget.uuid}/edit');
    if (mounted) await _load(silent: true);
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
        title: Text(s.deleteEntry),
        content: Text(s.deleteEntryConfirm),
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
    context.read<EntryBloc>().add(EntryDeleted(widget.uuid));
    context.pop();
  }

  Future<void> _previewAttachment(AttachmentMeta meta) async {
    if (_attachmentBusy) return;
    setState(() => _attachmentBusy = true);
    await AttachmentActions.previewInApp(context, meta);
    if (mounted) setState(() => _attachmentBusy = false);
  }

  Future<void> _downloadAttachment(AttachmentMeta meta) async {
    if (_attachmentBusy) return;
    setState(() => _attachmentBusy = true);
    await AttachmentActions.downloadToDevice(context, meta);
    if (mounted) setState(() => _attachmentBusy = false);
  }

  List<Widget> _extraFieldTiles(
    List<EntryExtraField> fields,
    AppLocalizations s,
    ColorScheme scheme,
    TextTheme textTheme,
  ) {
    final extras = fields.where((f) => !f.isEmpty).toList(growable: false);
    return [
      for (var i = 0; i < extras.length; i++)
        () {
          final extra = extras[i];
          final field = EntryEditorField.fromStorageKey(extra.type);
          final label = field?.label(s) ?? extra.type;
          final sensitive = field?.isSensitive ?? false;
          return ActionItem(
            title: label,
            subtitle: Text(
              sensitive ? '•' * extra.value.length.clamp(6, 20) : extra.value,
              style: textTheme.bodyMedium?.copyWith(
                fontFamily: sensitive ? 'monospace' : null,
                color: scheme.onSurfaceVariant,
              ),
            ),
            maxSubtitleLines: 4,
            icon: SettingsIcon(
              field?.icon ?? Icons.notes_rounded,
              backgroundColor: scheme.secondaryContainer,
              foregroundColor: scheme.onSecondaryContainer,
            ),
            trailing: MEIconButton(
              tooltip: s.copy,
              variant: MEButtonVariant.text,
              size: MEButtonSize.extraSmall,
              onPressed: () => _copy(label, extra.value),
              icon: const Icon(Icons.copy_rounded),
            ),
            itemPosition: extras.length == 1
                ? ItemPosition.alone
                : i == 0
                ? ItemPosition.top
                : i == extras.length - 1
                ? ItemPosition.bottom
                : ItemPosition.center,
            onTap: () => _copy(label, extra.value),
          );
        }(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_loading) {
      return MESliverScaffold(
        title: s.passwordDetails,
        leadingAppBar: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 16),
              child: Column(
                children: [
                  const MESkeleton.circle(size: 136),
                  const SizedBox(height: 16),
                  const MESkeleton.line(width: 180, height: 22),
                  const SizedBox(height: 10),
                  const MESkeleton.line(width: 120, height: 14),
                  const SizedBox(height: 20),
                  Row(
                    children: const [
                      Expanded(child: MESkeleton.box(height: 48)),
                      SizedBox(width: 12),
                      Expanded(child: MESkeleton.box(height: 48)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const VaultEntrySkeletonList(count: 3),
        ],
      );
    }

    if (_notFound || _entry == null) {
      return MESliverScaffold(
        title: s.passwordDetails,
        leadingAppBar: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        slivers: [
          SliverFillRemaining(
            child: MEEmptyState(
              icon: Icons.lock_outline_rounded,
              title: Text(s.entryNotFound),
              message: Text(s.entryNotFoundMessage),
              action: MEButton.outlined(
                onPressed: () => context.pop(),
                child: Text(s.goBack),
              ),
            ),
          ),
        ],
      );
    }

    final entry = _entry!;
    final title = entry.title.isEmpty ? s.untitled : entry.title;
    final passwordDisplay = _passwordVisible
        ? entry.password
        : '•' * entry.password.length.clamp(8, 24);
    final hasTotp = entry.totp != null && !entry.totp!.isEmpty;
    final website = entry.urls.isEmpty ? '' : entry.urls.first;

    return MESliverScaffold(
      extendedAppBar: false,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      leadingAppBar: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => context.pop(),
      ),
      appBarActions: [
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
        // Hero
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Column(
              children: [
                ResolvedEntryIcon(
                  entry: entry,
                  size: 72,
                  color: scheme.onPrimaryContainer,
                  withSurface: true,
                  surfaceSize: 170,
                  surfaceColor: scheme.primaryContainer,
                  expressive: true,
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                if (entry.username.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    entry.username,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: MEButton.tonal(
                        onPressed: entry.username.isEmpty
                            ? null
                            : () => _copy(s.username, entry.username),
                        child: Text(s.copyUsername),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MEButton(
                        onPressed: entry.password.isEmpty
                            ? null
                            : () => _copy(s.password, entry.password),
                        child: Text(s.copyPassword),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Credentials
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SectionLabel(title: s.credentials),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              ActionItem(
                title: s.username,
                subtitle: Text(
                  entry.username.isEmpty ? '—' : entry.username,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                icon: SettingsIcon(
                  Icons.person_outline_rounded,
                  backgroundColor: scheme.secondaryContainer,
                  foregroundColor: scheme.onSecondaryContainer,
                ),
                trailing: entry.username.isEmpty
                    ? null
                    : MEIconButton(
                        tooltip: s.copyUsername,
                        variant: MEButtonVariant.text,
                        size: MEButtonSize.extraSmall,
                        onPressed: () => _copy(s.username, entry.username),
                        icon: const Icon(Icons.copy_rounded),
                      ),
                itemPosition: ItemPosition.top,
                onTap: entry.username.isEmpty
                    ? null
                    : () => _copy(s.username, entry.username),
              ),
              ActionItem(
                title: s.password,
                subtitle: Text(
                  entry.password.isEmpty ? '—' : passwordDisplay,
                  style: textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    letterSpacing: _passwordVisible ? 0.6 : 2,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                maxSubtitleLines: 3,
                icon: SettingsIcon(
                  Icons.lock_outline_rounded,
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MEIconButton(
                      tooltip: _passwordVisible
                          ? s.hidePassword
                          : s.showPassword,
                      variant: MEButtonVariant.text,
                      size: MEButtonSize.extraSmall,
                      onPressed: entry.password.isEmpty
                          ? null
                          : () => setState(
                              () => _passwordVisible = !_passwordVisible,
                            ),
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                    if (entry.password.isNotEmpty)
                      MEIconButton(
                        tooltip: s.copyPassword,
                        variant: MEButtonVariant.text,
                        size: MEButtonSize.extraSmall,
                        onPressed: () => _copy(s.password, entry.password),
                        icon: const Icon(Icons.copy_rounded),
                      ),
                  ],
                ),
                itemPosition: website.isEmpty && entry.notes.isEmpty
                    ? ItemPosition.bottom
                    : ItemPosition.center,
                onTap: entry.password.isEmpty
                    ? null
                    : () => _copy(s.password, entry.password),
              ),
              if (website.isNotEmpty)
                ActionItem(
                  title: s.website,
                  subtitle: Text(
                    website,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  maxSubtitleLines: 2,
                  icon: SettingsIcon(
                    Icons.language_rounded,
                    backgroundColor: scheme.tertiaryContainer,
                    foregroundColor: scheme.onTertiaryContainer,
                  ),
                  trailing: MEIconButton(
                    tooltip: s.copy,
                    variant: MEButtonVariant.text,
                    size: MEButtonSize.extraSmall,
                    onPressed: () => _copy(s.website, website),
                    icon: const Icon(Icons.copy_rounded),
                  ),
                  itemPosition: entry.notes.isEmpty
                      ? ItemPosition.bottom
                      : ItemPosition.center,
                  onTap: () => _copy(s.website, website),
                ),
              if (entry.notes.isNotEmpty)
                ActionItem(
                  title: s.notes,
                  subtitle: Text(
                    entry.notes,
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
                  onTap: () => _copy(s.notes, entry.notes),
                ),
            ],
          ),
        ),

        if (entry.fields.any((f) => !f.isEmpty)) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SectionLabel(title: s.additionalFields),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                for (final entryField in _extraFieldTiles(
                  entry.fields,
                  s,
                  scheme,
                  textTheme,
                ))
                  entryField,
              ],
            ),
          ),
        ],

        // Authenticator
        if (hasTotp) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SectionLabel(title: s.authenticator),
            ),
          ),
          SliverToBoxAdapter(
            child: Material(
              color: scheme.tertiaryContainer.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: _totpCode == null
                    ? null
                    : () => _copy(s.authenticator, _totpCode!),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 12, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _totpCode ?? '------',
                              style: textTheme.headlineMedium?.copyWith(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w700,
                                letterSpacing: 4,
                                color: scheme.onTertiaryContainer,
                              ),
                            ),
                          ),
                          MEIconButton(
                            tooltip: s.copy,
                            variant: MEButtonVariant.tonal,
                            size: MEButtonSize.small,
                            onPressed: _totpCode == null
                                ? null
                                : () => _copy(s.authenticator, _totpCode!),
                            icon: const Icon(Icons.copy_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      MELinearProgressIndicator(value: _totpProgress),
                      const SizedBox(height: 8),
                      Text(
                        s.tapToCopy,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onTertiaryContainer.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],

        // Passkey
        if (entry.passkey != null) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SectionLabel(title: s.passkey),
            ),
          ),
          SliverToBoxAdapter(
            child: ActionItem(
              title: entry.passkey!.rpId,
              subtitle: Text(
                entry.passkey!.userName ?? entry.passkey!.credentialId,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              maxSubtitleLines: 2,
              icon: SettingsIcon(
                Icons.fingerprint_rounded,
                backgroundColor: scheme.tertiaryContainer,
                foregroundColor: scheme.onTertiaryContainer,
              ),
              itemPosition: ItemPosition.alone,
              onTap: () => _copy(
                s.passkey,
                entry.passkey!.userHandle ?? entry.passkey!.credentialId,
              ),
            ),
          ),
        ],

        // Attachments
        if (entry.attachments.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SectionLabel(title: s.attachments),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                for (final a in entry.attachments)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: VaultAttachmentCard(
                      key: ValueKey('attachment-${a.id}'),
                      meta: a,
                      enabled: !_attachmentBusy,
                      onTap: () => _previewAttachment(a),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MEIconButton(
                            tooltip: s.previewAttachment,
                            variant: MEButtonVariant.text,
                            size: MEButtonSize.extraSmall,
                            onPressed: _attachmentBusy
                                ? null
                                : () => _previewAttachment(a),
                            icon: const Icon(Icons.visibility_outlined),
                          ),
                          MEIconButton(
                            tooltip: s.downloadAttachment,
                            variant: MEButtonVariant.text,
                            size: MEButtonSize.extraSmall,
                            onPressed: _attachmentBusy
                                ? null
                                : () => _downloadAttachment(a),
                            icon: const Icon(Icons.download_outlined),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],

        // Meta
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 24, 4, 32),
            child: Row(
              children: [
                Icon(
                  entry.isSynced
                      ? Icons.cloud_done_outlined
                      : Icons.cloud_upload_outlined,
                  size: 16,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    [
                      s.revisionLabel(entry.revision),
                      if (entry.isSynced) s.synced else s.pendingSync,
                    ].join(' · '),
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
