import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum GroupedSelectionMode { normal, selecting, moving }

/// Multi-select / move state for flat string-grouped lists
/// (cards banks, crypto folders, secret devices).
class GroupedSelectionCubit extends Cubit<GroupedSelectionState> {
  GroupedSelectionCubit() : super(const GroupedSelectionState());

  void selectItem(String id) {
    if (state.isItemSelected(id)) return;
    emit(_next(selectedItemIds: [...state.selectedItemIds, id]));
  }

  void toggleItem(String id) {
    final selected = state.isItemSelected(id)
        ? state.selectedItemIds.where((e) => e != id).toList()
        : [...state.selectedItemIds, id];
    emit(_next(selectedItemIds: selected));
  }

  void selectGroup(String group) {
    if (group.isEmpty || state.isGroupSelected(group)) return;
    emit(_next(selectedGroups: [...state.selectedGroups, group]));
  }

  void toggleGroup(String group) {
    if (group.isEmpty) return;
    final selected = state.isGroupSelected(group)
        ? state.selectedGroups.where((g) => g != group).toList()
        : [...state.selectedGroups, group];
    emit(_next(selectedGroups: selected));
  }

  void selectAll({
    required List<String> itemIds,
    required List<String> groups,
  }) {
    emit(
      GroupedSelectionState(
        mode: GroupedSelectionMode.selecting,
        selectedItemIds: List.of(itemIds),
        selectedGroups: List.of(groups.where((g) => g.isNotEmpty)),
      ),
    );
  }

  void clear() => emit(const GroupedSelectionState());

  void startMoving() {
    if (!state.hasSelection) return;
    emit(state.copyWith(mode: GroupedSelectionMode.moving));
  }

  void cancelMoving() {
    if (!state.hasSelection) {
      clear();
      return;
    }
    emit(state.copyWith(mode: GroupedSelectionMode.selecting));
  }

  GroupedSelectionState _next({
    List<String>? selectedItemIds,
    List<String>? selectedGroups,
  }) {
    final items = selectedItemIds ?? state.selectedItemIds;
    final groups = selectedGroups ?? state.selectedGroups;
    final mode = items.isEmpty && groups.isEmpty
        ? GroupedSelectionMode.normal
        : GroupedSelectionMode.selecting;
    return GroupedSelectionState(
      mode: mode,
      selectedItemIds: items,
      selectedGroups: groups,
    );
  }
}

class GroupedSelectionState extends Equatable {
  const GroupedSelectionState({
    this.mode = GroupedSelectionMode.normal,
    this.selectedItemIds = const [],
    this.selectedGroups = const [],
  });

  final GroupedSelectionMode mode;
  final List<String> selectedItemIds;
  final List<String> selectedGroups;

  bool get isSelecting => mode == GroupedSelectionMode.selecting;
  bool get isMoving => mode == GroupedSelectionMode.moving;
  bool get hasSelection => selectedCount > 0;
  int get selectedCount => selectedItemIds.length + selectedGroups.length;

  bool isItemSelected(String id) => selectedItemIds.contains(id);

  bool isGroupSelected(String group) =>
      selectedGroups.any((g) => g.toLowerCase() == group.toLowerCase());

  GroupedSelectionState copyWith({
    GroupedSelectionMode? mode,
    List<String>? selectedItemIds,
    List<String>? selectedGroups,
  }) {
    return GroupedSelectionState(
      mode: mode ?? this.mode,
      selectedItemIds: selectedItemIds ?? this.selectedItemIds,
      selectedGroups: selectedGroups ?? this.selectedGroups,
    );
  }

  @override
  List<Object?> get props => [mode, selectedItemIds, selectedGroups];
}
