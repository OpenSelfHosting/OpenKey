import 'package:flutter/material.dart';
import 'package:openkey_app/src/src.dart';

/// Full-screen busy state for vault setup / unlock (KDF + DB open can take seconds).
class AuthBusyOverlay extends StatelessWidget {
  const AuthBusyOverlay({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AbsorbPointer(
      child: Material(
        color: scheme.surface.withValues(alpha: 0.82),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MELoadingIndicator(
                  size: 56,
                  contained: true,
                  color: scheme.onPrimaryContainer,
                  containerColor: scheme.primaryContainer,
                ),
                const SizedBox(height: 20),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
