import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage>
    with WidgetsBindingObserver {
  bool _bioEnabled = false;
  bool _bioSupported = false;
  bool _autofillEnabled = false;
  bool _showAutofill = false;
  bool _biometricToggleBusy = false;
  bool _autofillToggleBusy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadBiometrics();
    _loadAutofill();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadAutofill();
      _loadBiometrics();
    }
  }

  Future<void> _loadBiometrics() async {
    final bio = sl<BiometricUnlockService>();
    final supported = await bio.isSupported;
    final enabled = await bio.isEnabled;
    if (!mounted) return;
    setState(() {
      _bioSupported = supported;
      _bioEnabled = enabled;
    });
  }

  Future<void> _loadAutofill() async {
    final bridge = sl<AutofillBridge>();
    if (!bridge.isSupported) {
      if (mounted) setState(() => _showAutofill = false);
      return;
    }
    final enabled = await bridge.isAutofillEnabled();
    if (!mounted) return;
    setState(() {
      _showAutofill = true;
      _autofillEnabled = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final blockScreenshotSupported =
        sl<ScreenshotProtectionService>().isSupported;
    final showAutofillBiometric = _showAutofill &&
        _bioSupported &&
        !sl<AutofillBridge>().isBrowserAutofill;
    final showAutofillPresentation =
        _showAutofill && _autofillEnabled && sl<AutofillBridge>().isAndroid;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        final s = context.s;

        return MESliverScaffold(
          title: s.security,
          leadingAppBar: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          spacer: 4,
          slivers: [
            // Unlock
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionLabel(title: s.unlock),
                    ..._withPositions([
                      (pos) => ActionItem(
                            title: s.autoLock,
                            subtitle: Text(
                              s.lockMinutesLabel(settings.lockMinutes),
                              style: textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            icon: SettingsIcon(
                              Icons.timer_outlined,
                              backgroundColor: scheme.secondaryContainer,
                              foregroundColor: scheme.onSecondaryContainer,
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            itemPosition: pos,
                            onTap: () => const AutoLockSheet().show(context),
                          ),
                      if (_bioSupported)
                        (pos) => ActionItem(
                              title: s.biometricUnlock,
                              icon: SettingsIcon(
                                Icons.fingerprint_rounded,
                                backgroundColor: scheme.tertiaryContainer,
                                foregroundColor: scheme.onTertiaryContainer,
                              ),
                              trailing: Switch(
                                value: _bioEnabled,
                                onChanged: _biometricToggleBusy
                                    ? null
                                    : _toggleBiometrics,
                              ),
                              itemPosition: pos,
                            ),
                      (pos) => ActionItem(
                            title: s.changeMasterPassword,
                            subtitle: Text(
                              s.changeMasterPasswordSubtitle,
                              style: textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            maxSubtitleLines: 2,
                            icon: SettingsIcon(
                              Icons.password_rounded,
                              backgroundColor: scheme.primaryContainer,
                              foregroundColor: scheme.onPrimaryContainer,
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            itemPosition: pos,
                            onTap: () => const ChangeMasterPasswordSheet()
                                .show(context),
                          ),
                    ]),
                  ],
                ),
              ),
            ),

            // Autofill
            if (_showAutofill)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SectionLabel(title: s.autofillService),
                      ..._withPositions([
                        (pos) => ActionItem(
                              title: s.autofillService,
                              subtitle: Text(
                                _autofillEnabled
                                    ? s.autofillEnabled
                                    : (sl<AutofillBridge>().isBrowserAutofill
                                        ? s.autofillDisabledBrowser
                                        : s.autofillDisabled),
                                style: textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              maxSubtitleLines: 3,
                              icon: SettingsIcon(
                                Icons.keyboard_alt_outlined,
                                backgroundColor: _autofillEnabled
                                    ? scheme.primaryContainer
                                    : scheme.secondaryContainer,
                                foregroundColor: _autofillEnabled
                                    ? scheme.onPrimaryContainer
                                    : scheme.onSecondaryContainer,
                              ),
                              trailing: Switch(
                                value: _autofillEnabled,
                                onChanged: _autofillToggleBusy
                                    ? null
                                    : _toggleAutofill,
                              ),
                              itemPosition: pos,
                              onTap: _autofillToggleBusy
                                  ? null
                                  : () => _toggleAutofill(!_autofillEnabled),
                            ),
                        if (showAutofillPresentation)
                          (pos) => ActionItem(
                                title: s.autofillInline,
                                subtitle: Text(
                                  s.autofillInlineSubtitle,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                                maxSubtitleLines: 3,
                                icon: SettingsIcon(
                                  Icons.keyboard_alt_outlined,
                                  backgroundColor: settings.autofillInline
                                      ? scheme.primaryContainer
                                      : scheme.secondaryContainer,
                                  foregroundColor: settings.autofillInline
                                      ? scheme.onPrimaryContainer
                                      : scheme.onSecondaryContainer,
                                ),
                                trailing: Switch(
                                  value: settings.autofillInline,
                                  onChanged: (value) =>
                                      _toggleAutofillPresentation(inline: value),
                                ),
                                itemPosition: pos,
                              ),
                        if (showAutofillPresentation)
                          (pos) => ActionItem(
                                title: s.autofillPopup,
                                subtitle: Text(
                                  s.autofillPopupSubtitle,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                                maxSubtitleLines: 3,
                                icon: SettingsIcon(
                                  Icons.picture_in_picture_alt_outlined,
                                  backgroundColor: settings.autofillPopup
                                      ? scheme.primaryContainer
                                      : scheme.secondaryContainer,
                                  foregroundColor: settings.autofillPopup
                                      ? scheme.onPrimaryContainer
                                      : scheme.onSecondaryContainer,
                                ),
                                trailing: Switch(
                                  value: settings.autofillPopup,
                                  onChanged: (value) =>
                                      _toggleAutofillPresentation(popup: value),
                                ),
                                itemPosition: pos,
                              ),
                        if (showAutofillBiometric)
                          (pos) => ActionItem(
                                title: s.autofillRequireBiometric,
                                subtitle: Text(
                                  s.autofillRequireBiometricSubtitle,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                                maxSubtitleLines: 3,
                                icon: SettingsIcon(
                                  Icons.fingerprint_rounded,
                                  backgroundColor:
                                      settings.autofillRequireBiometric
                                          ? scheme.primaryContainer
                                          : scheme.tertiaryContainer,
                                  foregroundColor:
                                      settings.autofillRequireBiometric
                                          ? scheme.onPrimaryContainer
                                          : scheme.onTertiaryContainer,
                                ),
                                trailing: Switch(
                                  value: settings.autofillRequireBiometric,
                                  onChanged: _biometricToggleBusy
                                      ? null
                                      : _toggleAutofillBiometric,
                                ),
                                itemPosition: pos,
                              ),
                      ]),
                    ],
                  ),
                ),
              ),

            // Device protection
            if (blockScreenshotSupported)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SectionLabel(title: s.device),
                      ActionItem(
                        title: s.blockScreenshot,
                        subtitle: Text(
                          sl<ScreenshotProtectionService>().isBestEffortOnly
                              ? s.blockScreenshotLinuxNote
                              : s.blockScreenshotSubtitle,
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        maxSubtitleLines: 3,
                        icon: SettingsIcon(
                          Icons.screenshot_monitor_outlined,
                          backgroundColor: settings.blockScreenshot
                              ? scheme.errorContainer
                              : scheme.tertiaryContainer,
                          foregroundColor: settings.blockScreenshot
                              ? scheme.onErrorContainer
                              : scheme.onTertiaryContainer,
                        ),
                        trailing: Switch(
                          value: settings.blockScreenshot,
                          onChanged: context
                              .read<SettingsCubit>()
                              .setBlockScreenshot,
                        ),
                        itemPosition: ItemPosition.alone,
                        onTap: () => context
                            .read<SettingsCubit>()
                            .setBlockScreenshot(!settings.blockScreenshot),
                      ),
                    ],
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        );
      },
    );
  }

  List<Widget> _withPositions(
    List<Widget Function(ItemPosition)> builders,
  ) {
    return [
      for (var i = 0; i < builders.length; i++)
        builders[i](ItemPosition.fromIndex(i, builders.length)),
    ];
  }

  Future<void> _toggleAutofill(bool enable) async {
    if (_autofillToggleBusy) return;
    _autofillToggleBusy = true;
    setState(() {});
    try {
      await sl<AutofillBridge>().setAutofillEnabled(enable);
      await _loadAutofill();
    } finally {
      if (mounted) {
        _autofillToggleBusy = false;
        setState(() {});
      }
    }
  }

  Future<void> _toggleBiometrics(bool enable) async {
    if (_biometricToggleBusy) return;
    setState(() => _biometricToggleBusy = true);
    final bio = sl<BiometricUnlockService>();
    try {
      if (enable) {
        final session = sl<VaultSession>();
        if (!session.isUnlocked) return;
        final enabled = await bio.enable(
          session.vaultKey,
          authHash: session.authHash,
          s: context.s,
        );
        if (!enabled) return;
      } else {
        await bio.disable();
      }
      if (!mounted) return;
      setState(() => _bioEnabled = enable);
      showMEToast(
        context,
        message: enable
            ? context.s.biometricUnlockEnabled
            : context.s.biometricUnlockDisabled,
        kind: METoastKind.success,
      );
    } catch (e) {
      if (!mounted) return;
      showMEToast(
        context,
        message: context.s.biometricsUpdateFailed('$e'),
        kind: METoastKind.error,
      );
    } finally {
      if (mounted) setState(() => _biometricToggleBusy = false);
    }
  }

  Future<void> _toggleAutofillPresentation({bool? inline, bool? popup}) async {
    final cubit = context.read<SettingsCubit>();
    await cubit.setAutofillPresentation(inline: inline, popup: popup);
    await sl<AutofillBridge>().syncPresentation();
  }

  Future<void> _toggleAutofillBiometric(bool enable) async {
    if (_biometricToggleBusy) return;
    setState(() => _biometricToggleBusy = true);
    final bio = sl<BiometricUnlockService>();
    final s = context.s;
    final cubit = context.read<SettingsCubit>();
    try {
      if (enable) {
        final ok = await bio.authenticate(
          reason: s.autofillRequireBiometricReason,
          s: s,
        );
        if (!ok) return;
      }
      await cubit.setAutofillRequireBiometric(enable);
      await sl<AutofillBridge>().setRequireBiometric(enable);
      if (!mounted) return;
      showMEToast(
        context,
        message: enable
            ? s.autofillRequireBiometricEnabled
            : s.autofillRequireBiometricDisabled,
        kind: METoastKind.success,
      );
    } catch (e) {
      if (!mounted) return;
      showMEToast(
        context,
        message: s.biometricsUpdateFailed('$e'),
        kind: METoastKind.error,
      );
    } finally {
      if (mounted) setState(() => _biometricToggleBusy = false);
    }
  }
}
