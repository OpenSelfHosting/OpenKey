import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

class VaultHomePage extends StatefulWidget {
  const VaultHomePage({super.key});

  @override
  State<VaultHomePage> createState() => _VaultHomePageState();
}

class _VaultHomePageState extends State<VaultHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CollectionBloc>().add(const CollectionStarted());
      final entryBloc = context.read<EntryBloc>();
      // After unlock / restore the shell remounts; force a watch if the shared
      // singleton never got a snapshot (or still shows a stale empty list).
      final needsReload =
          entryBloc.state.status != EntryStatus.ready ||
          entryBloc.state.entries.isEmpty;
      _syncEntriesToFolder(
        context.read<CollectionBloc>().state.currentFolderUuid,
        forceReload: needsReload,
      );
    });
  }

  Future<void> _refresh() async {
    // Match maham: re-load local lists and push/pull with the server.
    context.read<CollectionBloc>().add(const CollectionStarted());
    final folder = context.read<CollectionBloc>().state.currentFolderUuid;
    context.read<EntryBloc>().add(
      EntryStarted(
        collectionUuid: folder ?? kVaultRootScope,
        forceReload: true,
      ),
    );
    await sl<SyncService>().syncNow();
  }

  /// Keep EntryBloc scoped to the open folder (maham: folder change → reload).
  void _syncEntriesToFolder(String? folderUuid, {bool forceReload = false}) {
    final entryBloc = context.read<EntryBloc>();
    if (entryBloc.state.isSearching) return;
    final scope = folderUuid ?? kVaultRootScope;
    entryBloc.add(
      EntryStarted(collectionUuid: scope, forceReload: forceReload),
    );
  }

  void _openFolder(VaultCollection folder) {
    context.read<CollectionBloc>().add(CollectionNavigateToFolder(folder));
  }

  void _goBackFolder() {
    final state = context.read<CollectionBloc>().state;
    final nextIndex = state.breadcrumb.length - 2;
    context.read<CollectionBloc>().add(CollectionNavigateBreadcrumb(nextIndex));
  }

  void _enterSearch() {
    context.read<EntryBloc>().add(const EntrySearchModeChanged(true));
  }

  void _exitSearch() {
    context.read<EntryBloc>().add(const EntrySearchModeChanged(false));
  }

  void _createCollection() {
    UpsertCollectionSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return BlocListener<CollectionBloc, CollectionState>(
      listenWhen: (p, c) => p.currentFolderUuid != c.currentFolderUuid,
      listener: (context, collectionState) {
        _syncEntriesToFolder(collectionState.currentFolderUuid);
      },
      child: BlocBuilder<VaultSelectionCubit, VaultSelectionState>(
        builder: (context, selection) {
          return BlocBuilder<EntryBloc, EntryState>(
            buildWhen: (p, c) =>
                p.mode != c.mode ||
                p.filterTags != c.filterTags ||
                p.query != c.query,
            builder: (context, entryUi) {
              return BlocBuilder<CollectionBloc, CollectionState>(
                builder: (context, collectionState) {
                  final isSelecting = selection.isSelecting;
                  final isMoving = selection.isMoving;
                  final isSearching = entryUi.isSearching;
                  final hideFab = isSelecting || isMoving || isSearching;
                  final title = collectionState.isRoot
                      ? s.vault
                      : collectionState.breadcrumb.last.name;

                  Widget? customAppBar;
                  List<Widget> actions = [];

                  Widget createAction() {
                    return MEIconButton(
                      tooltip: s.newCollection,
                      variant: MEButtonVariant.text,
                      onPressed: _createCollection,
                      icon: const Icon(Icons.create_new_folder_outlined),
                    );
                  }

                  Widget filterAction() {
                    return MEIconButton(
                      tooltip: s.sortAndFilter,
                      variant: MEButtonVariant.text,
                      onPressed: () => VaultFilterSheet.show(context),
                      icon: const Icon(Icons.filter_list_rounded),
                    );
                  }

                  Widget tagsAction() {
                    return MEBadge(
                      visible: entryUi.filterTags.isNotEmpty,
                      child: MEIconButton(
                        tooltip: s.tags,
                        variant: MEButtonVariant.text,
                        onPressed: () => TagFilterSheet.show(context),
                        icon: const Icon(Icons.tag),
                      ),
                    );
                  }

                  if (isSearching) {
                    customAppBar = AppBar(
                      key: const ValueKey('vault-searching-app-bar'),
                      automaticallyImplyLeading: false,
                      toolbarHeight: 72,
                      titleSpacing: 8,
                      title: MESearchBar(
                        hintText: s.searchPasswords,
                        leading: MEIconButton(
                          variant: MEButtonVariant.text,
                          onPressed: _exitSearch,
                          icon: Icon(Icons.adaptive.arrow_back_rounded),
                        ),
                        trailing: [filterAction(), tagsAction()],
                        onChanged: (value) => context.read<EntryBloc>().add(
                          EntrySearchChanged(value.trim()),
                        ),
                      ),
                    );
                  } else if (isSelecting || isMoving) {
                    final folders = collectionState.visibleCollections;
                    final entries = context.read<EntryBloc>().state.filtered;
                    customAppBar = AppBar(
                      leading: IconButton(
                        onPressed: () {
                          if (isMoving) {
                            if (collectionState.isRoot) {
                              context
                                  .read<VaultSelectionCubit>()
                                  .cancelMoving();
                            } else {
                              _goBackFolder();
                            }
                          } else {
                            context.read<VaultSelectionCubit>().clear();
                          }
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                      title: Text(
                        isMoving
                            ? s.moveTo
                            : '${selection.selectedCount} ${s.selectedItems}',
                      ),
                      actions: isMoving
                          ? [
                              IconButton(
                                onPressed: () =>
                                    UpsertCollectionSheet.show(context),
                                icon: const Icon(
                                  Icons.create_new_folder_rounded,
                                ),
                              ),
                            ]
                          : [
                              Checkbox(
                                value:
                                    selection.selectedCount > 0 &&
                                    selection.selectedCount ==
                                        folders.length + entries.length,
                                shape: const CircleBorder(),
                                onChanged: (v) {
                                  final cubit = context
                                      .read<VaultSelectionCubit>();
                                  if (v ?? false) {
                                    cubit.selectAll(
                                      entries: entries,
                                      collections: folders,
                                    );
                                  } else {
                                    cubit.clear();
                                  }
                                },
                              ),
                            ],
                    );
                  } else {
                    actions = [
                      MEIconButton(
                        tooltip: s.search,
                        variant: MEButtonVariant.text,
                        onPressed: _enterSearch,
                        icon: const Icon(Icons.search_rounded),
                      ),
                      createAction(),
                      filterAction(),
                      tagsAction(),
                    ];
                  }

                  return PopScope(
                    canPop:
                        collectionState.isRoot &&
                        !isSelecting &&
                        !isMoving &&
                        !isSearching,
                    onPopInvokedWithResult: (didPop, _) {
                      if (didPop) return;
                      if (isSearching) {
                        _exitSearch();
                        return;
                      }
                      if (isMoving) {
                        if (collectionState.isRoot) {
                          context.read<VaultSelectionCubit>().cancelMoving();
                        } else {
                          _goBackFolder();
                        }
                        return;
                      }
                      if (isSelecting) {
                        context.read<VaultSelectionCubit>().clear();
                        return;
                      }
                      _goBackFolder();
                    },
                    child: MESliverScaffold(
                      title: title,
                      centerTitle: false,
                      customAppBar: customAppBar,
                      extendedAppBar: false,
                      appBarActions: customAppBar == null ? actions : const [],
                      onRefresh: (isSelecting || isMoving || isSearching)
                          ? null
                          : _refresh,
                      bottomNavigationBar:
                          Breakpoints.isMobile(MediaQuery.sizeOf(context).width)
                          ? null
                          : isMoving
                          ? MovingActionBar(
                              itemCount: selection.selectedCount,
                              onCancel: () => context
                                  .read<VaultSelectionCubit>()
                                  .cancelMoving(),
                              onMoveHere: () => context
                                  .read<VaultSelectionCubit>()
                                  .moveSelectedHere(context),
                            )
                          : isSelecting
                          ? SelectingActionBar(
                              selectedCount: selection.selectedCount,
                              onDelete: () => context
                                  .read<VaultSelectionCubit>()
                                  .deleteSelected(context),
                              onEdit: () => context
                                  .read<VaultSelectionCubit>()
                                  .editSelected(context),
                              onMove: () => context
                                  .read<VaultSelectionCubit>()
                                  .startMoving(),
                            )
                          : null,
                      floatingActionButton: hideFab
                          ? null
                          : MEFab(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                final folder =
                                    collectionState.currentFolderUuid;
                                final path = folder == null
                                    ? AppRoutes.entryNew.path
                                    : '${AppRoutes.vault.path}/entry/new?collection=$folder';
                                context.push(path);
                              },
                            ),
                      slivers: [
                        if ((!collectionState.isRoot || isMoving) &&
                            !isSearching)
                          SliverToBoxAdapter(
                            child: AdaptiveContentWidth(
                              maxWidth: 960,
                              alignment: AlignmentDirectional.topStart,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: BreadcrumbBar(
                                breadcrumb: collectionState.breadcrumb,
                              ),
                            ),
                          ),
                        if (!isSearching)
                          CollectionsSection(onOpenFolder: _openFolder),
                        if (!isSearching)
                          const SliverToBoxAdapter(child: SizedBox(height: 8)),
                        _EntriesSliver(
                          isSelecting: isSelecting,
                          isMoving: isMoving,
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _EntriesSliver extends StatelessWidget {
  const _EntriesSliver({required this.isSelecting, required this.isMoving});

  final bool isSelecting;
  final bool isMoving;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final selection = context.watch<VaultSelectionCubit>().state;
    final collectionState = context.watch<CollectionBloc>().state;

    return BlocBuilder<EntryBloc, EntryState>(
      builder: (context, state) {
        var items = state.filtered;
        if (isMoving) {
          final movingIds = selection.selectedEntries
              .map((e) => e.uuid)
              .toSet();
          items = items.where((e) => !movingIds.contains(e.uuid)).toList();
        }

        if (state.status == EntryStatus.loading) {
          return const VaultEntrySkeletonList();
        }
        if (items.isEmpty) {
          final hasFolders = collectionState.visibleCollections.isNotEmpty;
          // Hide while moving, searching, or when child folders are listed.
          if (hasFolders || isMoving || state.isSearching) {
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          }
          final isRoot = collectionState.isRoot;
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: MEEmptyState(
                icon: isRoot ? Icons.lock_outline : Icons.folder_open_rounded,
                title: Text(isRoot ? s.noPasswordsYet : s.emptyCollection),
                message: Text(
                  isRoot ? s.noPasswordsYetMessage : s.emptyCollectionMessage,
                ),
              ),
            ),
          );
        }

        return SliverList.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final entry = items[index];
            final selected = selection.isEntrySelected(entry.uuid);
            final scheme = Theme.of(context).colorScheme;

            Widget icon;
            if (isSelecting) {
              icon = Checkbox(
                value: selected,
                onChanged: (_) =>
                    context.read<VaultSelectionCubit>().toggleEntry(entry),
              );
            } else {
              icon = ResolvedEntryIcon(
                entry: entry,
                size: 22,
                color: scheme.onSecondaryContainer,
                withSurface: true,
                surfaceSize: 40,
                surfaceColor: scheme.secondaryContainer,
              );
            }

            return AdaptiveContentWidth(
              maxWidth: 960,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ActionItem(
                key: ValueKey('entry-${entry.uuid}'),
                title: entry.title.isEmpty ? s.untitled : entry.title,
                subtitle: Text(
                  [
                    if (entry.username.isNotEmpty) entry.username,
                    if (entry.tags.isNotEmpty) entry.tags.join(' · '),
                  ].join('\n'),
                ),
                maxSubtitleLines: entry.tags.isEmpty ? 1 : 2,
                selected: selected,
                itemPosition: ItemPosition.fromIndex(index, items.length),
                icon: icon,
                onTap: () {
                  if (isSelecting) {
                    context.read<VaultSelectionCubit>().toggleEntry(entry);
                    return;
                  }
                  if (isMoving) return;
                  context.push('${AppRoutes.vault.path}/entry/${entry.uuid}');
                },
                onLongPress: () {
                  if (isSelecting || isMoving) return;
                  context.read<VaultSelectionCubit>().selectEntry(entry);
                },
                trailing: isSelecting || isMoving
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.copy_rounded),
                        tooltip: s.copyPassword,
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: entry.password),
                          );
                          if (context.mounted) {
                            showMEToast(
                              context,
                              message: s.passwordCopied,
                              kind: METoastKind.success,
                            );
                          }
                        },
                      ),
              ),
            );
          },
        );
      },
    );
  }
}
