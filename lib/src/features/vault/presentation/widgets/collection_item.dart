import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openkey_app/src/src.dart';

/// Flat folder row matching maham-app [HomeFoldersList] / [ActionItem] style.
class CollectionItem extends StatelessWidget {
  const CollectionItem({
    super.key,
    required this.collection,
    required this.count,
    required this.position,
    this.selected = false,
    this.isSelecting = false,
    this.isMoving = false,
    this.onTap,
    this.onLongPress,
  });

  final VaultCollection collection;
  final int count;
  final ItemPosition position;
  final bool selected;
  final bool isSelecting;
  final bool isMoving;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = context.s;

    Widget folderIcon;
    if (isSelecting) {
      folderIcon = Checkbox(value: selected, onChanged: (_) => onTap?.call());
    } else {
      folderIcon = VaultIconSurface(
        iconKey: collection.icon,
        size: 40,
        borderRadius: BorderRadius.circular(12),
        backgroundColor: scheme.secondaryContainer,
        child: CollectionIcon(
          iconKey: collection.icon,
          size: VaultIconSurface.needsBackdrop(collection.icon) ? 22 : 28,
          color: scheme.onSecondaryContainer,
        ),
      );
    }

    return ActionItem(
      key: ValueKey('collection-${collection.uuid}'),
      title: collection.name,
      itemPosition: position,
      selected: selected,
      padding: 16,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      maxSubtitleLines: 1,
      subtitle: count > 0
          ? Text(
              s.entriesCount(count),
              style: Theme.of(context).textTheme.bodySmall,
            )
          : null,
      icon: folderIcon,
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
