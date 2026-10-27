import 'package:flutter/material.dart';
import 'package:openkey_app/src/src.dart';

/// Skeleton placeholders while vault entries are loading.
class VaultEntrySkeletonList extends StatelessWidget {
  const VaultEntrySkeletonList({super.key, this.count = 5});

  final int count;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: count,
      itemBuilder: (context, index) {
        return AdaptiveContentWidth(
          maxWidth: 960,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Padding(
            padding: ItemPosition.fromIndex(index, count).padding,
            child: ClipRRect(
              borderRadius: ItemPosition.fromIndex(index, count).borderRadius,
              child: Material(
                color: Theme.of(context).colorScheme.surfaceContainer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      const MESkeleton.circle(size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            MESkeleton.line(width: 160, height: 16),
                            SizedBox(height: 8),
                            MESkeleton.line(width: 100, height: 12),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const MESkeleton.circle(size: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
