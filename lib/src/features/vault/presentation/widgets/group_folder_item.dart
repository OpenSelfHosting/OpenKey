import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openkey_app/src/src.dart';

/// Selectable folder row for flat named groups (banks / crypto folders / devices).
class GroupFolderItem extends StatelessWidget {
  const GroupFolderItem({
    super.key,
    required this.name,
    required this.count,
    required this.position,
    required this.iconKey,
    this.countLabel,
    this.selected = false,
    this.isSelecting = false,
    this.isMoving = false,
    this.onTap,
    this.onLongPress,
  });

  final String name;
  final int count;
  final ItemPosition position;
  final String iconKey;
  final String? countLabel;
  final bool selected;
  final bool isSelecting;
  final bool isMoving;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = context.s;
    final key = iconKey.trim().isEmpty ? NamedGroup.defaultIcon : iconKey;

    Widget leading;
    if (isSelecting) {
      leading = Checkbox(
        value: selected,
        onChanged: (_) => onTap?.call(),
      );
    } else {
      leading = VaultIconSurface(
        iconKey: key,
        size: 40,
        borderRadius: BorderRadius.circular(12),
        backgroundColor: scheme.secondaryContainer,
        child: CollectionIcon(
          iconKey: key,
          size: VaultIconSurface.needsBackdrop(key) ? 22 : 28,
          color: scheme.onSecondaryContainer,
        ),
      );
    }

    return ActionItem(
      key: ValueKey('group-folder-$name'),
      title: name,
      itemPosition: position,
      selected: selected,
      padding: 16,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      maxSubtitleLines: 1,
      subtitle: count > 0
          ? Text(
              countLabel ?? s.entriesCount(count),
              style: Theme.of(context).textTheme.bodySmall,
            )
          : null,
      icon: leading,
      onTap: onTap,
      onLongPress: onLongPress == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onLongPress!();
            },
      trailing: isSelecting || isMoving
          ? null
          : Icon(Icons.chevron_right, size: 28, color: scheme.onSurfaceVariant),
    );
  }
}
