import 'package:flutter/material.dart';
import 'package:openkey_app/src/core/widgets/expressive/expressive.dart';
import 'package:openkey_app/src/core/widgets/responsive/responsive.dart';

/// Folder rows as a grouped list matching vault [ActionItem] entries.
///
/// Pass [maxWidth] to center the list on large screens (same column as
/// login rows). Leave it null to stretch with the parent, like grouped
/// item lists on cards / crypto / secrets.
class FolderListSliver extends StatelessWidget {
  const FolderListSliver({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
    this.maxWidth,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index, ItemPosition position)
  itemBuilder;
  final EdgeInsetsGeometry padding;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: maxWidth == null ? padding : EdgeInsets.zero,
      sliver: SliverList.builder(
        itemCount: itemCount,
        itemBuilder: (context, index) {
          final child = itemBuilder(
            context,
            index,
            ItemPosition.fromIndex(index, itemCount),
          );
          if (maxWidth == null) return child;
          return AdaptiveContentWidth(
            maxWidth: maxWidth!,
            padding: padding,
            child: child,
          );
        },
      ),
    );
  }
}
