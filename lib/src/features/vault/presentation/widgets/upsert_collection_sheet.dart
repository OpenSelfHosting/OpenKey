import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openkey_app/src/src.dart';

/// Create / edit a flat collection (folder) with customizable icon.
class UpsertCollectionSheet extends StatefulWidget {
  const UpsertCollectionSheet({super.key, this.collection});

  final VaultCollection? collection;

  static Future<void> show(
    BuildContext context, {
    VaultCollection? collection,
  }) {
    return showMEBottomSheet<void>(
      context: context,
      builder: (_) => UpsertCollectionSheet(collection: collection),
    );
  }

  @override
  State<UpsertCollectionSheet> createState() => _UpsertCollectionSheetState();
}

class _UpsertCollectionSheetState extends State<UpsertCollectionSheet> {
  late final TextEditingController _name;
  late String _iconKey;

  bool get _isEdit => widget.collection != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.collection?.name ?? '');
    _iconKey = widget.collection?.icon ?? CollectionIcons.defaultKey;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickIcon() async {
    final suggested = await EntryIcons.suggest(title: _name.text);
    if (!mounted) return;
    final picked = await VaultIconPickerPage.show(
      context,
      selectedKey: _iconKey,
      suggestedKey: suggested,
      fallbackKey: CollectionIcons.defaultKey,
    );
    if (picked != null && mounted) {
      setState(() => _iconKey = picked);
    }
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) return;

    final bloc = context.read<CollectionBloc>();
    if (_isEdit) {
      bloc.add(
        CollectionUpdated(
          widget.collection!.copyWith(name: name, icon: _iconKey),
        ),
      );
    } else {
      bloc.add(CollectionCreated(name, icon: _iconKey));
    }
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final s = context.s;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.deleteCollection),
        content: Text(s.deleteCollectionConfirm),
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
    if (ok == true && mounted) {
      context
          .read<CollectionBloc>()
          .add(CollectionDeleted(widget.collection!.uuid));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Text(
            _isEdit ? s.editCollection : s.newCollection,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          Center(
            child: InkWell(
              onTap: _pickIcon,
              borderRadius: BorderRadius.circular(56),
              child: VaultIconSurface(
                iconKey: _iconKey,
                size: 112,
                expressive: true,
                backgroundColor: scheme.primaryContainer,
                child: CollectionIcon(
                  iconKey: _iconKey,
                  size: VaultIconSurface.needsBackdrop(_iconKey) ? 56 : 80,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: MEButton.text(
              onPressed: _pickIcon,
              child: Text(s.chooseIcon),
            ),
          ),
          const SizedBox(height: 16),
          METextField(
            controller: _name,
            label: s.name,
            autofocus: !_isEdit,
          ),
          const SizedBox(height: 20),
          MEButton(
            size: MEButtonSize.large,
            onPressed: _save,
            child: Text(_isEdit ? s.save : s.create),
          ),
          if (_isEdit) ...[
            const SizedBox(height: 8),
            MEButton.outlined(
              onPressed: _delete,
              child: Text(s.deleteCollection),
            ),
          ],
        ],
        ),
      ),
    );
  }
}
