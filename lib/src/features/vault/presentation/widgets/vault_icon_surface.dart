import 'package:flutter/material.dart';
import 'package:openkey_app/src/src.dart';

/// Optional tinted backdrop behind vault icons.
///
/// Brand trademarks and custom device images render without a background.
class VaultIconSurface extends StatelessWidget {
  const VaultIconSurface({
    super.key,
    required this.iconKey,
    required this.child,
    this.size = 40,
    this.iconSize,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.expressive = false,
  });

  final String iconKey;
  final Widget child;
  final double size;
  final double? iconSize;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;
  final bool expressive;

  static bool needsBackdrop(String key) {
    if (key.isEmpty) return true;
    if (CustomIcons.isCustom(key)) return false;
    if (EntryIcons.isBrand(key)) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final showBg = needsBackdrop(iconKey);

    if (!showBg) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(child: child),
      );
    }

    if (expressive) {
      return ExpressiveIconContainer(
        size: size,
        backgroundColor: backgroundColor ?? scheme.primaryContainer,
        child: child,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? scheme.secondaryContainer,
        borderRadius: borderRadius ?? BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
