import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openkey_app/src/src.dart';
import 'package:video_player/video_player.dart';

/// Full-screen preview for a decrypted vault attachment.
class AttachmentPreviewPage extends StatefulWidget {
  const AttachmentPreviewPage({
    super.key,
    required this.name,
    required this.bytes,
    this.onSave,
    this.onOpen,
  });

  final String name;
  final Uint8List bytes;
  final Future<bool> Function(String name, Uint8List bytes)? onSave;
  final Future<bool> Function(String name, Uint8List bytes)? onOpen;

  static Future<void> show(
    BuildContext context, {
    required String name,
    required Uint8List bytes,
  }) {
    return Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AttachmentPreviewPage(name: name, bytes: bytes),
      ),
    );
  }

  @override
  State<AttachmentPreviewPage> createState() => _AttachmentPreviewPageState();
}

Future<void> _deleteQuietly(File file) async {
  try {
    await file.delete();
  } catch (_) {}
}

class _AttachmentPreviewPageState extends State<AttachmentPreviewPage> {
  var _busy = false;
  File? _tempFile;
  VideoPlayerController? _player;
  var _playerReady = false;
  var _playerFailed = false;

  AttachmentKind get _kind => attachmentKindFor(widget.name);

  bool get _useInAppPlayer =>
      attachmentInAppVideoSupported &&
      (_kind == AttachmentKind.video || _kind == AttachmentKind.audio);

  @override
  void initState() {
    super.initState();
    if (_useInAppPlayer) {
      _initPlayer();
    }
  }

  @override
  void dispose() {
    final player = _player;
    _player = null;
    player?.dispose();
    final temp = _tempFile;
    _tempFile = null;
    if (temp != null) {
      unawaited(_deleteQuietly(temp));
    }
    super.dispose();
  }

  Future<void> _initPlayer() async {
    try {
      final file = await AttachmentActions.materializeTemp(
        widget.name,
        widget.bytes,
      );
      if (!mounted) {
        await file.delete();
        return;
      }
      _tempFile = file;
      final controller = VideoPlayerController.file(file);
      _player = controller;
      await controller.initialize().timeout(const Duration(seconds: 20));
      if (!mounted) return;
      await controller.setLooping(false);
      await controller.play();
      setState(() => _playerReady = true);
    } catch (_) {
      if (mounted) setState(() => _playerFailed = true);
    }
  }

  Future<void> _download() async {
    if (_busy) return;
    setState(() => _busy = true);
    final save =
        widget.onSave ??
        (name, bytes) =>
            AttachmentActions.save(context: context, name: name, bytes: bytes);
    final saved = await save(widget.name, widget.bytes);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!saved) return;
    showMEToast(
      context,
      message: context.s.attachmentSaved(widget.name),
      kind: METoastKind.success,
    );
  }

  Future<void> _open() async {
    if (_busy) return;
    setState(() => _busy = true);
    final open =
        widget.onOpen ??
        (name, bytes) => AttachmentActions.open(name: name, bytes: bytes);
    final ok = await open(widget.name, widget.bytes);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) return;
    showMEToast(
      context,
      message: context.s.couldNotOpenAttachment,
      kind: METoastKind.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    final media =
        _kind == AttachmentKind.image || _kind == AttachmentKind.video;
    final foreground = media ? Colors.white : scheme.onSurface;

    return Scaffold(
      backgroundColor: media ? Colors.black : scheme.surface,
      appBar: AppBar(
        backgroundColor: media ? Colors.black : null,
        foregroundColor: foreground,
        title: Text(widget.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: foreground),),
        actions: [
          MEIconButton(
            tooltip: s.downloadAttachment,
            variant: MEButtonVariant.text,
            size: MEButtonSize.small,
            onPressed: _busy ? null : _download,
            icon: Icon(Icons.download_outlined, color: foreground),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: _body(context)),
          if (_busy)
            const ColoredBox(
              color: Color(0x66000000),
              child: Center(child: MELoadingIndicator(size: 56)),
            ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    switch (_kind) {
      case AttachmentKind.image:
        return _ImagePreview(
          name: widget.name,
          bytes: widget.bytes,
          onOpen: _open,
          onDownload: _download,
        );
      case AttachmentKind.video:
      case AttachmentKind.audio:
        if (_useInAppPlayer && !_playerFailed) {
          return _InAppAvPreview(
            kind: _kind,
            name: widget.name,
            controller: _player,
            ready: _playerReady,
          );
        }
        return _SystemPlayPreview(
          kind: _kind,
          name: widget.name,
          sizeLabel: formatAttachmentSize(widget.bytes.length),
          onPlay: _open,
          onDownload: _download,
        );
      case AttachmentKind.text:
        return _TextPreview(bytes: widget.bytes);
      case AttachmentKind.other:
        return _FilePreview(
          name: widget.name,
          sizeLabel: formatAttachmentSize(widget.bytes.length),
          onOpen: _open,
          onDownload: _download,
        );
    }
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({
    required this.name,
    required this.bytes,
    required this.onOpen,
    required this.onDownload,
  });

  final String name;
  final Uint8List bytes;
  final VoidCallback onOpen;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return InteractiveViewer(
          minScale: 0.4,
          maxScale: 6,
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Image.memory(
              bytes,
              fit: BoxFit.contain,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) {
                return _FilePreview(
                  name: name,
                  sizeLabel: formatAttachmentSize(bytes.length),
                  onOpen: onOpen,
                  onDownload: onDownload,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _TextPreview extends StatelessWidget {
  const _TextPreview({required this.bytes});

  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    final text = _decodeText(bytes);
    if (text == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            context.s.attachmentNotPreviewable,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Scrollbar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: SelectableText(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontFamily: 'monospace',
            height: 1.45,
          ),
        ),
      ),
    );
  }
}

class _FilePreview extends StatelessWidget {
  const _FilePreview({
    required this.name,
    required this.sizeLabel,
    required this.onOpen,
    required this.onDownload,
  });

  final String name;
  final String sizeLabel;
  final VoidCallback onOpen;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insert_drive_file_outlined,
            size: 72,
            color: scheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            sizeLabel,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Text(
            s.attachmentNotPreviewable,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              MEButton.tonal(
                onPressed: onOpen,
                icon: const Icon(Icons.open_in_new_rounded),
                child: Text(s.openAttachment),
              ),
              MEButton(
                onPressed: onDownload,
                icon: const Icon(Icons.download_outlined),
                child: Text(s.downloadAttachment),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SystemPlayPreview extends StatelessWidget {
  const _SystemPlayPreview({
    required this.kind,
    required this.name,
    required this.sizeLabel,
    required this.onPlay,
    required this.onDownload,
  });

  final AttachmentKind kind;
  final String name;
  final String sizeLabel;
  final VoidCallback onPlay;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    final isVideo = kind == AttachmentKind.video;
    final onMedia = isVideo ? Colors.white : scheme.onSurface;
    final muted = isVideo
        ? Colors.white.withValues(alpha: 0.72)
        : scheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isVideo ? Icons.videocam_rounded : Icons.audiotrack_rounded,
            size: 88,
            color: isVideo ? Colors.white : scheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            name,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: onMedia),
          ),
          const SizedBox(height: 4),
          Text(
            sizeLabel,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: muted),
          ),
          const SizedBox(height: 28),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              MEButton(
                onPressed: onPlay,
                icon: const Icon(Icons.play_arrow_rounded),
                child: Text(isVideo ? s.playVideo : s.openAttachment),
              ),
              MEButton.tonal(
                onPressed: onDownload,
                icon: Icon(
                  Icons.download_outlined,
                  color: isVideo ? scheme.onSecondaryContainer : null,
                ),
                child: Text(s.downloadAttachment),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InAppAvPreview extends StatelessWidget {
  const _InAppAvPreview({
    required this.kind,
    required this.name,
    required this.controller,
    required this.ready,
  });

  final AttachmentKind kind;
  final String name;
  final VideoPlayerController? controller;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    if (!ready || controller == null || !controller!.value.isInitialized) {
      return const Center(child: MELoadingIndicator(size: 56));
    }
    final player = controller!;
    if (kind == AttachmentKind.audio) {
      return _AudioControls(name: name, controller: player);
    }
    return GestureDetector(
      onTap: () {
        if (player.value.isPlaying) {
          player.pause();
        } else {
          player.play();
        }
      },
      child: Center(
        child: AspectRatio(
          aspectRatio: player.value.aspectRatio == 0
              ? 16 / 9
              : player.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(player),
              AnimatedBuilder(
                animation: player,
                builder: (context, _) {
                  if (player.value.isPlaying) return const SizedBox.shrink();
                  return const Icon(
                    Icons.play_circle_fill_rounded,
                    size: 72,
                    color: Colors.white,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AudioControls extends StatelessWidget {
  const _AudioControls({required this.name, required this.controller});

  final String name;
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final playing = controller.value.isPlaying;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.audiotrack_rounded, size: 88, color: scheme.primary),
              const SizedBox(height: 16),
              Text(
                name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              MEIconButton(
                tooltip: playing
                    ? context.s.pausePlayback
                    : context.s.playVideo,
                variant: MEButtonVariant.filled,
                size: MEButtonSize.large,
                onPressed: () {
                  if (playing) {
                    controller.pause();
                  } else {
                    controller.play();
                  }
                },
                icon: Icon(
                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

String? _decodeText(Uint8List bytes) {
  final probe = bytes.length > 4096 ? bytes.sublist(0, 4096) : bytes;
  if (probe.contains(0)) return null;
  const limit = 512 * 1024;
  if (bytes.length <= limit) {
    return utf8.decode(bytes, allowMalformed: true);
  }
  return '${utf8.decode(bytes.sublist(0, limit), allowMalformed: true)}\n…';
}
