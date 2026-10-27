import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

class ServerSheet extends StatefulWidget {
  const ServerSheet({super.key});

  Future<void> show(BuildContext context) {
    return showMEBottomSheet<void>(
      context: context,
      builder: (_) => this,
    );
  }

  @override
  State<ServerSheet> createState() => _ServerSheetState();
}

class _ServerSheetState extends State<ServerSheet> {
  late final TextEditingController _url;
  bool _syncing = false;
  String? _message;
  bool _hasServerAccount = false;

  @override
  void initState() {
    super.initState();
    _url = TextEditingController(
      text: context.read<SettingsCubit>().state.serverUrl,
    );
    final token = sl<VaultMetadataStore>().accessToken;
    _hasServerAccount = token != null && token.isNotEmpty;
  }

  @override
  void dispose() {
    _url.dispose();
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
              s.server,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              s.serverSheetSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            METextField(
              controller: _url,
              label: s.serverUrl,
              hintText: s.serverUrlHint,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            ActionItem(
              title: s.register,
              subtitle: Text(s.registerSubtitle),
              icon: SettingsIcon(
                Icons.person_add_alt_1_rounded,
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
              ),
              itemPosition: ItemPosition.top,
              onTap: () async {
                await context.read<SettingsCubit>().setServerUrl(_url.text);
                if (!context.mounted) return;
                context.read<AuthBloc>().add(
                      AuthRegisterServerRequested(
                        serverUrl: _url.text.trim(),
                      ),
                    );
                Navigator.of(context).pop();
              },
            ),
            ActionItem(
              title: s.login,
              subtitle: Text(s.loginSubtitle),
              icon: SettingsIcon(
                Icons.login_rounded,
                backgroundColor: scheme.secondaryContainer,
                foregroundColor: scheme.onSecondaryContainer,
              ),
              itemPosition: ItemPosition.center,
              onTap: () async {
                await context.read<SettingsCubit>().setServerUrl(_url.text);
                if (!context.mounted) return;
                context.read<AuthBloc>().add(
                      AuthLoginServerRequested(serverUrl: _url.text.trim()),
                    );
                Navigator.of(context).pop();
              },
            ),
            ActionItem(
              title: _syncing ? s.syncing : s.syncNow,
              subtitle: Text(_message ?? s.syncSubtitle),
              maxSubtitleLines: 2,
              icon: SettingsIcon(
                Icons.sync_rounded,
                backgroundColor: scheme.tertiaryContainer,
                foregroundColor: scheme.onTertiaryContainer,
              ),
              itemPosition:
                  _hasServerAccount ? ItemPosition.center : ItemPosition.bottom,
              onTap: _syncing
                  ? null
                  : () async {
                      setState(() {
                        _syncing = true;
                        _message = null;
                      });
                      await context
                          .read<SettingsCubit>()
                          .setServerUrl(_url.text);
                      final result = await sl<SyncService>().syncNow();
                      if (!mounted) return;
                      setState(() {
                        _syncing = false;
                        _message = result.fold(
                          (f) => f.getMessage(context),
                          (_) => context.s.syncComplete,
                        );
                      });
                    },
            ),
            if (_hasServerAccount)
              ActionItem(
                title: s.deleteServerAccount,
                subtitle: Text(s.deleteServerAccountSubtitle),
                maxSubtitleLines: 2,
                icon: SettingsIcon(
                  Icons.delete_forever_rounded,
                  backgroundColor: scheme.errorContainer,
                  foregroundColor: scheme.onErrorContainer,
                ),
                itemPosition: ItemPosition.bottom,
                onTap: () => const DeleteServerAccountSheet().show(context),
              ),
          ],
        ),
      ),
    );
  }
}
