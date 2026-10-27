import 'package:flutter/material.dart';
import 'package:openkey_app/src/core/widgets/expressive/expressive.dart';

/// Side navigation for tablet/desktop, built on [MENavigationRail].
class AppNavigationRail extends StatelessWidget {
  const AppNavigationRail({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.expanded,
    required this.onToggleExpanded,
  });

  final List<MENavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool expanded;
  final VoidCallback onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return MENavigationRail(
      expanded: expanded,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: scheme.surfaceContainer,
      leading: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1).animate(animation),
              child: child,
            ),
          );
        },
        child: expanded
            ? Row(
                key: const ValueKey('expanded-leading'),
                children: [
                  IconButton(
                    tooltip: isRtl ? 'طي القائمة' : 'Collapse menu',
                    onPressed: onToggleExpanded,
                    icon: const Icon(Icons.menu_open_rounded),
                  ),
                  Expanded(
                    child: Text(
                      'OpenKey',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              )
            : IconButton(
                key: const ValueKey('collapsed-leading'),
                tooltip: isRtl ? 'توسيع القائمة' : 'Expand menu',
                onPressed: onToggleExpanded,
                icon: const Icon(Icons.menu_rounded),
              ),
      ),
      destinations: destinations,
    );
  }
}
