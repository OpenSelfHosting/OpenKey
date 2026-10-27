import 'dart:io' show File, Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

class TermuxCliSheet extends StatelessWidget {
  const TermuxCliSheet({super.key});

  static bool get isSupported =>
      !kIsWeb &&
      (Platform.isAndroid ||
          Platform.isLinux ||
          Platform.isMacOS ||
          Platform.isWindows);

  static String titleFor(AppLocalizations s) =>
      Platform.isAndroid ? s.cliTermuxTitle : s.cliTitle;

  static String subtitleFor(AppLocalizations s) =>
      Platform.isAndroid ? s.cliTermuxSubtitle : s.cliSubtitle;

  Future<void> show(BuildContext context) {
    return showMEBottomSheet<void>(
      context: context,
      builder: (_) => this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = context.s;
    final guide = _cliGuideFor(sl<NativeMessagingHost>());
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              titleFor(s),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              subtitleFor(s),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            _CliCommandBlock(
              label: s.cliTermuxInstall,
              command: guide.install,
            ),
            const SizedBox(height: 12),
            if (guide.connect == null)
              MEBanner(
                color: scheme.tertiaryContainer,
                icon: Icon(
                  Icons.info_outline_rounded,
                  color: scheme.onTertiaryContainer,
                ),
                content: Text(
                  s.cliTermuxUnavailable,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onTertiaryContainer,
                      ),
                ),
              )
            else
              _CliCommandBlock(
                label: s.cliTermuxConnect,
                command: guide.connect!,
              ),
          ],
        ),
      ),
    );
  }
}

class _CliGuide {
  const _CliGuide({required this.install, this.connect});

  final String install;
  final String? connect;
}

_CliGuide _cliGuideFor(NativeMessagingHost host) {
  if (Platform.isAndroid) {
    final port = host.loopbackPort;
    final token = host.cliBridgeAuthToken;
    return _CliGuide(
      install: 'pkg install nodejs\nnpm install -g openkey-cli',
      connect: (port == null || token == null)
          ? null
          : 'export OPENKEY_NATIVE_PORT=$port\n'
              'export OPENKEY_NATIVE_TOKEN=$token\n'
              'openkey status',
    );
  }
  if (Platform.isWindows) {
    return const _CliGuide(
      install: 'winget install OpenJS.NodeJS.LTS\nnpm install -g openkey-cli',
      connect: 'openkey status',
    );
  }
  if (Platform.isMacOS) {
    return const _CliGuide(
      install: 'brew install node\nnpm install -g openkey-cli',
      connect: 'openkey status',
    );
  }
  return _CliGuide(
    install: _linuxInstallCommand(),
    connect: 'openkey status',
  );
}

String _linuxInstallCommand() {
  final ids = _linuxOsIds();
  bool has(String id) => ids.contains(id);

  if (has('debian') ||
      has('ubuntu') ||
      has('linuxmint') ||
      has('pop') ||
      has('raspbian') ||
      has('elementary')) {
    return 'sudo apt update\n'
        'sudo apt install -y nodejs npm\n'
        'npm install -g openkey-cli';
  }
  if (has('fedora') ||
      has('rhel') ||
      has('centos') ||
      has('rocky') ||
      has('almalinux') ||
      has('nobara')) {
    return 'sudo dnf install -y nodejs\nnpm install -g openkey-cli';
  }
  if (has('arch') ||
      has('manjaro') ||
      has('endeavouros') ||
      has('cachyos')) {
    return 'sudo pacman -S --needed nodejs npm\nnpm install -g openkey-cli';
  }
  if (has('opensuse-tumbleweed') ||
      has('opensuse-leap') ||
      has('opensuse') ||
      has('sles')) {
    return 'sudo zypper install -y nodejs npm\nnpm install -g openkey-cli';
  }
  if (has('alpine')) {
    return 'sudo apk add nodejs npm\nnpm install -g openkey-cli';
  }
  return 'npm install -g openkey-cli';
}

Set<String> _linuxOsIds() {
  try {
    final text = File('/etc/os-release').readAsStringSync();
    String? value(String key) {
      final match = RegExp(
        '^$key=(.*)\$',
        multiLine: true,
      ).firstMatch(text);
      return match?.group(1)?.replaceAll('"', '').trim().toLowerCase();
    }

    final ids = <String>{};
    final id = value('ID');
    if (id != null && id.isNotEmpty) ids.add(id);
    final like = value('ID_LIKE');
    if (like != null && like.isNotEmpty) {
      ids.addAll(like.split(RegExp(r'\s+')));
    }
    return ids;
  } catch (_) {
    return {};
  }
}

class _CliCommandBlock extends StatelessWidget {
  const _CliCommandBlock({
    required this.label,
    required this.command,
  });

  final String label;
  final String command;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: textTheme.labelLarge),
        const SizedBox(height: 6),
        MECard(
          color: scheme.surfaceContainerHighest,
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SelectableText(
                  command,
                  style: textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              MEIconButton(
                tooltip: s.copy,
                variant: MEButtonVariant.tonal,
                size: MEButtonSize.small,
                onPressed: () => _copy(context, command, s.copied),
                icon: const Icon(Icons.copy_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _copy(
    BuildContext context,
    String text,
    String copiedMsg,
  ) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    showMEToast(
      context,
      message: copiedMsg,
      kind: METoastKind.success,
    );
  }
}
