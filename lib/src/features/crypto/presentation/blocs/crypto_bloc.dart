import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openkey_app/src/src.dart';

class CryptoBloc extends Bloc<CryptoEvent, CryptoState> {
  CryptoBloc(this._repository, this._metadata, this._sync)
      : super(CryptoState.fromStore(_metadata)) {
    on<CryptoStarted>(_onStarted);
    on<CryptoWalletCreated>(_onCreated);
    on<CryptoWalletUpdated>(_onUpdated);
    on<CryptoWalletDeleted>(_onDeleted);
    on<CryptoMovedToFolder>(_onMoved);
    on<CryptoWalletsMovedToFolder>(_onBulkMoved);
    on<CryptoFolderCreated>(_onFolderCreated);
    on<CryptoFolderRenamed>(_onFolderRenamed);
    on<CryptoFolderDeleted>(_onFolderDeleted);
    on<CryptoSearchChanged>(_onSearch);
    on<CryptoNavigateToFolder>(_onNavigateToFolder);
    on<CryptoNavigateToRoot>(_onNavigateToRoot);
    on<SetCryptoOrderEvent>(_onSetOrder);
    on<SetCryptoReverseOrderEvent>(_onSetReverse);
    on<CryptoNetworkFilterChanged>(_onNetworkFilter);
    on<_CryptoWalletsUpdated>(_onWalletsUpdated);
  }

  final CryptoRepository _repository;
  final VaultMetadataStore _metadata;
  final SyncService _sync;
  StreamSubscription<List<CryptoWallet>>? _walletsSub;

  Future<void> _onStarted(CryptoStarted event, Emitter<CryptoState> emit) async {
    await stopWatching();
    emit(
      state.copyWith(
        status: CryptoStatus.loading,
        folders: _metadata.cryptoFolders,
      ),
    );
    _walletsSub = _repository.watchWallets().listen(
      (wallets) => add(_CryptoWalletsUpdated(wallets)),
      onError: (_) {},
    );
  }

  /// Cancels Drift watches before the encrypted DB is closed (lock / reset).
  Future<void> stopWatching() async {
    final sub = _walletsSub;
    _walletsSub = null;
    detachWatch(sub);
  }

  Future<void> _persistFolders(List<NamedGroup> folders) async {
    await _metadata.setCryptoFolders(folders);
  }

  List<NamedGroup> _mergeFolders(
    List<NamedGroup> stored,
    List<CryptoWallet> wallets,
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
      final keepIcon = existing.iconKey != NamedGroup.defaultIcon ||
              group.iconKey == NamedGroup.defaultIcon
          ? existing.iconKey
          : group.iconKey;
      byKey[key] = existing.copyWith(name: name, icon: keepIcon);
    }

    for (final f in stored) {
      add(f);
    }
    for (final w in wallets) {
      add(NamedGroup(name: w.folder));
    }
    final out = byKey.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return out;
  }

  void _onWalletsUpdated(
    _CryptoWalletsUpdated event,
    Emitter<CryptoState> emit,
  ) {
    final folders = _mergeFolders(state.folders, event.wallets);
    emit(
      state.copyWith(
        status: CryptoStatus.ready,
        wallets: event.wallets,
        folders: folders,
      ),
    );
  }

  Future<void> _onCreated(
    CryptoWalletCreated event,
    Emitter<CryptoState> emit,
  ) async {
    final result = await _repository.createWallet(event.wallet);
    await result.fold(
      (f) async => emit(state.copyWith(error: f)),
      (created) async {
        if (created.folder.trim().isNotEmpty) {
          final next = _mergeFolders(state.folders, [created]);
          await _persistFolders(next);
          emit(state.copyWith(folders: next));
        }
        unawaited(_sync.syncIfConnected());
      },
    );
  }

  Future<void> _onUpdated(
    CryptoWalletUpdated event,
    Emitter<CryptoState> emit,
  ) async {
    final result = await _repository.updateWallet(event.wallet);
    await result.fold(
      (f) async => emit(state.copyWith(error: f)),
      (updated) async {
        if (updated.folder.trim().isNotEmpty) {
          final next = _mergeFolders(state.folders, [updated]);
          await _persistFolders(next);
          emit(state.copyWith(folders: next));
        }
        unawaited(_sync.syncIfConnected());
      },
    );
  }

  Future<void> _onDeleted(
    CryptoWalletDeleted event,
    Emitter<CryptoState> emit,
  ) async {
    final result = await _repository.deleteWallet(event.uuid);
    result.fold(
      (f) => emit(state.copyWith(error: f)),
      (_) => unawaited(_sync.syncIfConnected()),
    );
  }

  Future<void> _onMoved(
    CryptoMovedToFolder event,
    Emitter<CryptoState> emit,
  ) async {
    final existing = state.wallets.cast<CryptoWallet?>().firstWhere(
          (w) => w!.uuid == event.uuid,
          orElse: () => null,
        );
    if (existing == null) {
      final loaded = await _repository.getWallet(event.uuid);
      await loaded.fold(
        (f) async => emit(state.copyWith(error: f)),
        (wallet) async {
          if (wallet == null) return;
          await _moveWallet(wallet, event.folder, emit);
        },
      );
      return;
    }
    await _moveWallet(existing, event.folder, emit);
  }

  Future<void> _onBulkMoved(
    CryptoWalletsMovedToFolder event,
    Emitter<CryptoState> emit,
  ) async {
    for (final uuid in event.uuids) {
      final existing = state.wallets.cast<CryptoWallet?>().firstWhere(
            (w) => w!.uuid == uuid,
            orElse: () => null,
          );
      if (existing != null) {
        await _moveWallet(existing, event.folder, emit);
        continue;
      }
      final loaded = await _repository.getWallet(uuid);
      await loaded.fold(
        (f) async => emit(state.copyWith(error: f)),
        (wallet) async {
          if (wallet == null) return;
          await _moveWallet(wallet, event.folder, emit);
        },
      );
    }
  }

  void _onNavigateToFolder(
    CryptoNavigateToFolder event,
    Emitter<CryptoState> emit,
  ) {
    final folder = event.folder.trim();
    if (folder.isEmpty) {
      emit(state.copyWith(clearCurrentGroup: true));
      return;
    }
    emit(state.copyWith(currentGroup: folder));
  }

  void _onNavigateToRoot(
    CryptoNavigateToRoot event,
    Emitter<CryptoState> emit,
  ) {
    emit(state.copyWith(clearCurrentGroup: true));
  }

  Future<void> _moveWallet(
    CryptoWallet wallet,
    String folder,
    Emitter<CryptoState> emit,
  ) async {
    final nextFolder = folder.trim();
    if (wallet.folder.trim() == nextFolder) return;
    final updated = wallet.copyWith(folder: nextFolder);
    final result = await _repository.updateWallet(updated);
    await result.fold(
      (f) async => emit(state.copyWith(error: f)),
      (_) async {
        if (nextFolder.isNotEmpty) {
          final next = _mergeFolders(state.folders, [updated]);
          await _persistFolders(next);
          emit(state.copyWith(folders: next));
        }
        unawaited(_sync.syncIfConnected());
      },
    );
  }

  Future<void> _onFolderCreated(
    CryptoFolderCreated event,
    Emitter<CryptoState> emit,
  ) async {
    final name = event.name.trim();
    if (name.isEmpty) return;
    final exists = state.folders.any(
      (f) => f.name.toLowerCase() == name.toLowerCase(),
    );
    if (exists) {
      if (event.icon != null) {
        final next = state.folders
            .map(
              (f) => f.name.toLowerCase() == name.toLowerCase()
                  ? f.copyWith(icon: event.icon)
                  : f,
            )
            .toList();
        await _persistFolders(next);
        emit(state.copyWith(folders: next));
      }
      return;
    }
    final group = NamedGroup(
      name: name,
      icon: event.icon ?? NamedGroup.defaultIcon,
    );
    final next = _mergeFolders([...state.folders, group], state.wallets);
    await _persistFolders(next);
    emit(state.copyWith(folders: next));
  }

  Future<void> _onFolderRenamed(
    CryptoFolderRenamed event,
    Emitter<CryptoState> emit,
  ) async {
    final from = event.from.trim();
    final to = event.to.trim();
    if (from.isEmpty || to.isEmpty) return;
    final sameName = from.toLowerCase() == to.toLowerCase();
    if (sameName && event.icon == null) return;

    final affected = sameName
        ? const <CryptoWallet>[]
        : state.wallets
            .where((w) => w.folder.trim().toLowerCase() == from.toLowerCase())
            .toList();
    for (final wallet in affected) {
      final result = await _repository.updateWallet(
        wallet.copyWith(folder: to),
      );
      final failed = result.fold((f) => f, (_) => null);
      if (failed != null) {
        emit(state.copyWith(error: failed));
        return;
      }
    }

    final previous = state.folders.cast<NamedGroup?>().firstWhere(
          (f) => f!.name.toLowerCase() == from.toLowerCase(),
          orElse: () => null,
        );
    final icon = event.icon ?? previous?.iconKey ?? NamedGroup.defaultIcon;

    var next = state.folders
        .where((f) => f.name.toLowerCase() != from.toLowerCase())
        .toList();
    next = _mergeFolders(
      [...next, NamedGroup(name: to, icon: icon)],
      state.wallets,
    );
    await _persistFolders(next);
    final stayInRenamed = state.currentGroup != null &&
        state.currentGroup!.toLowerCase() == from.toLowerCase();
    emit(
      state.copyWith(
        folders: next,
        currentGroup: stayInRenamed ? to : state.currentGroup,
      ),
    );
    if (affected.isNotEmpty) unawaited(_sync.syncIfConnected());
  }

  Future<void> _onFolderDeleted(
    CryptoFolderDeleted event,
    Emitter<CryptoState> emit,
  ) async {
    final name = event.name.trim();
    if (name.isEmpty) return;
    final affected = state.wallets
        .where((w) => w.folder.trim().toLowerCase() == name.toLowerCase())
        .toList();
    if (event.clearWallets) {
      for (final wallet in affected) {
        final result = await _repository.updateWallet(
          wallet.copyWith(folder: ''),
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
    final next = state.folders
        .where((f) => f.name.toLowerCase() != name.toLowerCase())
        .toList();
    await _persistFolders(next);
    final leavingDeleted = state.currentGroup != null &&
        state.currentGroup!.toLowerCase() == name.toLowerCase();
    emit(
      state.copyWith(
        folders: next,
        clearCurrentGroup: leavingDeleted,
      ),
    );
    if (event.clearWallets && affected.isNotEmpty) {
      unawaited(_sync.syncIfConnected());
    }
  }

  void _onSearch(CryptoSearchChanged event, Emitter<CryptoState> emit) {
    emit(state.copyWith(query: event.query));
  }

  Future<void> _onSetOrder(
    SetCryptoOrderEvent event,
    Emitter<CryptoState> emit,
  ) async {
    await _metadata.setCryptoOrder(event.order.index);
    var reverse = state.reverseOrder;
    if (event.order == OrderType.byCustomOrder && reverse) {
      reverse = false;
      await _metadata.setCryptoReverseOrder(false);
    }
    emit(state.copyWith(order: event.order, reverseOrder: reverse));
  }

  Future<void> _onSetReverse(
    SetCryptoReverseOrderEvent event,
    Emitter<CryptoState> emit,
  ) async {
    if (state.order == OrderType.byCustomOrder) return;
    if (event.reverseOrder == state.reverseOrder) return;
    await _metadata.setCryptoReverseOrder(event.reverseOrder);
    emit(state.copyWith(reverseOrder: event.reverseOrder));
  }

  void _onNetworkFilter(
    CryptoNetworkFilterChanged event,
    Emitter<CryptoState> emit,
  ) {
    emit(state.copyWith(filterNetworks: event.networks));
  }

  @override
  Future<void> close() async {
    await stopWatching();
    return super.close();
  }
}

abstract class CryptoEvent extends Equatable {
  const CryptoEvent();
  @override
  List<Object?> get props => [];
}

class CryptoStarted extends CryptoEvent {
  const CryptoStarted();
}

class CryptoWalletCreated extends CryptoEvent {
  const CryptoWalletCreated(this.wallet);
  final CryptoWallet wallet;
  @override
  List<Object?> get props => [wallet];
}

class CryptoWalletUpdated extends CryptoEvent {
  const CryptoWalletUpdated(this.wallet);
  final CryptoWallet wallet;
  @override
  List<Object?> get props => [wallet];
}

class CryptoWalletDeleted extends CryptoEvent {
  const CryptoWalletDeleted(this.uuid);
  final String uuid;
  @override
  List<Object?> get props => [uuid];
}

class CryptoMovedToFolder extends CryptoEvent {
  const CryptoMovedToFolder({required this.uuid, required this.folder});
  final String uuid;

  /// Empty string = unassigned / Other.
  final String folder;
  @override
  List<Object?> get props => [uuid, folder];
}

class CryptoWalletsMovedToFolder extends CryptoEvent {
  const CryptoWalletsMovedToFolder({required this.uuids, required this.folder});
  final List<String> uuids;

  /// Empty string = unassigned / Other.
  final String folder;
  @override
  List<Object?> get props => [uuids, folder];
}

class CryptoNavigateToFolder extends CryptoEvent {
  const CryptoNavigateToFolder(this.folder);
  final String folder;
  @override
  List<Object?> get props => [folder];
}

class CryptoNavigateToRoot extends CryptoEvent {
  const CryptoNavigateToRoot();
}

class CryptoFolderCreated extends CryptoEvent {
  const CryptoFolderCreated(this.name, {this.icon});
  final String name;
  final String? icon;
  @override
  List<Object?> get props => [name, icon];
}

class CryptoFolderRenamed extends CryptoEvent {
  const CryptoFolderRenamed({
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

class CryptoFolderDeleted extends CryptoEvent {
  const CryptoFolderDeleted(this.name, {this.clearWallets = false});
  final String name;

  /// When true, wallets in this folder are moved to unassigned.
  final bool clearWallets;
  @override
  List<Object?> get props => [name, clearWallets];
}

class CryptoSearchChanged extends CryptoEvent {
  const CryptoSearchChanged(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

class SetCryptoOrderEvent extends CryptoEvent {
  const SetCryptoOrderEvent(this.order);
  final OrderType order;
  @override
  List<Object?> get props => [order];
}

class SetCryptoReverseOrderEvent extends CryptoEvent {
  const SetCryptoReverseOrderEvent(this.reverseOrder);
  final bool reverseOrder;
  @override
  List<Object?> get props => [reverseOrder];
}

class CryptoNetworkFilterChanged extends CryptoEvent {
  const CryptoNetworkFilterChanged(this.networks);
  final List<CryptoNetwork> networks;
  @override
  List<Object?> get props => [networks];
}

class _CryptoWalletsUpdated extends CryptoEvent {
  const _CryptoWalletsUpdated(this.wallets);
  final List<CryptoWallet> wallets;
  @override
  List<Object?> get props => [wallets];
}

enum CryptoStatus { initial, loading, ready }

class CryptoState extends Equatable {
  const CryptoState({
    this.status = CryptoStatus.initial,
    this.wallets = const [],
    this.folders = const [],
    this.currentGroup,
    this.query = '',
    this.order = OrderType.byLastModified,
    this.reverseOrder = true,
    this.filterNetworks = const [],
    this.error,
  });

  factory CryptoState.fromStore(VaultMetadataStore metadata) {
    OrderType resolve(int? index, OrderType fallback) {
      if (index != null && index >= 0 && index < OrderType.values.length) {
        return OrderType.values[index];
      }
      return fallback;
    }

    final order = resolve(metadata.cryptoOrderIndex, OrderType.byLastModified);
    return CryptoState(
      folders: metadata.cryptoFolders,
      order: order,
      reverseOrder: order == OrderType.byCustomOrder
          ? false
          : (metadata.cryptoReverseOrder ?? true),
    );
  }

  final CryptoStatus status;
  final List<CryptoWallet> wallets;

  /// Known folder groups (including empty ones the user created).
  final List<NamedGroup> folders;

  /// `null` = root; otherwise the open folder name.
  final String? currentGroup;
  final String query;
  final OrderType order;
  final bool reverseOrder;
  final List<CryptoNetwork> filterNetworks;
  final AppFailure? error;

  bool get isRoot => currentGroup == null;
  bool get isSearching => query.trim().isNotEmpty;

  String iconForGroup(String name) {
    final key = name.trim().toLowerCase();
    for (final f in folders) {
      if (f.name.toLowerCase() == key) return f.iconKey;
    }
    return NamedGroup.defaultIcon;
  }

  List<CryptoWallet> get filtered {
    var list = List<CryptoWallet>.of(wallets);
    if (filterNetworks.isNotEmpty) {
      list = list.where((w) => filterNetworks.contains(w.network)).toList();
    }
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (w) =>
                w.name.toLowerCase().contains(q) ||
                w.address.toLowerCase().contains(q) ||
                w.network.label.toLowerCase().contains(q) ||
                w.network.symbol.toLowerCase().contains(q) ||
                w.folder.toLowerCase().contains(q) ||
                w.notes.toLowerCase().contains(q),
          )
          .toList();
    }
    order.sortCryptoWallets(list, reverseOrder);
    return list;
  }

  List<NamedGroup> get visibleGroups {
    final byKey = <String, NamedGroup>{
      for (final f in folders)
        if (f.name.trim().isNotEmpty) f.name.toLowerCase(): f,
    };
    for (final w in filtered) {
      final name = w.folderGroup;
      if (name.isEmpty) continue;
      byKey.putIfAbsent(name.toLowerCase(), () => NamedGroup(name: name));
    }
    final list = byKey.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  int countInGroup(String group) {
    final key = group.trim().toLowerCase();
    return filtered
        .where((w) => w.folderGroup.toLowerCase() == key)
        .length;
  }

  List<CryptoWallet> get visibleItems {
    final all = filtered;
    if (isSearching) return all;
    if (currentGroup == null) {
      return all.where((w) => w.folderGroup.isEmpty).toList();
    }
    final key = currentGroup!.trim().toLowerCase();
    return all.where((w) => w.folderGroup.toLowerCase() == key).toList();
  }

  /// Folder groups for the list UI — includes empty created folders.
  Map<String, List<CryptoWallet>> groupedByFolder() {
    final map = <String, List<CryptoWallet>>{
      for (final f in folders) f.name: <CryptoWallet>[],
    };
    for (final wallet in filtered) {
      final key = wallet.folderGroup;
      map.putIfAbsent(key, () => []).add(wallet);
    }
    final keys = map.keys.toList()
      ..sort((a, b) {
        if (a.isEmpty) return 1;
        if (b.isEmpty) return -1;
        return a.toLowerCase().compareTo(b.toLowerCase());
      });
    return {for (final k in keys) k: map[k]!};
  }

  CryptoState copyWith({
    CryptoStatus? status,
    List<CryptoWallet>? wallets,
    List<NamedGroup>? folders,
    String? currentGroup,
    bool clearCurrentGroup = false,
    String? query,
    OrderType? order,
    bool? reverseOrder,
    List<CryptoNetwork>? filterNetworks,
    AppFailure? error,
  }) {
    return CryptoState(
      status: status ?? this.status,
      wallets: wallets ?? this.wallets,
      folders: folders ?? this.folders,
      currentGroup:
          clearCurrentGroup ? null : (currentGroup ?? this.currentGroup),
      query: query ?? this.query,
      order: order ?? this.order,
      reverseOrder: reverseOrder ?? this.reverseOrder,
      filterNetworks: filterNetworks ?? this.filterNetworks,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        wallets,
        folders,
        currentGroup,
        query,
        order,
        reverseOrder,
        filterNetworks,
        error,
      ];
}
