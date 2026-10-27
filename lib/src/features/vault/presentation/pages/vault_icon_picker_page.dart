import 'package:flutter/material.dart';
import 'package:openkey_app/src/src.dart';

/// Full-screen picker for material, brand SVG, or custom vault icons.
///
/// Shared by entries and collections — one catalog, one suggestion pipeline.
class VaultIconPickerPage extends StatefulWidget {
  const VaultIconPickerPage({
    super.key,
    this.selectedKey,
    this.suggestedKey,
    this.fallbackKey = EntryIcons.defaultKey,
  });

  final String? selectedKey;
  final String? suggestedKey;
  final String fallbackKey;

  static Future<String?> show(
    BuildContext context, {
    String? selectedKey,
    String? suggestedKey,
    String fallbackKey = EntryIcons.defaultKey,
  }) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => VaultIconPickerPage(
          selectedKey: selectedKey,
          suggestedKey: suggestedKey,
          fallbackKey: fallbackKey,
        ),
      ),
    );
  }

  @override
  State<VaultIconPickerPage> createState() => _VaultIconPickerPageState();
}

class _VaultIconPickerPageState extends State<VaultIconPickerPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late String _selected;
  String _query = '';
  List<BrandIconInfo> _brands = const [];
  bool _loadingBrands = true;
  bool _pickingCustom = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedKey?.isNotEmpty == true
        ? widget.selectedKey!
        : (widget.suggestedKey ?? widget.fallbackKey);
    _tabs = TabController(
      length: 2,
      vsync: this,
      initialIndex:
          EntryIcons.isBrand(_selected) && !CustomIcons.isCustom(_selected)
              ? 1
              : 0,
    );
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    final brands = await BrandIconCatalog.load();
    if (!mounted) return;
    setState(() {
      _brands = brands;
      _loadingBrands = false;
    });
  }

  Future<void> _pickFromDevice() async {
    if (_pickingCustom) return;
    setState(() => _pickingCustom = true);
    try {
      final key = await CustomIconFlow.pickAndEdit(context);
      if (key == null || !mounted) return;
      Navigator.of(context).pop(key);
    } finally {
      if (mounted) setState(() => _pickingCustom = false);
    }
  }

  Future<void> _reEditCustom() async {
    if (_pickingCustom || !CustomIcons.isCustom(_selected)) return;
    setState(() => _pickingCustom = true);
    try {
      final key = await CustomIconFlow.reEdit(context, _selected);
      if (key == null || !mounted) return;
      Navigator.of(context).pop(key);
    } finally {
      if (mounted) setState(() => _pickingCustom = false);
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.chooseIcon),
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(text: s.icons),
            Tab(text: s.brands),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: MEButton.outlined(
              onPressed: _pickingCustom ? null : _pickFromDevice,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_pickingCustom)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    const Icon(Icons.add_photo_alternate_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(s.fromDevice),
                ],
              ),
            ),
          ),
          if (CustomIcons.isCustom(_selected))
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(MECorners.large),
                ),
                tileColor: scheme.primaryContainer.withValues(alpha: 0.45),
                leading: EntryIcon(iconKey: _selected, size: 28),
                title: Text(s.customIcon),
                subtitle: Text(s.editIcon),
                trailing: Icon(Icons.edit_outlined, color: scheme.primary),
                onTap: _pickingCustom ? null : _reEditCustom,
              ),
            ),
          if (widget.suggestedKey != null &&
              widget.suggestedKey!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(MECorners.large),
                ),
                tileColor: scheme.secondaryContainer.withValues(alpha: 0.45),
                leading: EntryIcon(iconKey: widget.suggestedKey!, size: 28),
                title: Text(s.suggestedIcon),
                trailing: _selected == widget.suggestedKey
                    ? Icon(Icons.check_rounded, color: scheme.primary)
                    : null,
                onTap: () => Navigator.of(context).pop(widget.suggestedKey),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: MESearchBar(
              hintText: s.search,
              onChanged: (q) => setState(() => _query = q.trim().toLowerCase()),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _materialGrid(scheme),
                _brandsGrid(scheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _materialGrid(ColorScheme scheme) {
    final keys = EntryIcons.searchMaterial(_query);

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 88,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];
        return _cell(key, scheme);
      },
    );
  }

  Widget _brandsGrid(ColorScheme scheme) {
    if (_loadingBrands) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = _brands.where((b) {
      if (_query.isEmpty) return true;
      return b.searchText.contains(_query);
    }).toList();

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 88,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final brand = filtered[index];
        return _cell(
          brand.key,
          scheme,
          tooltip: brand.name,
        );
      },
    );
  }

  Widget _cell(String key, ColorScheme scheme, {String? tooltip}) {
    final selected = key == _selected;
    final child = Material(
      color: selected
          ? scheme.primaryContainer
          : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(MECorners.large),
      child: InkWell(
        borderRadius: BorderRadius.circular(MECorners.large),
        onTap: () => Navigator.of(context).pop(key),
        child: Center(
          child: EntryIcon(
            iconKey: key,
            size: 28,
            color: selected
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
    if (tooltip == null || tooltip.isEmpty) return child;
    return Tooltip(message: tooltip, child: child);
  }
}
