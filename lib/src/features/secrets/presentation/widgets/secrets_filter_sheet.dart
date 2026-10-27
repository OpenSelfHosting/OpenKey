import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openkey_app/src/src.dart';

/// Sort + kind filter sheet for developer secrets.
class SecretsFilterSheet extends StatefulWidget {
  const SecretsFilterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showMEBottomSheet<void>(
      context: context,
      builder: (_) => const SecretsFilterSheet(),
    );
  }

  @override
  State<SecretsFilterSheet> createState() => _SecretsFilterSheetState();
}

class _SecretsFilterSheetState extends State<SecretsFilterSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late List<SecretKind> _selectedKinds;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedKinds = List.of(context.read<SecretsBloc>().state.filterKinds);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleKind(SecretKind kind) {
    setState(() {
      if (_selectedKinds.contains(kind)) {
        _selectedKinds.remove(kind);
      } else {
        _selectedKinds.add(kind);
      }
    });
    context.read<SecretsBloc>().add(
      SecretsKindFilterChanged(List.of(_selectedKinds)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final s = context.s;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                Tab(text: s.sortBy),
                Tab(text: s.secretKind),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _tabController.index == 0
                    ? const _SecretsSortSection(key: ValueKey('sort'))
                    : _KindFilterSection(
                        key: const ValueKey('kinds'),
                        selected: _selectedKinds,
                        onToggle: _toggleKind,
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SecretsSortSection extends StatelessWidget {
  const _SecretsSortSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SecretsBloc, SecretsState>(
      buildWhen: (p, c) =>
          p.order != c.order || p.reverseOrder != c.reverseOrder,
      builder: (context, state) {
        final bloc = context.read<SecretsBloc>();
        final orders = OrderType.values
            .where((o) => o != OrderType.byCustomOrder)
            .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < orders.length; i++)
              _SortOption(
                order: orders[i],
                selected: state.order == orders[i],
                index: i,
                total: orders.length,
                onSelect: (o) => bloc.add(SetSecretsOrderEvent(o)),
              ),
            const SizedBox(height: 12),
            _ReverseRow(
              value: state.reverseOrder,
              subtitle: context.s.reverseOrderSecretsSubtitle,
              onChanged: (v) => bloc.add(SetSecretsReverseOrderEvent(v)),
            ),
          ],
        );
      },
    );
  }
}

class _KindFilterSection extends StatelessWidget {
  const _KindFilterSection({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  final List<SecretKind> selected;
  final ValueChanged<SecretKind> onToggle;

  @override
  Widget build(BuildContext context) {
    final kinds = SecretKind.values;
    final colors = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < kinds.length; i++)
          Builder(
            builder: (context) {
              final kind = kinds[i];
              final isSelected = selected.contains(kind);
              return ActionItem(
                title: kind.label(context),
                selected: isSelected,
                icon: ExpressiveIconContainer(
                  size: 36,
                  backgroundColor: colors.primary.withValues(
                    alpha: isSelected ? 0.2 : 0.1,
                  ),
                  shape: ExpressiveShape.cookie6Sided,
                  child: Icon(kind.icon, size: 18, color: colors.primary),
                ),
                trailing: Checkbox(
                  value: isSelected,
                  shape: const CircleBorder(),
                  onChanged: (_) => onToggle(kind),
                ),
                onTap: () => onToggle(kind),
                itemPosition: ItemPosition.fromIndex(i, kinds.length),
              );
            },
          ),
      ],
    );
  }
}

class _SortOption extends StatelessWidget {
  const _SortOption({
    required this.order,
    required this.selected,
    required this.index,
    required this.total,
    required this.onSelect,
  });

  final OrderType order;
  final bool selected;
  final int index;
  final int total;
  final ValueChanged<OrderType> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ActionItem(
      title: order.getName(context),
      itemPosition: ItemPosition.fromIndex(index, total),
      tileColor: selected
          ? colors.secondaryContainer
          : colors.surfaceContainerHigh,
      titleColor: selected ? colors.onSecondaryContainer : null,
      icon: ExpressiveIconContainer(
        size: 36,
        backgroundColor: selected
            ? colors.secondary
            : colors.surfaceContainerHighest,
        shape: switch (order) {
          OrderType.byCreationTime => ExpressiveShape.cookie6Sided,
          OrderType.byLastModified => ExpressiveShape.cookie9Sided,
          OrderType.byName => ExpressiveShape.cookie12Sided,
          OrderType.byCustomOrder => ExpressiveShape.cookie4Sided,
        },
        child: Icon(
          switch (order) {
            OrderType.byCreationTime => Icons.schedule_rounded,
            OrderType.byLastModified => Icons.update_rounded,
            OrderType.byName => Icons.sort_by_alpha_rounded,
            OrderType.byCustomOrder => Icons.reorder_rounded,
          },
          size: 18,
          color: selected ? colors.onSecondary : colors.onSurfaceVariant,
        ),
      ),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: colors.secondary, size: 22)
          : null,
      onTap: () => onSelect(order),
    );
  }
}

class _ReverseRow extends StatelessWidget {
  const _ReverseRow({
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
