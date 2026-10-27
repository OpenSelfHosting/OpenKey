import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';
import 'package:uuid/uuid.dart';

class EntryEditorPage extends StatefulWidget {
  const EntryEditorPage({super.key, this.uuid, this.collectionUuid});

  final String? uuid;
  final String? collectionUuid;

  bool get isNew => uuid == null || uuid == 'new';

  @override
  State<EntryEditorPage> createState() => _EntryEditorPageState();
}

class _EntryEditorPageState extends State<EntryEditorPage> {
  final _title = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _url = TextEditingController();
  final _androidApp = TextEditingController();
  final _notes = TextEditingController();
  final _totpSecret = TextEditingController();
  final Map<EntryEditorField, TextEditingController> _extraControllers = {};
  String? _collectionUuid;
  bool _loading = true;
  bool _saving = false;
  VaultEntry? _existing;
  List<AttachmentMeta> _attachments = const [];
  var _attachmentBusy = false;
  PasskeyPayload? _passkey;
  List<String> _tags = const [];
  String? _totpCode;
  Timer? _totpTimer;
  late List<EntryEditorField> _visibleFields;
  final Map<EntryEditorField, String?> _fieldErrors = {};
  String _iconKey = EntryIcons.defaultKey;
  bool _iconManual = false;

  /// Host the current auto favicon was fetched for (skip re-download).
  String? _autoFaviconHost;

  /// Blocks suggest listeners while entry fields are being hydrated on edit.
  bool _suppressIconSuggest = false;
  int _suggestToken = 0;

  @override
  void initState() {
    super.initState();
    _visibleFields = List.of(EntryEditorField.defaults);
    _collectionUuid = widget.collectionUuid;
    _title.addListener(_onSuggestFieldsChanged);
    _username.addListener(_onSuggestFieldsChanged);
    _url.addListener(_onSuggestFieldsChanged);
    _androidApp.addListener(_onSuggestFieldsChanged);
    _notes.addListener(_onSuggestFieldsChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _collectionUuid != null || !widget.isNew) return;
      final folder = context.read<CollectionBloc>().state.currentFolderUuid;
      if (folder != null) {
        setState(() => _collectionUuid = folder);
      }
    });
    _load();
  }

  void _onSuggestFieldsChanged() {
    if (_suppressIconSuggest || _iconManual) return;
    // Device-picked image: keep it unless the domain/host changed.
    if (CustomIcons.isCustom(_iconKey) && !CustomIcons.isFavicon(_iconKey)) {
      final host = _currentFaviconHost();
      if (host == _autoFaviconHost) return;
    }
    _scheduleIconSuggest();
  }

  List<String> _iconSuggestExtras() {
    final extras = <String>[_androidApp.text, _notes.text, ..._tags];
    for (final field in _visibleFields) {
      if (!field.isExtra) continue;
      // Skip non-textual / sensitive values that shouldn't drive brand icons.
      if (field == EntryEditorField.pin ||
          field == EntryEditorField.number ||
          field == EntryEditorField.card ||
          field == EntryEditorField.dateYmd ||
          field == EntryEditorField.dateYm ||
          field == EntryEditorField.recoveryCodes) {
        continue;
      }
      final value = _extraControllers[field]?.text.trim() ?? '';
      if (value.isNotEmpty) extras.add(value);
    }
    return extras;
  }

  String? _currentFaviconHost() {
    final suggestUrl = _suggestUrl();
    final pkg = AppIconFetcher.packageOf(suggestUrl);
    if (pkg != null) return pkg;
    final urlHost = FaviconFetcher.extractHost(_url.text);
    if (urlHost != null) return urlHost;
    if (FaviconFetcher.looksLikeDomain(_title.text)) {
      return FaviconFetcher.extractHost(_title.text);
    }
    return null;
  }

  String _suggestUrl() {
    final website = _url.text.trim();
    if (website.isNotEmpty) return website;
    final pkg = _androidApp.text.trim();
    if (pkg.isEmpty) return '';
    return pkg.startsWith('androidapp://') ? pkg : 'androidapp://$pkg';
  }

  void _scheduleIconSuggest() {
    final token = ++_suggestToken;
    Future<void>.delayed(const Duration(milliseconds: 280), () async {
      if (!mounted || token != _suggestToken || _iconManual) return;
      if (_suppressIconSuggest) return;

      // Device-picked image stays unless the domain changed.
      if (CustomIcons.isCustom(_iconKey) && !CustomIcons.isFavicon(_iconKey)) {
        final host = _currentFaviconHost();
        if (host == _autoFaviconHost) return;
      }

      final suggestUrl = _suggestUrl();
      final faviconHost = _currentFaviconHost();
      final keepFavicon =
          CustomIcons.isFavicon(_iconKey) &&
          faviconHost != null &&
          faviconHost == _autoFaviconHost;

      final suggested = await EntryIcons.suggest(
        title: _title.text,
        url: suggestUrl,
        username: _username.text,
        extras: _iconSuggestExtras(),
        // Reuse the already-fetched favicon for this host.
        fetchFavicon: !keepFavicon,
      );
      if (!mounted || token != _suggestToken || _iconManual) return;
      if (_suppressIconSuggest) return;

      // Prefer an existing host favicon over material fallback.
      if (keepFavicon &&
          !EntryIcons.isBrand(suggested) &&
          !CustomIcons.isFavicon(suggested)) {
        return;
      }

      if (suggested != _iconKey) {
        setState(() {
          _iconKey = suggested;
          if (CustomIcons.isFavicon(suggested)) {
            _autoFaviconHost = faviconHost;
          } else {
            _autoFaviconHost = null;
          }
        });
        if (CustomIcons.isFavicon(suggested) && faviconHost != null) {
          unawaited(FaviconFetcher.remember(faviconHost, suggested));
        }
      } else if (CustomIcons.isFavicon(suggested)) {
        _autoFaviconHost = faviconHost;
      }
    });
  }

  Future<void> _pickIcon() async {
    final suggested = await EntryIcons.suggest(
      title: _title.text,
      url: _suggestUrl(),
      username: _username.text,
      extras: _iconSuggestExtras(),
    );
    if (!mounted) return;
    final picked = await VaultIconPickerPage.show(
      context,
      selectedKey: _iconKey,
      suggestedKey: suggested,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _iconKey = picked;
      _iconManual = true;
      _autoFaviconHost = null;
    });
  }

  TextEditingController _extraController(EntryEditorField field) {
    return _extraControllers.putIfAbsent(field, () {
      final controller = TextEditingController();
      if (field.isExtra &&
          field != EntryEditorField.pin &&
          field != EntryEditorField.number &&
          field != EntryEditorField.card &&
          field != EntryEditorField.dateYmd &&
          field != EntryEditorField.dateYm &&
          field != EntryEditorField.recoveryCodes) {
        controller.addListener(_onSuggestFieldsChanged);
      }
      return controller;
    });
  }

  String _valueFor(EntryEditorField field) {
    return switch (field) {
      EntryEditorField.username => _username.text,
      EntryEditorField.password => _password.text,
      EntryEditorField.website => _url.text,
      EntryEditorField.androidApp => _androidApp.text,
      EntryEditorField.notes => _notes.text,
      EntryEditorField.totp => _totpSecret.text,
      _ when field.isExtra => _extraControllers[field]?.text ?? '',
      _ => '',
    };
  }

  void _validateField(EntryEditorField field, [String? value]) {
    final error = EntryFieldValidators.validate(
      field,
      value ?? _valueFor(field),
      context.s,
    );
    if (_fieldErrors[field] == error) return;
    setState(() {
      if (error == null) {
        _fieldErrors.remove(field);
      } else {
        _fieldErrors[field] = error;
      }
    });
  }

  bool _validateVisibleFields() {
    final s = context.s;
    final next = <EntryEditorField, String?>{};
    for (final field in _visibleFields) {
      final error = EntryFieldValidators.validate(field, _valueFor(field), s);
      if (error != null) next[field] = error;
    }
    setState(() {
      _fieldErrors
        ..clear()
        ..addAll(next);
    });
    return next.isEmpty;
  }

  Future<void> _load() async {
    if (widget.isNew) {
      _visibleFields = List.of(EntryEditorField.defaults);
      if (_visibleFields.contains(EntryEditorField.password)) {
        final settings = sl<SettingsCubit>().state;
        _password.text = settings.generatePassword(sl<CryptoService>());
      }
      _iconKey = EntryIcons.defaultKey;
      _iconManual = false;
      _autoFaviconHost = null;
      setState(() => _loading = false);
      _scheduleIconSuggest();
      return;
    }

    _suppressIconSuggest = true;
    final result = await sl<GetEntryUsecase>()(widget.uuid!);
    result.fold((_) {}, (entry) {
      if (entry != null) {
        _existing = entry;
        _title.text = entry.title;
        _username.text = entry.username;
        _password.text = entry.password;
        String website = '';
        String androidApp = '';
        for (final u in entry.urls) {
          if (u.startsWith('androidapp://')) {
            if (androidApp.isEmpty) {
              androidApp = u.substring('androidapp://'.length);
            }
          } else if (website.isEmpty) {
            website = u;
          }
        }
        _url.text = website;
        _androidApp.text = androidApp;
        _notes.text = entry.notes;
        _collectionUuid = entry.collectionUuid;
        _totpSecret.text = entry.totp?.secret ?? '';
        _attachments = entry.attachments;
        _passkey = entry.passkey;
        _tags = List.of(entry.tags);
        if (entry.icon.isNotEmpty) {
          _iconKey = entry.icon;
          // Picker lock is session-only. Auto-suggest stays on while editing so
          // adding/changing a domain can update the icon (create parity).
          _iconManual = false;
          final host =
              FaviconFetcher.extractHost(website) ??
              (FaviconFetcher.looksLikeDomain(entry.title)
                  ? FaviconFetcher.extractHost(entry.title)
                  : null);
          if (CustomIcons.isFavicon(entry.icon)) {
            _autoFaviconHost = host;
          } else if (CustomIcons.isCustom(entry.icon)) {
            // Legacy/device custom: remember host so unchanged domain keeps it.
            _autoFaviconHost = host;
          } else {
            _autoFaviconHost = null;
          }
        } else {
          _iconKey = EntryIcons.defaultKey;
          _iconManual = false;
          _autoFaviconHost = null;
        }
        for (final extra in entry.fields) {
          final field = EntryEditorField.fromStorageKey(extra.type);
          if (field == null) continue;
          _extraController(field).text = extra.value;
        }
        _visibleFields = EntryEditorField.inferOrderedFrom(entry);
        _startTotpTicker(entry.totp);
      }
    });
    _suppressIconSuggest = false;
    if (mounted) setState(() => _loading = false);
    _scheduleIconSuggest();
  }

  void _applyGeneratedPassword(String password) {
    setState(() {
      _password.text = password;
      _password.selection = TextSelection.collapsed(offset: password.length);
    });
  }

  void _quickGeneratePassword() {
    final settings = context.read<SettingsCubit>().state;
    _applyGeneratedPassword(settings.generatePassword(sl<CryptoService>()));
  }

  Future<void> _copyPassword() async {
    await Clipboard.setData(ClipboardData(text: _password.text));
    if (!mounted) return;
    showMEToast(
      context,
      message: context.s.passwordCopied,
      kind: METoastKind.success,
    );
  }

  Future<void> _openPasswordGenerator() async {
    final password = await PasswordGeneratorSheet(
      forUse: true,
      seedPassword: _password.text,
    ).show(context);
    if (!mounted || password == null || password.isEmpty) return;
    _applyGeneratedPassword(password);
  }

  Future<void> _manageFields() async {
    final next = await ManageEntryFieldsPage.show(
      context,
      visible: _visibleFields,
    );
    if (!mounted || next == null) return;

    setState(() {
      final previous = _visibleFields.toSet();
      final upcoming = next.toSet();

      for (final field in previous.difference(upcoming)) {
        _clearField(field);
      }

      for (final field in next) {
        if (field.isExtra) _extraController(field);
      }

      final passwordAdded =
          upcoming.contains(EntryEditorField.password) &&
          !previous.contains(EntryEditorField.password);
      if (passwordAdded && _password.text.isEmpty) {
        final settings = context.read<SettingsCubit>().state;
        _password.text = settings.generatePassword(sl<CryptoService>());
      }

      _visibleFields = List.of(next);
    });
    if (!_iconManual) _scheduleIconSuggest();
  }

  void _clearField(EntryEditorField field) {
    _fieldErrors.remove(field);
    switch (field) {
      case EntryEditorField.username:
        _username.clear();
      case EntryEditorField.password:
        _password.clear();
      case EntryEditorField.website:
        _url.clear();
      case EntryEditorField.androidApp:
        _androidApp.clear();
      case EntryEditorField.notes:
        _notes.clear();
      case EntryEditorField.tags:
        _tags = const [];
      case EntryEditorField.totp:
        _totpSecret.clear();
        _totpCode = null;
        _totpTimer?.cancel();
        _totpTimer = null;
      case EntryEditorField.passkey:
        _passkey = null;
      case EntryEditorField.attachments:
        _attachments = const [];
      case EntryEditorField.email:
      case EntryEditorField.phone:
      case EntryEditorField.pin:
      case EntryEditorField.number:
      case EntryEditorField.card:
      case EntryEditorField.address:
      case EntryEditorField.ipAddress:
      case EntryEditorField.walletAddress:
      case EntryEditorField.dateYmd:
      case EntryEditorField.dateYm:
      case EntryEditorField.recoveryCodes:
      case EntryEditorField.text:
        final controller = _extraControllers.remove(field);
        controller?.dispose();
    }
  }

  void _startTotpTicker(TotpConfig? config) {
    _totpTimer?.cancel();
    if (config == null || config.secret.isEmpty) return;
    void tick() {
      setState(() => _totpCode = sl<TotpService>().generate(config));
    }

    tick();
    _totpTimer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  Future<void> _scanTotpQr() async {
    final uri = await TotpQrScannerPage.scan(context);
    if (!mounted || uri == null || uri.isEmpty) return;
    final config = sl<TotpService>().parseOtpAuth(uri);
    _totpSecret.text = uri;
    _startTotpTicker(config);
  }

  Future<void> _pickDate(EntryEditorField field) async {
    final controller = _extraController(field);
    final now = DateTime.now();
    var initial = now;
    final raw = controller.text.trim();
    if (raw.isNotEmpty) {
      final parsed = DateTime.tryParse(
        field == EntryEditorField.dateYm && raw.length == 7 ? '$raw-01' : raw,
      );
      if (parsed != null) initial = parsed;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      final y = picked.year.toString().padLeft(4, '0');
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      controller.text = field == EntryEditorField.dateYm ? '$y-$m' : '$y-$m-$d';
    });
  }

  @override
  void dispose() {
    _totpTimer?.cancel();
    _title.dispose();
    _username.dispose();
    _password.dispose();
    _url.dispose();
    _androidApp.dispose();
    _notes.dispose();
    _totpSecret.dispose();
    for (final controller in _extraControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  List<EntryExtraField> _buildExtraFields() {
    final extras = <EntryExtraField>[];
    for (final field in _visibleFields) {
      if (!field.isExtra) continue;
      final value = _extraControllers[field]?.text ?? '';
      if (value.trim().isEmpty) continue;
      extras.add(EntryExtraField(type: field.storageKey, value: value));
    }
    return extras;
  }

  Future<void> _save() async {
    if (!_validateVisibleFields()) {
      if (!mounted) return;
      showMEToast(
        context,
        message: context.s.fixFieldErrors,
        kind: METoastKind.error,
      );
      return;
    }
    final totpRaw = _totpSecret.text.trim();
    TotpConfig? totp;
    if (_visibleFields.contains(EntryEditorField.totp) && totpRaw.isNotEmpty) {
      totp =
          sl<TotpService>().parseOtpAuth(totpRaw) ??
          TotpConfig(secret: totpRaw.replaceAll(' ', ''));
    }
    final rawFolder =
        _collectionUuid ??
        (widget.isNew
            ? context.read<CollectionBloc>().state.currentFolderUuid
            : null);
    final folderUuid =
        (rawFolder == null ||
            rawFolder.isEmpty ||
            rawFolder == kVaultRootScope ||
            rawFolder == '__all__')
        ? null
        : rawFolder;
    final entry = VaultEntry(
      uuid: widget.isNew ? const Uuid().v4() : widget.uuid!,
      collectionUuid: folderUuid,
      title: _title.text.trim(),
      username: _visibleFields.contains(EntryEditorField.username)
          ? _username.text.trim()
          : '',
      password: _visibleFields.contains(EntryEditorField.password)
          ? _password.text
          : '',
      urls: () {
        final list = <String>[];
        if (_visibleFields.contains(EntryEditorField.website) &&
            _url.text.trim().isNotEmpty) {
          list.add(_url.text.trim());
        }
        if (_visibleFields.contains(EntryEditorField.androidApp) &&
            _androidApp.text.trim().isNotEmpty) {
          var pkg = _androidApp.text.trim();
          if (pkg.startsWith('androidapp://')) {
            pkg = pkg.substring('androidapp://'.length);
          }
          if (pkg.isNotEmpty) list.add('androidapp://$pkg');
        }
        return list;
      }(),
      notes: _visibleFields.contains(EntryEditorField.notes) ? _notes.text : '',
      tags: _visibleFields.contains(EntryEditorField.tags) ? _tags : const [],
      fields: _buildExtraFields(),
      fieldOrder: _visibleFields.map((f) => f.name).toList(growable: false),
      icon: _iconKey,
      totp: totp,
      attachments: _visibleFields.contains(EntryEditorField.attachments)
          ? _attachments
          : const [],
      passkey: _visibleFields.contains(EntryEditorField.passkey)
          ? _passkey
          : null,
    );

    if (_saving) return;
    setState(() => _saving = true);
    // Await the write before popping so details pages reload fresh data
    // instead of racing the fire-and-forget EntryBloc handlers.
    final result = widget.isNew
        ? await sl<CreateEntryUsecase>()(entry)
        : await sl<UpdateEntryUsecase>()(entry);
    if (!mounted) return;
    result.fold((f) {
      setState(() => _saving = false);
      showMEToast(
        context,
        message: f.getMessage(context),
        kind: METoastKind.error,
      );
    }, (_) => context.pop());
  }

  Future<void> _addAttachment() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
      withData: false,
    );
    if (picked == null || picked.files.isEmpty) return;
    final file = picked.files.first;
    final bytes = await AttachmentActions.readPlatformFileBytes(file);
    if (bytes == null || bytes.isEmpty) {
      if (mounted) {
        showMEToast(
          context,
          message: context.s.failureAttachmentMissing,
          kind: METoastKind.error,
        );
      }
      return;
    }
    final filename = AttachmentActions.resolveFileName(file);
    final entryUuid = widget.isNew ? const Uuid().v4() : widget.uuid!;
    final result = await sl<AttachmentService>().addAttachment(
      entryUuid: entryUuid,
      filename: filename,
      bytes: bytes,
      contentType: attachmentContentType(filename),
    );
    result.fold((f) {
      if (mounted) {
        showMEToast(
          context,
          message: f.getMessage(context),
          kind: METoastKind.error,
        );
      }
    }, (meta) => setState(() => _attachments = [..._attachments, meta]));
  }

  Future<void> _previewAttachment(AttachmentMeta meta) async {
    if (_attachmentBusy) return;
    setState(() => _attachmentBusy = true);
    await AttachmentActions.previewInApp(context, meta);
    if (mounted) setState(() => _attachmentBusy = false);
  }

  Future<void> _downloadAttachment(AttachmentMeta meta) async {
    if (_attachmentBusy) return;
    setState(() => _attachmentBusy = true);
    await AttachmentActions.downloadToDevice(context, meta);
    if (mounted) setState(() => _attachmentBusy = false);
  }

  Future<void> _removeAttachment(AttachmentMeta meta) async {
    await sl<AttachmentService>().deleteLocalBlob(meta.id);
    if (!mounted) return;
    setState(
      () => _attachments = _attachments.where((a) => a.id != meta.id).toList(),
    );
  }

  Widget _sectionBlock({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  String? _passwordStrengthLabel(AppLocalizations s, double strength) {
    if (strength <= 0) return null;
    if (strength < 0.35) return s.passwordStrengthWeak;
    if (strength < 0.7) return s.passwordStrengthFair;
    return s.passwordStrengthStrong;
  }

  Future<void> _showPasswordActions() async {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    final action = await showMEBottomSheet<_PasswordMenuAction>(
      context: context,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                s.password,
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ActionItem(
                title: s.generate,
                icon: SettingsIcon(
                  Icons.autorenew_rounded,
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                ),
                itemPosition: ItemPosition.top,
                onTap: () =>
                    Navigator.pop(sheetContext, _PasswordMenuAction.generate),
              ),
              ActionItem(
                title: s.generateOptions,
                icon: SettingsIcon(
                  Icons.tune_rounded,
                  backgroundColor: scheme.secondaryContainer,
                  foregroundColor: scheme.onSecondaryContainer,
                ),
                itemPosition: ItemPosition.center,
                onTap: () =>
                    Navigator.pop(sheetContext, _PasswordMenuAction.options),
              ),
              ActionItem(
                title: s.copy,
                icon: SettingsIcon(
                  Icons.content_copy_rounded,
                  backgroundColor: scheme.tertiaryContainer,
                  foregroundColor: scheme.onTertiaryContainer,
                ),
                itemPosition: ItemPosition.bottom,
                onTap: () =>
                    Navigator.pop(sheetContext, _PasswordMenuAction.copy),
              ),
            ],
          ),
        );
      },
    );
    if (!mounted || action == null) return;
    switch (action) {
      case _PasswordMenuAction.generate:
        _quickGeneratePassword();
      case _PasswordMenuAction.options:
        await _openPasswordGenerator();
      case _PasswordMenuAction.copy:
        await _copyPassword();
    }
  }

  Widget _buildPasswordSection(AppLocalizations s) {
    final scheme = Theme.of(context).colorScheme;

    return MEPasswordField(
      controller: _password,
      label: s.password,
      showStrengthMeter: true,
      strengthLabel: (strength) => _passwordStrengthLabel(s, strength),
      showPasswordTooltip: s.showPassword,
      hidePasswordTooltip: s.hidePassword,
      trailingActions: IconButton(
        tooltip: s.passwordGenerator,
        icon: Icon(Icons.tune_rounded, color: scheme.onSurfaceVariant),
        onPressed: _showPasswordActions,
      ),
    );
  }

  Widget _buildExtraInput(EntryEditorField field, AppLocalizations s) {
    final controller = _extraController(field);
    final label = field.label(s);
    final error = _fieldErrors[field];
    final formatters = EntryFieldValidators.formatters(field);

    if (field.isSensitive && field != EntryEditorField.recoveryCodes) {
      return MEPasswordField(
        controller: controller,
        label: label,
        errorText: error,
        keyboardType: field.keyboardType,
        inputFormatters: formatters,
        onChanged: (value) => _validateField(field, value),
      );
    }

    if (field.isDateField) {
      return METextField(
        controller: controller,
        label: label,
        readOnly: true,
        errorText: error,
        leadingIcon: Icon(field.icon),
        trailingIcon: const Icon(Icons.calendar_today_outlined),
        onTrailingIconPressed: () => _pickDate(field),
        onTap: () => _pickDate(field),
      );
    }

    return METextField(
      controller: controller,
      label: label,
      keyboardType: field.keyboardType,
      maxLines: field.isMultiline ? 4 : 1,
      leadingIcon: Icon(field.icon),
      errorText: error,
      inputFormatters: formatters,
      onChanged: (value) => _validateField(field, value),
    );
  }

  List<Widget> _buildFieldWidgets(AppLocalizations s) {
    final children = <Widget>[];

    for (final field in _visibleFields) {
      children.add(const SizedBox(height: 12));

      if (field.isExtra) {
        children.add(_buildExtraInput(field, s));
        continue;
      }

      switch (field) {
        case EntryEditorField.username:
          children.add(METextField(controller: _username, label: s.username));
        case EntryEditorField.password:
          children.add(_buildPasswordSection(s));
        case EntryEditorField.website:
          children.add(
            METextField(
              controller: _url,
              label: s.website,
              keyboardType: TextInputType.url,
              errorText: _fieldErrors[field],
              onChanged: (value) {
                _validateField(EntryEditorField.website, value);
                _onSuggestFieldsChanged();
              },
            ),
          );
        case EntryEditorField.androidApp:
          children.add(
            METextField(
              controller: _androidApp,
              label: s.androidApp,
              hintText: s.androidAppHint,
              keyboardType: TextInputType.text,
              errorText: _fieldErrors[field],
              onChanged: (value) =>
                  _validateField(EntryEditorField.androidApp, value),
            ),
          );
        case EntryEditorField.notes:
          children.add(
            METextField(controller: _notes, label: s.notes, maxLines: 4),
          );
        case EntryEditorField.tags:
          children.add(
            METagInput(
              label: s.tags,
              hintText: s.addTagHint,
              tags: _tags,
              onChanged: (tags) {
                setState(() => _tags = tags);
                _onSuggestFieldsChanged();
              },
            ),
          );
        case EntryEditorField.totp:
          children.add(
            _sectionBlock(
              title: s.authenticatorTotp,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  METextField(
                    controller: _totpSecret,
                    label: s.totpSecretLabel,
                    trailingIcon: TotpQrScannerPage.isSupported
                        ? const Icon(Icons.qr_code_scanner_rounded)
                        : null,
                    onTrailingIconPressed: TotpQrScannerPage.isSupported
                        ? _scanTotpQr
                        : null,
                  ),
                  if (_totpCode != null) ...[
                    const SizedBox(height: 8),
                    MEListTile(
                      title: Text(
                        _totpCode!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 22,
                        ),
                      ),
                      subtitle: Text(s.tapToCopy),
                      onPressed: () =>
                          Clipboard.setData(ClipboardData(text: _totpCode!)),
                    ),
                  ],
                ],
              ),
            ),
          );
        case EntryEditorField.passkey:
          children.add(
            _sectionBlock(
              title: s.passkey,
              child: _passkey != null
                  ? MEListTile(
                      title: Text(_passkey!.rpId),
                      subtitle: Text(
                        [
                          if (_passkey!.userName != null &&
                              _passkey!.userName!.isNotEmpty)
                            _passkey!.userName!,
                          _passkey!.credentialId,
                          if (_passkey!.privateKeyCipher == null)
                            s.storePasskeyMetadata,
                        ].join('\n'),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => setState(() => _passkey = null),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        s.passkeyCreatedInBrowser,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
            ),
          );
        case EntryEditorField.attachments:
          children.add(
            _sectionBlock(
              title: s.attachments,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final a in _attachments)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: VaultAttachmentCard(
                        key: ValueKey('attachment-${a.id}'),
                        meta: a,
                        enabled: !_attachmentBusy,
                        onTap: () => _previewAttachment(a),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MEIconButton(
                              tooltip: s.previewAttachment,
                              variant: MEButtonVariant.text,
                              size: MEButtonSize.extraSmall,
                              onPressed: _attachmentBusy
                                  ? null
                                  : () => _previewAttachment(a),
                              icon: const Icon(Icons.visibility_outlined),
                            ),
                            MEIconButton(
                              tooltip: s.downloadAttachment,
                              variant: MEButtonVariant.text,
                              size: MEButtonSize.extraSmall,
                              onPressed: _attachmentBusy
                                  ? null
                                  : () => _downloadAttachment(a),
                              icon: const Icon(Icons.download_outlined),
                            ),
                            MEIconButton(
                              tooltip: s.delete,
                              variant: MEButtonVariant.text,
                              size: MEButtonSize.extraSmall,
                              onPressed: _attachmentBusy
                                  ? null
                                  : () => _removeAttachment(a),
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  MEButton.outlined(
                    onPressed: _addAttachment,
                    child: Text(s.addEncryptedAttachment),
                  ),
                ],
              ),
            ),
          );
        case EntryEditorField.email:
        case EntryEditorField.phone:
        case EntryEditorField.pin:
        case EntryEditorField.number:
        case EntryEditorField.card:
        case EntryEditorField.address:
        case EntryEditorField.ipAddress:
        case EntryEditorField.walletAddress:
        case EntryEditorField.dateYmd:
        case EntryEditorField.dateYm:
        case EntryEditorField.recoveryCodes:
        case EntryEditorField.text:
          break;
      }
    }

    return children;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final s = context.s;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? s.newEntry : s.editEntry),
        actions: [
          if (!widget.isNew)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                context.read<EntryBloc>().add(EntryDeleted(widget.uuid!));
                context.pop();
              },
            ),
          IconButton(
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const SizedBox(height: 22),
          Center(
            child: Column(
              children: [
                InkWell(
                  onTap: _pickIcon,
                  borderRadius: BorderRadius.circular(56),
                  child: VaultIconSurface(
                    iconKey: _iconKey,
                    size: 212,
                    expressive: true,
                    backgroundColor: scheme.primaryContainer,
                    child: EntryIcon(
                      iconKey: _iconKey,
                      size: VaultIconSurface.needsBackdrop(_iconKey)
                          ? 116
                          : 140,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 44),
          METextField(controller: _title, label: s.title),
          ..._buildFieldWidgets(s),
          if (_existing != null) ...[
            const SizedBox(height: 16),
            Text(
              '${s.revisionLabel(_existing!.revision)}'
              ' · ${_existing!.isSynced ? s.synced : s.pendingSync}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MEButton.outlined(
                onPressed: _manageFields,
                child: Text(s.chooseFields),
              ),
              const SizedBox(height: 12),
              MEButton(
                size: MEButtonSize.large,
                onPressed: _save,
                child: Text(widget.isNew ? s.create : s.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _PasswordMenuAction { generate, options, copy }
