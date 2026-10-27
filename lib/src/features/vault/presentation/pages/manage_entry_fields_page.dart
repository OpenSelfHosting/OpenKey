import 'package:flutter/material.dart';
import 'package:openkey_app/src/src.dart';

/// Full-screen page to enable, disable, and drag-reorder entry fields.
class ManageEntryFieldsPage extends StatefulWidget {
  const ManageEntryFieldsPage({super.key, required this.initialVisible});

  final List<EntryEditorField> initialVisible;

  static Future<List<EntryEditorField>?> show(
    BuildContext context, {
    required List<EntryEditorField> visible,
  }) {
    return Navigator.of(context).push<List<EntryEditorField>>(
      MaterialPageRoute(
        builder: (_) => ManageEntryFieldsPage(initialVisible: List.of(visible)),
      ),
    );
  }

  @override
  State<ManageEntryFieldsPage> createState() => _ManageEntryFieldsPageState();
}

class _ManageEntryFieldsPageState extends State<ManageEntryFieldsPage> {
  late List<EntryEditorField> _order;
  late Set<EntryEditorField> _enabled;

  @override
  void initState() {
    super.initState();
    _enabled = Set.of(widget.initialVisible);
    _order = [
      ...widget.initialVisible,
      ...EntryEditorField.displayOrder.where((f) => !_enabled.contains(f)),
    ];
  }

  void _toggle(EntryEditorField field, bool value) {
    setState(() {
      if (value) {
        _enabled.add(field);
      } else {
        _enabled.remove(field);
      }
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final item = _order.removeAt(oldIndex);
      _order.insert(newIndex, item);
    });
  }

  List<EntryEditorField> _result() {
    return _order.where(_enabled.contains).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final s = context.s;

    return Scaffold(
      appBar: AppBar(title: Text(s.chooseFields)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              s.chooseFieldsSubtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              buildDefaultDragHandles: false,
              itemCount: _order.length,
              onReorderItem: _onReorder,
              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, _) {
                    final t = Curves.easeOut.transform(animation.value);
                    return Material(
                      elevation: 2 + 4 * t,
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: child,
                    );
                  },
                );
              },
              itemBuilder: (context, index) {
                final field = _order[index];
                final enabled = _enabled.contains(field);
                return Padding(
                  key: ValueKey(field),
                  padding: const EdgeInsets.only(bottom: 2),
                  child: ActionItem(
                    title: field.label(s),
                    padding: 24,
                    icon: SettingsIcon(
                      field.icon,
                      backgroundColor: enabled
                          ? scheme.primaryContainer
                          : scheme.surfaceContainerHighest,
                      foregroundColor: enabled
                          ? scheme.onPrimaryContainer
                          : scheme.onSurfaceVariant,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MESwitch(
                          value: enabled,
                          onChanged: (value) => _toggle(field, value),
                        ),
                        const SizedBox(width: 18),
                        ReorderableDragStartListener(
                          index: index,
                          child: Icon(
                            Icons.drag_handle_rounded,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    itemPosition: ItemPosition.fromIndex(index, _order.length),
                    onTap: () => _toggle(field, !enabled),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: MEButton(
            onPressed: () => Navigator.of(context).pop(_result()),
            child: Text(s.done),
          ),
        ),
      ),
    );
  }
}
