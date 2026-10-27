import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

/// Crypto wallets — folder navigation + multi-select like the vault home.
class CryptoPage extends StatelessWidget {
  const CryptoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GroupedSelectionCubit(),
      child: const _CryptoPageBody(),
    );
  }
}

class _CryptoPageBody extends StatefulWidget {
  const _CryptoPageBody();

  @override
  State<_CryptoPageBody> createState() => _CryptoPageBodyState();
}

class _CryptoPageBodyState extends State<_CryptoPageBody> {
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CryptoBloc>().add(const CryptoStarted());
    });
  }

  Future<void> _refresh() async {
    await sl<SyncService>().syncNow();
    if (!mounted) return;
    context.read<CryptoBloc>().add(const CryptoStarted());
  }

  void _exitSearch() {
    context.read<CryptoBloc>().add(const CryptoSearchChanged(''));
    setState(() => _searching = false);
  }

  Future<void> _createFolder() async {
    final group = await CryptoFolderNameSheet.show(
      context,
      title: context.s.newFolder,
    );
    if (group == null || !mounted) return;
    context.read<CryptoBloc>().add(
      CryptoFolderCreated(group.name, icon: group.icon),
    );
    showMEToast(
      context,
      message: context.s.folderCreated,
      kind: METoastKind.success,
    );
  }

  void _openFolder(String folder) {
    context.read<CryptoBloc>().add(CryptoNavigateToFolder(folder));
  }

  void _goRoot() {
    context.read<CryptoBloc>().add(const CryptoNavigateToRoot());
  }

  Future<void> _deleteSelected(GroupedSelectionState selection) async {
    final s = context.s;
    final itemIds = List<String>.from(selection.selectedItemIds);
    final groups = List<String>.from(selection.selectedGroups);
    if (itemIds.isEmpty && groups.isEmpty) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.delete),
        content: Text(s.deleteSelectedConfirm(itemIds.length + groups.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(s.delete),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final bloc = context.read<CryptoBloc>();
    for (final id in itemIds) {
      bloc.add(CryptoWalletDeleted(id));
    }
    for (final group in groups) {
      final count = bloc.state.wallets
          .where((w) => w.folder.trim().toLowerCase() == group.toLowerCase())
          .length;
      bloc.add(CryptoFolderDeleted(group, clearWallets: count > 0));
    }
    context.read<GroupedSelectionCubit>().clear();
  }

  Future<void> _editSelected(GroupedSelectionState selection) async {
    if (selection.selectedCount != 1) return;
    if (selection.selectedItemIds.length == 1) {
      final id = selection.selectedItemIds.first;
      context.read<GroupedSelectionCubit>().clear();
      if (mounted) {
        context.push('${AppRoutes.crypto.path}/$id');
      }
      return;
    }
    if (selection.selectedGroups.length == 1) {
      final folder = selection.selectedGroups.first;
      final icon = context.read<CryptoBloc>().state.iconForGroup(folder);
      context.read<GroupedSelectionCubit>().clear();
      if (!mounted) return;
      final next = await CryptoFolderNameSheet.show(
        context,
        title: context.s.renameFolder,
        initial: folder,
        initialIcon: icon,
      );
      if (next == null || !mounted) return;
      context.read<CryptoBloc>().add(
        CryptoFolderRenamed(from: folder, to: next.name, icon: next.icon),
      );
    }
  }

  void _moveSelectedHere(GroupedSelectionState selection) {
    final target = context.read<CryptoBloc>().state.currentGroup ?? '';
    final ids = selection.selectedItemIds;
    if (ids.isNotEmpty) {
      context.read<CryptoBloc>().add(
        CryptoWalletsMovedToFolder(uuids: ids, folder: target),
      );
    }
    context.read<GroupedSelectionCubit>().clear();
  }

  Widget _buildBodySliver(
    BuildContext context,
    CryptoState state,
    GroupedSelectionState selection,
  ) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    final isSelecting = selection.isSelecting;
    final isMoving = selection.isMoving;

    if (state.status == CryptoStatus.loading &&
        state.wallets.isEmpty &&
        state.folders.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: MELoadingIndicator()),
      );
    }

    final groups = (!_searching && state.isRoot && !state.isSearching)
        ? state.visibleGroups
              .where((g) => !isMoving || !selection.isGroupSelected(g.name))
              .toList()
        : const <NamedGroup>[];
    var items = state.visibleItems;
    if (isMoving) {
      final movingIds = selection.selectedItemIds.toSet();
      items = items.where((w) => !movingIds.contains(w.uuid)).toList();
    }

    final hasAny = state.wallets.isNotEmpty || state.folders.isNotEmpty;
    if (!hasAny && groups.isEmpty && items.isEmpty) {
      if (_searching || state.isSearching) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }
      return SliverFillRemaining(
        hasScrollBody: false,
        child: MEEmptyState(
          icon: Icons.currency_bitcoin,
          title: Text(s.noCryptoWalletsYet),
          message: Text(s.noCryptoWalletsYetMessage),
        ),
      );
    }

    if (groups.isEmpty &&
        items.isEmpty &&
        !isMoving &&
        !_searching &&
        !state.isSearching) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: MEEmptyState(
          icon: state.isRoot
              ? Icons.currency_bitcoin
              : Icons.folder_open_rounded,
          title: Text(state.isRoot ? s.noCryptoWalletsYet : s.emptyFolder),
          message: Text(
            state.isRoot ? s.noCryptoWalletsYetMessage : s.emptyFolder,
          ),
        ),
      );
    }

    final slivers = <Widget>[];

    if (groups.isNotEmpty) {
      slivers.add(
        FolderListSliver(
          itemCount: groups.length,
          itemBuilder: (context, index, position) {
            final group = groups[index];
            final folder = group.name;
            final selected = selection.isGroupSelected(folder);
            return GroupFolderItem(
              name: folder,
              count: state.countInGroup(folder),
              iconKey: group.iconKey,
              position: position,
              selected: selected,
              isSelecting: isSelecting,
              isMoving: isMoving,
              onTap: () {
                if (isSelecting) {
                  context.read<GroupedSelectionCubit>().toggleGroup(folder);
                  return;
                }
                _openFolder(folder);
              },
              onLongPress: () {
                if (isSelecting || isMoving) return;
                context.read<GroupedSelectionCubit>().selectGroup(folder);
              },
            );
          },
        ),
      );
      slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 8)));
    }

    if (items.isEmpty) {
      if (groups.isEmpty && !isMoving) {
        slivers.add(
          SliverFillRemaining(
            hasScrollBody: false,
            child: MEEmptyState(
              icon: Icons.folder_open_rounded,
              title: Text(s.emptyFolder),
              message: Text(s.emptyFolder),
            ),
          ),
        );
      }
      return SliverMainAxisGroup(slivers: slivers);
    }

    slivers.add(
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        sliver: SliverList.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final wallet = items[index];
            final selected = selection.isItemSelected(wallet.uuid);
            final position = ItemPosition.fromIndex(index, items.length);

            Widget icon;
            if (isSelecting) {
              icon = Checkbox(
                value: selected,
                onChanged: (_) => context
                    .read<GroupedSelectionCubit>()
                    .toggleItem(wallet.uuid),
              );
            } else {
              icon = SettingsIcon(
                Icons.currency_bitcoin,
                backgroundColor: scheme.tertiaryContainer,
                foregroundColor: scheme.onTertiaryContainer,
              );
            }

            return ActionItem(
              title: wallet.displayName,
              subtitle: Text(
                '${wallet.network.symbol} · ${wallet.maskedAddress}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontFamily: 'monospace',
                ),
              ),
              icon: icon,
              selected: selected,
              trailing: isSelecting || isMoving ? null : null,
              itemPosition: position,
              onTap: () {
                if (isSelecting) {
                  context.read<GroupedSelectionCubit>().toggleItem(wallet.uuid);
                  return;
                }
                if (isMoving) return;
                context.push('${AppRoutes.crypto.path}/${wallet.uuid}');
              },
              onLongPress: () {
                if (isSelecting || isMoving) return;
                HapticFeedback.selectionClick();
                context.read<GroupedSelectionCubit>().selectItem(wallet.uuid);
              },
            );
          },
        ),
      ),
    );
    slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 100)));
    return SliverMainAxisGroup(slivers: slivers);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return BlocBuilder<GroupedSelectionCubit, GroupedSelectionState>(
      builder: (context, selection) {
        return BlocBuilder<CryptoBloc, CryptoState>(
          builder: (context, state) {
            final isSelecting = selection.isSelecting;
            final isMoving = selection.isMoving;
            final hideFab = isSelecting || isMoving || _searching;
            final title = state.isRoot
                ? s.cryptoWallets
                : (state.currentGroup ?? s.cryptoWallets);

            Widget? customAppBar;
            var actions = <Widget>[];

            Widget createAction() {
              return MEIconButton(
                tooltip: s.addFolder,
                variant: MEButtonVariant.text,
                onPressed: _createFolder,
                icon: const Icon(Icons.create_new_folder_outlined),
              );
            }

            Widget filterAction() {
              return BlocBuilder<CryptoBloc, CryptoState>(
                buildWhen: (p, c) => p.filterNetworks != c.filterNetworks,
                builder: (context, filterState) {
                  return MEBadge(
                    visible: filterState.filterNetworks.isNotEmpty,
                    child: MEIconButton(
                      tooltip: s.sortAndFilter,
                      variant: MEButtonVariant.text,
                      onPressed: () => CryptoFilterSheet.show(context),
                      icon: const Icon(Icons.filter_list_rounded),
                    ),
                  );
                },
              );
            }

            if (_searching) {
              customAppBar = AppBar(
                key: const ValueKey('crypto-searching-app-bar'),
                automaticallyImplyLeading: false,
                toolbarHeight: 72,
                titleSpacing: 8,
                title: MESearchBar(
                  hintText: s.searchCryptoWallets,
                  leading: MEIconButton(
                    variant: MEButtonVariant.text,
                    onPressed: _exitSearch,
                    icon: Icon(Icons.adaptive.arrow_back_rounded),
                  ),
                  trailing: [filterAction()],
                  onChanged: (value) => context.read<CryptoBloc>().add(
                    CryptoSearchChanged(value.trim()),
                  ),
                ),
              );
            } else if (isSelecting || isMoving) {
              final folders = state.isRoot
                  ? state.visibleGroups
                  : const <NamedGroup>[];
              final entries = state.visibleItems;
              customAppBar = AppBar(
                leading: IconButton(
                  onPressed: () {
                    if (isMoving) {
                      if (state.isRoot) {
                        context.read<GroupedSelectionCubit>().cancelMoving();
                      } else {
                        _goRoot();
                      }
                    } else {
                      context.read<GroupedSelectionCubit>().clear();
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
                          onPressed: _createFolder,
                          icon: const Icon(Icons.create_new_folder_rounded),
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
                            final cubit = context.read<GroupedSelectionCubit>();
                            if (v ?? false) {
                              cubit.selectAll(
                                itemIds: entries.map((e) => e.uuid).toList(),
                                groups: folders.map((g) => g.name).toList(),
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
                  onPressed: () => setState(() => _searching = true),
                  icon: const Icon(Icons.search_rounded),
                ),
                createAction(),
                if (!state.isRoot)
                  MEIconButton(
                    tooltip: s.folders,
                    variant: MEButtonVariant.text,
                    onPressed: () => CryptoFolderActionsSheet.show(
                      context,
                      folder: state.currentGroup!,
                    ),
                    icon: const Icon(Icons.more_horiz_rounded),
                  ),
                filterAction(),
              ];
            }

            return PopScope(
              canPop: state.isRoot && !isSelecting && !isMoving && !_searching,
              onPopInvokedWithResult: (didPop, _) {
                if (didPop) return;
                if (_searching) {
                  _exitSearch();
                  return;
                }
                if (isMoving) {
                  if (state.isRoot) {
                    context.read<GroupedSelectionCubit>().cancelMoving();
                  } else {
                    _goRoot();
                  }
                  return;
                }
                if (isSelecting) {
                  context.read<GroupedSelectionCubit>().clear();
                  return;
                }
                _goRoot();
              },
              child: MESliverScaffold(
                title: title,
                centerTitle: false,
                customAppBar: customAppBar,
                extendedAppBar: false,
                leadingAppBar: (_searching || isSelecting || isMoving)
                    ? null
                    : MEIconButton(
                        variant: MEButtonVariant.text,
                        icon: Icon(Icons.adaptive.arrow_back_rounded),
                        onPressed: () {
                          if (!state.isRoot) {
                            _goRoot();
                            return;
                          }
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(AppRoutes.items.path);
                          }
                        },
                      ),
                appBarActions: customAppBar == null ? actions : const [],
                onRefresh: (isSelecting || isMoving || _searching)
                    ? null
                    : _refresh,
                bottomNavigationBar: isMoving
                    ? MovingActionBar(
                        itemCount: selection.selectedCount,
                        onCancel: () => context
                            .read<GroupedSelectionCubit>()
                            .cancelMoving(),
                        onMoveHere: () => _moveSelectedHere(selection),
                      )
                    : isSelecting
                    ? SelectingActionBar(
                        selectedCount: selection.selectedCount,
                        onDelete: () => _deleteSelected(selection),
                        onEdit: () => _editSelected(selection),
                        onMove: () =>
                            context.read<GroupedSelectionCubit>().startMoving(),
                      )
                    : null,
                floatingActionButton: hideFab
                    ? null
                    : MEFab(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          context.push(AppRoutes.cryptoWalletNew.path);
                        },
                      ),
                slivers: [
                  if (!_searching)
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  _buildBodySliver(context, state, selection),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
