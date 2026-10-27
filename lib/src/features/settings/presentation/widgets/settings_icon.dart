import 'package:flutter/material.dart';
import 'package:openkey_app/src/src.dart';

/// Cookie-shaped icon used across settings rows (matches maham-app).
class SettingsIcon extends StatelessWidget {
  const SettingsIcon(
    this.icon, {
    super.key,
    this.size = 44,
    this.backgroundColor,
    this.foregroundColor,
    this.shape = ExpressiveShape.cookie9Sided,
  });

  final IconData icon;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final ExpressiveShape shape;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExpressiveIconContainer(
      size: size,
      shape: shape,
      backgroundColor: backgroundColor ?? scheme.primaryContainer,
      child: Icon(
        icon,
        size: size * 0.5,
        color: foregroundColor ?? scheme.onPrimaryContainer,
      ),
    );
  }
}
