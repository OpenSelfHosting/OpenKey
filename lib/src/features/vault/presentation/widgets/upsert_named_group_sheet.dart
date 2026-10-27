import 'package:flutter/material.dart';
import 'package:openkey_app/src/src.dart';

/// Create / rename a named group (bank, crypto folder, or device) with icon.
class UpsertNamedGroupSheet extends StatefulWidget {
  const UpsertNamedGroupSheet({
    super.key,
    required this.title,
    required this.nameLabel,
    required this.defaultIcon,
    this.initialName = '',
    this.initialIcon,
  });

  final String title;
  final String nameLabel;
  final String defaultIcon;
  final String initialName;
  final String? initialIcon;

  static Future<NamedGroup?> show(
    BuildContext context, {
    required String title,
    required String nameLabel,
    required String defaultIcon,
    String initialName = '',
    String? initialIcon,
  }) {
    return showMEBottomSheet<NamedGroup>(
      context: context,
      builder: (_) => UpsertNamedGroupSheet(
        title: title,
        nameLabel: nameLabel,
        defaultIcon: defaultIcon,
        initialName: initialName,
        initialIcon: initialIcon,
      ),
    );
  }

  @override
  State<UpsertNamedGroupSheet> createState() => _UpsertNamedGroupSheetState();
}

class _UpsertNamedGroupSheetState extends State<UpsertNamedGroupSheet> {
  late final TextEditingController _name;
  late String _iconKey;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialName);
    _iconKey = (widget.initialIcon?.trim().isNotEmpty ?? false)
        ? widget.initialIcon!.trim()
        : widget.defaultIcon;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickIcon() async {
    final suggested = await CollectionIcons.suggest(name: _name.text);
    if (!mounted) return;
    final picked = await VaultIconPickerPage.show(
      context,
      selectedKey: _iconKey,
      suggestedKey: suggested,
      fallbackKey: widget.defaultIcon,
    );
    if (picked != null && mounted) {
      setState(() => _iconKey = picked);
    }
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(
      context,
      NamedGroup(name: name, icon: _iconKey),
    );
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
            Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
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
              label: widget.nameLabel,
              autofocus: widget.initialName.isEmpty,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            MEButton(
              size: MEButtonSize.large,
              onPressed: _submit,
              child: Text(s.save),
            ),
          ],
        ),
      ),
    );
  }
}
