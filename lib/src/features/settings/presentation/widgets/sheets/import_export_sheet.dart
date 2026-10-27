import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';
import 'package:path_provider/path_provider.dart';

import 'export_io.dart' if (dart.library.html) 'export_io_stub.dart' as export_io;

class ImportExportSheet extends StatefulWidget {
  const ImportExportSheet({super.key, this.initialTab = 0});

  /// 0 = import, 1 = export.
  final int initialTab;

  Future<void> show(BuildContext context) {
    return showMEBottomSheet<void>(
      context: context,
      builder: (_) => this,
    );
  }

  @override
  State<ImportExportSheet> createState() => _ImportExportSheetState();
}

class _ImportExportSheetState extends State<ImportExportSheet> {
  late int _tab;
  bool _busy = false;
  int _importDone = 0;
  int _importTotal = 0;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab.clamp(0, 1);
  }

  bool get _isImport => _tab == 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = context.s;
    final subtitle = _busy
        ? (_isImport
            ? (_importTotal > 0
                ? s.importingProgress(_importDone, _importTotal)
                : s.importingPasswords)
            : s.exportingPasswords)
        : (_isImport ? s.importPasswordsSubtitle : s.exportPasswordsSubtitle);

    return PopScope(
      canPop: !_busy,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s.importExport,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            METabBar(
              tabs: [
                METab(label: s.importTab, icon: Icons.download_rounded),
                METab(label: s.exportTab, icon: Icons.upload_rounded),
              ],
              selectedIndex: _tab,
              onSelected: _busy
                  ? (_) {}
                  : (i) => setState(() => _tab = i),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            if (_busy) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _isImport && _importTotal > 0
                      ? _importDone / _importTotal
                      : null,
                  minHeight: 6,
                ),
              ),
              if (_isImport) ...[
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    s.importingPasswords,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
              ] else
                const SizedBox(height: 20),
            ] else if (_isImport)
              _ImportOptions(onImport: _import)
            else
              _ExportOptions(onExport: _export),
          ],
        ),
      ),
    );
  }

  Future<void> _import(String kind) async {
    if (_busy) return;
    final extensions = switch (kind) {
      'openkey' || 'bitwarden' => ['json'],
      'keepass' => ['kdbx'],
      _ => ['csv'],
    };
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return;
    if (!mounted) return;

    final bytes = picked.files.first.bytes;
    if (bytes == null || bytes.isEmpty) return;

    Uint8List? keePassKeyFile;
    var keePassPassword = '';
    if (kind == 'keepass') {
      final creds = await _promptKeePassCredentials(
        confirmLabel: context.s.importPasswords,
      );
      if (creds == null || !mounted) return;
      keePassPassword = creds.password;
      keePassKeyFile = creds.keyFile;
    }

    setState(() {
      _busy = true;
      _importDone = 0;
      _importTotal = 0;
    });
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;

    final importer = sl<ImportService>();
    late final FailureOr<int> result;
    try {
      void onProgress(int done, int total) {
        if (!mounted) return;
        if (done != total && done % 20 != 0) return;
        setState(() {
          _importDone = done;
          _importTotal = total;
        });
      }

      if (kind == 'keepass') {
        final items = await importer.parseKeePassKdbx(
          data: bytes,
          password: keePassPassword,
          keyFile: keePassKeyFile,
        );
        if (!mounted) return;
        setState(() => _importTotal = items.length);
        result = await importer.commit(items, onProgress: onProgress);
      } else if (kind == 'openkey') {
        final raw = utf8.decode(bytes);
        final data = importer.parseOpenKeyJson(raw);
        if (!mounted) return;
        setState(() => _importTotal = data.entries.length);
        result = await importer.commitOpenKey(data, onProgress: onProgress);
      } else {
        final raw = utf8.decode(bytes);
        final items = switch (kind) {
          'bitwarden' => importer.parseBitwardenJson(raw),
          '1password' => importer.parseOnePasswordCsv(raw),
          'lastpass' => importer.parseLastPassCsv(raw),
          _ => importer.parseChromeCsv(raw),
        };
        if (!mounted) return;
        setState(() => _importTotal = items.length);
        result = await importer.commit(items, onProgress: onProgress);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      final message = kind == 'keepass'
          ? context.s.keePassUnlockFailed
          : FailureMessage(e.toString()).getMessage(context);
      showMEToast(
        context,
        message: message,
        kind: METoastKind.error,
      );
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop();
    final s = context.s;
    result.fold(
      (f) => showMEToast(
        context,
        message: f.getMessage(context),
        kind: METoastKind.error,
      ),
      (n) => showMEToast(
        context,
        message: s.importedItems(n),
        kind: METoastKind.success,
      ),
    );
  }

  Future<({String password, Uint8List? keyFile})?> _promptKeePassCredentials({
    required String confirmLabel,
  }) {
    return showDialog<({String password, Uint8List? keyFile})>(
      context: context,
      builder: (ctx) => _KeePassCredentialsDialog(confirmLabel: confirmLabel),
    );
  }

  Future<void> _export(ExportFormat format) async {
    if (_busy) return;

    String? keePassPassword;
    Uint8List? keePassKeyFile;
    if (format == ExportFormat.keePassKdbx) {
      final creds = await _promptKeePassCredentials(
        confirmLabel: context.s.exportPasswords,
      );
      if (creds == null || !mounted) return;
      keePassPassword = creds.password;
      keePassKeyFile = creds.keyFile;
    }

    setState(() => _busy = true);
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;

    final exporter = sl<ExportService>();
    final result = await exporter.buildExport(
      format,
      keePassPassword: keePassPassword,
      keePassKeyFile: keePassKeyFile,
    );
    if (!mounted) return;

    await result.fold(
      (f) async {
        setState(() => _busy = false);
        showMEToast(
          context,
          message: f.getMessage(context),
          kind: METoastKind.error,
        );
      },
      (bytes) async {
        final name = exporter.fileName(format);
        final ext = exporter.extension(format);

        try {
          final path = await FilePicker.platform.saveFile(
            dialogTitle: context.s.exportPasswords,
            fileName: name,
            type: FileType.custom,
            allowedExtensions: [ext],
            bytes: bytes,
          );

          if (!mounted) return;

          if (path != null && path.isNotEmpty) {
            if (await export_io.pathNeedsWrite(path)) {
              await export_io.writeBytesToPath(path, bytes);
            }
          } else if (path == null) {
            final dir = await getApplicationDocumentsDirectory();
            final fallback = '${dir.path}/$name';
            await export_io.writeBytesToPath(fallback, bytes);
            if (!mounted) return;
            setState(() => _busy = false);
            Navigator.of(context).pop();
            showMEToast(
              context,
              message: context.s.exportedToPath(fallback),
              kind: METoastKind.success,
            );
            return;
          }

          if (!mounted) return;
          setState(() => _busy = false);
          Navigator.of(context).pop();
          showMEToast(
            context,
            message: context.s.exportedItems,
            kind: METoastKind.success,
          );
        } catch (e) {
          if (!mounted) return;
          setState(() => _busy = false);
          showMEToast(
            context,
            message: FailureMessage(e.toString()).getMessage(context),
            kind: METoastKind.error,
          );
        }
      },
    );
  }
}

class _ImportOptions extends StatelessWidget {
  const _ImportOptions({required this.onImport});

  final ValueChanged<String> onImport;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = context.s;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ActionItem(
          title: s.openKeyJson,
          subtitle: Text(s.openKeyJsonSubtitle),
          icon: SettingsIcon(
            Icons.shield_rounded,
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.onPrimaryContainer,
          ),
          itemPosition: ItemPosition.top,
          onTap: () => onImport('openkey'),
        ),
        ActionItem(
          title: s.bitwardenJson,
          subtitle: Text(s.bitwardenJsonSubtitle),
          icon: SettingsIcon(
            Icons.data_object_rounded,
            backgroundColor: scheme.secondaryContainer,
            foregroundColor: scheme.onSecondaryContainer,
          ),
          itemPosition: ItemPosition.center,
          onTap: () => onImport('bitwarden'),
        ),
        ActionItem(
          title: s.chromeCsv,
          subtitle: Text(s.chromeCsvSubtitle),
          icon: SettingsIcon(
            Icons.web_rounded,
            backgroundColor: scheme.tertiaryContainer,
            foregroundColor: scheme.onTertiaryContainer,
          ),
          itemPosition: ItemPosition.center,
          onTap: () => onImport('chrome'),
        ),
        ActionItem(
          title: s.lastPassCsv,
          subtitle: Text(s.lastPassCsvSubtitle),
          icon: SettingsIcon(
            Icons.lock_outline_rounded,
            backgroundColor: scheme.errorContainer,
            foregroundColor: scheme.onErrorContainer,
          ),
          itemPosition: ItemPosition.center,
          onTap: () => onImport('lastpass'),
        ),
        ActionItem(
          title: s.keePassKdbx,
          subtitle: Text(s.keePassKdbxSubtitle),
          icon: SettingsIcon(
            Icons.shield_moon_outlined,
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.onPrimaryContainer,
          ),
          itemPosition: ItemPosition.center,
          onTap: () => onImport('keepass'),
        ),
        ActionItem(
          title: s.onePasswordCsv,
          subtitle: Text(s.onePasswordCsvSubtitle),
          icon: SettingsIcon(
            Icons.key_rounded,
            backgroundColor: scheme.surfaceContainerHighest,
            foregroundColor: scheme.onSurfaceVariant,
          ),
          itemPosition: ItemPosition.bottom,
          onTap: () => onImport('1password'),
        ),
      ],
    );
  }
}

class _KeePassCredentialsDialog extends StatefulWidget {
  const _KeePassCredentialsDialog({required this.confirmLabel});

  final String confirmLabel;

  @override
  State<_KeePassCredentialsDialog> createState() =>
      _KeePassCredentialsDialogState();
}

class _KeePassCredentialsDialogState extends State<_KeePassCredentialsDialog> {
  final _password = TextEditingController();
  Uint8List? _keyFile;
  String? _keyFileName;
  var _obscure = true;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _pickKeyFile() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return;
    final file = picked.files.first;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) return;
    setState(() {
      _keyFile = bytes;
      _keyFileName = file.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return AlertDialog(
      title: Text(s.keePassKdbx),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _password,
            obscureText: _obscure,
            autofocus: true,
            decoration: InputDecoration(
              labelText: s.keePassPasswordHint,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickKeyFile,
            icon: const Icon(Icons.attach_file_rounded),
            label: Text(
              _keyFileName == null
                  ? s.keePassKeyFile
                  : '${s.keePassKeyFile}: $_keyFileName',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(s.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }

  void _submit() {
    Navigator.of(context).pop((
      password: _password.text,
      keyFile: _keyFile,
    ));
  }
}

class _ExportOptions extends StatelessWidget {
  const _ExportOptions({required this.onExport});

  final ValueChanged<ExportFormat> onExport;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = context.s;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ActionItem(
          title: s.openKeyJson,
          subtitle: Text(s.exportOpenKeySubtitle),
          icon: SettingsIcon(
            Icons.shield_rounded,
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.onPrimaryContainer,
          ),
          itemPosition: ItemPosition.top,
          onTap: () => onExport(ExportFormat.openKeyJson),
        ),
        ActionItem(
          title: s.bitwardenJson,
          subtitle: Text(s.exportBitwardenSubtitle),
          icon: SettingsIcon(
            Icons.data_object_rounded,
            backgroundColor: scheme.secondaryContainer,
            foregroundColor: scheme.onSecondaryContainer,
          ),
          itemPosition: ItemPosition.center,
          onTap: () => onExport(ExportFormat.bitwardenJson),
        ),
        ActionItem(
          title: s.chromeCsv,
          subtitle: Text(s.exportChromeSubtitle),
          icon: SettingsIcon(
            Icons.web_rounded,
            backgroundColor: scheme.tertiaryContainer,
            foregroundColor: scheme.onTertiaryContainer,
          ),
          itemPosition: ItemPosition.center,
          onTap: () => onExport(ExportFormat.chromeCsv),
        ),
        ActionItem(
          title: s.lastPassCsv,
          subtitle: Text(s.exportLastPassSubtitle),
          icon: SettingsIcon(
            Icons.lock_outline_rounded,
            backgroundColor: scheme.errorContainer,
            foregroundColor: scheme.onErrorContainer,
          ),
          itemPosition: ItemPosition.center,
          onTap: () => onExport(ExportFormat.lastPassCsv),
        ),
        ActionItem(
          title: s.keePassKdbx,
          subtitle: Text(s.exportKeePassSubtitle),
          icon: SettingsIcon(
            Icons.shield_moon_outlined,
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.onPrimaryContainer,
          ),
          itemPosition: ItemPosition.center,
          onTap: () => onExport(ExportFormat.keePassKdbx),
        ),
        ActionItem(
          title: s.onePasswordCsv,
          subtitle: Text(s.exportOnePasswordSubtitle),
          icon: SettingsIcon(
            Icons.key_rounded,
            backgroundColor: scheme.surfaceContainerHighest,
            foregroundColor: scheme.onSurfaceVariant,
          ),
          itemPosition: ItemPosition.bottom,
          onTap: () => onExport(ExportFormat.onePasswordCsv),
        ),
      ],
    );
  }
}
