import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openkey_app/src/src.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc(this._repository, this._metadata, this._sync)
      : super(WalletState.fromStore(_metadata)) {
    on<WalletStarted>(_onStarted);
    on<WalletCreated>(_onCreated);
    on<WalletUpdated>(_onUpdated);
    on<WalletDeleted>(_onDeleted);
    on<WalletMovedToBank>(_onMoved);
    on<WalletCardsMovedToBank>(_onBulkMoved);
    on<WalletBankCreated>(_onBankCreated);
    on<WalletBankRenamed>(_onBankRenamed);
    on<WalletBankDeleted>(_onBankDeleted);
    on<WalletSearchChanged>(_onSearch);
    on<WalletNavigateToBank>(_onNavigateToBank);
    on<WalletNavigateToRoot>(_onNavigateToRoot);
    on<SetCardsOrderEvent>(_onSetCardsOrder);
    on<SetCardsReverseOrderEvent>(_onSetCardsReverse);
    on<WalletBrandFilterChanged>(_onBrandFilter);
    on<_WalletCardsUpdated>(_onCardsUpdated);
  }

  final WalletRepository _repository;
  final VaultMetadataStore _metadata;
  final SyncService _sync;
  StreamSubscription<List<WalletCard>>? _cardsSub;

  Future<void> _onStarted(WalletStarted event, Emitter<WalletState> emit) async {
    await stopWatching();
    emit(
      state.copyWith(
        status: WalletStatus.loading,
        banks: _metadata.walletBanks,
      ),
    );
    _cardsSub = _repository.watchCards().listen(
      (cards) => add(_WalletCardsUpdated(cards)),
      onError: (_) {},
    );
  }

  /// Cancels Drift watches before the encrypted DB is closed (lock / reset).
  Future<void> stopWatching() async {
    final sub = _cardsSub;
    _cardsSub = null;
    detachWatch(sub);
  }

  Future<void> _persistBanks(List<NamedGroup> banks) async {
    await _metadata.setWalletBanks(banks);
  }

  List<NamedGroup> _mergeBanks(
    List<NamedGroup> stored,
    List<WalletCard> cards,
  ) {
    final byKey = <String, NamedGroup>{};
    void add(NamedGroup group) {
      final name = group.name.trim();
      if (name.isEmpty) return;
      final key = name.toLowerCase();
      final existing = byKey[key];
      if (existing == null) {
        byKey[key] = group.copyWith(name: name);
        return;
      }
      // Prefer a non-default custom icon already stored.
      final keepIcon = existing.iconKey != NamedGroup.bankDefaultIcon ||
              group.iconKey == NamedGroup.bankDefaultIcon
          ? existing.iconKey
          : group.iconKey;
      byKey[key] = existing.copyWith(name: name, icon: keepIcon);
    }

    for (final b in stored) {
      add(b);
    }
    for (final c in cards) {
      add(NamedGroup(name: c.bank, icon: NamedGroup.bankDefaultIcon));
    }
    final out = byKey.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return out;
  }

  void _onCardsUpdated(_WalletCardsUpdated event, Emitter<WalletState> emit) {
    final banks = _mergeBanks(state.banks, event.cards);
    emit(
      state.copyWith(
        status: WalletStatus.ready,
        cards: event.cards,
        banks: banks,
      ),
    );
  }

  Future<void> _onCreated(WalletCreated event, Emitter<WalletState> emit) async {
    final result = await _repository.createCard(event.card);
    await result.fold(
      (f) async => emit(state.copyWith(error: f)),
      (created) async {
        if (created.bank.trim().isNotEmpty) {
          final next = _mergeBanks(state.banks, [created]);
          await _persistBanks(next);
          emit(state.copyWith(banks: next));
        }
        unawaited(_sync.syncIfConnected());
      },
    );
  }

  Future<void> _onUpdated(WalletUpdated event, Emitter<WalletState> emit) async {
    final result = await _repository.updateCard(event.card);
    await result.fold(
      (f) async => emit(state.copyWith(error: f)),
      (updated) async {
        if (updated.bank.trim().isNotEmpty) {
          final next = _mergeBanks(state.banks, [updated]);
          await _persistBanks(next);
          emit(state.copyWith(banks: next));
        }
        unawaited(_sync.syncIfConnected());
      },
    );
  }

  Future<void> _onDeleted(WalletDeleted event, Emitter<WalletState> emit) async {
    final result = await _repository.deleteCard(event.uuid);
    result.fold(
      (f) => emit(state.copyWith(error: f)),
      (_) => unawaited(_sync.syncIfConnected()),
    );
  }

  Future<void> _onMoved(
    WalletMovedToBank event,
    Emitter<WalletState> emit,
  ) async {
    final existing = state.cards.cast<WalletCard?>().firstWhere(
          (c) => c!.uuid == event.uuid,
          orElse: () => null,
        );
    if (existing == null) {
      final loaded = await _repository.getCard(event.uuid);
      await loaded.fold(
        (f) async => emit(state.copyWith(error: f)),
        (card) async {
          if (card == null) return;
          await _moveCard(card, event.bank, emit);
        },
      );
      return;
    }
    await _moveCard(existing, event.bank, emit);
  }

  Future<void> _onBulkMoved(
    WalletCardsMovedToBank event,
    Emitter<WalletState> emit,
  ) async {
    for (final uuid in event.uuids) {
      final existing = state.cards.cast<WalletCard?>().firstWhere(
            (c) => c!.uuid == uuid,
            orElse: () => null,
          );
      if (existing != null) {
        await _moveCard(existing, event.bank, emit);
        continue;
      }
      final loaded = await _repository.getCard(uuid);
      await loaded.fold(
        (f) async => emit(state.copyWith(error: f)),
        (card) async {
          if (card == null) return;
          await _moveCard(card, event.bank, emit);
        },
      );
    }
  }

  void _onNavigateToBank(
    WalletNavigateToBank event,
    Emitter<WalletState> emit,
  ) {
    final bank = event.bank.trim();
    if (bank.isEmpty) {
      emit(state.copyWith(clearCurrentGroup: true));
      return;
    }
    emit(state.copyWith(currentGroup: bank));
  }

  void _onNavigateToRoot(
    WalletNavigateToRoot event,
    Emitter<WalletState> emit,
  ) {
    emit(state.copyWith(clearCurrentGroup: true));
  }

  Future<void> _moveCard(
    WalletCard card,
    String bank,
    Emitter<WalletState> emit,
  ) async {
    final nextBank = bank.trim();
    if (card.bank.trim() == nextBank) return;
    final updated = card.copyWith(bank: nextBank);
    final result = await _repository.updateCard(updated);
    await result.fold(
      (f) async => emit(state.copyWith(error: f)),
      (_) async {
        if (nextBank.isNotEmpty) {
          final next = _mergeBanks(state.banks, [updated]);
          await _persistBanks(next);
          emit(state.copyWith(banks: next));
        }
        unawaited(_sync.syncIfConnected());
      },
    );
  }

  Future<void> _onBankCreated(
    WalletBankCreated event,
    Emitter<WalletState> emit,
  ) async {
    final name = event.name.trim();
    if (name.isEmpty) return;
    final exists = state.banks.any(
      (b) => b.name.toLowerCase() == name.toLowerCase(),
    );
    if (exists) {
      // Update icon when recreating with a custom icon.
      if (event.icon != null) {
        final next = state.banks
            .map(
              (b) => b.name.toLowerCase() == name.toLowerCase()
                  ? b.copyWith(icon: event.icon)
                  : b,
            )
            .toList();
        await _persistBanks(next);
        emit(state.copyWith(banks: next));
      }
      return;
    }
    final group = NamedGroup(
      name: name,
      icon: event.icon ?? NamedGroup.bankDefaultIcon,
    );
    final next = _mergeBanks([...state.banks, group], state.cards);
    await _persistBanks(next);
    emit(state.copyWith(banks: next));
  }

  Future<void> _onBankRenamed(
    WalletBankRenamed event,
    Emitter<WalletState> emit,
  ) async {
    final from = event.from.trim();
    final to = event.to.trim();
    if (from.isEmpty || to.isEmpty) return;
    final sameName = from.toLowerCase() == to.toLowerCase();
    if (sameName && event.icon == null) return;

    final affected = sameName
        ? const <WalletCard>[]
        : state.cards
            .where((c) => c.bank.trim().toLowerCase() == from.toLowerCase())
            .toList();
    for (final card in affected) {
      final result = await _repository.updateCard(
        card.copyWith(bank: to),
      );
      final failed = result.fold((f) => f, (_) => null);
      if (failed != null) {
        emit(state.copyWith(error: failed));
        return;
      }
    }

    final previous = state.banks.cast<NamedGroup?>().firstWhere(
          (b) => b!.name.toLowerCase() == from.toLowerCase(),
          orElse: () => null,
        );
    final icon = event.icon ??
        previous?.iconKey ??
        NamedGroup.bankDefaultIcon;

    var next = state.banks
        .where((b) => b.name.toLowerCase() != from.toLowerCase())
        .toList();
    next = _mergeBanks(
      [...next, NamedGroup(name: to, icon: icon)],
      state.cards,
    );
    await _persistBanks(next);
    final stayInRenamed = state.currentGroup != null &&
        state.currentGroup!.toLowerCase() == from.toLowerCase();
    emit(
      state.copyWith(
        banks: next,
        currentGroup: stayInRenamed ? to : state.currentGroup,
      ),
    );
    if (affected.isNotEmpty) unawaited(_sync.syncIfConnected());
  }

  Future<void> _onBankDeleted(
    WalletBankDeleted event,
    Emitter<WalletState> emit,
  ) async {
    final name = event.name.trim();
    if (name.isEmpty) return;
    final affected = state.cards
        .where((c) => c.bank.trim().toLowerCase() == name.toLowerCase())
        .toList();
    if (event.clearCards) {
      for (final card in affected) {
        final result = await _repository.updateCard(
          card.copyWith(bank: ''),
        );
        final failed = result.fold((f) => f, (_) => null);
        if (failed != null) {
          emit(state.copyWith(error: failed));
          return;
        }
      }
    } else if (affected.isNotEmpty) {
      return;
    }
    final next = state.banks
        .where((b) => b.name.toLowerCase() != name.toLowerCase())
        .toList();
    await _persistBanks(next);
    final leavingDeleted = state.currentGroup != null &&
        state.currentGroup!.toLowerCase() == name.toLowerCase();
    emit(
      state.copyWith(
        banks: next,
        clearCurrentGroup: leavingDeleted,
      ),
    );
    if (event.clearCards && affected.isNotEmpty) {
      unawaited(_sync.syncIfConnected());
    }
  }

  void _onSearch(WalletSearchChanged event, Emitter<WalletState> emit) {
    emit(state.copyWith(query: event.query));
  }

  Future<void> _onSetCardsOrder(
    SetCardsOrderEvent event,
    Emitter<WalletState> emit,
  ) async {
    await _metadata.setCardsOrder(event.order.index);
    var reverse = state.cardsReverseOrder;
    if (event.order == OrderType.byCustomOrder && reverse) {
      reverse = false;
      await _metadata.setCardsReverseOrder(false);
    }
    emit(state.copyWith(cardsOrder: event.order, cardsReverseOrder: reverse));
  }

  Future<void> _onSetCardsReverse(
    SetCardsReverseOrderEvent event,
    Emitter<WalletState> emit,
  ) async {
    if (state.cardsOrder == OrderType.byCustomOrder) return;
    if (event.reverseOrder == state.cardsReverseOrder) return;
    await _metadata.setCardsReverseOrder(event.reverseOrder);
    emit(state.copyWith(cardsReverseOrder: event.reverseOrder));
  }

  void _onBrandFilter(
    WalletBrandFilterChanged event,
    Emitter<WalletState> emit,
  ) {
    emit(state.copyWith(filterBrands: event.brands));
  }

  @override
  Future<void> close() async {
    await stopWatching();
    return super.close();
  }
}

abstract class WalletEvent extends Equatable {
  const WalletEvent();
  @override
  List<Object?> get props => [];
}

class WalletStarted extends WalletEvent {
  const WalletStarted();
}

class WalletCreated extends WalletEvent {
  const WalletCreated(this.card);
  final WalletCard card;
  @override
  List<Object?> get props => [card];
}

class WalletUpdated extends WalletEvent {
  const WalletUpdated(this.card);
  final WalletCard card;
  @override
  List<Object?> get props => [card];
}

class WalletDeleted extends WalletEvent {
  const WalletDeleted(this.uuid);
  final String uuid;
  @override
  List<Object?> get props => [uuid];
}

class WalletMovedToBank extends WalletEvent {
  const WalletMovedToBank({required this.uuid, required this.bank});
  final String uuid;

  /// Empty string = unassigned / Other.
  final String bank;
  @override
  List<Object?> get props => [uuid, bank];
}

class WalletCardsMovedToBank extends WalletEvent {
  const WalletCardsMovedToBank({required this.uuids, required this.bank});
  final List<String> uuids;

  /// Empty string = unassigned / Other.
  final String bank;
  @override
  List<Object?> get props => [uuids, bank];
}

class WalletNavigateToBank extends WalletEvent {
  const WalletNavigateToBank(this.bank);
  final String bank;
  @override
  List<Object?> get props => [bank];
}

class WalletNavigateToRoot extends WalletEvent {
  const WalletNavigateToRoot();
}

class WalletBankCreated extends WalletEvent {
  const WalletBankCreated(this.name, {this.icon});
  final String name;
  final String? icon;
  @override
  List<Object?> get props => [name, icon];
}

class WalletBankRenamed extends WalletEvent {
  const WalletBankRenamed({
    required this.from,
    required this.to,
    this.icon,
  });
  final String from;
  final String to;
  final String? icon;
  @override
  List<Object?> get props => [from, to, icon];
}

class WalletBankDeleted extends WalletEvent {
  const WalletBankDeleted(this.name, {this.clearCards = false});
  final String name;

  /// When true, cards in this bank are moved to unassigned.
  final bool clearCards;
  @override
  List<Object?> get props => [name, clearCards];
}

class WalletSearchChanged extends WalletEvent {
  const WalletSearchChanged(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

class SetCardsOrderEvent extends WalletEvent {
  const SetCardsOrderEvent(this.order);
  final OrderType order;
  @override
  List<Object?> get props => [order];
}

class SetCardsReverseOrderEvent extends WalletEvent {
  const SetCardsReverseOrderEvent(this.reverseOrder);
  final bool reverseOrder;
  @override
  List<Object?> get props => [reverseOrder];
}

class WalletBrandFilterChanged extends WalletEvent {
  const WalletBrandFilterChanged(this.brands);
  final List<CardBrand> brands;
  @override
  List<Object?> get props => [brands];
}

class _WalletCardsUpdated extends WalletEvent {
  const _WalletCardsUpdated(this.cards);
  final List<WalletCard> cards;
  @override
  List<Object?> get props => [cards];
}

enum WalletStatus { initial, loading, ready }

class WalletState extends Equatable {
  const WalletState({
    this.status = WalletStatus.initial,
    this.cards = const [],
    this.banks = const [],
    this.currentGroup,
    this.query = '',
    this.cardsOrder = OrderType.byLastModified,
    this.cardsReverseOrder = true,
    this.filterBrands = const [],
    this.error,
  });

  factory WalletState.fromStore(VaultMetadataStore metadata) {
    OrderType resolve(int? index, OrderType fallback) {
      if (index != null && index >= 0 && index < OrderType.values.length) {
        return OrderType.values[index];
      }
      return fallback;
    }

    final cardsOrder = resolve(metadata.cardsOrderIndex, OrderType.byLastModified);
    return WalletState(
      banks: metadata.walletBanks,
      cardsOrder: cardsOrder,
      cardsReverseOrder: cardsOrder == OrderType.byCustomOrder
          ? false
          : (metadata.cardsReverseOrder ?? true),
    );
  }

  final WalletStatus status;
  final List<WalletCard> cards;

  /// Known bank groups (including empty ones the user created).
  final List<NamedGroup> banks;

  /// `null` = root; otherwise the open bank name.
  final String? currentGroup;
  final String query;
  final OrderType cardsOrder;
  final bool cardsReverseOrder;
  final List<CardBrand> filterBrands;
  final AppFailure? error;

  bool get isRoot => currentGroup == null;
  bool get isSearching => query.trim().isNotEmpty;

  String iconForGroup(String name) {
    final key = name.trim().toLowerCase();
    for (final b in banks) {
      if (b.name.toLowerCase() == key) return b.iconKey;
    }
    return NamedGroup.bankDefaultIcon;
  }

  List<WalletCard> get filteredCards {
    var list = List<WalletCard>.of(cards);
    if (filterBrands.isNotEmpty) {
      list = list.where((c) => filterBrands.contains(c.brand)).toList();
    }
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (c) =>
                c.name.toLowerCase().contains(q) ||
                c.holder.toLowerCase().contains(q) ||
                c.number.contains(q) ||
                c.brand.label.toLowerCase().contains(q) ||
                c.bank.toLowerCase().contains(q) ||
                c.notes.toLowerCase().contains(q),
          )
          .toList();
    }
    cardsOrder.sortWalletCards(list, cardsReverseOrder);
    return list;
  }

  /// Backward-compatible alias used by older call sites.
  List<WalletCard> get filtered => filteredCards;

  /// Named banks shown as folders at root (excludes the empty "Other" bucket).
  List<NamedGroup> get visibleGroups {
    final byKey = <String, NamedGroup>{
      for (final b in banks)
        if (b.name.trim().isNotEmpty) b.name.toLowerCase(): b,
    };
    for (final c in filteredCards) {
      final name = c.bankGroup;
      if (name.isEmpty) continue;
      byKey.putIfAbsent(
        name.toLowerCase(),
        () => NamedGroup(name: name, icon: NamedGroup.bankDefaultIcon),
      );
    }
    final list = byKey.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  int countInGroup(String group) {
    final key = group.trim().toLowerCase();
    return filteredCards
        .where((c) => c.bankGroup.toLowerCase() == key)
        .length;
  }

  /// Cards for the current folder view (or all matches while searching).
  List<WalletCard> get visibleItems {
    final all = filteredCards;
    if (isSearching) return all;
    if (currentGroup == null) {
      return all.where((c) => c.bankGroup.isEmpty).toList();
    }
    final key = currentGroup!.trim().toLowerCase();
    return all.where((c) => c.bankGroup.toLowerCase() == key).toList();
  }

  /// Bank groups for the list UI — includes empty created banks.
  Map<String, List<WalletCard>> groupedByBank() {
    final map = <String, List<WalletCard>>{
      for (final b in banks) b.name: <WalletCard>[],
    };
    for (final card in filteredCards) {
      final key = card.bankGroup;
      map.putIfAbsent(key, () => []).add(card);
    }
    final keys = map.keys.toList()
      ..sort((a, b) {
        if (a.isEmpty) return 1;
        if (b.isEmpty) return -1;
        return a.toLowerCase().compareTo(b.toLowerCase());
      });
    return {for (final k in keys) k: map[k]!};
  }

  WalletState copyWith({
    WalletStatus? status,
    List<WalletCard>? cards,
    List<NamedGroup>? banks,
    String? currentGroup,
    bool clearCurrentGroup = false,
    String? query,
    OrderType? cardsOrder,
    bool? cardsReverseOrder,
    List<CardBrand>? filterBrands,
    AppFailure? error,
  }) {
    return WalletState(
      status: status ?? this.status,
      cards: cards ?? this.cards,
      banks: banks ?? this.banks,
      currentGroup:
          clearCurrentGroup ? null : (currentGroup ?? this.currentGroup),
      query: query ?? this.query,
      cardsOrder: cardsOrder ?? this.cardsOrder,
      cardsReverseOrder: cardsReverseOrder ?? this.cardsReverseOrder,
      filterBrands: filterBrands ?? this.filterBrands,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        cards,
        banks,
        currentGroup,
        query,
        cardsOrder,
        cardsReverseOrder,
        filterBrands,
        error,
      ];
}
