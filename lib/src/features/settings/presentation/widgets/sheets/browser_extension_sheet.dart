import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

class BrowserExtensionSheet extends StatefulWidget {
  const BrowserExtensionSheet({super.key});

  Future<void> show(BuildContext context) {
    return showMEBottomSheet<void>(
      context: context,
      builder: (_) => this,
    );
  }

  @override
  State<BrowserExtensionSheet> createState() => _BrowserExtensionSheetState();
}

class _BrowserExtensionSheetState extends State<BrowserExtensionSheet> {
  late final TextEditingController _extensionId;
  bool _busy = false;
  String? _message;
  bool _registered = false;

  @override
  void initState() {
    super.initState();
    _extensionId = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    final host = sl<NativeMessagingHost>();
    final id = await host.readChromeExtensionId();
    final registered = await host.isBrowserNativeHostRegistered();
    if (!mounted) return;
    setState(() {
      if (id != null) _extensionId.text = id;
      _registered = registered;
    });
  }

  @override
  void dispose() {
    _extensionId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = context.s;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s.browserExtension,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              s.browserExtensionSheetSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            METextField(
              controller: _extensionId,
              label: s.chromeExtensionId,
              hintText: s.chromeExtensionIdHint,
            ),
            const SizedBox(height: 12),
            MEBanner(
              color: _registered
                  ? scheme.secondaryContainer
                  : scheme.tertiaryContainer,
              icon: Icon(
                _registered
                    ? Icons.check_circle_outline_rounded
                    : Icons.info_outline_rounded,
                color: _registered
                    ? scheme.onSecondaryContainer
                    : scheme.onTertiaryContainer,
              ),
              content: Text(
                _message ??
                    (_registered
                        ? s.browserExtensionHostReady
                        : s.browserExtensionHostHint),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _registered
                          ? scheme.onSecondaryContainer
                          : scheme.onTertiaryContainer,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            MEButton.filled(
              size: MEButtonSize.large,
              onPressed: _busy ? null : () => _connect(context),
              child: _busy
                  ? MELoadingIndicator(
                      size: 24,
                      color: scheme.onPrimary,
                    )
                  : Text(s.connectBrowserExtension.toUpperCase()),
            ),
            const SizedBox(height: 8),
            MEButton.tonal(
              size: MEButtonSize.large,
              onPressed: _busy ? null : () => _copyOfflineLink(context),
              child: Text(s.copyOfflineExtensionLink),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _connect(BuildContext context) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    final host = sl<NativeMessagingHost>();
    await host.start();
    final ok = await host.registerBrowserNativeHost(
      chromeExtensionId: _extensionId.text,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _registered = ok;
      _message = ok
          ? context.s.browserExtensionHostReady
          : context.s.browserExtensionHostFailed;
    });
    if (ok && context.mounted) {
      showMEToast(
        context,
        message: context.s.browserExtensionHostReady,
        kind: METoastKind.success,
      );
    }
  }

  Future<void> _copyOfflineLink(BuildContext context) async {
    final s = context.s;
    final confirmed = await showMEDialog<bool>(
      context: context,
      builder: (dialogContext) => MEDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Theme.of(dialogContext).colorScheme.error,
        ),
        title: Text(s.copyOfflineExtensionLink),
        content: Text(s.extensionLinkClipboardWarning),
        actions: [
          MEButton.text(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(s.cancel),
          ),
          MEButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(s.copy),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final payload = sl<AuthRepository>().extensionLinkPayload();
    if (payload == null) return;
    final text =
        'email=${payload['email']}\nsalt=${payload['saltB64']}\nwrapped=${payload['wrappedVaultKey']}';
    await Clipboard.setData(ClipboardData(text: text));
    Timer(const Duration(minutes: 1), () {
      Clipboard.setData(const ClipboardData(text: ''));
    });
    if (!context.mounted) return;
    showMEToast(
      context,
      message: context.s.extensionLinkCopied,
      kind: METoastKind.success,
    );
  }
}
