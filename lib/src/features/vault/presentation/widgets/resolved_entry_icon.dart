import 'dart:async';

import 'package:flutter/material.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

/// Resolves [VaultEntry.icon], falling back to a brand / favicon suggestion.
class ResolvedEntryIcon extends StatefulWidget {
  const ResolvedEntryIcon({
    super.key,
    required this.entry,
    this.size = 24,
    this.color,
    this.withSurface = false,
    this.surfaceSize = 40,
    this.surfaceColor,
    this.expressive = false,
  });

  final VaultEntry entry;
  final double size;
  final Color? color;
  final bool withSurface;
  final double surfaceSize;
  final Color? surfaceColor;
  final bool expressive;

  @override
  State<ResolvedEntryIcon> createState() => _ResolvedEntryIconState();
}

class _ResolvedEntryIconState extends State<ResolvedEntryIcon> {
  late String _key;
  static final Set<String> _persisting = {};

  bool get _needsSuggest => EntryIcons.isUnresolved(widget.entry.icon);

  @override
  void initState() {
    super.initState();
    _key = _needsSuggest ? EntryIcons.defaultKey : widget.entry.icon;
    if (_needsSuggest) {
      // Let the list paint first; network/decode runs on background isolates.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _needsSuggest) unawaited(_suggest());
      });
    }
  }

  @override
  void didUpdateWidget(covariant ResolvedEntryIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.uuid != widget.entry.uuid ||
        oldWidget.entry.icon != widget.entry.icon ||
        oldWidget.entry.title != widget.entry.title ||
        oldWidget.entry.urls != widget.entry.urls ||
        oldWidget.entry.username != widget.entry.username ||
        oldWidget.entry.notes != widget.entry.notes ||
        oldWidget.entry.tags != widget.entry.tags ||
        oldWidget.entry.fields != widget.entry.fields) {
      _key = _needsSuggest ? EntryIcons.defaultKey : widget.entry.icon;
      if (_needsSuggest) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _needsSuggest) unawaited(_suggest());
        });
      } else if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _suggest() async {
    final extras = <String>[
      widget.entry.notes,
      ...widget.entry.tags,
      for (final url in widget.entry.urls)
        if (url.startsWith('androidapp://'))
          url.substring('androidapp://'.length),
      for (final field in widget.entry.fields)
        if (field.value.trim().isNotEmpty) field.value,
    ];
    String website = '';
    String? androidApp;
    for (final u in widget.entry.urls) {
      if (u.startsWith('androidapp://')) {
        androidApp ??= u.substring('androidapp://'.length);
      } else if (website.isEmpty) {
        website = u;
      }
    }
    final suggested = await EntryIcons.suggest(
      title: widget.entry.title,
      url: website.isNotEmpty
          ? website
          : (androidApp != null && androidApp.isNotEmpty
              ? 'androidapp://$androidApp'
              : ''),
      username: widget.entry.username,
      extras: extras,
    );
    if (!mounted || !_needsSuggest) return;
    if (suggested != _key) setState(() => _key = suggested);
    final upgrade = EntryIcons.isBrand(suggested) ||
        CustomIcons.isCustom(suggested);
    if (!upgrade) return;
    // Persist website favicons / Android app icons / catalog brands so they
    // stay entry-local (synced inside the encrypted payload).
    if (CustomIcons.isFavicon(suggested)) {
      final source = website.isNotEmpty
          ? website
          : (androidApp != null && androidApp.isNotEmpty
              ? androidApp
              : (FaviconFetcher.looksLikeDomain(widget.entry.title)
                  ? widget.entry.title
                  : ''));
      if (source.isNotEmpty) {
        unawaited(FaviconFetcher.remember(source, suggested));
      }
    }
    unawaited(_persistIcon(suggested));
  }

  Future<void> _persistIcon(String iconKey) async {
    final uuid = widget.entry.uuid;
    if (!_needsSuggest) return;
    if (!_persisting.add(uuid)) return;
    try {
      final result = await sl<UpdateEntryUsecase>()(
        widget.entry.copyWith(icon: iconKey),
      );
      result.fold((_) => _persisting.remove(uuid), (_) {});
    } catch (_) {
      _persisting.remove(uuid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = widget.withSurface && !VaultIconSurface.needsBackdrop(_key)
        ? widget.surfaceSize * 0.72
        : widget.size;
    final icon = EntryIcon(
      iconKey: _key,
      size: iconSize,
      color: widget.color,
    );
    if (!widget.withSurface) return icon;
    return VaultIconSurface(
      iconKey: _key,
      size: widget.surfaceSize,
      backgroundColor: widget.surfaceColor,
      expressive: widget.expressive,
      child: icon,
    );
  }
}
