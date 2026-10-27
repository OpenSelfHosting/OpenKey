import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openkey_app/src/src.dart';

class SecretsBloc extends Bloc<SecretsEvent, SecretsState> {
  SecretsBloc(this._repository, this._metadata, this._sync)
      : super(SecretsState.fromStore(_metadata)) {
    on<SecretsStarted>(_onStarted);
    on<SecretCreated>(_onCreated);
    on<SecretUpdated>(_onUpdated);
    on<SecretDeleted>(_onDeleted);
    on<SecretMovedToDevice>(_onMoved);
    on<SecretsMovedToDevice>(_onBulkMoved);
    on<SecretDeviceCreated>(_onDeviceCreated);
    on<SecretDeviceRenamed>(_onDeviceRenamed);
    on<SecretDeviceDeleted>(_onDeviceDeleted);
    on<SecretsSearchChanged>(_onSearch);
    on<SecretsNavigateToDevice>(_onNavigateToDevice);
    on<SecretsNavigateToRoot>(_onNavigateToRoot);
    on<SetSecretsOrderEvent>(_onSetOrder);
    on<SetSecretsReverseOrderEvent>(_onSetReverse);
    on<SecretsKindFilterChanged>(_onKindFilter);
    on<_SecretsUpdated>(_onSecretsUpdated);
  }

  final SecretsRepository _repository;
  final VaultMetadataStore _metadata;
  final SyncService _sync;
  StreamSubscription<List<DevSecret>>? _secretsSub;

  Future<void> _onStarted(
    SecretsStarted event,
    Emitter<SecretsState> emit,
  ) async {
    await stopWatching();
    emit(
      state.copyWith(
        status: SecretsStatus.loading,
        devices: _metadata.secretDevices,
      ),
    );
    _secretsSub = _repository.watchSecrets().listen(
      (secrets) => add(_SecretsUpdated(secrets)),
      onError: (_) {},
    );
  }

  /// Cancels Drift watches before the encrypted DB is closed (lock / reset).
  Future<void> stopWatching() async {
    final sub = _secretsSub;
    _secretsSub = null;
    detachWatch(sub);
  }

  Future<void> _persistDevices(List<NamedGroup> devices) async {
    await _metadata.setSecretDevices(devices);
  }

  List<NamedGroup> _mergeDevices(
    List<NamedGroup> stored,
    List<DevSecret> secrets,
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
      final keepIcon = existing.iconKey != NamedGroup.deviceDefaultIcon ||
              group.iconKey == NamedGroup.deviceDefaultIcon
          ? existing.iconKey
          : group.iconKey;
      byKey[key] = existing.copyWith(name: name, icon: keepIcon);
    }

    for (final d in stored) {
      add(d);
    }
    for (final s in secrets) {
      add(NamedGroup(name: s.device, icon: NamedGroup.deviceDefaultIcon));
    }
    final out = byKey.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return out;
  }

  void _onSecretsUpdated(
    _SecretsUpdated event,
    Emitter<SecretsState> emit,
  ) {
    final devices = _mergeDevices(state.devices, event.secrets);
    emit(
      state.copyWith(
        status: SecretsStatus.ready,
        secrets: event.secrets,
        devices: devices,
      ),
    );
  }

  Future<void> _onCreated(
    SecretCreated event,
    Emitter<SecretsState> emit,
  ) async {
    final result = await _repository.createSecret(event.secret);
    await result.fold(
      (f) async => emit(state.copyWith(error: f)),
      (created) async {
        if (created.device.trim().isNotEmpty) {
          final next = _mergeDevices(state.devices, [created]);
          await _persistDevices(next);
          emit(state.copyWith(devices: next));
        }
        unawaited(_sync.syncIfConnected());
      },
    );
  }

  Future<void> _onUpdated(
    SecretUpdated event,
    Emitter<SecretsState> emit,
  ) async {
    final result = await _repository.updateSecret(event.secret);
    await result.fold(
      (f) async => emit(state.copyWith(error: f)),
      (updated) async {
        if (updated.device.trim().isNotEmpty) {
          final next = _mergeDevices(state.devices, [updated]);
          await _persistDevices(next);
          emit(state.copyWith(devices: next));
        }
        unawaited(_sync.syncIfConnected());
      },
    );
  }

  Future<void> _onDeleted(
    SecretDeleted event,
    Emitter<SecretsState> emit,
  ) async {
    final result = await _repository.deleteSecret(event.uuid);
    result.fold(
      (f) => emit(state.copyWith(error: f)),
      (_) => unawaited(_sync.syncIfConnected()),
    );
  }

  Future<void> _onMoved(
    SecretMovedToDevice event,
    Emitter<SecretsState> emit,
  ) async {
    final existing = state.secrets.cast<DevSecret?>().firstWhere(
          (s) => s!.uuid == event.uuid,
          orElse: () => null,
        );
    if (existing == null) {
      final loaded = await _repository.getSecret(event.uuid);
      await loaded.fold(
        (f) async => emit(state.copyWith(error: f)),
        (secret) async {
          if (secret == null) return;
          await _moveSecret(secret, event.device, emit);
        },
      );
      return;
    }
    await _moveSecret(existing, event.device, emit);
  }

  Future<void> _onBulkMoved(
    SecretsMovedToDevice event,
    Emitter<SecretsState> emit,
  ) async {
    for (final uuid in event.uuids) {
      final existing = state.secrets.cast<DevSecret?>().firstWhere(
            (s) => s!.uuid == uuid,
            orElse: () => null,
          );
      if (existing != null) {
        await _moveSecret(existing, event.device, emit);
        continue;
      }
      final loaded = await _repository.getSecret(uuid);
      await loaded.fold(
        (f) async => emit(state.copyWith(error: f)),
        (secret) async {
          if (secret == null) return;
          await _moveSecret(secret, event.device, emit);
        },
      );
    }
  }

  void _onNavigateToDevice(
    SecretsNavigateToDevice event,
    Emitter<SecretsState> emit,
  ) {
    final device = event.device.trim();
    if (device.isEmpty) {
      emit(state.copyWith(clearCurrentGroup: true));
      return;
    }
    emit(state.copyWith(currentGroup: device));
  }

  void _onNavigateToRoot(
    SecretsNavigateToRoot event,
    Emitter<SecretsState> emit,
  ) {
    emit(state.copyWith(clearCurrentGroup: true));
  }

  Future<void> _moveSecret(
    DevSecret secret,
    String device,
    Emitter<SecretsState> emit,
  ) async {
    final nextDevice = device.trim();
    if (secret.device.trim() == nextDevice) return;
    final updated = secret.copyWith(device: nextDevice);
    final result = await _repository.updateSecret(updated);
    await result.fold(
      (f) async => emit(state.copyWith(error: f)),
      (_) async {
        if (nextDevice.isNotEmpty) {
          final next = _mergeDevices(state.devices, [updated]);
          await _persistDevices(next);
          emit(state.copyWith(devices: next));
        }
        unawaited(_sync.syncIfConnected());
      },
    );
  }

  Future<void> _onDeviceCreated(
    SecretDeviceCreated event,
    Emitter<SecretsState> emit,
  ) async {
    final name = event.name.trim();
    if (name.isEmpty) return;
    final exists = state.devices.any(
      (d) => d.name.toLowerCase() == name.toLowerCase(),
    );
    if (exists) {
      if (event.icon != null) {
        final next = state.devices
            .map(
              (d) => d.name.toLowerCase() == name.toLowerCase()
                  ? d.copyWith(icon: event.icon)
                  : d,
            )
            .toList();
        await _persistDevices(next);
        emit(state.copyWith(devices: next));
      }
      return;
    }
    final group = NamedGroup(
      name: name,
      icon: event.icon ?? NamedGroup.deviceDefaultIcon,
    );
    final next = _mergeDevices([...state.devices, group], state.secrets);
    await _persistDevices(next);
    emit(state.copyWith(devices: next));
  }

  Future<void> _onDeviceRenamed(
    SecretDeviceRenamed event,
    Emitter<SecretsState> emit,
  ) async {
    final from = event.from.trim();
    final to = event.to.trim();
    if (from.isEmpty || to.isEmpty) return;
    final sameName = from.toLowerCase() == to.toLowerCase();
    if (sameName && event.icon == null) return;

    final affected = sameName
        ? const <DevSecret>[]
        : state.secrets
            .where((s) => s.device.trim().toLowerCase() == from.toLowerCase())
            .toList();
    for (final secret in affected) {
      final result = await _repository.updateSecret(
        secret.copyWith(device: to),
      );
      final failed = result.fold((f) => f, (_) => null);
      if (failed != null) {
        emit(state.copyWith(error: failed));
        return;
      }
    }

    final previous = state.devices.cast<NamedGroup?>().firstWhere(
          (d) => d!.name.toLowerCase() == from.toLowerCase(),
          orElse: () => null,
        );
    final icon =
        event.icon ?? previous?.iconKey ?? NamedGroup.deviceDefaultIcon;

    var next = state.devices
        .where((d) => d.name.toLowerCase() != from.toLowerCase())
        .toList();
    next = _mergeDevices(
      [...next, NamedGroup(name: to, icon: icon)],
      state.secrets,
    );
    await _persistDevices(next);
    final stayInRenamed = state.currentGroup != null &&
        state.currentGroup!.toLowerCase() == from.toLowerCase();
    emit(
      state.copyWith(
        devices: next,
        currentGroup: stayInRenamed ? to : state.currentGroup,
      ),
    );
    if (affected.isNotEmpty) unawaited(_sync.syncIfConnected());
  }

  Future<void> _onDeviceDeleted(
    SecretDeviceDeleted event,
    Emitter<SecretsState> emit,
  ) async {
    final name = event.name.trim();
    if (name.isEmpty) return;
    final affected = state.secrets
        .where((s) => s.device.trim().toLowerCase() == name.toLowerCase())
        .toList();
    if (event.clearSecrets) {
      for (final secret in affected) {
        final result = await _repository.updateSecret(
          secret.copyWith(device: ''),
        );
        final failed = result.fold((f) => f, (_) => null);
        if (failed != null) {
          emit(state.copyWith(error: failed));
          return;
        }
      }
    } else if (affected.isNotEmpty) {
      // Refuse deleting a non-empty device unless secrets are cleared.
      return;
    }
    final next = state.devices
        .where((d) => d.name.toLowerCase() != name.toLowerCase())
        .toList();
    await _persistDevices(next);
    final leavingDeleted = state.currentGroup != null &&
        state.currentGroup!.toLowerCase() == name.toLowerCase();
    emit(
      state.copyWith(
        devices: next,
        clearCurrentGroup: leavingDeleted,
      ),
    );
    if (event.clearSecrets && affected.isNotEmpty) {
      unawaited(_sync.syncIfConnected());
    }
  }

  void _onSearch(SecretsSearchChanged event, Emitter<SecretsState> emit) {
    emit(state.copyWith(query: event.query));
  }

  Future<void> _onSetOrder(
    SetSecretsOrderEvent event,
    Emitter<SecretsState> emit,
  ) async {
    await _metadata.setSecretsOrder(event.order.index);
    var reverse = state.reverseOrder;
    if (event.order == OrderType.byCustomOrder && reverse) {
      reverse = false;
      await _metadata.setSecretsReverseOrder(false);
    }
    emit(state.copyWith(order: event.order, reverseOrder: reverse));
  }

  Future<void> _onSetReverse(
    SetSecretsReverseOrderEvent event,
    Emitter<SecretsState> emit,
  ) async {
    if (state.order == OrderType.byCustomOrder) return;
    if (event.reverseOrder == state.reverseOrder) return;
    await _metadata.setSecretsReverseOrder(event.reverseOrder);
    emit(state.copyWith(reverseOrder: event.reverseOrder));
  }

  void _onKindFilter(
    SecretsKindFilterChanged event,
    Emitter<SecretsState> emit,
  ) {
    emit(state.copyWith(filterKinds: event.kinds));
  }

  @override
  Future<void> close() async {
    await stopWatching();
    return super.close();
  }
}

abstract class SecretsEvent extends Equatable {
  const SecretsEvent();
  @override
  List<Object?> get props => [];
}

class SecretsStarted extends SecretsEvent {
  const SecretsStarted();
}

class SecretCreated extends SecretsEvent {
  const SecretCreated(this.secret);
  final DevSecret secret;
  @override
  List<Object?> get props => [secret];
}

class SecretUpdated extends SecretsEvent {
  const SecretUpdated(this.secret);
  final DevSecret secret;
  @override
  List<Object?> get props => [secret];
}

class SecretDeleted extends SecretsEvent {
  const SecretDeleted(this.uuid);
  final String uuid;
  @override
  List<Object?> get props => [uuid];
}

class SecretMovedToDevice extends SecretsEvent {
  const SecretMovedToDevice({required this.uuid, required this.device});
  final String uuid;

  /// Empty string = unassigned / Other.
  final String device;
  @override
  List<Object?> get props => [uuid, device];
}

class SecretsMovedToDevice extends SecretsEvent {
  const SecretsMovedToDevice({required this.uuids, required this.device});
  final List<String> uuids;

  /// Empty string = unassigned / Other.
  final String device;
  @override
  List<Object?> get props => [uuids, device];
}

class SecretsNavigateToDevice extends SecretsEvent {
  const SecretsNavigateToDevice(this.device);
  final String device;
  @override
  List<Object?> get props => [device];
}

class SecretsNavigateToRoot extends SecretsEvent {
  const SecretsNavigateToRoot();
}

class SecretDeviceCreated extends SecretsEvent {
  const SecretDeviceCreated(this.name, {this.icon});
  final String name;
  final String? icon;
  @override
  List<Object?> get props => [name, icon];
}

class SecretDeviceRenamed extends SecretsEvent {
  const SecretDeviceRenamed({
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

class SecretDeviceDeleted extends SecretsEvent {
  const SecretDeviceDeleted(this.name, {this.clearSecrets = false});
  final String name;

  /// When true, secrets in this device are moved to unassigned.
  final bool clearSecrets;
  @override
  List<Object?> get props => [name, clearSecrets];
}

class SecretsSearchChanged extends SecretsEvent {
  const SecretsSearchChanged(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

class SetSecretsOrderEvent extends SecretsEvent {
  const SetSecretsOrderEvent(this.order);
  final OrderType order;
  @override
  List<Object?> get props => [order];
}

class SetSecretsReverseOrderEvent extends SecretsEvent {
  const SetSecretsReverseOrderEvent(this.reverseOrder);
  final bool reverseOrder;
  @override
  List<Object?> get props => [reverseOrder];
}

class SecretsKindFilterChanged extends SecretsEvent {
  const SecretsKindFilterChanged(this.kinds);
  final List<SecretKind> kinds;
  @override
  List<Object?> get props => [kinds];
}

class _SecretsUpdated extends SecretsEvent {
  const _SecretsUpdated(this.secrets);
  final List<DevSecret> secrets;
  @override
  List<Object?> get props => [secrets];
}

enum SecretsStatus { initial, loading, ready }

class SecretsState extends Equatable {
  const SecretsState({
    this.status = SecretsStatus.initial,
    this.secrets = const [],
    this.devices = const [],
    this.currentGroup,
    this.query = '',
    this.order = OrderType.byLastModified,
    this.reverseOrder = true,
    this.filterKinds = const [],
    this.error,
  });

  factory SecretsState.fromStore(VaultMetadataStore metadata) {
    OrderType resolve(int? index, OrderType fallback) {
      if (index != null && index >= 0 && index < OrderType.values.length) {
        return OrderType.values[index];
      }
      return fallback;
    }

    final order =
        resolve(metadata.secretsOrderIndex, OrderType.byLastModified);
    return SecretsState(
      devices: metadata.secretDevices,
      order: order,
      reverseOrder: order == OrderType.byCustomOrder
          ? false
          : (metadata.secretsReverseOrder ?? true),
    );
  }

  final SecretsStatus status;
  final List<DevSecret> secrets;

  /// Known device groups (including empty ones the user created).
  final List<NamedGroup> devices;

  /// `null` = root; otherwise the open device name.
  final String? currentGroup;
  final String query;
  final OrderType order;
  final bool reverseOrder;
  final List<SecretKind> filterKinds;
  final AppFailure? error;

  bool get isRoot => currentGroup == null;
  bool get isSearching => query.trim().isNotEmpty;

  String iconForGroup(String name) {
    final key = name.trim().toLowerCase();
    for (final d in devices) {
      if (d.name.toLowerCase() == key) return d.iconKey;
    }
    return NamedGroup.deviceDefaultIcon;
  }

  List<DevSecret> get filtered {
    var list = List<DevSecret>.of(secrets);
    if (filterKinds.isNotEmpty) {
      list = list.where((s) => filterKinds.contains(s.kind)).toList();
    }
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (s) =>
                s.name.toLowerCase().contains(q) ||
                s.host.toLowerCase().contains(q) ||
                s.username.toLowerCase().contains(q) ||
                s.kind.name.toLowerCase().contains(q) ||
                s.device.toLowerCase().contains(q) ||
                s.notes.toLowerCase().contains(q),
          )
          .toList();
    }
    order.sortDevSecrets(list, reverseOrder);
    return list;
  }

  List<NamedGroup> get visibleGroups {
    final byKey = <String, NamedGroup>{
      for (final d in devices)
        if (d.name.trim().isNotEmpty) d.name.toLowerCase(): d,
    };
    for (final s in filtered) {
      final name = s.deviceGroup;
      if (name.isEmpty) continue;
      byKey.putIfAbsent(
        name.toLowerCase(),
        () => NamedGroup(name: name, icon: NamedGroup.deviceDefaultIcon),
      );
    }
    final list = byKey.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  int countInGroup(String group) {
    final key = group.trim().toLowerCase();
    return filtered
        .where((s) => s.deviceGroup.toLowerCase() == key)
        .length;
  }

  List<DevSecret> get visibleItems {
    final all = filtered;
    if (isSearching) return all;
    if (currentGroup == null) {
      return all.where((s) => s.deviceGroup.isEmpty).toList();
    }
    final key = currentGroup!.trim().toLowerCase();
    return all.where((s) => s.deviceGroup.toLowerCase() == key).toList();
  }

  /// Device groups for the list UI — includes empty created devices.
  Map<String, List<DevSecret>> groupedByDevice() {
    final map = <String, List<DevSecret>>{
      for (final d in devices) d.name: <DevSecret>[],
    };
    for (final secret in filtered) {
      final key = secret.deviceGroup;
      map.putIfAbsent(key, () => []).add(secret);
    }
    final keys = map.keys.toList()
      ..sort((a, b) {
        if (a.isEmpty) return 1;
        if (b.isEmpty) return -1;
        return a.toLowerCase().compareTo(b.toLowerCase());
      });
    return {for (final k in keys) k: map[k]!};
  }

  SecretsState copyWith({
    SecretsStatus? status,
    List<DevSecret>? secrets,
    List<NamedGroup>? devices,
    String? currentGroup,
    bool clearCurrentGroup = false,
    String? query,
    OrderType? order,
    bool? reverseOrder,
    List<SecretKind>? filterKinds,
    AppFailure? error,
  }) {
    return SecretsState(
      status: status ?? this.status,
      secrets: secrets ?? this.secrets,
      devices: devices ?? this.devices,
      currentGroup:
          clearCurrentGroup ? null : (currentGroup ?? this.currentGroup),
      query: query ?? this.query,
      order: order ?? this.order,
      reverseOrder: reverseOrder ?? this.reverseOrder,
      filterKinds: filterKinds ?? this.filterKinds,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        secrets,
        devices,
        currentGroup,
        query,
        order,
        reverseOrder,
        filterKinds,
        error,
      ];
}
