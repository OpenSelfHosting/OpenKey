import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';
import 'package:video_player/video_player.dart';

/// Rich attachment row with lazy content preview (thumbnail or text snippet).
class VaultAttachmentCard extends StatelessWidget {
  const VaultAttachmentCard({
    super.key,
    required this.meta,
    this.onTap,
    this.enabled = true,
    this.trailing,
    this.loadPreview = true,
  });

  final AttachmentMeta meta;
  final VoidCallback? onTap;
  final bool enabled;
  final Widget? trailing;

  /// When false, skips decrypting bytes for inline previews.
  final bool loadPreview;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final kind = attachmentKindFor(meta.name);
    final ext = attachmentExtension(meta.name);

    return Material(
      color: scheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MECorners.large),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AttachmentPreviewBox(
                meta: meta,
                kind: kind,
                loadPreview: loadPreview,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meta.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _KindChip(kind: kind, extension: ext),
                        Text(
                          formatAttachmentSize(meta.size),
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 4), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

class _KindChip extends StatelessWidget {
  const _KindChip({required this.kind, required this.extension});

  final AttachmentKind kind;
  final String extension;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (Color bg, Color fg, String label) = switch (kind) {
      AttachmentKind.image => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
        extension.isEmpty ? 'IMG' : extension.toUpperCase(),
      ),
      AttachmentKind.video => (
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
        extension.isEmpty ? 'VID' : extension.toUpperCase(),
      ),
      AttachmentKind.audio => (
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
        extension.isEmpty ? 'AUD' : extension.toUpperCase(),
      ),
      AttachmentKind.text => (
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
        extension.isEmpty ? 'TXT' : extension.toUpperCase(),
      ),
      AttachmentKind.other => (
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
        extension.isEmpty ? 'FILE' : extension.toUpperCase(),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(MECorners.small),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _AttachmentPreviewBox extends StatefulWidget {
  const _AttachmentPreviewBox({
    required this.meta,
    required this.kind,
    required this.loadPreview,
  });

  final AttachmentMeta meta;
  final AttachmentKind kind;
  final bool loadPreview;

  @override
  State<_AttachmentPreviewBox> createState() => _AttachmentPreviewBoxState();
}

class _AttachmentPreviewBoxState extends State<_AttachmentPreviewBox> {
  Uint8List? _bytes;
  var _loading = false;
  var _failed = false;
  VideoPlayerController? _videoController;
  File? _videoTemp;

  bool get _loadsPreviewBytes =>
      widget.kind == AttachmentKind.image ||
      widget.kind == AttachmentKind.text ||
      (widget.kind == AttachmentKind.video && attachmentInAppVideoSupported);

  @override
  void initState() {
    super.initState();
    if (widget.loadPreview && _loadsPreviewBytes) {
      _load();
    }
  }

  @override
  void didUpdateWidget(covariant _AttachmentPreviewBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.meta.id != widget.meta.id) {
      _disposeVideo();
      _bytes = null;
      _failed = false;
      if (widget.loadPreview && _loadsPreviewBytes) {
        _load();
      }
    }
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  void _disposeVideo() {
    final player = _videoController;
    _videoController = null;
    player?.dispose();
    final temp = _videoTemp;
    _videoTemp = null;
    if (temp != null) {
      unawaited(_deleteTempFile(temp));
    }
  }

  Future<void> _deleteTempFile(File file) async {
    try {
      await file.delete();
    } catch (_) {}
  }

  Future<void> _load() async {
    if (_loading || (_bytes != null && _videoController != null)) return;
    setState(() {
      _loading = true;
      _failed = false;
    });
    final result = await sl<AttachmentService>().readAttachment(widget.meta);
    if (!mounted) return;
    await result.fold(
      (_) async {
        if (mounted) {
          setState(() {
            _loading = false;
            _failed = true;
          });
        }
      },
      (bytes) async {
        if (widget.kind == AttachmentKind.video &&
            attachmentInAppVideoSupported) {
          await _prepareVideoFrame(bytes);
        } else if (mounted) {
          setState(() {
            _bytes = bytes;
            _loading = false;
          });
        }
      },
    );
  }

  Future<void> _prepareVideoFrame(Uint8List bytes) async {
    try {
      final file = await AttachmentActions.materializeTemp(
        widget.meta.name,
        bytes,
      );
      final controller = VideoPlayerController.file(file);
      _videoTemp = file;
      _videoController = controller;
      await controller.initialize().timeout(const Duration(seconds: 12));
      await controller.setVolume(0);
      await controller.pause();
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (_) {
      _disposeVideo();
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const size = 72.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(MECorners.medium),
      child: SizedBox(
        width: size,
        height: size,
        child: _buildContent(context, scheme),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme scheme) {
    if (_loading) {
      return ColoredBox(
        color: scheme.surfaceContainerHighest,
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final player = _videoController;
    if (player != null && player.value.isInitialized) {
      return Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: player.value.size.width,
              height: player.value.size.height,
              child: VideoPlayer(player),
            ),
          ),
          Container(
            color: Colors.black.withValues(alpha: 0.25),
            child: const Center(
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      );
    }

    if (_bytes != null && !_failed) {
      if (widget.kind == AttachmentKind.image) {
        return Image.memory(
          _bytes!,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) => _iconFallback(scheme),
        );
      }
      if (widget.kind == AttachmentKind.text) {
        final snippet = attachmentTextPreview(_bytes!, maxChars: 120);
        if (snippet != null) {
          return ColoredBox(
            color: scheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Text(
                snippet,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontFamily: 'monospace',
                  height: 1.25,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }
      }
    }

    return _iconFallback(scheme);
  }

  Widget _iconFallback(ColorScheme scheme) {
    final icon = attachmentIconFor(widget.meta.name);
    final isVideo = widget.kind == AttachmentKind.video;
    return ColoredBox(
      color: isVideo ? scheme.tertiaryContainer : scheme.primaryContainer,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            icon,
            size: 30,
            color: isVideo
                ? scheme.onTertiaryContainer
                : scheme.onPrimaryContainer,
          ),
          if (isVideo)
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}
