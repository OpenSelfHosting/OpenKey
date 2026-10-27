import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';
import 'package:uuid/uuid.dart';

/// Confirms saving a login captured by system Autofill (Android / iOS).
class AutofillSavePage extends StatefulWidget {
  const AutofillSavePage({
    super.key,
    required this.request,
  });

  final AutofillSaveRequest request;

  @override
  State<AutofillSavePage> createState() => _AutofillSavePageState();
}

class _AutofillSavePageState extends State<AutofillSavePage> {
  late final TextEditingController _title;
  late final TextEditingController _username;
  late final TextEditingController _password;
  late final TextEditingController _url;
  bool _saving = false;
  String? _resolvedIcon;

  @override
  void initState() {
    super.initState();
    final r = widget.request;
    _title = TextEditingController(text: r.suggestedTitle);
    _username = TextEditingController(text: r.username);
    _password = TextEditingController(text: r.password);
    _url = TextEditingController(text: r.suggestedUrl);
    _resolveIcon();
  }

  Future<void> _resolveIcon() async {
    final r = widget.request;
    String? icon;

    // Prefer the installed app icon whenever we have a native package.
    if (r.isNativeAppSave) {
      icon = await AppIconFetcher.iconKeyFromBase64(r.iconBase64);
      if (icon == null) {
        okDebugLog(
          'AutofillSave: iconBase64 missing/invalid, fetching for ${r.packageName}',
        );
        icon = await AppIconFetcher.iconKeyFor(r.packageName);
      }
      if (icon != null) {
        okDebugLog('AutofillSave: resolved app icon for ${r.packageName}');
      }
    }

    icon ??= await EntryIcons.suggest(
      title: _title.text,
      url: _url.text,
      username: _username.text,
      extras: [
        if (r.packageName.trim().isNotEmpty) r.packageName.trim(),
      ],
    );

    if (!mounted) return;
    setState(() => _resolvedIcon = icon);
  }

  @override
  void dispose() {
    _title.dispose();
    _username.dispose();
    _password.dispose();
    _url.dispose();
    super.dispose();
  }

  List<String> _buildUrls() {
    final typed = _url.text.trim();
    final urls = <String>[];
    if (typed.isNotEmpty) urls.add(typed);

    final appUrl = widget.request.androidAppUrl;
    if (appUrl.isNotEmpty && !urls.contains(appUrl)) {
      urls.add(appUrl);
    }

    final website = widget.request.websiteUrl;
    if (website.isNotEmpty && !urls.contains(website)) {
      urls.add(website);
    }
    return urls;
  }

  Future<void> _save() async {
    if (_saving) return;

    setState(() => _saving = true);
    final urls = _buildUrls();

    var icon = _resolvedIcon ?? '';
    if (icon.isEmpty || icon == EntryIcons.defaultKey) {
      if (widget.request.isNativeAppSave) {
        icon = await AppIconFetcher.iconKeyFromBase64(widget.request.iconBase64) ??
            await AppIconFetcher.iconKeyFor(widget.request.packageName) ??
            '';
      }
      if (icon.isEmpty) {
        icon = await EntryIcons.suggest(
          title: _title.text,
          url: urls.isEmpty ? '' : urls.first,
          username: _username.text,
          extras: [
            if (widget.request.packageName.trim().isNotEmpty)
              widget.request.packageName.trim(),
          ],
        );
      }
    }

    final hasApp = urls.any((u) => u.startsWith('androidapp://'));
    final hasWeb = urls.any((u) => !u.startsWith('androidapp://'));

    final entry = VaultEntry(
      uuid: const Uuid().v4(),
      title: _title.text.trim().isEmpty ? 'Login' : _title.text.trim(),
      username: _username.text.trim(),
      password: _password.text,
      urls: urls,
      icon: icon,
      fieldOrder: [
        EntryEditorField.username.name,
        EntryEditorField.password.name,
        if (hasWeb) EntryEditorField.website.name,
        if (hasApp) EntryEditorField.androidApp.name,
      ],
    );
    final result = await sl<CreateEntryUsecase>()(entry);
    if (!mounted) return;
    result.fold(
      (f) {
        setState(() => _saving = false);
        showMEToast(
          context,
          message: f.getMessage(context),
          kind: METoastKind.error,
        );
      },
      (_) async {
        await sl<AutofillBridge>().syncCredentials();
        if (!mounted) return;
        showMEToast(
          context,
          message: context.s.autofillSaved,
          kind: METoastKind.success,
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.vault.path);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    final iconKey = _resolvedIcon ?? EntryIcons.defaultKey;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.autofillSaveTitle),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.vault.path);
            }
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            s.autofillSaveSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 20),
          Center(
            child: VaultIconSurface(
              iconKey: iconKey,
              size: 72,
              child: EntryIcon(
                iconKey: iconKey,
                // Custom / brand / app icons fill the tile; material keeps padding.
                size: VaultIconSurface.needsBackdrop(iconKey) ? 48 : 72,
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _title,
            decoration: InputDecoration(labelText: s.title),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _username,
            decoration: InputDecoration(labelText: s.username),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            decoration: InputDecoration(labelText: s.password),
            obscureText: true,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _url,
            decoration: InputDecoration(
              labelText: s.website,
              hintText: 'https://… · androidapp://… · appleapp://…',
            ),
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(s.save),
          ),
        ],
      ),
    );
  }
}
