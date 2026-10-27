import 'package:flutter/material.dart';
import 'package:openkey_app/src/src.dart';

class SelectingActionBar extends StatelessWidget {
  const SelectingActionBar({
    super.key,
    required this.selectedCount,
    required this.onDelete,
    required this.onEdit,
    required this.onMove,
  });

  final int selectedCount;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onMove;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerHigh,
      elevation: 0,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(
              height: 1,
              thickness: 1,
              color: scheme.outlineVariant.withValues(alpha: 0.45),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              child: Row(
                children: [
                  Expanded(
                    child: _Action(
                      icon: Icons.delete_outline_rounded,
                      label: s.delete,
                      color: scheme.error,
                      onTap: onDelete,
                    ),
                  ),
                  if (selectedCount == 1)
                    Expanded(
                      child: _Action(
                        icon: Icons.edit_outlined,
                        label: s.edit,
                        onTap: onEdit,
                      ),
                    ),
                  Expanded(
                    child: _Action(
                      icon: Icons.drive_file_move_outlined,
                      label: s.moveTo,
                      onTap: onMove,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MovingActionBar extends StatelessWidget {
  const MovingActionBar({
    super.key,
    required this.itemCount,
    required this.onMoveHere,
    required this.onCancel,
  });

  final int itemCount;
  final VoidCallback onMoveHere;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: scheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(
              height: 1,
              thickness: 1,
              color: scheme.outlineVariant.withValues(alpha: 0.45),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.folder_rounded,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.movingLabel,
                          style: textTheme.labelMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          s.movingItemsCount(itemCount),
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  MEButton.text(
                    onPressed: onCancel,
                    child: Text(s.cancel),
                  ),
                  const SizedBox(width: 4),
                  MEButton(
                    onPressed: onMoveHere,
                    child: Text(s.moveHere),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.onSurface;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: c, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: c,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
