import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

/// Payment cards list — folder navigation + multi-select like the vault home.
class WalletsPage extends StatelessWidget {
  const WalletsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GroupedSelectionCubit(),
      child: const _WalletsPageBody(),
    );
  }
}

class _WalletsPageBody extends StatefulWidget {
  const _WalletsPageBody();

  @override
  State<_WalletsPageBody> createState() => _WalletsPageBodyState();
}

class _WalletsPageBodyState extends State<_WalletsPageBody> {
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletBloc>().add(const WalletStarted());
    });
  }

  Future<void> _refresh() async {
    await sl<SyncService>().syncNow();
    if (!mounted) return;
    context.read<WalletBloc>().add(const WalletStarted());
  }

  void _exitSearch() {
    context.read<WalletBloc>().add(const WalletSearchChanged(''));
    setState(() => _searching = false);
  }

  Future<void> _createBank() async {
    final group = await WalletBankNameSheet.show(
      context,
      title: context.s.newBank,
    );
    if (group == null || !mounted) return;
    context.read<WalletBloc>().add(
      WalletBankCreated(group.name, icon: group.icon),
    );
    showMEToast(
      context,
      message: context.s.bankCreated,
      kind: METoastKind.success,
    );
  }

  void _openBank(String bank) {
    context.read<WalletBloc>().add(WalletNavigateToBank(bank));
  }

  void _goRoot() {
    context.read<WalletBloc>().add(const WalletNavigateToRoot());
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

    final bloc = context.read<WalletBloc>();
    for (final id in itemIds) {
      bloc.add(WalletDeleted(id));
    }
    for (final group in groups) {
      final count = bloc.state.cards
          .where((c) => c.bank.trim().toLowerCase() == group.toLowerCase())
          .length;
      bloc.add(WalletBankDeleted(group, clearCards: count > 0));
    }
    context.read<GroupedSelectionCubit>().clear();
  }

  Future<void> _editSelected(GroupedSelectionState selection) async {
    if (selection.selectedCount != 1) return;
    if (selection.selectedItemIds.length == 1) {
      final id = selection.selectedItemIds.first;
      context.read<GroupedSelectionCubit>().clear();
      if (mounted) {
        context.push('${AppRoutes.wallets.path}/$id');
      }
      return;
    }
    if (selection.selectedGroups.length == 1) {
      final bank = selection.selectedGroups.first;
      final icon = context.read<WalletBloc>().state.iconForGroup(bank);
      context.read<GroupedSelectionCubit>().clear();
      if (!mounted) return;
      final next = await WalletBankNameSheet.show(
        context,
        title: context.s.renameBank,
        initial: bank,
        initialIcon: icon,
      );
      if (next == null || !mounted) return;
      context.read<WalletBloc>().add(
        WalletBankRenamed(from: bank, to: next.name, icon: next.icon),
      );
    }
  }

  void _moveSelectedHere(GroupedSelectionState selection) {
    final target = context.read<WalletBloc>().state.currentGroup ?? '';
    final ids = selection.selectedItemIds;
    if (ids.isNotEmpty) {
      context.read<WalletBloc>().add(
        WalletCardsMovedToBank(uuids: ids, bank: target),
      );
    }
    // Groups are flat — deleting/renaming only; move ignores selected folders.
    context.read<GroupedSelectionCubit>().clear();
  }

  List<Widget> _buildSlivers(
    BuildContext context,
    WalletState state,
    GroupedSelectionState selection,
  ) {
    final s = context.s;
    final isSelecting = selection.isSelecting;
    final isMoving = selection.isMoving;

    if (state.status == WalletStatus.loading &&
        state.cards.isEmpty &&
        state.banks.isEmpty) {
      return const [
        SliverFillRemaining(child: Center(child: MELoadingIndicator())),
      ];
    }

    final groups = (!_searching && state.isRoot && !state.isSearching)
        ? state.visibleGroups
              .where((g) => !isMoving || !selection.isGroupSelected(g.name))
              .toList()
        : const <NamedGroup>[];
    var items = state.visibleItems;
    if (isMoving) {
      final movingIds = selection.selectedItemIds.toSet();
      items = items.where((c) => !movingIds.contains(c.uuid)).toList();
    }

    final hasAny = state.cards.isNotEmpty || state.banks.isNotEmpty;
    if (!hasAny && groups.isEmpty && items.isEmpty) {
      if (_searching || state.isSearching) {
        return const [SliverToBoxAdapter(child: SizedBox.shrink())];
      }
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: MEEmptyState(
            icon: Icons.credit_card_outlined,
            title: Text(s.noCardsYet),
            message: Text(s.noCardsYetMessage),
          ),
        ),
      ];
    }

    if (groups.isEmpty &&
        items.isEmpty &&
        !isMoving &&
        !_searching &&
        !state.isSearching) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: MEEmptyState(
            icon: state.isRoot
                ? Icons.credit_card_outlined
                : Icons.account_balance_outlined,
            title: Text(state.isRoot ? s.noCardsYet : s.emptyBank),
            message: Text(state.isRoot ? s.noCardsYetMessage : s.emptyBank),
          ),
        ),
      ];
    }

    final slivers = <Widget>[];

    if (groups.isNotEmpty) {
      slivers.add(
        FolderListSliver(
          itemCount: groups.length,
          itemBuilder: (context, index, position) {
            final group = groups[index];
            final bank = group.name;
            final selected = selection.isGroupSelected(bank);
            return GroupFolderItem(
              name: bank,
              count: state.countInGroup(bank),
              iconKey: group.iconKey,
              position: position,
              selected: selected,
              isSelecting: isSelecting,
              isMoving: isMoving,
              onTap: () {
                if (isSelecting) {
                  context.read<GroupedSelectionCubit>().toggleGroup(bank);
                  return;
                }
                _openBank(bank);
              },
              onLongPress: () {
                if (isSelecting || isMoving) return;
                context.read<GroupedSelectionCubit>().selectGroup(bank);
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
              icon: Icons.account_balance_outlined,
              title: Text(s.emptyBank),
              message: Text(s.emptyBank),
            ),
          ),
        );
      }
      return slivers;
    }

    slivers.add(
      SliverList.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final card = items[index];
          final selected = selection.isItemSelected(card.uuid);
          return _WalletCardTile(
            card: card,
            selected: selected,
            isSelecting: isSelecting,
            onTap: () {
              if (isSelecting) {
                context.read<GroupedSelectionCubit>().toggleItem(card.uuid);
                return;
              }
              if (isMoving) return;
              context.push('${AppRoutes.wallets.path}/${card.uuid}');
            },
            onLongPress: () {
              if (isSelecting || isMoving) return;
              HapticFeedback.selectionClick();
              context.read<GroupedSelectionCubit>().selectItem(card.uuid);
            },
          );
        },
      ),
    );
    slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 100)));
    return slivers;
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return BlocBuilder<GroupedSelectionCubit, GroupedSelectionState>(
      builder: (context, selection) {
        return BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) {
            final isSelecting = selection.isSelecting;
            final isMoving = selection.isMoving;
            final hideFab = isSelecting || isMoving || _searching;
            final title = state.isRoot
                ? s.paymentCards
                : (state.currentGroup ?? s.paymentCards);

            Widget? customAppBar;
            var actions = <Widget>[];

            Widget createAction() {
              return MEIconButton(
                tooltip: s.addBank,
                variant: MEButtonVariant.text,
                onPressed: _createBank,
                icon: const Icon(Icons.create_new_folder_outlined),
              );
            }

            Widget filterAction() {
              return BlocBuilder<WalletBloc, WalletState>(
                buildWhen: (p, c) => p.filterBrands != c.filterBrands,
                builder: (context, filterState) {
                  return MEBadge(
                    visible: filterState.filterBrands.isNotEmpty,
                    child: MEIconButton(
                      tooltip: s.sortAndFilter,
                      variant: MEButtonVariant.text,
                      onPressed: () => CardsFilterSheet.show(context),
                      icon: const Icon(Icons.filter_list_rounded),
                    ),
                  );
                },
              );
            }

            if (_searching) {
              customAppBar = AppBar(
                key: const ValueKey('cards-searching-app-bar'),
                automaticallyImplyLeading: false,
                toolbarHeight: 72,
                titleSpacing: 8,
                title: MESearchBar(
                  hintText: s.searchCards,
                  leading: MEIconButton(
                    variant: MEButtonVariant.text,
                    onPressed: _exitSearch,
                    icon: Icon(Icons.adaptive.arrow_back_rounded),
                  ),
                  trailing: [filterAction()],
                  onChanged: (value) => context.read<WalletBloc>().add(
                    WalletSearchChanged(value.trim()),
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
                          onPressed: _createBank,
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
                    tooltip: s.banks,
                    variant: MEButtonVariant.text,
                    onPressed: () => WalletBankActionsSheet.show(
                      context,
                      bank: state.currentGroup!,
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
                          context.push(AppRoutes.walletNew.path);
                        },
                      ),
                slivers: [
                  if (!_searching)
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  ...() {
                    final cardSlivers = _buildSlivers(
                      context,
                      state,
                      selection,
                    );
                    if (cardSlivers.length == 1) return cardSlivers;
                    return [SliverMainAxisGroup(slivers: cardSlivers)];
                  }(),
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

class _WalletCardTile extends StatelessWidget {
  const _WalletCardTile({
    required this.card,
    required this.onTap,
    this.onLongPress,
    this.selected = false,
    this.isSelecting = false,
  });

  final WalletCard card;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool selected;
  final bool isSelecting;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(MECorners.extraLarge),
        child: Stack(
          children: [
            IgnorePointer(
              child: MECreditCard(
                number: card.number,
                holder: card.holder,
                expiry: card.expiry,
                cvc: card.cvc,
                bankName: card.bank,
                brand: card.brand.name,
                interactive: false,
                border: selected
                    ? Border.all(color: scheme.primary, width: 3)
                    : null,
              ),
            ),
            if (isSelecting)
              PositionedDirectional(
                top: 8,
                start: 8,
                child: Material(
                  color: scheme.surface.withValues(alpha: 0.9),
                  shape: const CircleBorder(),
                  child: Checkbox(
                    value: selected,
                    shape: const CircleBorder(),
                    onChanged: (_) => onTap(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
