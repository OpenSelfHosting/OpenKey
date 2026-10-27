import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openkey_app/src/src.dart';

/// Unified M3 Expressive bottom sheet for folder + entry sorting (maham-style).
class VaultFilterSheet extends StatefulWidget {
  const VaultFilterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showMEBottomSheet<void>(
      context: context,
      builder: (_) => const VaultFilterSheet(),
    );
  }

  @override
  State<VaultFilterSheet> createState() => _VaultFilterSheetState();
}

class _VaultFilterSheetState extends State<VaultFilterSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final s = context.s;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(s.sortAndFilter, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(4),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: colors.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: colors.onSecondaryContainer,
              unselectedLabelColor: colors.onSurfaceVariant,
              labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              splashBorderRadius: BorderRadius.circular(12),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.folder_rounded, size: 18),
                      const SizedBox(width: 6),
                      Text(s.applyToFolders),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.key_rounded, size: 18),
                      const SizedBox(width: 6),
                      Text(s.applyToEntries),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeInOutCubicEmphasized,
                switchOutCurve: Curves.easeInOutCubic,
                child: _tabController.index == 0
                    ? const _FolderSortSection(key: ValueKey('folders'))
                    : const _EntrySortSection(key: ValueKey('entries')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FolderSortSection extends StatelessWidget {
  const _FolderSortSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollectionBloc, CollectionState>(
      buildWhen: (p, c) =>
          p.order != c.order || p.reverseOrder != c.reverseOrder,
      builder: (context, state) {
        final bloc = context.read<CollectionBloc>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _SectionLabel(label: context.s.sortBy),
            const SizedBox(height: 8),
            _SortOptionsList(
              currentOrder: state.order,
              onSelect: (order) => bloc.add(SetCollectionOrderEvent(order)),
            ),
            if (state.order != OrderType.byCustomOrder) ...[
              const SizedBox(height: 16),
              _SectionLabel(label: context.s.options),
              const SizedBox(height: 8),
              _ReverseToggle(
                value: state.reverseOrder,
                subtitle: context.s.reverseOrderFoldersSubtitle,
                onChanged: (v) =>
                    bloc.add(SetCollectionReverseOrderEvent(v)),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _EntrySortSection extends StatelessWidget {
  const _EntrySortSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EntryBloc, EntryState>(
      buildWhen: (p, c) =>
          p.order != c.order || p.reverseOrder != c.reverseOrder,
      builder: (context, state) {
        final bloc = context.read<EntryBloc>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _SectionLabel(label: context.s.sortBy),
            const SizedBox(height: 8),
            _SortOptionsList(
              currentOrder: state.order,
              onSelect: (order) => bloc.add(SetEntryOrderEvent(order)),
            ),
            if (state.order != OrderType.byCustomOrder) ...[
              const SizedBox(height: 16),
              _SectionLabel(label: context.s.options),
              const SizedBox(height: 8),
              _ReverseToggle(
                value: state.reverseOrder,
                subtitle: context.s.reverseOrderEntriesSubtitle,
                onChanged: (v) => bloc.add(SetEntryReverseOrderEvent(v)),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SortOptionsList extends StatelessWidget {
  const _SortOptionsList({
    required this.currentOrder,
    required this.onSelect,
  });

  final OrderType currentOrder;
  final ValueChanged<OrderType> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final orders = OrderType.values;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < orders.length; i++)
          _buildOption(context, colors, orders[i], i, orders.length),
      ],
    );
  }

  Widget _buildOption(
    BuildContext context,
    ColorScheme colors,
    OrderType order,
    int index,
    int total,
  ) {
    final isSelected = order == currentOrder;

    return ActionItem(
      title: order.getName(context),
      itemPosition: ItemPosition.fromIndex(index, total),
      tileColor: isSelected
          ? colors.secondaryContainer
          : colors.surfaceContainerHigh,
      titleColor: isSelected ? colors.onSecondaryContainer : null,
      icon: ExpressiveIconContainer(
        size: 36,
        backgroundColor: isSelected
            ? colors.secondary
            : colors.surfaceContainerHighest,
        shape: _shapeForOrder(order),
        child: Icon(
          _iconForOrder(order),
          size: 18,
          color: isSelected ? colors.onSecondary : colors.onSurfaceVariant,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: colors.secondary, size: 22)
          : null,
      onTap: () => onSelect(order),
    );
  }

  IconData _iconForOrder(OrderType order) {
    return switch (order) {
      OrderType.byCreationTime => Icons.schedule_rounded,
      OrderType.byLastModified => Icons.update_rounded,
      OrderType.byName => Icons.sort_by_alpha_rounded,
      OrderType.byCustomOrder => Icons.reorder_rounded,
    };
  }

  ExpressiveShape _shapeForOrder(OrderType order) {
    return switch (order) {
      OrderType.byCreationTime => ExpressiveShape.cookie6Sided,
      OrderType.byLastModified => ExpressiveShape.cookie9Sided,
      OrderType.byName => ExpressiveShape.cookie12Sided,
      OrderType.byCustomOrder => ExpressiveShape.cookie4Sided,
    };
  }
}

class _ReverseToggle extends StatelessWidget {
  const _ReverseToggle({
    required this.value,
    required this.subtitle,
    required this.onChanged,
  });

  final bool value;
  final String subtitle;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ActionItem(
      icon: ExpressiveIconContainer(
        size: 36,
        backgroundColor: value
            ? colors.tertiaryContainer
            : colors.surfaceContainerHighest,
        shape: ExpressiveShape.cookie6Sided,
        child: Icon(
          CupertinoIcons.sort_down,
          size: 18,
          color: value ? colors.onTertiaryContainer : colors.onSurfaceVariant,
        ),
      ),
      title: context.s.reverseOrder,
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      itemPosition: ItemPosition.alone,
      tileColor: colors.surfaceContainerHigh,
      onTap: () => onChanged(!value),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}
