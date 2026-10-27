import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

/// Developer secrets — device folders + multi-select like the vault home.
class SecretsPage extends StatelessWidget {
  const SecretsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GroupedSelectionCubit(),
      child: const _SecretsPageBody(),
    );
  }
}

class _SecretsPageBody extends StatefulWidget {
  const _SecretsPageBody();

  @override
  State<_SecretsPageBody> createState() => _SecretsPageBodyState();
}

class _SecretsPageBodyState extends State<_SecretsPageBody> {
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SecretsBloc>().add(const SecretsStarted());
    });
  }

  Future<void> _refresh() async {
    await sl<SyncService>().syncNow();
    if (!mounted) return;
    context.read<SecretsBloc>().add(const SecretsStarted());
  }

  void _exitSearch() {
    context.read<SecretsBloc>().add(const SecretsSearchChanged(''));
    setState(() => _searching = false);
  }

  Future<void> _createDevice() async {
    final group = await SecretDeviceNameSheet.show(
      context,
      title: context.s.newDevice,
    );
    if (group == null || !mounted) return;
    context.read<SecretsBloc>().add(
      SecretDeviceCreated(group.name, icon: group.icon),
    );
    showMEToast(
      context,
      message: context.s.deviceCreated,
      kind: METoastKind.success,
    );
  }

  Future<void> _addSecret() async {
    context.push(AppRoutes.secretNew.path);
  }

  void _openDevice(String device) {
    context.read<SecretsBloc>().add(SecretsNavigateToDevice(device));
  }

  void _goRoot() {
    context.read<SecretsBloc>().add(const SecretsNavigateToRoot());
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

    final bloc = context.read<SecretsBloc>();
    for (final id in itemIds) {
      bloc.add(SecretDeleted(id));
    }
    for (final group in groups) {
      final count = bloc.state.secrets
          .where((s) => s.device.trim().toLowerCase() == group.toLowerCase())
          .length;
      bloc.add(SecretDeviceDeleted(group, clearSecrets: count > 0));
    }
    context.read<GroupedSelectionCubit>().clear();
  }

  Future<void> _editSelected(GroupedSelectionState selection) async {
    if (selection.selectedCount != 1) return;
    if (selection.selectedItemIds.length == 1) {
      final id = selection.selectedItemIds.first;
      context.read<GroupedSelectionCubit>().clear();
      if (mounted) {
        context.push('${AppRoutes.secrets.path}/$id');
      }
      return;
    }
    if (selection.selectedGroups.length == 1) {
      final device = selection.selectedGroups.first;
      final icon = context.read<SecretsBloc>().state.iconForGroup(device);
      context.read<GroupedSelectionCubit>().clear();
      if (!mounted) return;
      final next = await SecretDeviceNameSheet.show(
        context,
        title: context.s.renameDevice,
        initial: device,
        initialIcon: icon,
      );
      if (next == null || !mounted) return;
      context.read<SecretsBloc>().add(
        SecretDeviceRenamed(from: device, to: next.name, icon: next.icon),
      );
    }
  }

  void _moveSelectedHere(GroupedSelectionState selection) {
    final target = context.read<SecretsBloc>().state.currentGroup ?? '';
    final ids = selection.selectedItemIds;
    if (ids.isNotEmpty) {
      context.read<SecretsBloc>().add(
        SecretsMovedToDevice(uuids: ids, device: target),
      );
    }
    context.read<GroupedSelectionCubit>().clear();
  }

  Widget _buildBodySliver(
    BuildContext context,
    SecretsState state,
    GroupedSelectionState selection,
  ) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    final isSelecting = selection.isSelecting;
    final isMoving = selection.isMoving;

    if (state.status == SecretsStatus.loading &&
        state.secrets.isEmpty &&
        state.devices.isEmpty) {
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
      items = items
          .where((secret) => !movingIds.contains(secret.uuid))
          .toList();
    }

    final hasAny = state.secrets.isNotEmpty || state.devices.isNotEmpty;
    if (!hasAny && groups.isEmpty && items.isEmpty) {
      if (_searching || state.isSearching) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }
      return SliverFillRemaining(
        hasScrollBody: false,
        child: MEEmptyState(
          icon: Icons.terminal_rounded,
          title: Text(s.noSecretsYet),
          message: Text(s.noSecretsYetMessage),
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
          icon: state.isRoot ? Icons.terminal_rounded : Icons.computer_rounded,
          title: Text(state.isRoot ? s.noSecretsYet : s.emptyDevice),
          message: Text(state.isRoot ? s.noSecretsYetMessage : s.emptyDevice),
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
            final device = group.name;
            final selected = selection.isGroupSelected(device);
            return GroupFolderItem(
              name: device,
              count: state.countInGroup(device),
              iconKey: group.iconKey,
              position: position,
              selected: selected,
              isSelecting: isSelecting,
              isMoving: isMoving,
              onTap: () {
                if (isSelecting) {
                  context.read<GroupedSelectionCubit>().toggleGroup(device);
                  return;
                }
                _openDevice(device);
              },
              onLongPress: () {
                if (isSelecting || isMoving) return;
                context.read<GroupedSelectionCubit>().selectGroup(device);
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
              icon: Icons.computer_rounded,
              title: Text(s.emptyDevice),
              message: Text(s.emptyDevice),
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
            final secret = items[index];
            final selected = selection.isItemSelected(secret.uuid);
            final position = ItemPosition.fromIndex(index, items.length);

            Widget icon;
            if (isSelecting) {
              icon = Checkbox(
                value: selected,
                onChanged: (_) => context
                    .read<GroupedSelectionCubit>()
                    .toggleItem(secret.uuid),
              );
            } else {
              icon = SettingsIcon(
                secret.kind.icon,
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
              );
            }

            return ActionItem(
              title: secret.displayName,
              subtitle: Text(
                secret.listSubtitle(context),
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
                  context.read<GroupedSelectionCubit>().toggleItem(secret.uuid);
                  return;
                }
                if (isMoving) return;
                context.push('${AppRoutes.secrets.path}/${secret.uuid}');
              },
              onLongPress: () {
                if (isSelecting || isMoving) return;
                HapticFeedback.selectionClick();
                context.read<GroupedSelectionCubit>().selectItem(secret.uuid);
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
        return BlocBuilder<SecretsBloc, SecretsState>(
          builder: (context, state) {
            final isSelecting = selection.isSelecting;
            final isMoving = selection.isMoving;
            final hideFab = isSelecting || isMoving || _searching;
            final title = state.isRoot
                ? s.secrets
                : (state.currentGroup ?? s.secrets);

            Widget? customAppBar;
            var actions = <Widget>[];

            Widget createAction() {
              return MEIconButton(
                tooltip: s.addDevice,
                variant: MEButtonVariant.text,
                onPressed: _createDevice,
                icon: const Icon(Icons.create_new_folder_outlined),
              );
            }

            Widget filterAction() {
              return BlocBuilder<SecretsBloc, SecretsState>(
                buildWhen: (p, c) => p.filterKinds != c.filterKinds,
                builder: (context, filterState) {
                  return MEBadge(
                    visible: filterState.filterKinds.isNotEmpty,
                    child: MEIconButton(
                      tooltip: s.sortAndFilter,
                      variant: MEButtonVariant.text,
                      onPressed: () => SecretsFilterSheet.show(context),
                      icon: const Icon(Icons.filter_list_rounded),
                    ),
                  );
                },
              );
            }

            if (_searching) {
              customAppBar = AppBar(
                key: const ValueKey('secrets-searching-app-bar'),
                automaticallyImplyLeading: false,
                toolbarHeight: 72,
                titleSpacing: 8,
                title: MESearchBar(
                  hintText: s.searchSecrets,
                  leading: MEIconButton(
                    variant: MEButtonVariant.text,
                    onPressed: _exitSearch,
                    icon: Icon(Icons.adaptive.arrow_back_rounded),
                  ),
                  trailing: [filterAction()],
                  onChanged: (value) => context.read<SecretsBloc>().add(
                    SecretsSearchChanged(value.trim()),
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
                          onPressed: _createDevice,
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
                    tooltip: s.devices,
                    variant: MEButtonVariant.text,
                    onPressed: () => SecretDeviceActionsSheet.show(
                      context,
                      device: state.currentGroup!,
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
                    : MEFab(icon: const Icon(Icons.add), onPressed: _addSecret),
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
