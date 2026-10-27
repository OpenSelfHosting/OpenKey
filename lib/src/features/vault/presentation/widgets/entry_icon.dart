import 'package:flutter/material.dart';
import 'package:openkey_app/src/src.dart';
import 'package:vector_graphics/vector_graphics.dart';

/// Renders a vault icon key (`material:*`, `brands/*.svg`, `brand:*`, or `custom:*`).
class EntryIcon extends StatelessWidget {
  const EntryIcon({
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
    final key = iconKey.isEmpty ? EntryIcons.defaultKey : iconKey;

    if (CustomIcons.isCustom(key)) {
      return CustomIconImage(
        iconKey: key,
        size: size,
        fallbackColor: color,
      );
    }

    final brandPath = EntryIcons.brandAssetPath(key);
    if (brandPath != null) {
      return SizedBox.square(
        dimension: size,
        child: VectorGraphic(
          loader: AssetBytesLoader(brandPath),
          width: size,
          height: size,
          fit: BoxFit.contain,
          placeholderBuilder: (_) => Icon(
            Icons.key_rounded,
            size: size * 0.7,
            color: color,
          ),
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.key_rounded,
            size: size * 0.7,
            color: color,
          ),
        ),
      );
    }

    return Icon(
      EntryIcons.resolveMaterial(key),
      size: size,
      color: color,
    );
  }
}
