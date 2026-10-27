import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/core/router/go_router_refresh_stream.dart';
import 'package:openkey_app/src/src.dart';

part 'app_routes.dart';

class AppRouter {
  static final _rootKey = GlobalKey<NavigatorState>();
  static GoRouter? _router;
  static GoRouterRefreshStream? _authRefresh;

  /// Root navigator — safe for dialogs shown from `MaterialApp.router` builder.
  static GlobalKey<NavigatorState> get rootNavigatorKey => _rootKey;

  static GoRouter get routes {
    return _router ??= _createRouter();
  }

  static GoRouter _createRouter() {
    _authRefresh = GoRouterRefreshStream(sl<AuthBloc>().stream);
    return GoRouter(
      initialLocation: AppRoutes.onboarding.path,
      navigatorKey: _rootKey,
      refreshListenable: _authRefresh,
      redirect: _redirect,
      routes: [
        GoRoute(
          path: AppRoutes.onboarding.path,
          builder: (context, state) => const OnboardingPage(),
        ),
        GoRoute(
          path: AppRoutes.setup.path,
          builder: (context, state) => const SetupPage(),
          routes: [
            GoRoute(
              path: 'create',
              builder: (context, state) => const SetupCreatePage(),
            ),
            GoRoute(
              path: 'signin',
              builder: (context, state) => const SetupSignInPage(),
            ),
            GoRoute(
              path: 'restore',
              builder: (context, state) => const SetupRestorePage(),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.unlock.path,
          builder: (context, state) => const UnlockPage(),
        ),
        GoRoute(
          path: AppRoutes.autofillSave.path,
          builder: (context, state) {
            final extra = state.extra;
            final request = extra is AutofillSaveRequest
                ? extra
                : const AutofillSaveRequest(
                    username: '',
                    password: '',
                    uri: '',
                    packageName: '',
                  );
            return AutofillSavePage(request: request);
          },
        ),
        ShellRoute(
          builder: (context, state, child) => VaultShellPage(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.vault.path,
              builder: (context, state) => const VaultHomePage(),
              routes: [
                GoRoute(
                  path: 'collection/:uuid',
                  builder: (context, state) =>
                      CollectionDetailPage(uuid: state.pathParameters['uuid']!),
                ),
                GoRoute(
                  path: 'entry/new',
                  builder: (context, state) => EntryEditorPage(
                    collectionUuid: state.uri.queryParameters['collection'],
                  ),
                ),
                GoRoute(
                  path: 'entry/:uuid',
                  builder: (context, state) {
                    final uuid = state.pathParameters['uuid']!;
                    return PasswordDetailsPage(uuid: uuid);
                  },
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (context, state) {
                        final uuid = state.pathParameters['uuid']!;
                        return EntryEditorPage(uuid: uuid);
                      },
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: AppRoutes.settings.path,
              builder: (context, state) => const SettingsPage(),
              routes: [
                GoRoute(
                  path: 'account',
                  builder: (context, state) => const AccountPage(),
                ),
                GoRoute(
                  path: 'appearance',
                  builder: (context, state) => const AppearancePage(),
                ),
                GoRoute(
                  path: 'theme-mode',
                  builder: (context, state) => const ThemeModePage(),
                ),
                GoRoute(
                  path: 'fonts',
                  builder: (context, state) => const FontsPage(),
                ),
                GoRoute(
                  path: 'language',
                  builder: (context, state) => const LanguagesPage(),
                ),
                GoRoute(
                  path: 'password-generator',
                  builder: (context, state) => const PasswordGeneratorPage(),
                ),
                GoRoute(
                  path: 'security',
                  builder: (context, state) => const SecurityPage(),
                ),
                GoRoute(
                  path: 'data',
                  builder: (context, state) => const DataSharingPage(),
                ),
                GoRoute(
                  path: 'faq',
                  builder: (context, state) => const FaqPage(),
                ),
                GoRoute(
                  path: 'about-app',
                  builder: (context, state) => const AboutAppPage(),
                ),
              ],
            ),
            GoRoute(
              path: AppRoutes.items.path,
              builder: (context, state) => const ItemsHubPage(),
            ),
            GoRoute(
              path: AppRoutes.wallets.path,
              builder: (context, state) => const WalletsPage(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const WalletEditorPage(),
                ),
                GoRoute(
                  path: ':uuid',
                  builder: (context, state) =>
                      WalletDetailsPage(uuid: state.pathParameters['uuid']!),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (context, state) =>
                          WalletEditorPage(uuid: state.pathParameters['uuid']),
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: AppRoutes.crypto.path,
              builder: (context, state) => const CryptoPage(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const CryptoWalletEditorPage(),
                ),
                GoRoute(
                  path: ':uuid',
                  builder: (context, state) => CryptoWalletDetailsPage(
                    uuid: state.pathParameters['uuid']!,
                  ),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (context, state) => CryptoWalletEditorPage(
                        uuid: state.pathParameters['uuid'],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: AppRoutes.secrets.path,
              builder: (context, state) => const SecretsPage(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const SecretEditorPage(),
                ),
                GoRoute(
                  path: ':uuid',
                  builder: (context, state) =>
                      SecretDetailsPage(uuid: state.pathParameters['uuid']!),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (context, state) =>
                          SecretEditorPage(uuid: state.pathParameters['uuid']),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static String? _redirect(BuildContext context, GoRouterState state) {
    final auth = sl<AuthBloc>().state;
    final loc = state.matchedLocation;
    final onAuth =
        _isSetupLocation(loc) ||
        loc == AppRoutes.unlock.path ||
        loc == AppRoutes.onboarding.path;
    final onAutofillSave = loc == AppRoutes.autofillSave.path;
    final onboardingDone = sl<VaultMetadataStore>().onboardingCompleted;

    if (!auth.hasVault) {
      if (onboardingDone && loc == AppRoutes.onboarding.path) {
        return AppRoutes.onboarding.path;
      }
      if (onboardingDone && !_isSetupLocation(loc)) {
        return AppRoutes.setup.path;
      }
      return null;
    }
    if (auth.addingAccount) {
      if (!_isSetupLocation(loc)) {
        okDebugLog(
          '[add-account] redirect $loc → /setup?addAccount=1 '
          'status=${auth.status}',
        );
        return '${AppRoutes.setup.path}?addAccount=1';
      }
      okDebugLog('[add-account] redirect stay on setup status=${auth.status}');
      return null;
    }
    // Stay on the current screen during AuthStatus.loading (e.g. backup
    // restore) so we don't bounce to Unlock and kill in-flight vault watches.
    if (auth.hasVault &&
        !auth.isUnlocked &&
        auth.status != AuthStatus.loading &&
        loc != AppRoutes.unlock.path) {
      return AppRoutes.unlock.path;
    }
    if (auth.isUnlocked && onAuth) {
      // After unlock from autofill auth, stay out of vault if a save is pending;
      // AutofillLifecycle will navigate to save.
      return AppRoutes.vault.path;
    }
    if (auth.isUnlocked && onAutofillSave) {
      return null;
    }
    return null;
  }

  static bool _isSetupLocation(String loc) {
    return loc == AppRoutes.setup.path ||
        loc.startsWith('${AppRoutes.setup.path}/');
  }
}
