import 'package:flutter/material.dart';
import 'package:openkey_app/src/src.dart';

/// Auth brand mark — Material 3 Expressive.
///
/// One morphing shape, one color role, bold dual-tone wordmark,
/// and a light spatial spring on appear. No competing surfaces.
class AuthBrandHero extends StatelessWidget {
  const AuthBrandHero({
    super.key,
    this.compact = false,
    this.markSize,
    this.iconSize,
    this.textSize,
  });

  /// Smaller mark for screens that already have a strong identity block.
  final bool compact;

  /// Controls the morphing shape size (diameter).
  final double? markSize;

  /// Controls the icon size.
  final double? iconSize;

  /// Controls the text size (font size).
  final double? textSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final motion = METheme.of(context).motion;
    // If explicit sizes are provided, use them. Otherwise, fall back to default or compact logic.
    final resolvedMarkSize = markSize ?? (compact ? 88.0 : 128.0);
    final resolvedIconSize = iconSize ?? (compact ? 36.0 : 52.0);
    final resolvedTextStyle = (compact ? textTheme.titleLarge : textTheme.headlineSmall)
        ?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
          height: 1.1,
          fontSize: textSize ?? (compact
              ? textTheme.titleLarge?.fontSize
              : textTheme.headlineSmall?.fontSize),
        );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.92, end: 1),
      duration: motion.slowSpatial.approximateDuration,
      curve: motion.slowSpatial.curve,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MEMorphingShape(
            size: resolvedMarkSize,
            color: scheme.primaryContainer,
            shapes: const [
              MEExpressiveShape.cookie,
              MEExpressiveShape.clover,
              MEExpressiveShape.flower,
              MEExpressiveShape.sunny,
            ],
            interval: const Duration(seconds: 3),
            child: Icon(
              Icons.password_rounded,
              size: resolvedIconSize,
              color: scheme.onPrimaryContainer,
            ),
          ),
          SizedBox(height: compact ? 12 : 20),
          Text.rich(
            TextSpan(
              style: resolvedTextStyle,
              children: [
                TextSpan(
                  text: 'Open',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: textSize,
                  ),
                ),
                TextSpan(
                  text: 'Key',
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: textSize,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
