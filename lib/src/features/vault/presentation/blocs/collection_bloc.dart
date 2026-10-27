import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:openkey_app/src/src.dart';

@lazySingleton
class CollectionBloc extends Bloc<CollectionEvent, CollectionState> {
  CollectionBloc(
    this._watchCollections,
    this._createCollection,
    this._updateCollection,
    this._deleteCollection,
    this._moveCollections,
    this._metadata,
  ) : super(CollectionState.fromStore(_metadata)) {
    on<CollectionStarted>(_onStarted);
    on<CollectionCreated>(_onCreated);
    on<CollectionUpdated>(_onUpdated);
    on<CollectionDeleted>(_onDeleted);
    on<CollectionNavigateToFolder>(_onNavigateToFolder);
    on<CollectionNavigateBreadcrumb>(_onNavigateBreadcrumb);
    on<CollectionsMoved>(_onMoved);
    on<SetCollectionOrderEvent>(_onSetOrder);
    on<SetCollectionReverseOrderEvent>(_onSetReverseOrder);
    on<_CollectionStreamUpdated>(_onStreamUpdate);
  }

  final WatchCollectionsUsecase _watchCollections;
  final CreateCollectionUsecase _createCollection;
  final UpdateCollectionUsecase _updateCollection;
  final DeleteCollectionUsecase _deleteCollection;
  final MoveCollectionsUsecase _moveCollections;
  final VaultMetadataStore _metadata;
  StreamSubscription<List<VaultCollection>>? _sub;

  Future<void> _onStarted(
    CollectionStarted event,
    Emitter<CollectionState> emit,
  ) async {
    await stopWatching();
    if (event.resetNavigation) {
      emit(
        state.copyWith(
          status: CollectionStatus.loading,
          allCollections: const [],
          breadcrumb: const [],
          clearCurrentFolder: true,
        ),
      );
    } else {
      emit(state.copyWith(status: CollectionStatus.loading));
    }
    _sub = _watchCollections().listen(
      (items) => add(_CollectionStreamUpdated(items)),
      onError: (_) {},
    );
  }

  Future<void> stopWatching() async {
    final sub = _sub;
    _sub = null;
    detachWatch(sub);
  }

  void _onStreamUpdate(
    _CollectionStreamUpdated event,
    Emitter<CollectionState> emit,
  ) {
    emit(
      state.copyWith(
        status: CollectionStatus.ready,
        allCollections: event.collections,
      ),
    );
  }

  Future<void> _onCreated(
    CollectionCreated event,
    Emitter<CollectionState> emit,
  ) async {
    final result = await _createCollection(
      CreateCollectionParams(
        name: event.name,
        icon: event.icon,
        color: event.color,
        parentUuid: event.parentUuid ?? state.currentFolderUuid,
      ),
    );
    result.fold((f) => emit(state.copyWith(error: f)), (_) {});
  }

  Future<void> _onUpdated(
    CollectionUpdated event,
    Emitter<CollectionState> emit,
  ) async {
    final result = await _updateCollection(event.collection);
    result.fold((f) => emit(state.copyWith(error: f)), (_) {});
  }

  Future<void> _onDeleted(
    CollectionDeleted event,
    Emitter<CollectionState> emit,
  ) async {
    final result = await _deleteCollection(event.uuid);
    result.fold((f) => emit(state.copyWith(error: f)), (_) {});
  }

  void _onNavigateToFolder(
    CollectionNavigateToFolder event,
    Emitter<CollectionState> emit,
  ) {
    emit(
      state.copyWith(
        currentFolderUuid: event.folder.uuid,
        breadcrumb: [...state.breadcrumb, event.folder],
        clearCurrentFolder: false,
      ),
    );
  }

  void _onNavigateBreadcrumb(
    CollectionNavigateBreadcrumb event,
    Emitter<CollectionState> emit,
  ) {
    if (event.index < 0) {
      emit(
        state.copyWith(
          breadcrumb: const [],
          clearCurrentFolder: true,
        ),
      );
      return;
    }
    if (event.index < state.breadcrumb.length) {
      final crumb = state.breadcrumb.sublist(0, event.index + 1);
      emit(
        state.copyWith(
          breadcrumb: crumb,
          currentFolderUuid: crumb.last.uuid,
        ),
      );
    }
  }

  Future<void> _onMoved(
    CollectionsMoved event,
    Emitter<CollectionState> emit,
  ) async {
    final movable = event.collections
        .where((c) => _canMoveInto(c.uuid, event.targetParentUuid))
        .toList();
    if (movable.isEmpty) return;

    final target = event.targetParentUuid;
    final movedIds = {for (final c in movable) c.uuid};

    emit(
      state.copyWith(
        status: CollectionStatus.ready,
        allCollections: [
          for (final c in state.allCollections)
            if (movedIds.contains(c.uuid))
              target == null
                  ? c.copyWith(clearParent: true)
                  : c.copyWith(parentUuid: target)
            else
              c,
        ],
      ),
    );

    final result = await _moveCollections(
      MoveCollectionsParams(
        uuids: movedIds.toList(),
        parentUuid: target,
      ),
    );
    result.fold((f) {
      emit(state.copyWith(error: f));
      add(const CollectionStarted());
    }, (_) {});
  }

  Future<void> _onSetOrder(
    SetCollectionOrderEvent event,
    Emitter<CollectionState> emit,
  ) async {
    await _metadata.setCollectionsOrder(event.order.index);
    var reverseOrder = state.reverseOrder;
    if (event.order == OrderType.byCustomOrder && reverseOrder) {
      reverseOrder = false;
      await _metadata.setCollectionsReverseOrder(false);
    }
    emit(state.copyWith(order: event.order, reverseOrder: reverseOrder));
  }

  Future<void> _onSetReverseOrder(
    SetCollectionReverseOrderEvent event,
    Emitter<CollectionState> emit,
  ) async {
    if (state.order == OrderType.byCustomOrder) return;
    if (event.reverseOrder == state.reverseOrder) return;
    await _metadata.setCollectionsReverseOrder(event.reverseOrder);
    emit(state.copyWith(reverseOrder: event.reverseOrder));
  }

  /// Prevent moving a folder into itself or one of its descendants.
  bool _canMoveInto(String folderUuid, String? targetParentUuid) {
    if (targetParentUuid == null) return true;
    if (targetParentUuid == folderUuid) return false;
    var cursor = targetParentUuid;
    final byId = {for (final c in state.allCollections) c.uuid: c};
    while (true) {
      if (cursor == folderUuid) return false;
      final parent = byId[cursor]?.parentUuid;
      if (parent == null) return true;
      cursor = parent;
    }
  }

  @override
  Future<void> close() async {
    await stopWatching();
    return super.close();
  }
}

abstract class CollectionEvent extends Equatable {
  const CollectionEvent();
  @override
  List<Object?> get props => [];
}

class CollectionStarted extends CollectionEvent {
  const CollectionStarted({this.resetNavigation = false});

  /// When true, clears breadcrumb / folder scope (e.g. after backup restore).
  final bool resetNavigation;

  @override
  List<Object?> get props => [resetNavigation];
}

class CollectionCreated extends CollectionEvent {
  const CollectionCreated(
    this.name, {
    this.icon = CollectionIcons.defaultKey,
    this.color,
    this.parentUuid,
  });
  final String name;
  final String icon;
  final int? color;
  final String? parentUuid;
  @override
  List<Object?> get props => [name, icon, color, parentUuid];
}

class CollectionUpdated extends CollectionEvent {
  const CollectionUpdated(this.collection);
  final VaultCollection collection;
  @override
  List<Object?> get props => [collection];
}

class CollectionDeleted extends CollectionEvent {
  const CollectionDeleted(this.uuid);
  final String uuid;
  @override
  List<Object?> get props => [uuid];
}

class CollectionNavigateToFolder extends CollectionEvent {
  const CollectionNavigateToFolder(this.folder);
  final VaultCollection folder;
  @override
  List<Object?> get props => [folder];
}

class CollectionNavigateBreadcrumb extends CollectionEvent {
  const CollectionNavigateBreadcrumb(this.index);
  final int index;
  @override
  List<Object?> get props => [index];
}

class CollectionsMoved extends CollectionEvent {
  const CollectionsMoved({
    required this.collections,
    required this.targetParentUuid,
  });
  final List<VaultCollection> collections;
  final String? targetParentUuid;
  @override
  List<Object?> get props => [collections, targetParentUuid];
}

class SetCollectionOrderEvent extends CollectionEvent {
  const SetCollectionOrderEvent(this.order);
  final OrderType order;
  @override
  List<Object?> get props => [order];
}

class SetCollectionReverseOrderEvent extends CollectionEvent {
  const SetCollectionReverseOrderEvent(this.reverseOrder);
  final bool reverseOrder;
  @override
  List<Object?> get props => [reverseOrder];
}

class _CollectionStreamUpdated extends CollectionEvent {
  const _CollectionStreamUpdated(this.collections);
  final List<VaultCollection> collections;
  @override
  List<Object?> get props => [collections];
}

enum CollectionStatus { initial, loading, ready }

class CollectionState extends Equatable {
  const CollectionState({
    this.status = CollectionStatus.initial,
    this.allCollections = const [],
    this.currentFolderUuid,
    this.breadcrumb = const [],
    this.order = OrderType.byCreationTime,
    this.reverseOrder = true,
    this.error,
  });

  factory CollectionState.fromStore(VaultMetadataStore metadata) {
    final storedOrderIndex = metadata.collectionsOrderIndex;
    final storedReverse = metadata.collectionsReverseOrder;
    final order =
        (storedOrderIndex != null &&
            storedOrderIndex >= 0 &&
            storedOrderIndex < OrderType.values.length)
        ? OrderType.values[storedOrderIndex]
        : OrderType.byCreationTime;
    final reverse = order == OrderType.byCustomOrder
        ? false
        : (storedReverse ?? true);
    return CollectionState(order: order, reverseOrder: reverse);
  }

  final CollectionStatus status;
  final List<VaultCollection> allCollections;
  final String? currentFolderUuid;
  final List<VaultCollection> breadcrumb;
  final OrderType order;
  final bool reverseOrder;
  final AppFailure? error;

  bool get isRoot => currentFolderUuid == null;

  List<VaultCollection> get visibleCollections {
    final list = allCollections
        .where((c) => c.parentUuid == currentFolderUuid)
        .toList();
    order.sortCollections(list, reverseOrder);
    return list;
  }

  CollectionState copyWith({
    CollectionStatus? status,
    List<VaultCollection>? allCollections,
    String? currentFolderUuid,
    List<VaultCollection>? breadcrumb,
    OrderType? order,
    bool? reverseOrder,
    AppFailure? error,
    bool clearCurrentFolder = false,
  }) {
    return CollectionState(
      status: status ?? this.status,
      allCollections: allCollections ?? this.allCollections,
      currentFolderUuid: clearCurrentFolder
          ? null
          : (currentFolderUuid ?? this.currentFolderUuid),
      breadcrumb: breadcrumb ?? this.breadcrumb,
      order: order ?? this.order,
      reverseOrder: reverseOrder ?? this.reverseOrder,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    allCollections,
    currentFolderUuid,
    breadcrumb,
    order,
    reverseOrder,
    error,
  ];
}
