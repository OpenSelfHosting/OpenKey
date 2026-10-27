import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:openkey_app/src/src.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

/// Full-screen image editor (crop / rotate / filters) for custom icons.
class IconImageEditorPage extends StatelessWidget {
  const IconImageEditorPage({
    super.key,
    required this.bytes,
    this.heroTag = 'openkey-icon-editor',
  });

  final Uint8List bytes;
  final String heroTag;

  /// Opens the editor and returns edited image bytes, or `null` if cancelled.
  static Future<Uint8List?> edit(
    BuildContext context,
    Uint8List bytes, {
    String heroTag = 'openkey-icon-editor',
  }) {
    return Navigator.of(context, rootNavigator: true).push<Uint8List>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => IconImageEditorPage(bytes: bytes, heroTag: heroTag),
      ),
    );
  }

  ProImageEditorConfigs _configs(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);

    return ProImageEditorConfigs(
      theme: theme,
      heroTag: heroTag,
      designMode: ImageEditorDesignMode.material,
      mainEditor: const MainEditorConfigs(
        tools: [
          SubEditorMode.cropRotate,
          SubEditorMode.filter,
          SubEditorMode.blur,
        ],
      ),
      cropRotateEditor: const CropRotateEditorConfigs(
        initAspectRatio: 1,
        desktopCornerDragArea: 28,
        mobileCornerDragArea: 48,
        aspectRatios: [
          AspectRatioItem(text: 'Free', value: -1),
          AspectRatioItem(text: 'Original', value: 0),
          AspectRatioItem(text: '1:1', value: 1),
        ],
      ),
      i18n: I18n(
        cancel: s.cancel,
        done: s.done,
        remove: s.delete,
        redo: s.redo,
        undo: s.undo,
        importStateHistoryMsg: s.preparingImage,
        doneLoadingMsg: s.preparingImage,
        various: I18nVarious(
          closeEditorWarningCancelBtn: s.cancel,
          closeEditorWarningConfirmBtn: s.discard,
          closeEditorWarningMessage: s.discardChangesMessage,
          closeEditorWarningTitle: s.discardChanges,
          loadingDialogMsg: s.preparingImage,
        ),
        cropRotateEditor: I18nCropRotateEditor(
          cancel: s.cancel,
          done: s.done,
          reset: s.reset,
          ratio: s.ratio,
          rotate: s.rotate,
          flip: s.flip,
          undo: s.undo,
          redo: s.redo,
          back: s.back,
          bottomNavigationBarText: s.cropOrRotate,
          smallScreenMoreTooltip: s.more,
        ),
        filterEditor: I18nFilterEditor(
          done: s.done,
          back: s.back,
          bottomNavigationBarText: s.filter,
        ),
        blurEditor: I18nBlurEditor(
          done: s.done,
          back: s.back,
          bottomNavigationBarText: s.blur,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProImageEditor.memory(
      bytes,
      configs: _configs(context),
      callbacks: ProImageEditorCallbacks(
        onImageEditingComplete: (edited) async {
          if (!context.mounted) return;
          Navigator.of(context).pop(edited);
        },
      ),
    );
  }
}
