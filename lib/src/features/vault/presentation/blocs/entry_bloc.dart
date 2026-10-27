import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

enum VaultViewMode { normal, searching }

@lazySingleton
class EntryBloc extends Bloc<EntryEvent, EntryState> {
  EntryBloc(
    this._watchEntries,
    this._createEntry,
    this._updateEntry,
    this._deleteEntry,
    this._moveEntries,
    this._metadata,
  ) : super(EntryState.fromStore(_metadata)) {
    on<EntryStarted>(_onStarted);
    on<EntryCreated>(_onCreated);
    on<EntryUpdated>(_onUpdated);
    on<EntryDeleted>(_onDeleted);
    on<EntriesMoved>(_onMoved);
    on<EntrySearchChanged>(_onSearch);
    on<EntrySearchModeChanged>(_onSearchMode);
    on<EntryTagFilterChanged>(_onTagFilter);
    on<SetEntryOrderEvent>(_onSetOrder);
    on<SetEntryReverseOrderEvent>(_onSetReverseOrder);
    on<_EntryStreamUpdated>(_onStreamUpdate);
  }

  final WatchEntriesUsecase _watchEntries;
  final CreateEntryUsecase _createEntry;
  final UpdateEntryUsecase _updateEntry;
  final DeleteEntryUsecase _deleteEntry;
  final MoveEntriesUsecase _moveEntries;
  final VaultMetadataStore _metadata;
  StreamSubscription<List<VaultEntry>>? _sub;
  String? _folderScopeBeforeSearch;
  int _watchGeneration = 0;

  Future<void> _onStarted(EntryStarted event, Emitter<EntryState> emit) async {
    final scope = event.collectionUuid ?? kVaultRootScope;

    // Already watching the full vault: only switch the folder filter.
    // Re-subscribing per folder cleared the list and raced with creates, which
    // made passwords vanish / appear to leak across folders (shared singleton).
    if (_sub != null && !event.forceReload) {
      if (state.collectionUuid == scope) return;
      emit(
        state.copyWith(
          collectionUuid: scope,
          // Keep loading if the first snapshot has not arrived yet — otherwise
          // the UI flashes an empty "ready" list until pull-to-refresh.
          status: state.status == EntryStatus.ready
              ? EntryStatus.ready
              : EntryStatus.loading,
          query: state.mode == VaultViewMode.searching ? state.query : '',
        ),
      );
      return;
    }

    await stopWatching();
    final generation = _watchGeneration;
    emit(
      EntryState(
        status: EntryStatus.loading,
        collectionUuid: scope,
        query: state.mode == VaultViewMode.searching ? state.query : '',
        mode: state.mode,
        filterTags: state.filterTags,
        order: state.order,
        reverseOrder: state.reverseOrder,
        entries: const [],
      ),
    );
    // Always watch every password entry; [scopedEntries] filters by folder.
    _sub = _watchEntries(collectionUuid: '__all__').listen((items) {
      if (generation != _watchGeneration) return;
      add(_EntryStreamUpdated(items, generation));
    }, onError: (_) {});
  }

  Future<void> stopWatching() async {
    final sub = _sub;
    _sub = null;
    _watchGeneration++;
    detachWatch(sub);
  }

  void _onStreamUpdate(_EntryStreamUpdated event, Emitter<EntryState> emit) {
    if (event.generation != _watchGeneration) return;
    emit(state.copyWith(status: EntryStatus.ready, entries: event.entries));
    // Keep native Autofill cache in sync while the vault is unlocked.
    unawaited(sl<AutofillBridge>().syncCredentials());
  }

  Future<void> _onCreated(EntryCreated event, Emitter<EntryState> emit) async {
    final result = await _createEntry(event.entry);
    result.fold((f) => emit(state.copyWith(error: f)), (_) {});
  }

  Future<void> _onUpdated(EntryUpdated event, Emitter<EntryState> emit) async {
    final result = await _updateEntry(event.entry);
    result.fold((f) => emit(state.copyWith(error: f)), (_) {});
  }

  Future<void> _onDeleted(EntryDeleted event, Emitter<EntryState> emit) async {
    final result = await _deleteEntry(event.uuid);
    result.fold((f) => emit(state.copyWith(error: f)), (_) {});
  }

  Future<void> _onMoved(EntriesMoved event, Emitter<EntryState> emit) async {
    if (event.entries.isEmpty) return;
    final target = event.targetCollectionUuid == kVaultRootScope
        ? null
        : event.targetCollectionUuid;
    final movedIds = {for (final e in event.entries) e.uuid};

    // Optimistic UI so the destination folder reflects the move immediately.
    emit(
      state.copyWith(
        status: EntryStatus.ready,
        entries: [
          for (final e in state.entries)
            if (movedIds.contains(e.uuid))
              target == null
                  ? e.copyWith(clearCollection: true)
                  : e.copyWith(collectionUuid: target)
            else
              e,
        ],
      ),
    );

    final result = await _moveEntries(
      MoveEntriesParams(
        uuids: movedIds.toList(),
        collectionUuid: target,
      ),
    );
    result.fold((f) {
      emit(state.copyWith(error: f));
      // Resync from DB if the write failed.
      add(
        EntryStarted(
          collectionUuid: state.collectionUuid,
          forceReload: true,
        ),
      );
    }, (_) {});
  }

  void _onSearch(EntrySearchChanged event, Emitter<EntryState> emit) {
    emit(state.copyWith(query: event.query));
  }

  Future<void> _onSearchMode(
    EntrySearchModeChanged event,
    Emitter<EntryState> emit,
  ) async {
    if (event.searching) {
      _folderScopeBeforeSearch = state.collectionUuid;
      emit(state.copyWith(mode: VaultViewMode.searching, query: ''));
      add(const EntryStarted(collectionUuid: '__all__'));
    } else {
      final scope = _folderScopeBeforeSearch ?? kVaultRootScope;
      _folderScopeBeforeSearch = null;
      emit(
        state.copyWith(
          mode: VaultViewMode.normal,
          query: '',
          clearFilterTags: true,
        ),
      );
      add(EntryStarted(collectionUuid: scope));
    }
  }

  void _onTagFilter(EntryTagFilterChanged event, Emitter<EntryState> emit) {
    emit(state.copyWith(filterTags: event.tags));
  }

  Future<void> _onSetOrder(
    SetEntryOrderEvent event,
    Emitter<EntryState> emit,
  ) async {
    await _metadata.setEntriesOrder(event.order.index);
    var reverseOrder = state.reverseOrder;
    if (event.order == OrderType.byCustomOrder && reverseOrder) {
      reverseOrder = false;
      await _metadata.setEntriesReverseOrder(false);
    }
    emit(state.copyWith(order: event.order, reverseOrder: reverseOrder));
  }

  Future<void> _onSetReverseOrder(
    SetEntryReverseOrderEvent event,
    Emitter<EntryState> emit,
  ) async {
    if (state.order == OrderType.byCustomOrder) return;
    if (event.reverseOrder == state.reverseOrder) return;
    await _metadata.setEntriesReverseOrder(event.reverseOrder);
    emit(state.copyWith(reverseOrder: event.reverseOrder));
  }

  @override
  Future<void> close() async {
    await stopWatching();
    return super.close();
  }
}

abstract class EntryEvent extends Equatable {
  const EntryEvent();
  @override
  List<Object?> get props => [];
}

class EntryStarted extends EntryEvent {
  const EntryStarted({this.collectionUuid, this.forceReload = false});
  final String? collectionUuid;
  /// When true, cancels and re-subscribes to the DB watch (e.g. pull-to-refresh).
  final bool forceReload;
  @override
  List<Object?> get props => [collectionUuid, forceReload];
}

class EntryCreated extends EntryEvent {
  const EntryCreated(this.entry);
  final VaultEntry entry;
  @override
  List<Object?> get props => [entry];
}

class EntryUpdated extends EntryEvent {
  const EntryUpdated(this.entry);
  final VaultEntry entry;
  @override
  List<Object?> get props => [entry];
}

class EntryDeleted extends EntryEvent {
  const EntryDeleted(this.uuid);
  final String uuid;
  @override
  List<Object?> get props => [uuid];
}

class EntriesMoved extends EntryEvent {
  const EntriesMoved({
    required this.entries,
    required this.targetCollectionUuid,
  });
  final List<VaultEntry> entries;
  final String? targetCollectionUuid;
  @override
  List<Object?> get props => [entries, targetCollectionUuid];
}

class EntrySearchChanged extends EntryEvent {
  const EntrySearchChanged(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

class EntrySearchModeChanged extends EntryEvent {
  const EntrySearchModeChanged(this.searching);
  final bool searching;
  @override
  List<Object?> get props => [searching];
}

class EntryTagFilterChanged extends EntryEvent {
  const EntryTagFilterChanged(this.tags);
  final List<String> tags;
  @override
  List<Object?> get props => [tags];
}

class SetEntryOrderEvent extends EntryEvent {
  const SetEntryOrderEvent(this.order);
  final OrderType order;
  @override
  List<Object?> get props => [order];
}

class SetEntryReverseOrderEvent extends EntryEvent {
  const SetEntryReverseOrderEvent(this.reverseOrder);
  final bool reverseOrder;
  @override
  List<Object?> get props => [reverseOrder];
}

class _EntryStreamUpdated extends EntryEvent {
  const _EntryStreamUpdated(this.entries, this.generation);
  final List<VaultEntry> entries;
  final int generation;
  @override
  List<Object?> get props => [entries, generation];
}

enum EntryStatus { initial, loading, ready }

class EntryState extends Equatable {
  const EntryState({
    this.status = EntryStatus.initial,
    this.entries = const [],
    this.query = '',
    this.collectionUuid,
    this.mode = VaultViewMode.normal,
    this.filterTags = const [],
    this.order = OrderType.byLastModified,
    this.reverseOrder = true,
    this.error,
  });

  factory EntryState.fromStore(VaultMetadataStore metadata) {
    final storedOrderIndex = metadata.entriesOrderIndex;
    final storedReverse = metadata.entriesReverseOrder;
    final order =
        (storedOrderIndex != null &&
            storedOrderIndex >= 0 &&
            storedOrderIndex < OrderType.values.length)
        ? OrderType.values[storedOrderIndex]
        : OrderType.byLastModified;
    final reverse = order == OrderType.byCustomOrder
        ? false
        : (storedReverse ?? true);
    return EntryState(order: order, reverseOrder: reverse);
  }

  final EntryStatus status;
  final List<VaultEntry> entries;
  final String query;
  final String? collectionUuid;
  final VaultViewMode mode;
  final List<String> filterTags;
  final OrderType order;
  final bool reverseOrder;
  final AppFailure? error;

  bool get isSearching => mode == VaultViewMode.searching;

  /// Unique tag names across the currently loaded entries.
  List<String> get availableTags {
    final set = <String>{};
    for (final e in entries) {
      set.addAll(e.tags);
    }
    final list = set.toList()..sort();
    return list;
  }

  /// Entries belonging to the active folder scope (maham-style).
  List<VaultEntry> get scopedEntries {
    if (isSearching || collectionUuid == null || collectionUuid == '__all__') {
      return entries;
    }
    if (collectionUuid == kVaultRootScope) {
      return entries.where((e) => e.collectionUuid == null).toList();
    }
    return entries.where((e) => e.collectionUuid == collectionUuid).toList();
  }

  List<VaultEntry> get filtered {
    var list = scopedEntries;
    if (filterTags.isNotEmpty) {
      list = list
          .where((e) => filterTags.any((t) => e.tags.contains(t)))
          .toList();
    }
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (e) =>
                e.title.toLowerCase().contains(q) ||
                e.username.toLowerCase().contains(q) ||
                e.notes.toLowerCase().contains(q) ||
                e.urls.any((u) => u.toLowerCase().contains(q)) ||
                e.tags.any((t) => t.toLowerCase().contains(q)),
          )
          .toList();
    }
    final sorted = List<VaultEntry>.of(list);
    order.sortEntries(sorted, reverseOrder);
    return sorted;
  }

  EntryState copyWith({
    EntryStatus? status,
    List<VaultEntry>? entries,
    String? query,
    String? collectionUuid,
    VaultViewMode? mode,
    List<String>? filterTags,
    OrderType? order,
    bool? reverseOrder,
    AppFailure? error,
    bool clearFilterTags = false,
  }) {
    return EntryState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      query: query ?? this.query,
      collectionUuid: collectionUuid ?? this.collectionUuid,
      mode: mode ?? this.mode,
      filterTags: clearFilterTags ? const [] : (filterTags ?? this.filterTags),
      order: order ?? this.order,
      reverseOrder: reverseOrder ?? this.reverseOrder,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    entries,
    query,
    collectionUuid,
    mode,
    filterTags,
    order,
    reverseOrder,
    error,
  ];
}
