import 'dart:io' show Platform;

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Whether this build should use the custom desktop window chrome.
bool get useDesktopWindowFrame {
  if (kIsWeb) return false;
  return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
}

/// Frameless desktop shell: thin border + draggable title bar with window
/// controls (Windows/Linux) or traffic-light padding (macOS).
class DesktopWindowFrame extends StatelessWidget {
  const DesktopWindowFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!useDesktopWindowFrame) return child;

    final scheme = Theme.of(context).colorScheme;
    return WindowBorder(
      color: scheme.outlineVariant,
      width: 1,
      child: ColoredBox(
        color: scheme.surface,
        child: Column(
          children: [
            const DesktopTitleBar(),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class DesktopTitleBar extends StatelessWidget {
  const DesktopTitleBar({super.key, this.title = 'OpenKey'});

  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isMac = Platform.isMacOS;

    final buttonColors = WindowButtonColors(
      iconNormal: scheme.onSurfaceVariant,
      mouseOver: scheme.surfaceContainerHighest,
      mouseDown: scheme.surfaceContainerHigh,
      iconMouseOver: scheme.onSurface,
      iconMouseDown: scheme.onSurface,
    );
    final closeColors = WindowButtonColors(
      mouseOver: const Color(0xFFC42B1C),
      mouseDown: const Color(0xFFB22B1B),
      iconNormal: scheme.onSurfaceVariant,
      iconMouseOver: Colors.white,
      iconMouseDown: Colors.white,
    );

    return WindowTitleBarBox(
      child: ColoredBox(
        color: scheme.surfaceContainer,
        child: Row(
          children: [
            if (isMac) const SizedBox(width: 78),
            Expanded(
              child: MoveWindow(
                child: Align(
                  alignment: isMac
                      ? Alignment.center
                      : AlignmentDirectional.centerStart,
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: isMac ? 0 : 12,
                    ),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (!isMac) _WindowButtons(colors: buttonColors, close: closeColors),
          ],
        ),
      ),
    );
  }
}

class _WindowButtons extends StatefulWidget {
  const _WindowButtons({required this.colors, required this.close});

  final WindowButtonColors colors;
  final WindowButtonColors close;

  @override
  State<_WindowButtons> createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<_WindowButtons> {
  void _maximizeOrRestore() {
    setState(() => appWindow.maximizeOrRestore());
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: widget.colors),
        if (appWindow.isMaximized)
          RestoreWindowButton(
            colors: widget.colors,
            onPressed: _maximizeOrRestore,
          )
        else
          MaximizeWindowButton(
            colors: widget.colors,
            onPressed: _maximizeOrRestore,
          ),
        CloseWindowButton(colors: widget.close),
      ],
    );
  }
}
