import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openkey_app/src/src.dart';

/// Sort + brand filter sheet for payment cards (maham HomeFilterSheet style).
class CardsFilterSheet extends StatefulWidget {
  const CardsFilterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showMEBottomSheet<void>(
      context: context,
      builder: (_) => const CardsFilterSheet(),
    );
  }

  @override
  State<CardsFilterSheet> createState() => _CardsFilterSheetState();
}

class _CardsFilterSheetState extends State<CardsFilterSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late List<CardBrand> _selectedBrands;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedBrands = List.of(context.read<WalletBloc>().state.filterBrands);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleBrand(CardBrand brand) {
    setState(() {
      if (_selectedBrands.contains(brand)) {
        _selectedBrands.remove(brand);
      } else {
        _selectedBrands.add(brand);
      }
    });
    context.read<WalletBloc>().add(
      WalletBrandFilterChanged(List.of(_selectedBrands)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final s = context.s;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
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
              labelStyle: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              splashBorderRadius: BorderRadius.circular(12),
              tabs: [
                Tab(text: s.sortBy),
                Tab(text: s.brands),
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
                    ? const _CardsSortSection(key: ValueKey('sort'))
                    : _BrandFilterSection(
                        key: const ValueKey('brands'),
                        selected: _selectedBrands,
                        onToggle: _toggleBrand,
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CardsSortSection extends StatelessWidget {
  const _CardsSortSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      buildWhen: (p, c) =>
          p.cardsOrder != c.cardsOrder ||
          p.cardsReverseOrder != c.cardsReverseOrder,
      builder: (context, state) {
        final bloc = context.read<WalletBloc>();
        // Skip custom order for cards (no sortOrder field).
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
                selected: state.cardsOrder == orders[i],
                index: i,
                total: orders.length,
                onSelect: (o) => bloc.add(SetCardsOrderEvent(o)),
              ),
            const SizedBox(height: 12),
            _ReverseRow(
              value: state.cardsReverseOrder,
              subtitle: context.s.reverseOrderCardsSubtitle,
              onChanged: (v) => bloc.add(SetCardsReverseOrderEvent(v)),
            ),
          ],
        );
      },
    );
  }
}

class _BrandFilterSection extends StatelessWidget {
  const _BrandFilterSection({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  final List<CardBrand> selected;
  final ValueChanged<CardBrand> onToggle;

  @override
  Widget build(BuildContext context) {
    final brands = CardBrand.values.where((b) => b != CardBrand.other).toList();
    final colors = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < brands.length; i++)
          ActionItem(
            title: brands[i].label,
            selected: selected.contains(brands[i]),
            icon: ExpressiveIconContainer(
              size: 36,
              backgroundColor: colors.primary.withValues(
                alpha: selected.contains(brands[i]) ? 0.2 : 0.1,
              ),
              shape: ExpressiveShape.cookie9Sided,
              child: Icon(
                Icons.credit_card_rounded,
                size: 18,
                color: colors.primary,
              ),
            ),
            trailing: Checkbox(
              value: selected.contains(brands[i]),
              shape: const CircleBorder(),
              onChanged: (_) => onToggle(brands[i]),
            ),
            onTap: () => onToggle(brands[i]),
            itemPosition: ItemPosition.fromIndex(i, brands.length),
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
