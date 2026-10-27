import 'package:flutter/material.dart';
import 'package:openkey_app/src/src.dart';

/// Renders a collection icon using the shared [EntryIcon] catalog.
class CollectionIcon extends StatelessWidget {
  const CollectionIcon({
    super.key,
    required this.iconKey,
    this.size = 24,
    this.color,
  });

  final String iconKey;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final key = iconKey.isEmpty ? CollectionIcons.defaultKey : iconKey;
    return EntryIcon(
      iconKey: key,
      size: size,
      color: color,
    );
  }
}
