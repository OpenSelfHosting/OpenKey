part of 'app_router.dart';

enum AppRoutes {
  onboarding('/onboarding'),
  setup('/setup'),
  setupCreate('/setup/create'),
  setupSignIn('/setup/signin'),
  setupRestore('/setup/restore'),
  unlock('/unlock'),
  vault('/vault'),
  items('/items'),
  settings('/settings'),
  account('/settings/account'),
  appearance('/settings/appearance'),
  themeMode('/settings/theme-mode'),
  fonts('/settings/fonts'),
  language('/settings/language'),
  passwordGenerator('/settings/password-generator'),
  security('/settings/security'),
  dataSharing('/settings/data'),
  faq('/settings/faq'),
  aboutApp('/settings/about-app'),
  autofillSave('/autofill/save'),
  wallets('/wallets'),
  walletNew('/wallets/new'),
  walletDetail('/wallets/:uuid'),
  walletEdit('/wallets/:uuid/edit'),
  crypto('/crypto'),
  cryptoWalletNew('/crypto/new'),
  cryptoWalletDetail('/crypto/:uuid'),
  cryptoWalletEdit('/crypto/:uuid/edit'),
  secrets('/secrets'),
  secretNew('/secrets/new'),
  secretDetail('/secrets/:uuid'),
  secretEdit('/secrets/:uuid/edit'),
  collectionDetail('/vault/collection/:uuid'),
  entryNew('/vault/entry/new'),
  entryDetail('/vault/entry/:uuid'),
  entryEdit('/vault/entry/:uuid/edit');

  const AppRoutes(this.path);
  final String path;
}
