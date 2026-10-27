import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:openkey_app/src/src.dart';

/// Pick / re-edit custom icon images through [IconImageEditorPage].
class CustomIconFlow {
  CustomIconFlow._();

  /// Gallery pick → crop/edit → encoded icon key.
  static Future<String?> pickAndEdit(BuildContext context) async {
    final bytes = await CustomIcons.pickBytes();
    if (bytes == null || !context.mounted) return null;
    return _editAndEncode(context, bytes);
  }

  /// Re-open the editor for an existing custom icon.
  static Future<String?> reEdit(BuildContext context, String iconKey) async {
    final bytes = CustomIcons.decode(iconKey);
    if (bytes == null || bytes.isEmpty || !context.mounted) return null;
    return _editAndEncode(
      context,
      bytes,
      heroTag: 'openkey-icon-re-edit',
    );
  }

  static Future<String?> _editAndEncode(
    BuildContext context,
    Uint8List bytes, {
    String heroTag = 'openkey-icon-editor',
  }) async {
    final edited = await IconImageEditorPage.edit(
      context,
      bytes,
      heroTag: heroTag,
    );
    if (edited == null || edited.isEmpty || !context.mounted) return null;
    return CustomIcons.fromEditedBytes(edited);
  }
}
