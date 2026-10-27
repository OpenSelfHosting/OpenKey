import 'dart:io';

import 'package:flutter/material.dart';
import 'package:openkey_app/src/src.dart';

class AccountAvatar extends StatelessWidget {
  const AccountAvatar({
    super.key,
    required this.account,
    this.size = 40,
    this.onPressed,
    this.selected = false,
  });

  final VaultAccount account;
  final double size;
  final VoidCallback? onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final path = account.avatarPath;
    final file = path == null ? null : File(path);
    final hasFile = file != null && file.existsSync();
    final image = hasFile ? _versionedFileImage(file) : null;

    return MEAvatar(
      size: size,
      selected: selected,
      onPressed: onPressed,
      semanticLabel: account.email,
      backgroundColor: scheme.primaryContainer,
      foregroundColor: scheme.onPrimaryContainer,
      image: image,
      child: hasFile
          ? null
          : Text(
              account.initials,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                    fontSize: size * 0.4,
                  ),
            ),
    );
  }

  static ImageProvider _versionedFileImage(File file) {
    var version = 0;
    try {
      version = Object.hash(
        file.lastModifiedSync().millisecondsSinceEpoch,
        file.lengthSync(),
      );
    } catch (_) {}
    return _VersionedFileImage(file, version: version);
  }
}

/// [FileImage] keys only on path, so overwriting `$id.png` would keep the old
/// decode. Version (mtime + size) makes a cache miss after a replacement.
class _VersionedFileImage extends FileImage {
  const _VersionedFileImage(super.file, {required this.version});

  final int version;

  @override
  bool operator ==(Object other) {
    return other is _VersionedFileImage &&
        other.file.path == file.path &&
        other.version == version &&
        other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(file.path, version, scale);
}
