import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/src/src.dart';

/// Adaptive app shell (Invito-style):
/// - Mobile: bottom navigation (hidden on nested routes)
/// - Tablet: navigation rail + content panel
/// - Desktop: navigation rail + optional master/detail split
///
/// Primary tabs: Vault · Items · Settings. Cards / crypto / secrets
/// live under Items and are reached via push (bottom bar hidden).
class VaultShellPage extends StatefulWidget {
  const VaultShellPage({super.key, required this.child});

  final Widget child;

  @override
  State<VaultShellPage> createState() => _VaultShellPageState();
}

class _VaultShellPageState extends State<VaultShellPage> {
  bool _railExtended = false;

  static const _tabRoots = {
    '/vault',
    '/items',
    '/settings',
  };

  String get _path => GoRouterState.of(context).uri.path;

  bool get _isRootTab => _tabRoots.contains(_path);

  bool get _isVaultDetail =>
      _path.startsWith('/vault/') && _path != '/vault';

  bool get _isSettingsSub =>
      _path.startsWith('/settings/') && _path != '/settings';

  bool get _isWalletsDetail =>
      _path.startsWith('/wallets/') && _path != '/wallets';

  bool get _isCryptoDetail =>
      _path.startsWith('/crypto/') && _path != '/crypto';

  bool get _isSecretsDetail =>
      _path.startsWith('/secrets/') && _path != '/secrets';

  int _indexForLocation(String location) {
    if (location.startsWith(AppRoutes.settings.path)) return 2;
    if (location == AppRoutes.items.path ||
        location.startsWith(AppRoutes.wallets.path) ||
        location.startsWith(AppRoutes.crypto.path) ||
        location.startsWith(AppRoutes.secrets.path)) {
      return 1;
    }
    return 0;
  }

  List<MENavigationDestination> _destinations(BuildContext context, AppLocalizations s) {
    final auth = context.watch<AuthBloc>().state;
    final email = auth.email;

    return [
      MENavigationDestination(
        icon: const Icon(Icons.lock_outline),
        selectedIcon: const Icon(Icons.lock),
        label: s.vault,
      ),
      MENavigationDestination(
        icon: const Icon(Icons.grid_view_outlined),
        selectedIcon: const Icon(Icons.grid_view_rounded),
        label: s.items,
      ),
      
      MENavigationDestination(
        onLongPress: () => const AccountSwitcherSheet().show(context),
        icon: AccountAvatar(
                          key: ValueKey(auth.avatarGeneration),
                          account: VaultAccount(
                            id: auth.activeAccountId ?? '',
                            email: email ?? '',
                            avatarPath: auth.avatarPath,
                          ),
                          size: 28,
                        ),
        selectedIcon: AccountAvatar(
                          key: ValueKey(auth.avatarGeneration),
                          account: VaultAccount(
                            id: auth.activeAccountId ?? '',
                            email: email ?? '',
                            avatarPath: auth.avatarPath,
                          ),
                          size: 28,
                        ),    
        label: s.settings, 
      )
    ];
  }

  void _onDestinationSelected(int i) {
    switch (i) {
      case 0:
        context.go(AppRoutes.vault.path);
      case 1:
        context.go(AppRoutes.items.path);
      default:
        context.go(AppRoutes.settings.path);
    }
  }

  Widget? _masterForDesktop() {
    if (_isVaultDetail) return const VaultHomePage();
    if (_isSettingsSub) return const SettingsPage();
    if (_isWalletsDetail) return const WalletsPage();
    if (_isCryptoDetail) return const CryptoPage();
    if (_isSecretsDetail) return const SecretsPage();
    // List pages under Items show the hub as the master pane.
    if (_path == AppRoutes.wallets.path ||
        _path == AppRoutes.crypto.path ||
        _path == AppRoutes.secrets.path) {
      return const ItemsHubPage();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (Breakpoints.isMobile(width)) {
          return _buildMobile(context);
        }
        if (Breakpoints.isTablet(width)) {
          return _buildRailLayout(context, showMasterDetail: false);
        }
        return _buildRailLayout(context, showMasterDetail: true);
      },
    );
  }

  Widget _buildMobile(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = context.s;
    final index = _indexForLocation(_path);
    final navColor = scheme.surfaceContainerHigh;

    return BlocBuilder<VaultSelectionCubit, VaultSelectionState>(
      builder: (context, selection) {
        final onVault = _path == AppRoutes.vault.path ||
            _path.startsWith('${AppRoutes.vault.path}/');
        final showSelectionBar =
            onVault && _isRootTab && (selection.isSelecting || selection.isMoving);

        Widget? bottomBar;
        if (showSelectionBar) {
          bottomBar = selection.isMoving
              ? MovingActionBar(
                  itemCount: selection.selectedCount,
                  onCancel: () =>
                      context.read<VaultSelectionCubit>().cancelMoving(),
                  onMoveHere: () => context
                      .read<VaultSelectionCubit>()
                      .moveSelectedHere(context),
                )
              : SelectingActionBar(
                  selectedCount: selection.selectedCount,
                  onDelete: () => context
                      .read<VaultSelectionCubit>()
                      .deleteSelected(context),
                  onEdit: () =>
                      context.read<VaultSelectionCubit>().editSelected(context),
                  onMove: () =>
                      context.read<VaultSelectionCubit>().startMoving(),
                );  
        } else if (_isRootTab) {
          bottomBar = MENavigationBar(
            selectedIndex: index,
            onDestinationSelected: _onDestinationSelected,
            backgroundColor: navColor,
            destinations: _destinations(context, s),
          );
        }

        return AppSystemUiScope(
          navigationBarColor: bottomBar != null ? navColor : scheme.surface,
          child: Scaffold(
            backgroundColor: scheme.surface,
            body: widget.child,
            bottomNavigationBar: AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: bottomBar ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRailLayout(
    BuildContext context, {
    required bool showMasterDetail,
  }) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    final index = _indexForLocation(_path);
    final master = showMasterDetail ? _masterForDesktop() : null;

    return Scaffold(
      backgroundColor: scheme.surfaceContainer,
      body: Row(
        children: [
          AppNavigationRail(
            expanded: _railExtended,
            selectedIndex: index,
            onDestinationSelected: _onDestinationSelected,
            onToggleExpanded: () =>
                setState(() => _railExtended = !_railExtended),
            destinations: _destinations(context, s),
          ),
          if (master != null) ...[
            Expanded(
              child: AppContentPanel(
                borderRadius: const BorderRadiusDirectional.only(
                  topStart: Radius.circular(20),
                  bottomStart: Radius.circular(20),
                ),
                child: master,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: VerticalDivider(
                width: 1,
                color: scheme.outlineVariant,
              ),
            ),
            Expanded(
              child: AppContentPanel(
                borderRadius: const BorderRadiusDirectional.only(
                  topEnd: Radius.circular(20),
                  bottomEnd: Radius.circular(20),
                ),
                child: widget.child,
              ),
            ),
          ] else
            Expanded(
              child: AppContentPanel(
                borderRadius: BorderRadius.circular(20),
                child: widget.child,
              ),
            ),
        ],
      ),
    );
  }
}
