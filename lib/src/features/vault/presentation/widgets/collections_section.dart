import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openkey_app/src/src.dart';

/// Folders for the current level as a grouped list, matching vault entries.
class CollectionsSection extends StatelessWidget {
  const CollectionsSection({super.key, required this.onOpenFolder});

  final ValueChanged<VaultCollection> onOpenFolder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VaultSelectionCubit, VaultSelectionState>(
      builder: (context, selection) {
        return BlocBuilder<CollectionBloc, CollectionState>(
          builder: (context, collectionState) {
            var folders = collectionState.visibleCollections;
            if (selection.isMoving) {
              final movingIds = selection.selectedCollections
                  .map((c) => c.uuid)
                  .toSet();
              folders = folders
                  .where((f) => !movingIds.contains(f.uuid))
                  .toList();
            }
            if (folders.isEmpty) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }

            // Counts from the full in-memory entry list (EntryBloc watches all).
            return BlocBuilder<EntryBloc, EntryState>(
              buildWhen: (p, c) => p.entries != c.entries,
              builder: (context, entryState) {
                return SliverMainAxisGroup(
                  slivers: [
                    FolderListSliver(
                      maxWidth: 960,
                      itemCount: folders.length,
                      itemBuilder: (context, index, position) {
                        final collection = folders[index];
                        final selected = selection.isCollectionSelected(
                          collection.uuid,
                        );
                        final count = entryState.entries
                            .where((e) => e.collectionUuid == collection.uuid)
                            .length;
                        return CollectionItem(
                          collection: collection,
                          count: count,
                          selected: selected,
                          isSelecting: selection.isSelecting,
                          isMoving: selection.isMoving,
                          position: position,
                          onTap: () {
                            if (selection.isSelecting) {
                              context
                                  .read<VaultSelectionCubit>()
                                  .toggleCollection(collection);
                              return;
                            }
                            onOpenFolder(collection);
                          },
                          onLongPress: () {
                            if (selection.isSelecting || selection.isMoving) {
                              return;
                            }
                            context
                                .read<VaultSelectionCubit>()
                                .selectCollection(collection);
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
