import 'package:flutter/material.dart';

/// Section header for grouped list screens (settings, vault, and related pages).
class SectionLabel extends StatelessWidget {
  const SectionLabel({
    super.key,
    required this.title,
    this.subtitle,
    this.accentColor,
    this.padding = const EdgeInsets.fromLTRB(4, 0, 4, 8),
  });

  final String title;
  final String? subtitle;
  final Color? accentColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = accentColor ?? scheme.onSurface;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
