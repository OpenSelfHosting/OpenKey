import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/src/src.dart';

enum VaultSelectionMode { normal, selecting, moving }

class VaultSelectionCubit extends Cubit<VaultSelectionState> {
  VaultSelectionCubit() : super(const VaultSelectionState());

  void selectEntry(VaultEntry entry) {
    if (state.isEntrySelected(entry.uuid)) return;
    emit(
      _next(
        selectedEntries: [...state.selectedEntries, entry],
      ),
    );
  }

  void toggleEntry(VaultEntry entry) {
    final selected = state.isEntrySelected(entry.uuid)
        ? state.selectedEntries.where((e) => e.uuid != entry.uuid).toList()
        : [...state.selectedEntries, entry];
    emit(_next(selectedEntries: selected));
  }

  void selectCollection(VaultCollection collection) {
    if (state.isCollectionSelected(collection.uuid)) return;
    emit(
      _next(
        selectedCollections: [...state.selectedCollections, collection],
      ),
    );
  }

  void toggleCollection(VaultCollection collection) {
    final selected = state.isCollectionSelected(collection.uuid)
        ? state.selectedCollections
            .where((c) => c.uuid != collection.uuid)
            .toList()
        : [...state.selectedCollections, collection];
    emit(_next(selectedCollections: selected));
  }

  void selectAll({
    required List<VaultEntry> entries,
    required List<VaultCollection> collections,
  }) {
    emit(
      VaultSelectionState(
        mode: VaultSelectionMode.selecting,
        selectedEntries: List.of(entries),
        selectedCollections: List.of(collections),
      ),
    );
  }

  void clear() => emit(const VaultSelectionState());

  void startMoving() {
    if (!state.hasSelection) return;
    emit(state.copyWith(mode: VaultSelectionMode.moving));
  }

  void cancelMoving() {
    if (!state.hasSelection) {
      clear();
      return;
    }
    emit(state.copyWith(mode: VaultSelectionMode.selecting));
  }

  Future<void> deleteSelected(BuildContext context) async {
    final entries = List<VaultEntry>.from(state.selectedEntries);
    final collections =
        List<VaultCollection>.from(state.selectedCollections);
    if (entries.isEmpty && collections.isEmpty) return;

    final s = context.s;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.delete),
        content: Text(s.deleteSelectedConfirm(entries.length + collections.length)),
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
    if (ok != true || !context.mounted) return;

    final entryBloc = context.read<EntryBloc>();
    final collectionBloc = context.read<CollectionBloc>();
    for (final e in entries) {
      entryBloc.add(EntryDeleted(e.uuid));
    }
    for (final c in collections) {
      collectionBloc.add(CollectionDeleted(c.uuid));
    }
    clear();
  }

  Future<void> editSelected(BuildContext context) async {
    if (state.selectedCount != 1) return;
    if (state.selectedEntries.length == 1) {
      final entry = state.selectedEntries.first;
      clear();
      if (context.mounted) {
        context.push('${AppRoutes.vault.path}/entry/${entry.uuid}');
      }
      return;
    }
    if (state.selectedCollections.length == 1) {
      final collection = state.selectedCollections.first;
      clear();
      if (context.mounted) {
        await UpsertCollectionSheet.show(context, collection: collection);
      }
    }
  }

  void moveSelectedHere(BuildContext context) {
    final target = context.read<CollectionBloc>().state.currentFolderUuid;
    final entryBloc = context.read<EntryBloc>();
    final collectionBloc = context.read<CollectionBloc>();

    if (state.selectedEntries.isNotEmpty) {
      entryBloc.add(
        EntriesMoved(
          entries: state.selectedEntries,
          targetCollectionUuid: target,
        ),
      );
    }
    if (state.selectedCollections.isNotEmpty) {
      collectionBloc.add(
        CollectionsMoved(
          collections: state.selectedCollections,
          targetParentUuid: target,
        ),
      );
    }
    clear();
  }

  VaultSelectionState _next({
    List<VaultEntry>? selectedEntries,
    List<VaultCollection>? selectedCollections,
  }) {
    final entries = selectedEntries ?? state.selectedEntries;
    final collections = selectedCollections ?? state.selectedCollections;
    final mode = entries.isEmpty && collections.isEmpty
        ? VaultSelectionMode.normal
        : VaultSelectionMode.selecting;
    return VaultSelectionState(
      mode: mode,
      selectedEntries: entries,
      selectedCollections: collections,
    );
  }
}

class VaultSelectionState extends Equatable {
  const VaultSelectionState({
    this.mode = VaultSelectionMode.normal,
    this.selectedEntries = const [],
    this.selectedCollections = const [],
  });

  final VaultSelectionMode mode;
  final List<VaultEntry> selectedEntries;
  final List<VaultCollection> selectedCollections;

  bool get isSelecting => mode == VaultSelectionMode.selecting;
  bool get isMoving => mode == VaultSelectionMode.moving;
  bool get hasSelection => selectedCount > 0;
  int get selectedCount =>
      selectedEntries.length + selectedCollections.length;

  bool isEntrySelected(String uuid) =>
      selectedEntries.any((e) => e.uuid == uuid);

  bool isCollectionSelected(String uuid) =>
      selectedCollections.any((c) => c.uuid == uuid);

  VaultSelectionState copyWith({
    VaultSelectionMode? mode,
    List<VaultEntry>? selectedEntries,
    List<VaultCollection>? selectedCollections,
  }) {
    return VaultSelectionState(
      mode: mode ?? this.mode,
      selectedEntries: selectedEntries ?? this.selectedEntries,
      selectedCollections: selectedCollections ?? this.selectedCollections,
    );
  }

  @override
  List<Object?> get props => [mode, selectedEntries, selectedCollections];
}
