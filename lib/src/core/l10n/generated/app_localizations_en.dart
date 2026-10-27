// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get appearanceSubtitle => 'Theme, colors, fonts, and language';

  @override
  String get themeMode => 'Theme mode';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get fonts => 'Fonts';

  @override
  String get displayFont => 'Display font';

  @override
  String get defaultFont => 'Default';

  @override
  String get arabicFont => 'Arabic';

  @override
  String get developerFont => 'Developer';

  @override
  String get technicalFont => 'Technical';

  @override
  String get standardFont => 'Standard';

  @override
  String get defaultFontDes => 'The default font for the application.';

  @override
  String get arabicFontDes => 'A font optimized for Arabic script.';

  @override
  String get developerFontDes => 'A font designed for developers.';

  @override
  String get technicalFontDes => 'A font suitable for technical content.';

  @override
  String get standardFontDes => 'A standard font for general use.';

  @override
  String get googleSansFlexFont => 'Google Sans Flex';

  @override
  String get googleSansFlexFontDes =>
      'Google’s expressive brand typeface for Material 3 Expressive.';

  @override
  String get robotoFlexFont => 'Roboto Flex';

  @override
  String get robotoFlexFontDes =>
      'Material Design’s variable font with weight, width, and optical size.';

  @override
  String get figtreeFont => 'Figtree';

  @override
  String get figtreeFontDes =>
      'A soft geometric sans often paired with Material You themes.';

  @override
  String get nunitoFont => 'Nunito';

  @override
  String get nunitoFontDes =>
      'A rounded geometric sans with a friendly, modern tone.';

  @override
  String get dynamicColors => 'Dynamic colors';

  @override
  String get dynamicColorsSubtitle =>
      'Build the theme from a chosen color seed';

  @override
  String get colorScheme => 'Color scheme';

  @override
  String get colorSchemeSubtitle => 'Pick a seed color and palette style';

  @override
  String get highContrast => 'High contrast';

  @override
  String get highContrastSubtitle => 'Increase contrast for better readability';

  @override
  String get security => 'Security';

  @override
  String get securitySubtitle =>
      'Auto-lock, biometrics, autofill, and master password';

  @override
  String get account => 'Account';

  @override
  String get accountPageTitle => 'Account';

  @override
  String get accountPhoto => 'Profile photo';

  @override
  String get changeAccountPhoto => 'Change photo';

  @override
  String get removeAccountPhoto => 'Remove photo';

  @override
  String get changeEmail => 'Change email';

  @override
  String get changeEmailSubtitle =>
      'Re-wraps your vault key. You will unlock with the new email.';

  @override
  String get newEmail => 'New email';

  @override
  String get emailChanged => 'Email updated';

  @override
  String get switchAccount => 'Switch account';

  @override
  String get addAccount => 'Add account';

  @override
  String get addAccountSubtitle =>
      'Create or sign in to another vault on this device';

  @override
  String get removeAccountFromDevice => 'Remove from this device';

  @override
  String get removeAccountFromDeviceSubtitle =>
      'Deletes this local vault. A linked server account is not deleted.';

  @override
  String get removeAccountConfirm =>
      'This vault and its items will be removed from this device. This cannot be undone.';

  @override
  String get otherAccounts => 'Other accounts';

  @override
  String get useThisAccount => 'Use this account';

  @override
  String get currentAccount => 'Current account';

  @override
  String get chooseAccount => 'Choose account';

  @override
  String get switchingAccount => 'Switching account…';

  @override
  String get welcomeBackShort => 'Welcome back';

  @override
  String get tools => 'Tools';

  @override
  String get help => 'Help';

  @override
  String get autoLock => 'Auto-lock';

  @override
  String minutesLabel(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n minutes',
      one: '$n minute',
    );
    return '$_temp0';
  }

  @override
  String get autoLockOff => 'Off';

  @override
  String get blockScreenshot => 'Block screenshots';

  @override
  String get blockScreenshotSubtitle =>
      'Prevent screenshots and screen recording of the app.';

  @override
  String get blockScreenshotLinuxNote =>
      'Best-effort on Linux — the compositor may still allow captures.';

  @override
  String get biometricUnlock => 'Biometric unlock';

  @override
  String get autofillService => 'Autofill service';

  @override
  String get autofillEnabled => 'OpenKey is your password & passkey provider';

  @override
  String get autofillDisabled =>
      'Enable OpenKey for passwords (AutoFill) and passkeys (Credential Provider)';

  @override
  String get autofillDisabledBrowser =>
      'Install the OpenKey browser extension and unlock the vault';

  @override
  String get autofillSaveTitle => 'Save password';

  @override
  String get autofillSaveSubtitle => 'Save this login to your OpenKey vault?';

  @override
  String get autofillSaved => 'Password saved';

  @override
  String get autofillRequireBiometric => 'Require biometric for Autofill';

  @override
  String get autofillRequireBiometricSubtitle =>
      'Ask for fingerprint or face before filling passwords into apps and websites.';

  @override
  String get autofillRequireBiometricReason => 'Confirm Autofill with OpenKey';

  @override
  String get autofillRequireBiometricEnabled =>
      'Autofill biometric confirmation enabled';

  @override
  String get autofillRequireBiometricDisabled =>
      'Autofill biometric confirmation disabled';

  @override
  String get autofillInline => 'Inline in keyboard';

  @override
  String get autofillInlineSubtitle =>
      'Show suggestions in the keyboard strip. Turns off the popup over the field.';

  @override
  String get autofillPopup => 'Popup above the field';

  @override
  String get autofillPopupSubtitle =>
      'Show a dropdown over the input field. Turns off keyboard suggestions.';

  @override
  String get androidApp => 'Android app';

  @override
  String get androidAppHint => 'Package name, e.g. com.example.app';

  @override
  String get biometricUnlockReason => 'Unlock your OpenKey vault';

  @override
  String get enableBiometricUnlockReason => 'Enable biometric unlock';

  @override
  String get biometricHint => 'Verify your identity';

  @override
  String get biometricNotRecognized => 'Not recognized. Try again.';

  @override
  String get goToSettings => 'Go to settings';

  @override
  String get biometricGoToSettingsDescription =>
      'Biometric authentication is not set up on your device. Go to Settings to enroll a fingerprint or face.';

  @override
  String get unlock => 'Unlock';

  @override
  String get unlocking => 'Unlocking…';

  @override
  String get masterPassword => 'Master password';

  @override
  String get unlockSubtitle => 'Enter your master password to unlock.';

  @override
  String welcomeBack(String email) {
    return 'Welcome back, $email';
  }

  @override
  String get fieldRequired => 'Required';

  @override
  String get resetLocalVault => 'Reset local vault';

  @override
  String get resetLocalVaultTitle => 'Reset local vault?';

  @override
  String get resetLocalVaultSubtitle =>
      'Permanently deletes all vault data stored on this device.';

  @override
  String get resetLocalVaultConfirm =>
      'All passwords and vault data on this device will be permanently deleted so you can create a new vault. Server data is not deleted. This cannot be undone.';

  @override
  String get dangerZone => 'Danger zone';

  @override
  String get reset => 'Reset';

  @override
  String get createVault => 'Create vault';

  @override
  String get creatingVault => 'Creating…';

  @override
  String get setupSubtitle =>
      'Create your encrypted vault. Your master password never leaves this device.';

  @override
  String get setupSignInSubtitle =>
      'Sign in to your self-hosted OpenKey server to restore this vault on the device.';

  @override
  String get setupModeCreate => 'Create';

  @override
  String get setupModeSignIn => 'Sign in';

  @override
  String get setupModeRestore => 'Restore';

  @override
  String get setupSignInAction => 'Sign in';

  @override
  String get setupSigningIn => 'Signing in…';

  @override
  String get setupRestoreSubtitle =>
      'Restore your vault from an encrypted OpenKey backup (.okbak).';

  @override
  String get setupRestoreAction => 'Restore vault';

  @override
  String get setupRestoreChooseFile => 'Choose backup file';

  @override
  String get setupRestoreChooseFileSubtitle =>
      'Select an encrypted .okbak file.';

  @override
  String setupRestoreBackupAccount(String email) {
    return 'This backup is for $email';
  }

  @override
  String get setupRestoreNeedFile => 'Choose a backup file first';

  @override
  String get setupLinkSelfHostedTitle => 'Link self-hosted server';

  @override
  String get setupLinkSelfHostedSubtitle =>
      'Optional. Register this vault for sync across devices.';

  @override
  String get setupLinkServerHelper =>
      'Your vault will be registered on this server after creation.';

  @override
  String get setupSignInServerHelper =>
      'URL of the OpenKey server that already has your account.';

  @override
  String get setupChooserTitle => 'How do you want to start?';

  @override
  String get setupChooserSubtitle =>
      'Create a vault, sign in, or restore a backup.';

  @override
  String get setupChooseCreateTitle => 'Create a vault';

  @override
  String get setupChooseCreateSubtitle => 'New encrypted vault on this device.';

  @override
  String get setupChooseSignInTitle => 'Sign in';

  @override
  String get setupChooseSignInSubtitle =>
      'Restore from your self-hosted OpenKey server.';

  @override
  String get setupChooseRestoreTitle => 'Restore backup';

  @override
  String get setupChooseRestoreSubtitle => 'Open an encrypted .okbak file.';

  @override
  String get invalidServerUrl =>
      'Enter a valid URL starting with http:// or https://';

  @override
  String get confirmMasterPassword => 'Confirm master password';

  @override
  String get email => 'Email';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get invalidEmailFormat => 'Invalid email address';

  @override
  String get invalidUrlFormat =>
      'Invalid URL. Use a format like https://example.com';

  @override
  String get invalidPhoneFormat => 'Invalid phone number';

  @override
  String get invalidPinFormat => 'PIN must be 4–12 digits';

  @override
  String get invalidNumberFormat => 'Enter digits only';

  @override
  String get invalidCardFormat => 'Invalid card number';

  @override
  String get invalidIpFormat => 'Invalid IP address';

  @override
  String get invalidWalletFormat => 'Invalid wallet address';

  @override
  String get invalidRecoveryCodesFormat => 'Invalid recovery codes';

  @override
  String get fixFieldErrors => 'Fix the highlighted fields before saving';

  @override
  String get passwordTooShort => 'At least 8 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordTooShortStrong => 'At least 12 characters';

  @override
  String get passwordTooWeak =>
      'Use a longer mix of letters, numbers, and symbols';

  @override
  String get masterPasswordHelper =>
      '12+ characters with mixed types recommended';

  @override
  String get passwordHintOptional => 'Password hint (optional)';

  @override
  String get passwordHintHelper =>
      'A vague reminder only — never include the password itself';

  @override
  String passwordHintReveal(String hint) {
    return 'Hint: $hint';
  }

  @override
  String get setupZeroKnowledgeBanner =>
      'Zero-knowledge encryption: OpenKey cannot read or reset your vault.';

  @override
  String get vaultNoticesTitle => 'Before you create your vault';

  @override
  String get vaultNoticesSubtitle =>
      'Please acknowledge these points to continue.';

  @override
  String get vaultNoticeNoRecovery =>
      'If you forget your master password, your data cannot be recovered.';

  @override
  String get vaultNoticeLocalEncryption =>
      'Your vault is encrypted on this device; your master password never leaves it in plaintext.';

  @override
  String get vaultNoticeBackups =>
      'Regular encrypted backups are the only way to protect against device loss.';

  @override
  String get vaultNoticeDeviceTransfer =>
      'Moving to a new device requires a backup restore or optional server sync.';

  @override
  String get acceptAllNotices => 'Accept all';

  @override
  String get server => 'Self-hosted server';

  @override
  String get notConnected => 'Not connected';

  @override
  String get data => 'Data & sharing';

  @override
  String get dataSubtitle => 'Server, backup, import/export, and sharing';

  @override
  String get importExport => 'Import & export';

  @override
  String get importExportSubtitle => 'Move passwords in or out of your vault';

  @override
  String get importTab => 'Import';

  @override
  String get exportTab => 'Export';

  @override
  String get importPasswords => 'Import passwords';

  @override
  String get importPasswordsSubtitle =>
      'Entries are encrypted with your vault key on this device.';

  @override
  String get exportPasswords => 'Export passwords';

  @override
  String get exportPasswordsSubtitle =>
      'Decrypts entries on this device and saves an export file.';

  @override
  String get exportingPasswords => 'Exporting…';

  @override
  String get exportBitwardenSubtitle => 'Unencrypted Bitwarden JSON';

  @override
  String get exportChromeSubtitle => 'CSV compatible with Chrome';

  @override
  String get exportLastPassSubtitle => 'CSV compatible with LastPass';

  @override
  String get exportOnePasswordSubtitle => 'CSV compatible with 1Password';

  @override
  String get exportKeePassSubtitle =>
      'Encrypted KeePass / KeePassXC database (.kdbx)';

  @override
  String get exportOpenKeySubtitle =>
      'Unencrypted OpenKey JSON with folders and full entry data';

  @override
  String get exportedItems => 'Vault exported';

  @override
  String exportedToPath(String path) {
    return 'Exported to $path';
  }

  @override
  String get changeMasterPassword => 'Change master password';

  @override
  String get changeMasterPasswordSubtitle =>
      'Re-wraps your vault key. Entries stay encrypted with the same vault key.';

  @override
  String get currentMasterPassword => 'Current master password';

  @override
  String get newMasterPassword => 'New master password';

  @override
  String get masterPasswordUnchanged => 'Choose a different password';

  @override
  String get masterPasswordChanged => 'Master password updated';

  @override
  String get deleteServerAccount => 'Delete server account';

  @override
  String get deleteServerAccountSubtitle =>
      'Removes your ciphertext from the server. This device keeps its local vault.';

  @override
  String get deleteServerAccountWarning =>
      'This cannot be undone. Synced data on the server will be permanently deleted.';

  @override
  String get serverAccountDeleted => 'Server account deleted';

  @override
  String get browserExtension => 'Browser extension';

  @override
  String get browserExtensionSubtitle =>
      'Connect Chrome / Edge / Firefox to the unlocked vault';

  @override
  String get browserExtensionSheetSubtitle =>
      'Paste the unpacked Chrome extension ID from chrome://extensions (Developer mode). Firefox uses a fixed ID automatically.';

  @override
  String get chromeExtensionId => 'Chrome extension ID';

  @override
  String get chromeExtensionIdHint =>
      'Shown under the extension name on chrome://extensions';

  @override
  String get connectBrowserExtension => 'Connect extension';

  @override
  String get copyOfflineExtensionLink => 'Copy offline vault link';

  @override
  String get extensionLinkClipboardWarning =>
      'This copies vault unlock material to the clipboard. Other apps can read it until you clear the clipboard or it auto-clears after one minute.';

  @override
  String get browserExtensionHostReady =>
      'Native host registered. Keep OpenKey unlocked, then tap “Use desktop app” in the extension.';

  @override
  String get browserExtensionHostHint =>
      'Unlock the vault, paste the Chrome extension ID, then connect.';

  @override
  String get browserExtensionHostFailed =>
      'Could not register the native host. Unlock the vault and try again.';

  @override
  String get cliTitle => 'CLI';

  @override
  String get cliSubtitle =>
      'Install the OpenKey CLI, then run the connect command while the vault is unlocked.';

  @override
  String get cliTermuxTitle => 'Termux / CLI';

  @override
  String get cliTermuxSubtitle =>
      'Install the OpenKey CLI in Termux, then run the connect command while the vault is unlocked.';

  @override
  String get cliTermuxInstall => 'Install';

  @override
  String get cliTermuxConnect => 'Connect';

  @override
  String get cliTermuxUnavailable =>
      'Unlock the vault to show the connect command.';

  @override
  String get aboutPrivacy =>
      'OpenKey encrypts your passwords end-to-end. Your master password and vault key never leave this device.';

  @override
  String get localVault => 'Local vault';

  @override
  String get followDevice => 'Follow device appearance';

  @override
  String get passwordGenerator => 'Password generator';

  @override
  String get generatedPassword => 'Generated password';

  @override
  String get passwordLength => 'Length';

  @override
  String charactersLabel(int n) {
    return '$n characters';
  }

  @override
  String get includeUppercase => 'Uppercase letters';

  @override
  String get includeLowercase => 'Lowercase letters';

  @override
  String get includeDigits => 'Digits';

  @override
  String get includeSymbols => 'Symbols';

  @override
  String get avoidAmbiguous => 'Avoid ambiguous characters';

  @override
  String get avoidAmbiguousSubtitle => 'Exclude I, l, 1, O, 0, o, |';

  @override
  String get regenerate => 'Regenerate';

  @override
  String get copyPassword => 'Copy';

  @override
  String get passwordCopied => 'Password copied';

  @override
  String get passwordGeneratorSubtitle => 'Generate a strong unique password';

  @override
  String get usePassword => 'Use password';

  @override
  String get generateOptions => 'Options';

  @override
  String get characterSets => 'Character sets';

  @override
  String get passwordStrengthWeak => 'Weak';

  @override
  String get passwordStrengthFair => 'Fair';

  @override
  String get passwordStrengthStrong => 'Strong';

  @override
  String get generatorTitle => 'Generator';

  @override
  String get generatorSubtitle => 'Create passwords, usernames, and emails';

  @override
  String get generatorModePassword => 'Password';

  @override
  String get generatorModeUsername => 'Username';

  @override
  String get generatorModeEmail => 'Email';

  @override
  String get generatedUsername => 'Generated username';

  @override
  String get generatedEmail => 'Generated email';

  @override
  String get usernameStyle => 'Style';

  @override
  String get usernameStyleWords => 'Words';

  @override
  String get usernameStyleRandom => 'Random';

  @override
  String get usernameCapitalize => 'Capitalize';

  @override
  String get usernameIncludeDigits => 'Add numbers';

  @override
  String get usernameSeparator => 'Separator';

  @override
  String get usernameSeparatorNone => 'None';

  @override
  String get emailType => 'Email type';

  @override
  String get emailTypeRandom => 'Random';

  @override
  String get emailTypePlus => 'Plus address';

  @override
  String get emailDomain => 'Domain';

  @override
  String get emailDomainHint => 'yourdomain.com';

  @override
  String get emailPlusBase => 'Your email';

  @override
  String get emailPlusBaseHint => 'you@gmail.com';

  @override
  String get emailPlusHelp =>
      'Creates you+tag@gmail.com so you can filter signups in your inbox.';

  @override
  String get emailRandomHelp =>
      'Creates a unique address on a domain you control, such as a catch-all.';

  @override
  String get passwordDetails => 'Password details';

  @override
  String get untitled => 'Untitled';

  @override
  String get credentials => 'Credentials';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get website => 'Website';

  @override
  String get notes => 'Notes';

  @override
  String get authenticator => 'Authenticator';

  @override
  String get passkey => 'Passkey';

  @override
  String get attachments => 'Attachments';

  @override
  String get downloadAttachment => 'Download';

  @override
  String get previewAttachment => 'Preview';

  @override
  String get openAttachment => 'Open';

  @override
  String get playVideo => 'Play video';

  @override
  String get pausePlayback => 'Pause';

  @override
  String get openingAttachment => 'Opening attachment…';

  @override
  String attachmentSaved(String name) {
    return '$name saved';
  }

  @override
  String get couldNotOpenAttachment => 'Couldn\'t open this attachment.';

  @override
  String get attachmentNotPreviewable =>
      'Preview isn\'t available for this file type. You can download it instead.';

  @override
  String get copyUsername => 'Copy username';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get tapToCopy => 'Tap to copy';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteEntry => 'Delete entry?';

  @override
  String get deleteEntryConfirm =>
      'This permanently removes the password from your vault.';

  @override
  String get entryNotFound => 'Entry not found';

  @override
  String get entryNotFoundMessage => 'This password may have been deleted.';

  @override
  String get goBack => 'Go back';

  @override
  String get synced => 'Synced';

  @override
  String get pendingSync => 'Pending sync';

  @override
  String revisionLabel(int n) {
    return 'Revision $n';
  }

  @override
  String valueCopied(String label) {
    return '$label copied';
  }

  @override
  String get vault => 'Vault';

  @override
  String get items => 'Items';

  @override
  String get itemsHubSubtitle => 'Cards, crypto wallets, and secrets.';

  @override
  String get itemsCardsSubtitle => 'Payment cards and billing details';

  @override
  String get itemsCryptoSubtitle => 'Addresses, keys, and seed phrases';

  @override
  String get itemsSecretsSubtitle => 'SSH keys, API tokens, and .env snippets';

  @override
  String itemsCountLabel(int count) {
    return '$count saved';
  }

  @override
  String get wallets => 'Wallets';

  @override
  String get searchCards => 'Search cards';

  @override
  String get noCardsYet => 'No cards yet';

  @override
  String get noCardsYetMessage => 'Add a card to store it securely.';

  @override
  String get addCard => 'Add card';

  @override
  String get editCard => 'Edit card';

  @override
  String get save => 'Save';

  @override
  String get cardDetails => 'Card details';

  @override
  String get cardName => 'Card name';

  @override
  String get cardHolder => 'Cardholder';

  @override
  String get cardNumber => 'Card number';

  @override
  String get cardExpiry => 'Expiry';

  @override
  String get cardCvc => 'CVC';

  @override
  String get copyNumber => 'Copy number';

  @override
  String get copyCvc => 'Copy CVC';

  @override
  String get tapCardToFlip => 'Tap the card to flip';

  @override
  String get deleteCard => 'Delete card?';

  @override
  String get deleteCardConfirm =>
      'This permanently removes the card from your wallet.';

  @override
  String get cardNotFound => 'Card not found';

  @override
  String get cardNotFoundMessage => 'This card may have been deleted.';

  @override
  String get bank => 'Bank';

  @override
  String get banks => 'Banks';

  @override
  String get otherBank => 'Other';

  @override
  String get addBank => 'Add bank';

  @override
  String get newBank => 'New bank';

  @override
  String get bankName => 'Bank name';

  @override
  String get renameBank => 'Rename bank';

  @override
  String get deleteBank => 'Delete bank?';

  @override
  String get deleteBankConfirm =>
      'Remove this bank group? Cards can be moved to Other.';

  @override
  String get deleteBankAndClear => 'Delete and unassign cards';

  @override
  String get moveToBank => 'Move to bank';

  @override
  String get noBanksYet => 'No banks yet';

  @override
  String get createBankHint => 'Create a bank to organize your payment cards.';

  @override
  String get bankCreated => 'Bank created';

  @override
  String get cardMoved => 'Card moved';

  @override
  String get emptyBank => 'No cards in this bank';

  @override
  String get paymentCards => 'Cards';

  @override
  String get cryptoWallets => 'Crypto';

  @override
  String get searchCryptoWallets => 'Search crypto wallets';

  @override
  String get noCryptoWalletsYet => 'No crypto wallets yet';

  @override
  String get noCryptoWalletsYetMessage =>
      'Add a wallet to store keys securely.';

  @override
  String get addCryptoWallet => 'Add crypto wallet';

  @override
  String get editCryptoWallet => 'Edit crypto wallet';

  @override
  String get cryptoNetwork => 'Network';

  @override
  String get cryptoWalletName => 'Wallet name';

  @override
  String get walletAddress => 'Address';

  @override
  String get privateKey => 'Private key';

  @override
  String get seedPhrase => 'Seed phrase';

  @override
  String get cryptoDetails => 'Wallet details';

  @override
  String get copyAddress => 'Copy address';

  @override
  String get deleteCryptoWallet => 'Delete crypto wallet?';

  @override
  String get deleteCryptoWalletConfirm =>
      'This permanently removes the wallet and its secrets from your vault.';

  @override
  String get cryptoWalletNotFound => 'Crypto wallet not found';

  @override
  String get cryptoWalletNotFoundMessage =>
      'This wallet may have been deleted.';

  @override
  String get folders => 'Folders';

  @override
  String get otherFolder => 'Other';

  @override
  String get addFolder => 'Add folder';

  @override
  String get newFolder => 'New folder';

  @override
  String get folderName => 'Folder name';

  @override
  String get renameFolder => 'Rename folder';

  @override
  String get deleteFolder => 'Delete folder?';

  @override
  String get deleteFolderConfirm =>
      'Remove this folder group? Wallets can be moved to Other.';

  @override
  String get deleteFolderAndClear => 'Delete and unassign wallets';

  @override
  String get moveToFolder => 'Move to folder';

  @override
  String get noFoldersYet => 'No folders yet';

  @override
  String get createFolderHint =>
      'Create a folder to organize your crypto wallets.';

  @override
  String get folderCreated => 'Folder created';

  @override
  String get cryptoWalletMoved => 'Wallet moved';

  @override
  String get emptyFolder => 'No wallets in this folder';

  @override
  String get secrets => 'Secrets';

  @override
  String get searchSecrets => 'Search secrets';

  @override
  String get noSecretsYet => 'No secrets yet';

  @override
  String get noSecretsYetMessage =>
      'Store SSH keys, API tokens, and .env snippets securely.';

  @override
  String get addSecret => 'Add secret';

  @override
  String get editSecret => 'Edit secret';

  @override
  String get secretKind => 'Type';

  @override
  String get secretKindSsh => 'SSH key';

  @override
  String get secretKindApiToken => 'API token';

  @override
  String get secretKindEnv => '.env snippet';

  @override
  String get secretKindOther => 'Other';

  @override
  String get secretName => 'Name';

  @override
  String get secretUsername => 'Username';

  @override
  String get secretHost => 'Host';

  @override
  String get secretEndpoint => 'Endpoint / URL';

  @override
  String get publicKey => 'Public key';

  @override
  String get apiToken => 'API token';

  @override
  String get envContent => '.env content';

  @override
  String get secretValue => 'Secret';

  @override
  String get passphrase => 'Passphrase';

  @override
  String get secretDetails => 'Secret details';

  @override
  String get copySecret => 'Copy secret';

  @override
  String get deleteSecret => 'Delete secret?';

  @override
  String get deleteSecretConfirm =>
      'This permanently removes the secret from your vault.';

  @override
  String get secretNotFound => 'Secret not found';

  @override
  String get secretNotFoundMessage => 'This secret may have been deleted.';

  @override
  String get reverseOrderSecretsSubtitle => 'Display secrets in reverse order.';

  @override
  String get device => 'Device';

  @override
  String get devices => 'Devices';

  @override
  String get otherDevice => 'Other';

  @override
  String get addDevice => 'Add device';

  @override
  String get newDevice => 'New device';

  @override
  String get deviceName => 'Device name';

  @override
  String get renameDevice => 'Rename device';

  @override
  String get deleteDevice => 'Delete device?';

  @override
  String get deleteDeviceConfirm =>
      'Remove this device group? Secrets can be moved to Other.';

  @override
  String get deleteDeviceAndClear => 'Delete and unassign secrets';

  @override
  String get moveToDevice => 'Move to device';

  @override
  String get noDevicesYet => 'No devices yet';

  @override
  String get createDeviceHint =>
      'Create a device to organize secrets from each machine.';

  @override
  String get deviceCreated => 'Device created';

  @override
  String get secretMoved => 'Secret moved';

  @override
  String get emptyDevice => 'No secrets on this device';

  @override
  String get faq => 'Frequently asked questions';

  @override
  String get faqSubtitle => 'Encryption, unlock, sync, backups, and more';

  @override
  String get faqEncryptionQ => 'Is my data encrypted?';

  @override
  String get faqEncryptionA =>
      'Yes. OpenKey encrypts your vault end-to-end on this device. Your master password and vault key never leave the device in plaintext.';

  @override
  String get faqForgotPasswordQ => 'What if I forget my master password?';

  @override
  String get faqForgotPasswordA =>
      'There is no recovery without your master password. Because encryption is zero-knowledge, OpenKey cannot reset it. Keep a secure backup of your password.';

  @override
  String get faqOfflineQ => 'Does OpenKey work offline?';

  @override
  String get faqOfflineA =>
      'Yes. Your vault is stored locally and unlocks without a network connection. An optional server is only needed for sync and sharing.';

  @override
  String get faqAutoLockQ => 'How does auto-lock work?';

  @override
  String get faqAutoLockA =>
      'When you leave the app without closing it, OpenKey counts how long you were away. After the time you choose in Settings, the vault locks and you’ll need your master password or biometrics to unlock again. Closing the app ends the session immediately.';

  @override
  String get faqBiometricQ => 'Is biometric unlock safe?';

  @override
  String get faqBiometricA =>
      'Yes. Biometrics unlock a key stored in the device secure hardware. Your master password is never replaced — you can still unlock with it anytime.';

  @override
  String get faqSyncQ => 'What is self-hosted sync?';

  @override
  String get faqSyncA =>
      'You can run your own OpenKey server. Devices send encrypted vault data so they stay in sync remotely. The server stores ciphertext only and never sees plaintext secrets. Your master password stays on each device.';

  @override
  String get faqBackupQ => 'How does Backup & Restore work?';

  @override
  String get faqBackupA =>
      'In Settings → Backup & Restore you can save a full vault copy to this device. OpenKey packs the database, app settings, and attachments into a compressed file, then encrypts it with your vault key (.okbak). Nobody can read the file without your master password. Restore decrypts that file and replaces the local vault with the backup — so keep the password and the .okbak file somewhere safe.';

  @override
  String get appName => 'OpenKey';

  @override
  String get copy => 'Copy';

  @override
  String get create => 'Create';

  @override
  String get generate => 'Generate';

  @override
  String get name => 'Name';

  @override
  String get title => 'Title';

  @override
  String get lock => 'Lock';

  @override
  String get all => 'All';

  @override
  String get entry => 'Entry';

  @override
  String get collection => 'Collection';

  @override
  String get searchPasswords => 'Search passwords';

  @override
  String get noPasswordsYet => 'No passwords yet';

  @override
  String get noPasswordsYetMessage => 'Add an entry or create a collection.';

  @override
  String get newCollection => 'New collection';

  @override
  String get newEntry => 'New entry';

  @override
  String get editEntry => 'Edit entry';

  @override
  String get chooseFields => 'Fields';

  @override
  String get chooseFieldsSubtitle =>
      'Toggle fields on or off, then drag to reorder';

  @override
  String get done => 'Done';

  @override
  String get phone => 'Phone';

  @override
  String get pin => 'PIN';

  @override
  String get number => 'Number';

  @override
  String get address => 'Address';

  @override
  String get ipAddress => 'IP address';

  @override
  String get dateYmd => 'Date';

  @override
  String get dateYm => 'Month / year';

  @override
  String get recoveryCodes => 'Recovery codes';

  @override
  String get customText => 'Text';

  @override
  String get additionalFields => 'Additional fields';

  @override
  String get emptyCollection => 'Empty collection';

  @override
  String get emptyCollectionMessage =>
      'Add a password entry to this collection.';

  @override
  String get editCollection => 'Edit collection';

  @override
  String get deleteCollection => 'Delete collection';

  @override
  String get deleteCollectionConfirm =>
      'Entries in this collection will be removed from the folder (not deleted). Continue?';

  @override
  String get chooseIcon => 'Choose icon';

  @override
  String get icons => 'Icons';

  @override
  String get brands => 'Brands';

  @override
  String get suggestedIcon => 'Suggested icon';

  @override
  String get fromDevice => 'From device';

  @override
  String get customIcon => 'Custom icon';

  @override
  String get editIcon => 'Edit icon';

  @override
  String get cropOrRotate => 'Crop / Rotate';

  @override
  String get rotate => 'Rotate';

  @override
  String get flip => 'Flip';

  @override
  String get ratio => 'Ratio';

  @override
  String get filter => 'Filter';

  @override
  String get blur => 'Blur';

  @override
  String get discardChanges => 'Discard changes?';

  @override
  String get discardChangesMessage => 'Your edits will be lost.';

  @override
  String get discard => 'Discard';

  @override
  String get undo => 'Undo';

  @override
  String get redo => 'Redo';

  @override
  String get more => 'More';

  @override
  String get back => 'Back';

  @override
  String get preparingImage => 'Preparing image…';

  @override
  String get search => 'Search';

  @override
  String get noFolder => 'No folder';

  @override
  String get folder => 'Folder';

  @override
  String entriesCount(int count) {
    return '$count entries';
  }

  @override
  String get moveTo => 'Move to';

  @override
  String get moveHere => 'Move here';

  @override
  String get movingLabel => 'Moving';

  @override
  String movingItemsCount(int count) {
    return '$count items';
  }

  @override
  String get tags => 'Tags';

  @override
  String get noTags => 'No tags yet';

  @override
  String get noTagsMessage => 'Add tags when editing a password entry.';

  @override
  String get sortAndFilter => 'Sort & Filter';

  @override
  String get applyToFolders => 'Folders';

  @override
  String get applyToEntries => 'Passwords';

  @override
  String get sortBy => 'Sort by';

  @override
  String get options => 'Options';

  @override
  String get sortByCreationTime => 'Sort by creation time';

  @override
  String get sortByLastModified => 'Sort by last modified';

  @override
  String get sortByName => 'Sort by name';

  @override
  String get sortByCustomOrder => 'Custom order';

  @override
  String get reverseOrder => 'Reverse order';

  @override
  String get reverseOrderFoldersSubtitle => 'Display folders in reverse order.';

  @override
  String get reverseOrderEntriesSubtitle =>
      'Display passwords in reverse order.';

  @override
  String get reverseOrderCardsSubtitle => 'Display cards in reverse order.';

  @override
  String get reverseOrderCryptoSubtitle => 'Display wallets in reverse order.';

  @override
  String get addTagHint => 'Add a tag';

  @override
  String deleteSelectedConfirm(int count) {
    return 'Delete $count selected items?';
  }

  @override
  String get totpSecretLabel => 'TOTP secret / otpauth';

  @override
  String get scanTotpQr => 'Scan QR code';

  @override
  String get scanTotpQrHint => 'Point the camera at the authenticator QR code';

  @override
  String get invalidTotpQr =>
      'This QR code is not a valid TOTP authenticator code';

  @override
  String get cameraPermissionDenied =>
      'Camera permission is required to scan QR codes';

  @override
  String get storePasskeyMetadata => 'Passkey';

  @override
  String get passkeyCreatedInBrowser =>
      'Create passkeys with the OpenKey browser extension or via system Autofill / Credential Provider on mobile when OpenKey is unlocked.';

  @override
  String get rpId => 'RP ID';

  @override
  String get credentialId => 'Credential ID';

  @override
  String get addPasskeyItem => 'No passkey yet';

  @override
  String bytesLabel(int n) {
    return '$n bytes';
  }

  @override
  String get addEncryptedAttachment => 'Add encrypted attachment';

  @override
  String get expiryHint => 'MM/YY';

  @override
  String get autoLockSubtitle => 'Lock the vault after you leave the app.';

  @override
  String get serverUrl => 'Server URL';

  @override
  String get serverUrlHint => 'https://openkey.example.com';

  @override
  String get serverSheetSubtitle =>
      'Register or log in to sync encrypted vault ciphertext only.';

  @override
  String get register => 'Register';

  @override
  String get registerSubtitle => 'Create an account on this server';

  @override
  String get login => 'Login';

  @override
  String get loginSubtitle => 'Sign in with this vault auth hash';

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncing => 'Syncing…';

  @override
  String get syncSubtitle => 'Push and pull encrypted changes';

  @override
  String get syncComplete => 'Sync complete';

  @override
  String get extensionLinkCopied => 'Extension link payload copied';

  @override
  String get biometricUnlockEnabled => 'Biometric unlock enabled';

  @override
  String get biometricUnlockDisabled => 'Biometric unlock disabled';

  @override
  String biometricsUpdateFailed(String error) {
    return 'Could not update biometrics: $error';
  }

  @override
  String get bitwardenJson => 'Bitwarden JSON';

  @override
  String get bitwardenJsonSubtitle => 'Export from Bitwarden → import here';

  @override
  String get openKeyJson => 'OpenKey JSON';

  @override
  String get openKeyJsonSubtitle => 'Backup exported from OpenKey';

  @override
  String get chromeCsv => 'Chrome CSV';

  @override
  String get chromeCsvSubtitle => 'Passwords exported from Chrome';

  @override
  String get lastPassCsv => 'LastPass CSV';

  @override
  String get lastPassCsvSubtitle => 'CSV export from LastPass';

  @override
  String get keePassKdbx => 'KeePass (.kdbx)';

  @override
  String get keePassKdbxSubtitle => 'Encrypted KeePass / KeePassXC database';

  @override
  String get keePassPasswordHint => 'Database password';

  @override
  String get keePassKeyFile => 'Key file (optional)';

  @override
  String get keePassUnlockFailed =>
      'Could not open the KeePass database. Check the password and key file.';

  @override
  String get onePasswordCsv => '1Password CSV';

  @override
  String get onePasswordCsvSubtitle => 'CSV export from 1Password';

  @override
  String get importingPasswords => 'Importing…';

  @override
  String importingProgress(int done, int total) {
    return 'Importing $done of $total…';
  }

  @override
  String importedItems(int n) {
    return 'Imported $n items';
  }

  @override
  String get failureUnknown => 'Something went wrong.';

  @override
  String get failureNetwork => 'Network error. Check your connection.';

  @override
  String get failureUnauthorized => 'Unauthorized. Please sign in again.';

  @override
  String get failureNotFound => 'Not found.';

  @override
  String get failureServer => 'Server error.';

  @override
  String get failureInvalidCredentials => 'Invalid email or master password.';

  @override
  String get failureVaultLocked => 'Vault is locked.';

  @override
  String get failureVaultAlreadyExists =>
      'A vault already exists on this device.';

  @override
  String get failureDecryptionFailed => 'Could not decrypt vault data.';

  @override
  String get failureSyncFailed => 'Sync failed.';

  @override
  String get failureCreateCollection => 'Failed to create collection.';

  @override
  String get failureUpdateCollection => 'Failed to update collection.';

  @override
  String get failureDeleteCollection => 'Failed to delete collection.';

  @override
  String get failureGetCollections => 'Failed to load collections.';

  @override
  String get failureCreateEntry => 'Failed to create entry.';

  @override
  String get failureUpdateEntry => 'Failed to update entry.';

  @override
  String get failureDeleteEntry => 'Failed to delete entry.';

  @override
  String get failureGetEntries => 'Failed to load entries.';

  @override
  String get failureNoVault => 'No vault found. Create one first.';

  @override
  String get failureConnectServerFirst =>
      'Connect to a server in Settings first.';

  @override
  String get failureAttachmentTooLarge => 'Attachment exceeds 20 MB limit.';

  @override
  String get failureAttachmentMissing => 'Attachment ciphertext missing.';

  @override
  String get failureAccountEmailExists =>
      'That email already has a vault on this device.';

  @override
  String get root => 'Root';

  @override
  String get selectedItems => 'selected';

  @override
  String get authenticatorTotp => 'Authenticator (TOTP)';

  @override
  String get openKeyPro => 'OpenKey Pro';

  @override
  String get proSubtitle =>
      'Unlock premium features and support OpenKey development.';

  @override
  String get premiumFeatureTitle => 'Premium feature';

  @override
  String get premiumFeatureSubtitle =>
      'Subscribe to unlock this premium feature.';

  @override
  String get premiumFeatureContent =>
      'This is a premium feature. Subscribe to access it.';

  @override
  String get premiumBadge => 'Pro';

  @override
  String get subscribe => 'Subscribe';

  @override
  String get upgradeNow => 'Upgrade Now';

  @override
  String get oops => 'Oops!';

  @override
  String get subscription => 'Subscription';

  @override
  String get subscriptionTitle => 'Subscription';

  @override
  String get subscriptionSubtitle => 'Choose a plan that works for you.';

  @override
  String get manageYourSubscription => 'Manage your subscription';

  @override
  String get manageSubscriptionAction => 'Manage subscription';

  @override
  String get subIsActiveTitle => 'Your subscription is active';

  @override
  String get subIsNotActiveTitle => 'Your subscription is inactive';

  @override
  String get thanksForSubscribing => 'Thanks for subscribing!';

  @override
  String get subIsCancelled =>
      'Your subscription is cancelled and will not renew.';

  @override
  String get subIsPaused => 'Your subscription is paused.';

  @override
  String get restorePurchase => 'Restore purchase';

  @override
  String get viewPlansPaywall => 'View subscription options';

  @override
  String get openCustomerCenter => 'Manage in Customer Center';

  @override
  String get subscriptionDesktopNote =>
      'In-app purchases are available on Android, iOS, and macOS. On Windows and Linux, sign in with the same OpenKey account to unlock Pro after subscribing on a mobile or Mac device.';

  @override
  String get subscriptionRefreshStatus => 'Refresh subscription status';

  @override
  String get subscriptionNoInternetMsg =>
      'There\'s a problem with your internet connection. Check your network and try again.';

  @override
  String get subscriptionRegionBlockedMsg =>
      'Subscription services aren\'t reachable in your region. Connect to a VPN and try again.';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get lifetime => 'Lifetime';

  @override
  String get monthlySubtitle => 'Auto-renew, cancel anytime';

  @override
  String get yearlySubtitle => 'Auto-renew, best value, cancel anytime';

  @override
  String get lifetimeSubtitle => 'One-time purchase, yours forever';

  @override
  String monthlyPriceLabel(String price) {
    return '$price/mo';
  }

  @override
  String yearlyPriceLabel(String price) {
    return '$price/yr';
  }

  @override
  String lifetimePriceLabel(String price) {
    return '$price';
  }

  @override
  String monthlySubscribeLabel(String price) {
    return 'Subscribe for $price / month';
  }

  @override
  String yearlySubscribeLabel(String price) {
    return 'Subscribe for $price / year';
  }

  @override
  String lifetimeSubscribeLabel(String price) {
    return 'Buy lifetime for $price';
  }

  @override
  String get bestValue => 'Best Value';

  @override
  String get skip => 'Skip';

  @override
  String get getStarted => 'Get started';

  @override
  String get onboardingFaqTitle => 'Know this before you start';

  @override
  String get onboardingFaqSubtitle =>
      'The questions people ask most about OpenKey. Tap any to expand — then create your vault.';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingWelcomeTitle => 'Your keys. Your vault.';

  @override
  String get onboardingWelcomeSubtitle =>
      'OpenKey keeps passwords, codes, and cards in one encrypted home — built for everyday use.';

  @override
  String get onboardingWelcomePhrase1 => 'Zero-knowledge by design';

  @override
  String get onboardingWelcomePhrase2 => 'Autofill in one tap';

  @override
  String get onboardingWelcomePhrase3 => 'Self-hosted when you want';

  @override
  String get onboardingSecurityTitle => 'Nobody else can read it';

  @override
  String get onboardingSecuritySubtitle =>
      'End-to-end encryption means your master password never leaves this device. We store ciphertext only.';

  @override
  String get onboardingAutofillTitle => 'Fill once. Trust forever.';

  @override
  String get onboardingAutofillSubtitle =>
      'Log in across apps and sites without hunting for passwords. Autofill makes OpenKey part of every day.';

  @override
  String get onboardingAllInOneTitle => 'One app. Whole vault.';

  @override
  String get onboardingAllInOneSubtitle =>
      'Passwords, authenticator codes, payment cards, crypto wallets, and developer secrets — replace the clutter with a single trusted vault.';

  @override
  String get onboardingFeaturePasswords => 'Passwords';

  @override
  String get onboardingFeatureCrypto => 'Crypto';

  @override
  String get onboardingFeatureAutofill => 'Autofill';

  @override
  String get onboardingFeatureSelfHost => 'Self-host.';

  @override
  String get onboardingFooterHint =>
      'Takes under a minute. You can skip anytime.';

  @override
  String get onboardingLetsGo => 'Let\'s Go!';

  @override
  String onboardingStepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onboardingWelcomeHeadline => 'Welcome\nto OpenKey.';

  @override
  String get onboardingWelcomeLead => 'Let\'s set everything up for you';

  @override
  String get onboardingEcosystemTitle => 'Your\ncomplete\nvault.';

  @override
  String get onboardingEcosystemSubtitle =>
      'Passwords, codes, and cards — encrypted and ready wherever you sign in.';

  @override
  String get onboardingStyleTitle => 'Style it\nyour way.';

  @override
  String get onboardingEnableAutofillTitle => 'Enable\nAutofill.';

  @override
  String get onboardingAutofillCardTitle => 'Password Autofill';

  @override
  String get onboardingAutofillCardSubtitle =>
      'Fill logins in apps and sites from your vault.';

  @override
  String get onboardingAutofillGranted => 'Autofill is ready';

  @override
  String get onboardingFinishBadge => 'Setup complete';

  @override
  String get onboardingFinishTitle => 'Ready to\nlock in.';

  @override
  String get onboardingFinishSubtitle =>
      'Create a master password and start saving what matters — your vault is one step away.';

  @override
  String get onboardingCreateVault => 'Create vault';

  @override
  String get errorLoadingData => 'Error loading data. Please try again.';

  @override
  String get retryAgain => 'Retry';

  @override
  String get autoRenewLabel => 'Auto-renewal';

  @override
  String get cancelledLabel => 'Cancelled';

  @override
  String get pausedLabel => 'Paused';

  @override
  String get supportAppDevelopmentTitle => 'Support development';

  @override
  String get supportAppDevelopmentSubtitle =>
      'Your subscription helps us keep improving OpenKey.';

  @override
  String get limitEntriesTitle => 'Entry limit reached';

  @override
  String get limitCollectionsTitle => 'Collection limit reached';

  @override
  String get limitWalletsTitle => 'Card limit reached';

  @override
  String get limitCryptoWalletsTitle => 'Crypto wallet limit reached';

  @override
  String get limitSecretsTitle => 'Secret limit reached';

  @override
  String limitReachedContent(int usage, int limit, String feature) {
    return 'You\'ve used $usage out of $limit $feature. Upgrade to Pro for unlimited access.';
  }

  @override
  String limitSubtitle(int limit, String feature) {
    return 'Free plan includes up to $limit $feature.';
  }

  @override
  String get entries => 'entries';

  @override
  String get collections => 'collections';

  @override
  String get cards => 'cards';

  @override
  String get cryptoWalletsFeature => 'crypto wallets';

  @override
  String get secretsFeature => 'secrets';

  @override
  String expiresOn(String date) {
    return 'Expires on $date';
  }

  @override
  String get unlockUnlimitedEntriesTitle => 'Unlimited entries';

  @override
  String get unlockUnlimitedEntriesSubtitle =>
      'Store as many passwords and logins as you need.';

  @override
  String get unlockUnlimitedCollectionsTitle => 'Unlimited collections';

  @override
  String get unlockUnlimitedCollectionsSubtitle =>
      'Organize your vault with as many folders as you want.';

  @override
  String get unlockUnlimitedWalletsTitle => 'Unlimited cards';

  @override
  String get unlockUnlimitedWalletsSubtitle =>
      'Save as many payment cards as you need.';

  @override
  String get unlockUnlimitedCryptoWalletsTitle => 'Unlimited crypto wallets';

  @override
  String get unlockUnlimitedCryptoWalletsSubtitle =>
      'Store addresses, keys, and seed phrases without limits.';

  @override
  String get unlockUnlimitedSecretsTitle => 'Unlimited developer secrets';

  @override
  String get unlockUnlimitedSecretsSubtitle =>
      'Store SSH keys, API tokens, and .env snippets without limits.';

  @override
  String get unlockSyncTitle => 'Server sync';

  @override
  String get unlockSyncSubtitle =>
      'Connect your self-hosted server and sync across devices.';

  @override
  String get unlockAttachmentsTitle => 'Attachments';

  @override
  String get unlockAttachmentsSubtitle =>
      'Attach encrypted files to vault entries.';

  @override
  String get unlockImportExportTitle => 'Import & export';

  @override
  String get unlockImportExportSubtitle => 'Move data in and out of OpenKey.';

  @override
  String get unknownFailureMsg => 'An unknown error has occurred.';

  @override
  String get purchaseCancelledMsg => 'The purchase was cancelled.';

  @override
  String get storeProblemMsg => 'There was a problem with the store.';

  @override
  String get purchaseNotAllowedMsg =>
      'Purchases are not allowed on this device.';

  @override
  String get purchaseInvalidMsg => 'The purchase is invalid.';

  @override
  String get productNotAvailableForPurchaseMsg =>
      'This product is not available for purchase.';

  @override
  String get productAlreadyPurchasedMsg =>
      'This product has already been purchased.';

  @override
  String get receiptAlreadyInUseMsg => 'This receipt is already in use.';

  @override
  String get invalidReceiptMsg => 'The receipt is invalid.';

  @override
  String get missingReceiptFileMsg => 'The receipt file is missing.';

  @override
  String get networkErrorMsg =>
      'A network error occurred. Please check your connection.';

  @override
  String get invalidCredentialsMsg => 'Invalid credentials provided.';

  @override
  String get unexpectedBackendResponseMsg =>
      'Unexpected response from the backend.';

  @override
  String get receiptInUseByOtherSubscriberMsg =>
      'The receipt is in use by another subscriber.';

  @override
  String get invalidAppUserIdMsg => 'The app user ID is invalid.';

  @override
  String get operationAlreadyInProgressMsg =>
      'An operation is already in progress.';

  @override
  String get unknownBackendErrorMsg =>
      'An unknown error occurred on the server.';

  @override
  String get invalidAppleSubscriptionKeyMsg =>
      'The Apple subscription key is invalid.';

  @override
  String get ineligibleMsg => 'You are not eligible for this purchase.';

  @override
  String get insufficientPermissionsMsg =>
      'You do not have sufficient permissions.';

  @override
  String get paymentPendingMsg => 'Payment is pending.';

  @override
  String get invalidSubscriberAttributesMsg =>
      'Subscriber attributes are invalid.';

  @override
  String get logOutWithAnonymousUserMsg =>
      'Cannot log out with an anonymous user.';

  @override
  String get configurationErrorMsg => 'There is a configuration error.';

  @override
  String get unsupportedErrorMsg => 'This operation is not supported.';

  @override
  String get emptySubscriberAttributesMsg => 'Subscriber attributes are empty.';

  @override
  String get productDiscountMissingIdentifierMsg =>
      'Product discount identifier is missing.';

  @override
  String get unknownNonNativeErrorMsg =>
      'An unknown non-native error occurred.';

  @override
  String get productDiscountMissingSubscriptionGroupIdentifierMsg =>
      'Product discount subscription group identifier is missing.';

  @override
  String get customerInfoErrorMsg => 'Failed to retrieve customer information.';

  @override
  String get systemInfoErrorMsg => 'Failed to retrieve system information.';

  @override
  String get beginRefundRequestErrorMsg => 'Failed to begin refund request.';

  @override
  String get productRequestTimeoutMsg => 'Product request timed out.';

  @override
  String get apiEndpointBlockedMsg => 'API endpoint is blocked.';

  @override
  String get invalidPromotionalOfferMsg => 'The promotional offer is invalid.';

  @override
  String get offlineConnectionMsg =>
      'No internet connection. Please connect and try again.';

  @override
  String get featureNotAvailableInCustomEntitlementsComputationModeMsg =>
      'This feature is not available in custom entitlements computation mode.';

  @override
  String get signatureVerificationFailedMsg => 'Signature verification failed.';

  @override
  String get featureNotSupportedWithStoreKit1Msg =>
      'This feature is not supported with StoreKit 1.';

  @override
  String get invalidWebPurchaseTokenMsg => 'The web purchase token is invalid.';

  @override
  String get purchaseBelongsToOtherUserMsg =>
      'This purchase belongs to another user.';

  @override
  String get expiredWebPurchaseTokenMsg =>
      'The web purchase token has expired.';

  @override
  String get testStoreSimulatedPurchaseErrorMsg =>
      'Test store simulated purchase error.';

  @override
  String get aboutApp => 'About the App';

  @override
  String get aboutAppSubtitle =>
      'Learn more about OpenKey and its development.';

  @override
  String get developerName => 'OpenSelfHosting';

  @override
  String get developer => 'Open-source software you host yourself';

  @override
  String rateUsIn(String storeName) {
    return 'Rate us on $storeName';
  }

  @override
  String get doYouLikeTheAppRateUs => 'Do you like the app? Rate us!';

  @override
  String get licenses => 'Licenses';

  @override
  String get openLicenses => 'Open licenses';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle => 'Read our privacy policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get termsOfServiceSubtitle => 'Read our terms of service';

  @override
  String get pricing => 'Pricing';

  @override
  String get pricingSubtitle => 'Free vs OpenKey Pro plans';

  @override
  String get copied => 'Copied to clipboard';

  @override
  String get contact => 'Contact';

  @override
  String get contactSubtitle => 'Get in touch with us for support or feedback.';

  @override
  String get telegram => 'Telegram';

  @override
  String get ok => 'OK';

  @override
  String get localBackupRestoreTitle => 'Backup & Restore';

  @override
  String get localBackupRestoreSubtitle =>
      'Create an encrypted full-vault backup (.okbak), or restore one. Includes the database, settings, and attachments.';

  @override
  String get exportBackup => 'Export Backup';

  @override
  String get exportBackupSubtitleEmpty =>
      'Create an encrypted local backup and choose where to save it.';

  @override
  String exportBackupSubtitleLatest(String path) {
    return 'Latest export: $path';
  }

  @override
  String get importBackup => 'Restore Backup';

  @override
  String get importBackupSubtitle =>
      'Replace this vault with an encrypted OpenKey backup (.okbak).';

  @override
  String get confirmRestore => 'Confirm Restore';

  @override
  String get confirmRestoreMessage =>
      'Restoring replaces the local database, settings, and attachments with the backup. Enter the master password used for that backup to decrypt it.';

  @override
  String get creatingBackup => 'Creating backup…';

  @override
  String get creatingBackupBody =>
      'Compressing and encrypting your full vault.';

  @override
  String get restoringBackupProgress => 'Restoring backup…';

  @override
  String get restoringBackupBody => 'Decrypting and restoring your vault.';

  @override
  String get restoringBackupVerifying => 'Verifying master password…';

  @override
  String get restoringBackupDecrypting => 'Decrypting backup data…';

  @override
  String get restoringBackupWriting => 'Writing restored vault…';

  @override
  String get restoringBackupUnlocking => 'Opening restored vault…';

  @override
  String get backupComplete => 'Backup complete';

  @override
  String get backupCompleteLocalBody =>
      'Your encrypted backup was saved successfully.';

  @override
  String get backupCompleteLocalDetail =>
      'Keep this file somewhere safe. You need the master password to restore it.';

  @override
  String get backupError => 'Backup error';

  @override
  String get restoreCompleted => 'Restore complete';

  @override
  String get restoreCompletedBody =>
      'Your vault was restored from the encrypted backup.';
}
