import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('pt'),
    Locale('ru'),
    Locale('ur'),
    Locale('zh'),
  ];

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @appearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Theme, colors, fonts, and language'**
  String get appearanceSubtitle;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get themeMode;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @fonts.
  ///
  /// In en, this message translates to:
  /// **'Fonts'**
  String get fonts;

  /// No description provided for @displayFont.
  ///
  /// In en, this message translates to:
  /// **'Display font'**
  String get displayFont;

  /// No description provided for @defaultFont.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultFont;

  /// No description provided for @arabicFont.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabicFont;

  /// No description provided for @developerFont.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developerFont;

  /// No description provided for @technicalFont.
  ///
  /// In en, this message translates to:
  /// **'Technical'**
  String get technicalFont;

  /// No description provided for @standardFont.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standardFont;

  /// No description provided for @defaultFontDes.
  ///
  /// In en, this message translates to:
  /// **'The default font for the application.'**
  String get defaultFontDes;

  /// No description provided for @arabicFontDes.
  ///
  /// In en, this message translates to:
  /// **'A font optimized for Arabic script.'**
  String get arabicFontDes;

  /// No description provided for @developerFontDes.
  ///
  /// In en, this message translates to:
  /// **'A font designed for developers.'**
  String get developerFontDes;

  /// No description provided for @technicalFontDes.
  ///
  /// In en, this message translates to:
  /// **'A font suitable for technical content.'**
  String get technicalFontDes;

  /// No description provided for @standardFontDes.
  ///
  /// In en, this message translates to:
  /// **'A standard font for general use.'**
  String get standardFontDes;

  /// No description provided for @googleSansFlexFont.
  ///
  /// In en, this message translates to:
  /// **'Google Sans Flex'**
  String get googleSansFlexFont;

  /// No description provided for @googleSansFlexFontDes.
  ///
  /// In en, this message translates to:
  /// **'Google’s expressive brand typeface for Material 3 Expressive.'**
  String get googleSansFlexFontDes;

  /// No description provided for @robotoFlexFont.
  ///
  /// In en, this message translates to:
  /// **'Roboto Flex'**
  String get robotoFlexFont;

  /// No description provided for @robotoFlexFontDes.
  ///
  /// In en, this message translates to:
  /// **'Material Design’s variable font with weight, width, and optical size.'**
  String get robotoFlexFontDes;

  /// No description provided for @figtreeFont.
  ///
  /// In en, this message translates to:
  /// **'Figtree'**
  String get figtreeFont;

  /// No description provided for @figtreeFontDes.
  ///
  /// In en, this message translates to:
  /// **'A soft geometric sans often paired with Material You themes.'**
  String get figtreeFontDes;

  /// No description provided for @nunitoFont.
  ///
  /// In en, this message translates to:
  /// **'Nunito'**
  String get nunitoFont;

  /// No description provided for @nunitoFontDes.
  ///
  /// In en, this message translates to:
  /// **'A rounded geometric sans with a friendly, modern tone.'**
  String get nunitoFontDes;

  /// No description provided for @dynamicColors.
  ///
  /// In en, this message translates to:
  /// **'Dynamic colors'**
  String get dynamicColors;

  /// No description provided for @dynamicColorsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Build the theme from a chosen color seed'**
  String get dynamicColorsSubtitle;

  /// No description provided for @colorScheme.
  ///
  /// In en, this message translates to:
  /// **'Color scheme'**
  String get colorScheme;

  /// No description provided for @colorSchemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a seed color and palette style'**
  String get colorSchemeSubtitle;

  /// No description provided for @highContrast.
  ///
  /// In en, this message translates to:
  /// **'High contrast'**
  String get highContrast;

  /// No description provided for @highContrastSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Increase contrast for better readability'**
  String get highContrastSubtitle;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @securitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-lock, biometrics, autofill, and master password'**
  String get securitySubtitle;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @accountPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountPageTitle;

  /// No description provided for @accountPhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get accountPhoto;

  /// No description provided for @changeAccountPhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changeAccountPhoto;

  /// No description provided for @removeAccountPhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removeAccountPhoto;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get changeEmail;

  /// No description provided for @changeEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Re-wraps your vault key. You will unlock with the new email.'**
  String get changeEmailSubtitle;

  /// No description provided for @newEmail.
  ///
  /// In en, this message translates to:
  /// **'New email'**
  String get newEmail;

  /// No description provided for @emailChanged.
  ///
  /// In en, this message translates to:
  /// **'Email updated'**
  String get emailChanged;

  /// No description provided for @switchAccount.
  ///
  /// In en, this message translates to:
  /// **'Switch account'**
  String get switchAccount;

  /// No description provided for @addAccount.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get addAccount;

  /// No description provided for @addAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create or sign in to another vault on this device'**
  String get addAccountSubtitle;

  /// No description provided for @removeAccountFromDevice.
  ///
  /// In en, this message translates to:
  /// **'Remove from this device'**
  String get removeAccountFromDevice;

  /// No description provided for @removeAccountFromDeviceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deletes this local vault. A linked server account is not deleted.'**
  String get removeAccountFromDeviceSubtitle;

  /// No description provided for @removeAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'This vault and its items will be removed from this device. This cannot be undone.'**
  String get removeAccountConfirm;

  /// No description provided for @otherAccounts.
  ///
  /// In en, this message translates to:
  /// **'Other accounts'**
  String get otherAccounts;

  /// No description provided for @useThisAccount.
  ///
  /// In en, this message translates to:
  /// **'Use this account'**
  String get useThisAccount;

  /// No description provided for @currentAccount.
  ///
  /// In en, this message translates to:
  /// **'Current account'**
  String get currentAccount;

  /// No description provided for @chooseAccount.
  ///
  /// In en, this message translates to:
  /// **'Choose account'**
  String get chooseAccount;

  /// No description provided for @switchingAccount.
  ///
  /// In en, this message translates to:
  /// **'Switching account…'**
  String get switchingAccount;

  /// No description provided for @welcomeBackShort.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBackShort;

  /// No description provided for @tools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get tools;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @autoLock.
  ///
  /// In en, this message translates to:
  /// **'Auto-lock'**
  String get autoLock;

  /// No description provided for @minutesLabel.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{{n} minute} other{{n} minutes}}'**
  String minutesLabel(num n);

  /// No description provided for @autoLockOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get autoLockOff;

  /// No description provided for @blockScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Block screenshots'**
  String get blockScreenshot;

  /// No description provided for @blockScreenshotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Prevent screenshots and screen recording of the app.'**
  String get blockScreenshotSubtitle;

  /// No description provided for @blockScreenshotLinuxNote.
  ///
  /// In en, this message translates to:
  /// **'Best-effort on Linux — the compositor may still allow captures.'**
  String get blockScreenshotLinuxNote;

  /// No description provided for @biometricUnlock.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock'**
  String get biometricUnlock;

  /// No description provided for @autofillService.
  ///
  /// In en, this message translates to:
  /// **'Autofill service'**
  String get autofillService;

  /// No description provided for @autofillEnabled.
  ///
  /// In en, this message translates to:
  /// **'OpenKey is your password & passkey provider'**
  String get autofillEnabled;

  /// No description provided for @autofillDisabled.
  ///
  /// In en, this message translates to:
  /// **'Enable OpenKey for passwords (AutoFill) and passkeys (Credential Provider)'**
  String get autofillDisabled;

  /// No description provided for @autofillDisabledBrowser.
  ///
  /// In en, this message translates to:
  /// **'Install the OpenKey browser extension and unlock the vault'**
  String get autofillDisabledBrowser;

  /// No description provided for @autofillSaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get autofillSaveTitle;

  /// No description provided for @autofillSaveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save this login to your OpenKey vault?'**
  String get autofillSaveSubtitle;

  /// No description provided for @autofillSaved.
  ///
  /// In en, this message translates to:
  /// **'Password saved'**
  String get autofillSaved;

  /// No description provided for @autofillRequireBiometric.
  ///
  /// In en, this message translates to:
  /// **'Require biometric for Autofill'**
  String get autofillRequireBiometric;

  /// No description provided for @autofillRequireBiometricSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask for fingerprint or face before filling passwords into apps and websites.'**
  String get autofillRequireBiometricSubtitle;

  /// No description provided for @autofillRequireBiometricReason.
  ///
  /// In en, this message translates to:
  /// **'Confirm Autofill with OpenKey'**
  String get autofillRequireBiometricReason;

  /// No description provided for @autofillRequireBiometricEnabled.
  ///
  /// In en, this message translates to:
  /// **'Autofill biometric confirmation enabled'**
  String get autofillRequireBiometricEnabled;

  /// No description provided for @autofillRequireBiometricDisabled.
  ///
  /// In en, this message translates to:
  /// **'Autofill biometric confirmation disabled'**
  String get autofillRequireBiometricDisabled;

  /// No description provided for @autofillInline.
  ///
  /// In en, this message translates to:
  /// **'Inline in keyboard'**
  String get autofillInline;

  /// No description provided for @autofillInlineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show suggestions in the keyboard strip. Turns off the popup over the field.'**
  String get autofillInlineSubtitle;

  /// No description provided for @autofillPopup.
  ///
  /// In en, this message translates to:
  /// **'Popup above the field'**
  String get autofillPopup;

  /// No description provided for @autofillPopupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show a dropdown over the input field. Turns off keyboard suggestions.'**
  String get autofillPopupSubtitle;

  /// No description provided for @androidApp.
  ///
  /// In en, this message translates to:
  /// **'Android app'**
  String get androidApp;

  /// No description provided for @androidAppHint.
  ///
  /// In en, this message translates to:
  /// **'Package name, e.g. com.example.app'**
  String get androidAppHint;

  /// No description provided for @biometricUnlockReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock your OpenKey vault'**
  String get biometricUnlockReason;

  /// No description provided for @enableBiometricUnlockReason.
  ///
  /// In en, this message translates to:
  /// **'Enable biometric unlock'**
  String get enableBiometricUnlockReason;

  /// No description provided for @biometricHint.
  ///
  /// In en, this message translates to:
  /// **'Verify your identity'**
  String get biometricHint;

  /// No description provided for @biometricNotRecognized.
  ///
  /// In en, this message translates to:
  /// **'Not recognized. Try again.'**
  String get biometricNotRecognized;

  /// No description provided for @goToSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to settings'**
  String get goToSettings;

  /// No description provided for @biometricGoToSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is not set up on your device. Go to Settings to enroll a fingerprint or face.'**
  String get biometricGoToSettingsDescription;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @unlocking.
  ///
  /// In en, this message translates to:
  /// **'Unlocking…'**
  String get unlocking;

  /// No description provided for @masterPassword.
  ///
  /// In en, this message translates to:
  /// **'Master password'**
  String get masterPassword;

  /// No description provided for @unlockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your master password to unlock.'**
  String get unlockSubtitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {email}'**
  String welcomeBack(String email);

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @resetLocalVault.
  ///
  /// In en, this message translates to:
  /// **'Reset local vault'**
  String get resetLocalVault;

  /// No description provided for @resetLocalVaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset local vault?'**
  String get resetLocalVaultTitle;

  /// No description provided for @resetLocalVaultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently deletes all vault data stored on this device.'**
  String get resetLocalVaultSubtitle;

  /// No description provided for @resetLocalVaultConfirm.
  ///
  /// In en, this message translates to:
  /// **'All passwords and vault data on this device will be permanently deleted so you can create a new vault. Server data is not deleted. This cannot be undone.'**
  String get resetLocalVaultConfirm;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get dangerZone;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @createVault.
  ///
  /// In en, this message translates to:
  /// **'Create vault'**
  String get createVault;

  /// No description provided for @creatingVault.
  ///
  /// In en, this message translates to:
  /// **'Creating…'**
  String get creatingVault;

  /// No description provided for @setupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your encrypted vault. Your master password never leaves this device.'**
  String get setupSubtitle;

  /// No description provided for @setupSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your self-hosted OpenKey server to restore this vault on the device.'**
  String get setupSignInSubtitle;

  /// No description provided for @setupModeCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get setupModeCreate;

  /// No description provided for @setupModeSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get setupModeSignIn;

  /// No description provided for @setupModeRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get setupModeRestore;

  /// No description provided for @setupSignInAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get setupSignInAction;

  /// No description provided for @setupSigningIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get setupSigningIn;

  /// No description provided for @setupRestoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restore your vault from an encrypted OpenKey backup (.okbak).'**
  String get setupRestoreSubtitle;

  /// No description provided for @setupRestoreAction.
  ///
  /// In en, this message translates to:
  /// **'Restore vault'**
  String get setupRestoreAction;

  /// No description provided for @setupRestoreChooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose backup file'**
  String get setupRestoreChooseFile;

  /// No description provided for @setupRestoreChooseFileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select an encrypted .okbak file.'**
  String get setupRestoreChooseFileSubtitle;

  /// No description provided for @setupRestoreBackupAccount.
  ///
  /// In en, this message translates to:
  /// **'This backup is for {email}'**
  String setupRestoreBackupAccount(String email);

  /// No description provided for @setupRestoreNeedFile.
  ///
  /// In en, this message translates to:
  /// **'Choose a backup file first'**
  String get setupRestoreNeedFile;

  /// No description provided for @setupLinkSelfHostedTitle.
  ///
  /// In en, this message translates to:
  /// **'Link self-hosted server'**
  String get setupLinkSelfHostedTitle;

  /// No description provided for @setupLinkSelfHostedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional. Register this vault for sync across devices.'**
  String get setupLinkSelfHostedSubtitle;

  /// No description provided for @setupLinkServerHelper.
  ///
  /// In en, this message translates to:
  /// **'Your vault will be registered on this server after creation.'**
  String get setupLinkServerHelper;

  /// No description provided for @setupSignInServerHelper.
  ///
  /// In en, this message translates to:
  /// **'URL of the OpenKey server that already has your account.'**
  String get setupSignInServerHelper;

  /// No description provided for @setupChooserTitle.
  ///
  /// In en, this message translates to:
  /// **'How do you want to start?'**
  String get setupChooserTitle;

  /// No description provided for @setupChooserSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a vault, sign in, or restore a backup.'**
  String get setupChooserSubtitle;

  /// No description provided for @setupChooseCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a vault'**
  String get setupChooseCreateTitle;

  /// No description provided for @setupChooseCreateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'New encrypted vault on this device.'**
  String get setupChooseCreateSubtitle;

  /// No description provided for @setupChooseSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get setupChooseSignInTitle;

  /// No description provided for @setupChooseSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from your self-hosted OpenKey server.'**
  String get setupChooseSignInSubtitle;

  /// No description provided for @setupChooseRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get setupChooseRestoreTitle;

  /// No description provided for @setupChooseRestoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open an encrypted .okbak file.'**
  String get setupChooseRestoreSubtitle;

  /// No description provided for @invalidServerUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid URL starting with http:// or https://'**
  String get invalidServerUrl;

  /// No description provided for @confirmMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm master password'**
  String get confirmMasterPassword;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get invalidEmail;

  /// No description provided for @invalidEmailFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmailFormat;

  /// No description provided for @invalidUrlFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL. Use a format like https://example.com'**
  String get invalidUrlFormat;

  /// No description provided for @invalidPhoneFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhoneFormat;

  /// No description provided for @invalidPinFormat.
  ///
  /// In en, this message translates to:
  /// **'PIN must be 4–12 digits'**
  String get invalidPinFormat;

  /// No description provided for @invalidNumberFormat.
  ///
  /// In en, this message translates to:
  /// **'Enter digits only'**
  String get invalidNumberFormat;

  /// No description provided for @invalidCardFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid card number'**
  String get invalidCardFormat;

  /// No description provided for @invalidIpFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid IP address'**
  String get invalidIpFormat;

  /// No description provided for @invalidWalletFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid wallet address'**
  String get invalidWalletFormat;

  /// No description provided for @invalidRecoveryCodesFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid recovery codes'**
  String get invalidRecoveryCodesFormat;

  /// No description provided for @fixFieldErrors.
  ///
  /// In en, this message translates to:
  /// **'Fix the highlighted fields before saving'**
  String get fixFieldErrors;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordTooShortStrong.
  ///
  /// In en, this message translates to:
  /// **'At least 12 characters'**
  String get passwordTooShortStrong;

  /// No description provided for @passwordTooWeak.
  ///
  /// In en, this message translates to:
  /// **'Use a longer mix of letters, numbers, and symbols'**
  String get passwordTooWeak;

  /// No description provided for @masterPasswordHelper.
  ///
  /// In en, this message translates to:
  /// **'12+ characters with mixed types recommended'**
  String get masterPasswordHelper;

  /// No description provided for @passwordHintOptional.
  ///
  /// In en, this message translates to:
  /// **'Password hint (optional)'**
  String get passwordHintOptional;

  /// No description provided for @passwordHintHelper.
  ///
  /// In en, this message translates to:
  /// **'A vague reminder only — never include the password itself'**
  String get passwordHintHelper;

  /// No description provided for @passwordHintReveal.
  ///
  /// In en, this message translates to:
  /// **'Hint: {hint}'**
  String passwordHintReveal(String hint);

  /// No description provided for @setupZeroKnowledgeBanner.
  ///
  /// In en, this message translates to:
  /// **'Zero-knowledge encryption: OpenKey cannot read or reset your vault.'**
  String get setupZeroKnowledgeBanner;

  /// No description provided for @vaultNoticesTitle.
  ///
  /// In en, this message translates to:
  /// **'Before you create your vault'**
  String get vaultNoticesTitle;

  /// No description provided for @vaultNoticesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please acknowledge these points to continue.'**
  String get vaultNoticesSubtitle;

  /// No description provided for @vaultNoticeNoRecovery.
  ///
  /// In en, this message translates to:
  /// **'If you forget your master password, your data cannot be recovered.'**
  String get vaultNoticeNoRecovery;

  /// No description provided for @vaultNoticeLocalEncryption.
  ///
  /// In en, this message translates to:
  /// **'Your vault is encrypted on this device; your master password never leaves it in plaintext.'**
  String get vaultNoticeLocalEncryption;

  /// No description provided for @vaultNoticeBackups.
  ///
  /// In en, this message translates to:
  /// **'Regular encrypted backups are the only way to protect against device loss.'**
  String get vaultNoticeBackups;

  /// No description provided for @vaultNoticeDeviceTransfer.
  ///
  /// In en, this message translates to:
  /// **'Moving to a new device requires a backup restore or optional server sync.'**
  String get vaultNoticeDeviceTransfer;

  /// No description provided for @acceptAllNotices.
  ///
  /// In en, this message translates to:
  /// **'Accept all'**
  String get acceptAllNotices;

  /// No description provided for @server.
  ///
  /// In en, this message translates to:
  /// **'Self-hosted server'**
  String get server;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get notConnected;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data & sharing'**
  String get data;

  /// No description provided for @dataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Server, backup, import/export, and sharing'**
  String get dataSubtitle;

  /// No description provided for @importExport.
  ///
  /// In en, this message translates to:
  /// **'Import & export'**
  String get importExport;

  /// No description provided for @importExportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Move passwords in or out of your vault'**
  String get importExportSubtitle;

  /// No description provided for @importTab.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importTab;

  /// No description provided for @exportTab.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportTab;

  /// No description provided for @importPasswords.
  ///
  /// In en, this message translates to:
  /// **'Import passwords'**
  String get importPasswords;

  /// No description provided for @importPasswordsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Entries are encrypted with your vault key on this device.'**
  String get importPasswordsSubtitle;

  /// No description provided for @exportPasswords.
  ///
  /// In en, this message translates to:
  /// **'Export passwords'**
  String get exportPasswords;

  /// No description provided for @exportPasswordsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Decrypts entries on this device and saves an export file.'**
  String get exportPasswordsSubtitle;

  /// No description provided for @exportingPasswords.
  ///
  /// In en, this message translates to:
  /// **'Exporting…'**
  String get exportingPasswords;

  /// No description provided for @exportBitwardenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unencrypted Bitwarden JSON'**
  String get exportBitwardenSubtitle;

  /// No description provided for @exportChromeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'CSV compatible with Chrome'**
  String get exportChromeSubtitle;

  /// No description provided for @exportLastPassSubtitle.
  ///
  /// In en, this message translates to:
  /// **'CSV compatible with LastPass'**
  String get exportLastPassSubtitle;

  /// No description provided for @exportOnePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'CSV compatible with 1Password'**
  String get exportOnePasswordSubtitle;

  /// No description provided for @exportKeePassSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Encrypted KeePass / KeePassXC database (.kdbx)'**
  String get exportKeePassSubtitle;

  /// No description provided for @exportOpenKeySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unencrypted OpenKey JSON with folders and full entry data'**
  String get exportOpenKeySubtitle;

  /// No description provided for @exportedItems.
  ///
  /// In en, this message translates to:
  /// **'Vault exported'**
  String get exportedItems;

  /// No description provided for @exportedToPath.
  ///
  /// In en, this message translates to:
  /// **'Exported to {path}'**
  String exportedToPath(String path);

  /// No description provided for @changeMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'Change master password'**
  String get changeMasterPassword;

  /// No description provided for @changeMasterPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Re-wraps your vault key. Entries stay encrypted with the same vault key.'**
  String get changeMasterPasswordSubtitle;

  /// No description provided for @currentMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'Current master password'**
  String get currentMasterPassword;

  /// No description provided for @newMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'New master password'**
  String get newMasterPassword;

  /// No description provided for @masterPasswordUnchanged.
  ///
  /// In en, this message translates to:
  /// **'Choose a different password'**
  String get masterPasswordUnchanged;

  /// No description provided for @masterPasswordChanged.
  ///
  /// In en, this message translates to:
  /// **'Master password updated'**
  String get masterPasswordChanged;

  /// No description provided for @deleteServerAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete server account'**
  String get deleteServerAccount;

  /// No description provided for @deleteServerAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Removes your ciphertext from the server. This device keeps its local vault.'**
  String get deleteServerAccountSubtitle;

  /// No description provided for @deleteServerAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone. Synced data on the server will be permanently deleted.'**
  String get deleteServerAccountWarning;

  /// No description provided for @serverAccountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Server account deleted'**
  String get serverAccountDeleted;

  /// No description provided for @browserExtension.
  ///
  /// In en, this message translates to:
  /// **'Browser extension'**
  String get browserExtension;

  /// No description provided for @browserExtensionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect Chrome / Edge / Firefox to the unlocked vault'**
  String get browserExtensionSubtitle;

  /// No description provided for @browserExtensionSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Paste the unpacked Chrome extension ID from chrome://extensions (Developer mode). Firefox uses a fixed ID automatically.'**
  String get browserExtensionSheetSubtitle;

  /// No description provided for @chromeExtensionId.
  ///
  /// In en, this message translates to:
  /// **'Chrome extension ID'**
  String get chromeExtensionId;

  /// No description provided for @chromeExtensionIdHint.
  ///
  /// In en, this message translates to:
  /// **'Shown under the extension name on chrome://extensions'**
  String get chromeExtensionIdHint;

  /// No description provided for @connectBrowserExtension.
  ///
  /// In en, this message translates to:
  /// **'Connect extension'**
  String get connectBrowserExtension;

  /// No description provided for @copyOfflineExtensionLink.
  ///
  /// In en, this message translates to:
  /// **'Copy offline vault link'**
  String get copyOfflineExtensionLink;

  /// No description provided for @extensionLinkClipboardWarning.
  ///
  /// In en, this message translates to:
  /// **'This copies vault unlock material to the clipboard. Other apps can read it until you clear the clipboard or it auto-clears after one minute.'**
  String get extensionLinkClipboardWarning;

  /// No description provided for @browserExtensionHostReady.
  ///
  /// In en, this message translates to:
  /// **'Native host registered. Keep OpenKey unlocked, then tap “Use desktop app” in the extension.'**
  String get browserExtensionHostReady;

  /// No description provided for @browserExtensionHostHint.
  ///
  /// In en, this message translates to:
  /// **'Unlock the vault, paste the Chrome extension ID, then connect.'**
  String get browserExtensionHostHint;

  /// No description provided for @browserExtensionHostFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not register the native host. Unlock the vault and try again.'**
  String get browserExtensionHostFailed;

  /// No description provided for @cliTitle.
  ///
  /// In en, this message translates to:
  /// **'CLI'**
  String get cliTitle;

  /// No description provided for @cliSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Install the OpenKey CLI, then run the connect command while the vault is unlocked.'**
  String get cliSubtitle;

  /// No description provided for @cliTermuxTitle.
  ///
  /// In en, this message translates to:
  /// **'Termux / CLI'**
  String get cliTermuxTitle;

  /// No description provided for @cliTermuxSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Install the OpenKey CLI in Termux, then run the connect command while the vault is unlocked.'**
  String get cliTermuxSubtitle;

  /// No description provided for @cliTermuxInstall.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get cliTermuxInstall;

  /// No description provided for @cliTermuxConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get cliTermuxConnect;

  /// No description provided for @cliTermuxUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unlock the vault to show the connect command.'**
  String get cliTermuxUnavailable;

  /// No description provided for @aboutPrivacy.
  ///
  /// In en, this message translates to:
  /// **'OpenKey encrypts your passwords end-to-end. Your master password and vault key never leave this device.'**
  String get aboutPrivacy;

  /// No description provided for @localVault.
  ///
  /// In en, this message translates to:
  /// **'Local vault'**
  String get localVault;

  /// No description provided for @followDevice.
  ///
  /// In en, this message translates to:
  /// **'Follow device appearance'**
  String get followDevice;

  /// No description provided for @passwordGenerator.
  ///
  /// In en, this message translates to:
  /// **'Password generator'**
  String get passwordGenerator;

  /// No description provided for @generatedPassword.
  ///
  /// In en, this message translates to:
  /// **'Generated password'**
  String get generatedPassword;

  /// No description provided for @passwordLength.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get passwordLength;

  /// No description provided for @charactersLabel.
  ///
  /// In en, this message translates to:
  /// **'{n} characters'**
  String charactersLabel(int n);

  /// No description provided for @includeUppercase.
  ///
  /// In en, this message translates to:
  /// **'Uppercase letters'**
  String get includeUppercase;

  /// No description provided for @includeLowercase.
  ///
  /// In en, this message translates to:
  /// **'Lowercase letters'**
  String get includeLowercase;

  /// No description provided for @includeDigits.
  ///
  /// In en, this message translates to:
  /// **'Digits'**
  String get includeDigits;

  /// No description provided for @includeSymbols.
  ///
  /// In en, this message translates to:
  /// **'Symbols'**
  String get includeSymbols;

  /// No description provided for @avoidAmbiguous.
  ///
  /// In en, this message translates to:
  /// **'Avoid ambiguous characters'**
  String get avoidAmbiguous;

  /// No description provided for @avoidAmbiguousSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Exclude I, l, 1, O, 0, o, |'**
  String get avoidAmbiguousSubtitle;

  /// No description provided for @regenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerate;

  /// No description provided for @copyPassword.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyPassword;

  /// No description provided for @passwordCopied.
  ///
  /// In en, this message translates to:
  /// **'Password copied'**
  String get passwordCopied;

  /// No description provided for @passwordGeneratorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Generate a strong unique password'**
  String get passwordGeneratorSubtitle;

  /// No description provided for @usePassword.
  ///
  /// In en, this message translates to:
  /// **'Use password'**
  String get usePassword;

  /// No description provided for @generateOptions.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get generateOptions;

  /// No description provided for @characterSets.
  ///
  /// In en, this message translates to:
  /// **'Character sets'**
  String get characterSets;

  /// No description provided for @passwordStrengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get passwordStrengthWeak;

  /// No description provided for @passwordStrengthFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get passwordStrengthFair;

  /// No description provided for @passwordStrengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get passwordStrengthStrong;

  /// No description provided for @generatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Generator'**
  String get generatorTitle;

  /// No description provided for @generatorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create passwords, usernames, and emails'**
  String get generatorSubtitle;

  /// No description provided for @generatorModePassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get generatorModePassword;

  /// No description provided for @generatorModeUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get generatorModeUsername;

  /// No description provided for @generatorModeEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get generatorModeEmail;

  /// No description provided for @generatedUsername.
  ///
  /// In en, this message translates to:
  /// **'Generated username'**
  String get generatedUsername;

  /// No description provided for @generatedEmail.
  ///
  /// In en, this message translates to:
  /// **'Generated email'**
  String get generatedEmail;

  /// No description provided for @usernameStyle.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get usernameStyle;

  /// No description provided for @usernameStyleWords.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get usernameStyleWords;

  /// No description provided for @usernameStyleRandom.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get usernameStyleRandom;

  /// No description provided for @usernameCapitalize.
  ///
  /// In en, this message translates to:
  /// **'Capitalize'**
  String get usernameCapitalize;

  /// No description provided for @usernameIncludeDigits.
  ///
  /// In en, this message translates to:
  /// **'Add numbers'**
  String get usernameIncludeDigits;

  /// No description provided for @usernameSeparator.
  ///
  /// In en, this message translates to:
  /// **'Separator'**
  String get usernameSeparator;

  /// No description provided for @usernameSeparatorNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get usernameSeparatorNone;

  /// No description provided for @emailType.
  ///
  /// In en, this message translates to:
  /// **'Email type'**
  String get emailType;

  /// No description provided for @emailTypeRandom.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get emailTypeRandom;

  /// No description provided for @emailTypePlus.
  ///
  /// In en, this message translates to:
  /// **'Plus address'**
  String get emailTypePlus;

  /// No description provided for @emailDomain.
  ///
  /// In en, this message translates to:
  /// **'Domain'**
  String get emailDomain;

  /// No description provided for @emailDomainHint.
  ///
  /// In en, this message translates to:
  /// **'yourdomain.com'**
  String get emailDomainHint;

  /// No description provided for @emailPlusBase.
  ///
  /// In en, this message translates to:
  /// **'Your email'**
  String get emailPlusBase;

  /// No description provided for @emailPlusBaseHint.
  ///
  /// In en, this message translates to:
  /// **'you@gmail.com'**
  String get emailPlusBaseHint;

  /// No description provided for @emailPlusHelp.
  ///
  /// In en, this message translates to:
  /// **'Creates you+tag@gmail.com so you can filter signups in your inbox.'**
  String get emailPlusHelp;

  /// No description provided for @emailRandomHelp.
  ///
  /// In en, this message translates to:
  /// **'Creates a unique address on a domain you control, such as a catch-all.'**
  String get emailRandomHelp;

  /// No description provided for @passwordDetails.
  ///
  /// In en, this message translates to:
  /// **'Password details'**
  String get passwordDetails;

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// No description provided for @credentials.
  ///
  /// In en, this message translates to:
  /// **'Credentials'**
  String get credentials;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @authenticator.
  ///
  /// In en, this message translates to:
  /// **'Authenticator'**
  String get authenticator;

  /// No description provided for @passkey.
  ///
  /// In en, this message translates to:
  /// **'Passkey'**
  String get passkey;

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// No description provided for @downloadAttachment.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get downloadAttachment;

  /// No description provided for @previewAttachment.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewAttachment;

  /// No description provided for @openAttachment.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openAttachment;

  /// No description provided for @playVideo.
  ///
  /// In en, this message translates to:
  /// **'Play video'**
  String get playVideo;

  /// No description provided for @pausePlayback.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pausePlayback;

  /// No description provided for @openingAttachment.
  ///
  /// In en, this message translates to:
  /// **'Opening attachment…'**
  String get openingAttachment;

  /// No description provided for @attachmentSaved.
  ///
  /// In en, this message translates to:
  /// **'{name} saved'**
  String attachmentSaved(String name);

  /// No description provided for @couldNotOpenAttachment.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open this attachment.'**
  String get couldNotOpenAttachment;

  /// No description provided for @attachmentNotPreviewable.
  ///
  /// In en, this message translates to:
  /// **'Preview isn\'t available for this file type. You can download it instead.'**
  String get attachmentNotPreviewable;

  /// No description provided for @copyUsername.
  ///
  /// In en, this message translates to:
  /// **'Copy username'**
  String get copyUsername;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @tapToCopy.
  ///
  /// In en, this message translates to:
  /// **'Tap to copy'**
  String get tapToCopy;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete entry?'**
  String get deleteEntry;

  /// No description provided for @deleteEntryConfirm.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes the password from your vault.'**
  String get deleteEntryConfirm;

  /// No description provided for @entryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Entry not found'**
  String get entryNotFound;

  /// No description provided for @entryNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This password may have been deleted.'**
  String get entryNotFoundMessage;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @synced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get synced;

  /// No description provided for @pendingSync.
  ///
  /// In en, this message translates to:
  /// **'Pending sync'**
  String get pendingSync;

  /// No description provided for @revisionLabel.
  ///
  /// In en, this message translates to:
  /// **'Revision {n}'**
  String revisionLabel(int n);

  /// No description provided for @valueCopied.
  ///
  /// In en, this message translates to:
  /// **'{label} copied'**
  String valueCopied(String label);

  /// No description provided for @vault.
  ///
  /// In en, this message translates to:
  /// **'Vault'**
  String get vault;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @itemsHubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cards, crypto wallets, and secrets.'**
  String get itemsHubSubtitle;

  /// No description provided for @itemsCardsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Payment cards and billing details'**
  String get itemsCardsSubtitle;

  /// No description provided for @itemsCryptoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Addresses, keys, and seed phrases'**
  String get itemsCryptoSubtitle;

  /// No description provided for @itemsSecretsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'SSH keys, API tokens, and .env snippets'**
  String get itemsSecretsSubtitle;

  /// No description provided for @itemsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} saved'**
  String itemsCountLabel(int count);

  /// No description provided for @wallets.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get wallets;

  /// No description provided for @searchCards.
  ///
  /// In en, this message translates to:
  /// **'Search cards'**
  String get searchCards;

  /// No description provided for @noCardsYet.
  ///
  /// In en, this message translates to:
  /// **'No cards yet'**
  String get noCardsYet;

  /// No description provided for @noCardsYetMessage.
  ///
  /// In en, this message translates to:
  /// **'Add a card to store it securely.'**
  String get noCardsYetMessage;

  /// No description provided for @addCard.
  ///
  /// In en, this message translates to:
  /// **'Add card'**
  String get addCard;

  /// No description provided for @editCard.
  ///
  /// In en, this message translates to:
  /// **'Edit card'**
  String get editCard;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cardDetails.
  ///
  /// In en, this message translates to:
  /// **'Card details'**
  String get cardDetails;

  /// No description provided for @cardName.
  ///
  /// In en, this message translates to:
  /// **'Card name'**
  String get cardName;

  /// No description provided for @cardHolder.
  ///
  /// In en, this message translates to:
  /// **'Cardholder'**
  String get cardHolder;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card number'**
  String get cardNumber;

  /// No description provided for @cardExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry'**
  String get cardExpiry;

  /// No description provided for @cardCvc.
  ///
  /// In en, this message translates to:
  /// **'CVC'**
  String get cardCvc;

  /// No description provided for @copyNumber.
  ///
  /// In en, this message translates to:
  /// **'Copy number'**
  String get copyNumber;

  /// No description provided for @copyCvc.
  ///
  /// In en, this message translates to:
  /// **'Copy CVC'**
  String get copyCvc;

  /// No description provided for @tapCardToFlip.
  ///
  /// In en, this message translates to:
  /// **'Tap the card to flip'**
  String get tapCardToFlip;

  /// No description provided for @deleteCard.
  ///
  /// In en, this message translates to:
  /// **'Delete card?'**
  String get deleteCard;

  /// No description provided for @deleteCardConfirm.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes the card from your wallet.'**
  String get deleteCardConfirm;

  /// No description provided for @cardNotFound.
  ///
  /// In en, this message translates to:
  /// **'Card not found'**
  String get cardNotFound;

  /// No description provided for @cardNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This card may have been deleted.'**
  String get cardNotFoundMessage;

  /// No description provided for @bank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bank;

  /// No description provided for @banks.
  ///
  /// In en, this message translates to:
  /// **'Banks'**
  String get banks;

  /// No description provided for @otherBank.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherBank;

  /// No description provided for @addBank.
  ///
  /// In en, this message translates to:
  /// **'Add bank'**
  String get addBank;

  /// No description provided for @newBank.
  ///
  /// In en, this message translates to:
  /// **'New bank'**
  String get newBank;

  /// No description provided for @bankName.
  ///
  /// In en, this message translates to:
  /// **'Bank name'**
  String get bankName;

  /// No description provided for @renameBank.
  ///
  /// In en, this message translates to:
  /// **'Rename bank'**
  String get renameBank;

  /// No description provided for @deleteBank.
  ///
  /// In en, this message translates to:
  /// **'Delete bank?'**
  String get deleteBank;

  /// No description provided for @deleteBankConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this bank group? Cards can be moved to Other.'**
  String get deleteBankConfirm;

  /// No description provided for @deleteBankAndClear.
  ///
  /// In en, this message translates to:
  /// **'Delete and unassign cards'**
  String get deleteBankAndClear;

  /// No description provided for @moveToBank.
  ///
  /// In en, this message translates to:
  /// **'Move to bank'**
  String get moveToBank;

  /// No description provided for @noBanksYet.
  ///
  /// In en, this message translates to:
  /// **'No banks yet'**
  String get noBanksYet;

  /// No description provided for @createBankHint.
  ///
  /// In en, this message translates to:
  /// **'Create a bank to organize your payment cards.'**
  String get createBankHint;

  /// No description provided for @bankCreated.
  ///
  /// In en, this message translates to:
  /// **'Bank created'**
  String get bankCreated;

  /// No description provided for @cardMoved.
  ///
  /// In en, this message translates to:
  /// **'Card moved'**
  String get cardMoved;

  /// No description provided for @emptyBank.
  ///
  /// In en, this message translates to:
  /// **'No cards in this bank'**
  String get emptyBank;

  /// No description provided for @paymentCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get paymentCards;

  /// No description provided for @cryptoWallets.
  ///
  /// In en, this message translates to:
  /// **'Crypto'**
  String get cryptoWallets;

  /// No description provided for @searchCryptoWallets.
  ///
  /// In en, this message translates to:
  /// **'Search crypto wallets'**
  String get searchCryptoWallets;

  /// No description provided for @noCryptoWalletsYet.
  ///
  /// In en, this message translates to:
  /// **'No crypto wallets yet'**
  String get noCryptoWalletsYet;

  /// No description provided for @noCryptoWalletsYetMessage.
  ///
  /// In en, this message translates to:
  /// **'Add a wallet to store keys securely.'**
  String get noCryptoWalletsYetMessage;

  /// No description provided for @addCryptoWallet.
  ///
  /// In en, this message translates to:
  /// **'Add crypto wallet'**
  String get addCryptoWallet;

  /// No description provided for @editCryptoWallet.
  ///
  /// In en, this message translates to:
  /// **'Edit crypto wallet'**
  String get editCryptoWallet;

  /// No description provided for @cryptoNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get cryptoNetwork;

  /// No description provided for @cryptoWalletName.
  ///
  /// In en, this message translates to:
  /// **'Wallet name'**
  String get cryptoWalletName;

  /// No description provided for @walletAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get walletAddress;

  /// No description provided for @privateKey.
  ///
  /// In en, this message translates to:
  /// **'Private key'**
  String get privateKey;

  /// No description provided for @seedPhrase.
  ///
  /// In en, this message translates to:
  /// **'Seed phrase'**
  String get seedPhrase;

  /// No description provided for @cryptoDetails.
  ///
  /// In en, this message translates to:
  /// **'Wallet details'**
  String get cryptoDetails;

  /// No description provided for @copyAddress.
  ///
  /// In en, this message translates to:
  /// **'Copy address'**
  String get copyAddress;

  /// No description provided for @deleteCryptoWallet.
  ///
  /// In en, this message translates to:
  /// **'Delete crypto wallet?'**
  String get deleteCryptoWallet;

  /// No description provided for @deleteCryptoWalletConfirm.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes the wallet and its secrets from your vault.'**
  String get deleteCryptoWalletConfirm;

  /// No description provided for @cryptoWalletNotFound.
  ///
  /// In en, this message translates to:
  /// **'Crypto wallet not found'**
  String get cryptoWalletNotFound;

  /// No description provided for @cryptoWalletNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This wallet may have been deleted.'**
  String get cryptoWalletNotFoundMessage;

  /// No description provided for @folders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get folders;

  /// No description provided for @otherFolder.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherFolder;

  /// No description provided for @addFolder.
  ///
  /// In en, this message translates to:
  /// **'Add folder'**
  String get addFolder;

  /// No description provided for @newFolder.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get newFolder;

  /// No description provided for @folderName.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get folderName;

  /// No description provided for @renameFolder.
  ///
  /// In en, this message translates to:
  /// **'Rename folder'**
  String get renameFolder;

  /// No description provided for @deleteFolder.
  ///
  /// In en, this message translates to:
  /// **'Delete folder?'**
  String get deleteFolder;

  /// No description provided for @deleteFolderConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this folder group? Wallets can be moved to Other.'**
  String get deleteFolderConfirm;

  /// No description provided for @deleteFolderAndClear.
  ///
  /// In en, this message translates to:
  /// **'Delete and unassign wallets'**
  String get deleteFolderAndClear;

  /// No description provided for @moveToFolder.
  ///
  /// In en, this message translates to:
  /// **'Move to folder'**
  String get moveToFolder;

  /// No description provided for @noFoldersYet.
  ///
  /// In en, this message translates to:
  /// **'No folders yet'**
  String get noFoldersYet;

  /// No description provided for @createFolderHint.
  ///
  /// In en, this message translates to:
  /// **'Create a folder to organize your crypto wallets.'**
  String get createFolderHint;

  /// No description provided for @folderCreated.
  ///
  /// In en, this message translates to:
  /// **'Folder created'**
  String get folderCreated;

  /// No description provided for @cryptoWalletMoved.
  ///
  /// In en, this message translates to:
  /// **'Wallet moved'**
  String get cryptoWalletMoved;

  /// No description provided for @emptyFolder.
  ///
  /// In en, this message translates to:
  /// **'No wallets in this folder'**
  String get emptyFolder;

  /// No description provided for @secrets.
  ///
  /// In en, this message translates to:
  /// **'Secrets'**
  String get secrets;

  /// No description provided for @searchSecrets.
  ///
  /// In en, this message translates to:
  /// **'Search secrets'**
  String get searchSecrets;

  /// No description provided for @noSecretsYet.
  ///
  /// In en, this message translates to:
  /// **'No secrets yet'**
  String get noSecretsYet;

  /// No description provided for @noSecretsYetMessage.
  ///
  /// In en, this message translates to:
  /// **'Store SSH keys, API tokens, and .env snippets securely.'**
  String get noSecretsYetMessage;

  /// No description provided for @addSecret.
  ///
  /// In en, this message translates to:
  /// **'Add secret'**
  String get addSecret;

  /// No description provided for @editSecret.
  ///
  /// In en, this message translates to:
  /// **'Edit secret'**
  String get editSecret;

  /// No description provided for @secretKind.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get secretKind;

  /// No description provided for @secretKindSsh.
  ///
  /// In en, this message translates to:
  /// **'SSH key'**
  String get secretKindSsh;

  /// No description provided for @secretKindApiToken.
  ///
  /// In en, this message translates to:
  /// **'API token'**
  String get secretKindApiToken;

  /// No description provided for @secretKindEnv.
  ///
  /// In en, this message translates to:
  /// **'.env snippet'**
  String get secretKindEnv;

  /// No description provided for @secretKindOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get secretKindOther;

  /// No description provided for @secretName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get secretName;

  /// No description provided for @secretUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get secretUsername;

  /// No description provided for @secretHost.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get secretHost;

  /// No description provided for @secretEndpoint.
  ///
  /// In en, this message translates to:
  /// **'Endpoint / URL'**
  String get secretEndpoint;

  /// No description provided for @publicKey.
  ///
  /// In en, this message translates to:
  /// **'Public key'**
  String get publicKey;

  /// No description provided for @apiToken.
  ///
  /// In en, this message translates to:
  /// **'API token'**
  String get apiToken;

  /// No description provided for @envContent.
  ///
  /// In en, this message translates to:
  /// **'.env content'**
  String get envContent;

  /// No description provided for @secretValue.
  ///
  /// In en, this message translates to:
  /// **'Secret'**
  String get secretValue;

  /// No description provided for @passphrase.
  ///
  /// In en, this message translates to:
  /// **'Passphrase'**
  String get passphrase;

  /// No description provided for @secretDetails.
  ///
  /// In en, this message translates to:
  /// **'Secret details'**
  String get secretDetails;

  /// No description provided for @copySecret.
  ///
  /// In en, this message translates to:
  /// **'Copy secret'**
  String get copySecret;

  /// No description provided for @deleteSecret.
  ///
  /// In en, this message translates to:
  /// **'Delete secret?'**
  String get deleteSecret;

  /// No description provided for @deleteSecretConfirm.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes the secret from your vault.'**
  String get deleteSecretConfirm;

  /// No description provided for @secretNotFound.
  ///
  /// In en, this message translates to:
  /// **'Secret not found'**
  String get secretNotFound;

  /// No description provided for @secretNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This secret may have been deleted.'**
  String get secretNotFoundMessage;

  /// No description provided for @reverseOrderSecretsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Display secrets in reverse order.'**
  String get reverseOrderSecretsSubtitle;

  /// No description provided for @device.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get device;

  /// No description provided for @devices.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get devices;

  /// No description provided for @otherDevice.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherDevice;

  /// No description provided for @addDevice.
  ///
  /// In en, this message translates to:
  /// **'Add device'**
  String get addDevice;

  /// No description provided for @newDevice.
  ///
  /// In en, this message translates to:
  /// **'New device'**
  String get newDevice;

  /// No description provided for @deviceName.
  ///
  /// In en, this message translates to:
  /// **'Device name'**
  String get deviceName;

  /// No description provided for @renameDevice.
  ///
  /// In en, this message translates to:
  /// **'Rename device'**
  String get renameDevice;

  /// No description provided for @deleteDevice.
  ///
  /// In en, this message translates to:
  /// **'Delete device?'**
  String get deleteDevice;

  /// No description provided for @deleteDeviceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this device group? Secrets can be moved to Other.'**
  String get deleteDeviceConfirm;

  /// No description provided for @deleteDeviceAndClear.
  ///
  /// In en, this message translates to:
  /// **'Delete and unassign secrets'**
  String get deleteDeviceAndClear;

  /// No description provided for @moveToDevice.
  ///
  /// In en, this message translates to:
  /// **'Move to device'**
  String get moveToDevice;

  /// No description provided for @noDevicesYet.
  ///
  /// In en, this message translates to:
  /// **'No devices yet'**
  String get noDevicesYet;

  /// No description provided for @createDeviceHint.
  ///
  /// In en, this message translates to:
  /// **'Create a device to organize secrets from each machine.'**
  String get createDeviceHint;

  /// No description provided for @deviceCreated.
  ///
  /// In en, this message translates to:
  /// **'Device created'**
  String get deviceCreated;

  /// No description provided for @secretMoved.
  ///
  /// In en, this message translates to:
  /// **'Secret moved'**
  String get secretMoved;

  /// No description provided for @emptyDevice.
  ///
  /// In en, this message translates to:
  /// **'No secrets on this device'**
  String get emptyDevice;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get faq;

  /// No description provided for @faqSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Encryption, unlock, sync, backups, and more'**
  String get faqSubtitle;

  /// No description provided for @faqEncryptionQ.
  ///
  /// In en, this message translates to:
  /// **'Is my data encrypted?'**
  String get faqEncryptionQ;

  /// No description provided for @faqEncryptionA.
  ///
  /// In en, this message translates to:
  /// **'Yes. OpenKey encrypts your vault end-to-end on this device. Your master password and vault key never leave the device in plaintext.'**
  String get faqEncryptionA;

  /// No description provided for @faqForgotPasswordQ.
  ///
  /// In en, this message translates to:
  /// **'What if I forget my master password?'**
  String get faqForgotPasswordQ;

  /// No description provided for @faqForgotPasswordA.
  ///
  /// In en, this message translates to:
  /// **'There is no recovery without your master password. Because encryption is zero-knowledge, OpenKey cannot reset it. Keep a secure backup of your password.'**
  String get faqForgotPasswordA;

  /// No description provided for @faqOfflineQ.
  ///
  /// In en, this message translates to:
  /// **'Does OpenKey work offline?'**
  String get faqOfflineQ;

  /// No description provided for @faqOfflineA.
  ///
  /// In en, this message translates to:
  /// **'Yes. Your vault is stored locally and unlocks without a network connection. An optional server is only needed for sync and sharing.'**
  String get faqOfflineA;

  /// No description provided for @faqAutoLockQ.
  ///
  /// In en, this message translates to:
  /// **'How does auto-lock work?'**
  String get faqAutoLockQ;

  /// No description provided for @faqAutoLockA.
  ///
  /// In en, this message translates to:
  /// **'When you leave the app without closing it, OpenKey counts how long you were away. After the time you choose in Settings, the vault locks and you’ll need your master password or biometrics to unlock again. Closing the app ends the session immediately.'**
  String get faqAutoLockA;

  /// No description provided for @faqBiometricQ.
  ///
  /// In en, this message translates to:
  /// **'Is biometric unlock safe?'**
  String get faqBiometricQ;

  /// No description provided for @faqBiometricA.
  ///
  /// In en, this message translates to:
  /// **'Yes. Biometrics unlock a key stored in the device secure hardware. Your master password is never replaced — you can still unlock with it anytime.'**
  String get faqBiometricA;

  /// No description provided for @faqSyncQ.
  ///
  /// In en, this message translates to:
  /// **'What is self-hosted sync?'**
  String get faqSyncQ;

  /// No description provided for @faqSyncA.
  ///
  /// In en, this message translates to:
  /// **'You can run your own OpenKey server. Devices send encrypted vault data so they stay in sync remotely. The server stores ciphertext only and never sees plaintext secrets. Your master password stays on each device.'**
  String get faqSyncA;

  /// No description provided for @faqBackupQ.
  ///
  /// In en, this message translates to:
  /// **'How does Backup & Restore work?'**
  String get faqBackupQ;

  /// No description provided for @faqBackupA.
  ///
  /// In en, this message translates to:
  /// **'In Settings → Backup & Restore you can save a full vault copy to this device. OpenKey packs the database, app settings, and attachments into a compressed file, then encrypts it with your vault key (.okbak). Nobody can read the file without your master password. Restore decrypts that file and replaces the local vault with the backup — so keep the password and the .okbak file somewhere safe.'**
  String get faqBackupA;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'OpenKey'**
  String get appName;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @lock.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get lock;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @entry.
  ///
  /// In en, this message translates to:
  /// **'Entry'**
  String get entry;

  /// No description provided for @collection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get collection;

  /// No description provided for @searchPasswords.
  ///
  /// In en, this message translates to:
  /// **'Search passwords'**
  String get searchPasswords;

  /// No description provided for @noPasswordsYet.
  ///
  /// In en, this message translates to:
  /// **'No passwords yet'**
  String get noPasswordsYet;

  /// No description provided for @noPasswordsYetMessage.
  ///
  /// In en, this message translates to:
  /// **'Add an entry or create a collection.'**
  String get noPasswordsYetMessage;

  /// No description provided for @newCollection.
  ///
  /// In en, this message translates to:
  /// **'New collection'**
  String get newCollection;

  /// No description provided for @newEntry.
  ///
  /// In en, this message translates to:
  /// **'New entry'**
  String get newEntry;

  /// No description provided for @editEntry.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get editEntry;

  /// No description provided for @chooseFields.
  ///
  /// In en, this message translates to:
  /// **'Fields'**
  String get chooseFields;

  /// No description provided for @chooseFieldsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Toggle fields on or off, then drag to reorder'**
  String get chooseFieldsSubtitle;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get pin;

  /// No description provided for @number.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get number;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @ipAddress.
  ///
  /// In en, this message translates to:
  /// **'IP address'**
  String get ipAddress;

  /// No description provided for @dateYmd.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateYmd;

  /// No description provided for @dateYm.
  ///
  /// In en, this message translates to:
  /// **'Month / year'**
  String get dateYm;

  /// No description provided for @recoveryCodes.
  ///
  /// In en, this message translates to:
  /// **'Recovery codes'**
  String get recoveryCodes;

  /// No description provided for @customText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get customText;

  /// No description provided for @additionalFields.
  ///
  /// In en, this message translates to:
  /// **'Additional fields'**
  String get additionalFields;

  /// No description provided for @emptyCollection.
  ///
  /// In en, this message translates to:
  /// **'Empty collection'**
  String get emptyCollection;

  /// No description provided for @emptyCollectionMessage.
  ///
  /// In en, this message translates to:
  /// **'Add a password entry to this collection.'**
  String get emptyCollectionMessage;

  /// No description provided for @editCollection.
  ///
  /// In en, this message translates to:
  /// **'Edit collection'**
  String get editCollection;

  /// No description provided for @deleteCollection.
  ///
  /// In en, this message translates to:
  /// **'Delete collection'**
  String get deleteCollection;

  /// No description provided for @deleteCollectionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Entries in this collection will be removed from the folder (not deleted). Continue?'**
  String get deleteCollectionConfirm;

  /// No description provided for @chooseIcon.
  ///
  /// In en, this message translates to:
  /// **'Choose icon'**
  String get chooseIcon;

  /// No description provided for @icons.
  ///
  /// In en, this message translates to:
  /// **'Icons'**
  String get icons;

  /// No description provided for @brands.
  ///
  /// In en, this message translates to:
  /// **'Brands'**
  String get brands;

  /// No description provided for @suggestedIcon.
  ///
  /// In en, this message translates to:
  /// **'Suggested icon'**
  String get suggestedIcon;

  /// No description provided for @fromDevice.
  ///
  /// In en, this message translates to:
  /// **'From device'**
  String get fromDevice;

  /// No description provided for @customIcon.
  ///
  /// In en, this message translates to:
  /// **'Custom icon'**
  String get customIcon;

  /// No description provided for @editIcon.
  ///
  /// In en, this message translates to:
  /// **'Edit icon'**
  String get editIcon;

  /// No description provided for @cropOrRotate.
  ///
  /// In en, this message translates to:
  /// **'Crop / Rotate'**
  String get cropOrRotate;

  /// No description provided for @rotate.
  ///
  /// In en, this message translates to:
  /// **'Rotate'**
  String get rotate;

  /// No description provided for @flip.
  ///
  /// In en, this message translates to:
  /// **'Flip'**
  String get flip;

  /// No description provided for @ratio.
  ///
  /// In en, this message translates to:
  /// **'Ratio'**
  String get ratio;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @blur.
  ///
  /// In en, this message translates to:
  /// **'Blur'**
  String get blur;

  /// No description provided for @discardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChanges;

  /// No description provided for @discardChangesMessage.
  ///
  /// In en, this message translates to:
  /// **'Your edits will be lost.'**
  String get discardChangesMessage;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @redo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @preparingImage.
  ///
  /// In en, this message translates to:
  /// **'Preparing image…'**
  String get preparingImage;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @noFolder.
  ///
  /// In en, this message translates to:
  /// **'No folder'**
  String get noFolder;

  /// No description provided for @folder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get folder;

  /// No description provided for @entriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} entries'**
  String entriesCount(int count);

  /// No description provided for @moveTo.
  ///
  /// In en, this message translates to:
  /// **'Move to'**
  String get moveTo;

  /// No description provided for @moveHere.
  ///
  /// In en, this message translates to:
  /// **'Move here'**
  String get moveHere;

  /// No description provided for @movingLabel.
  ///
  /// In en, this message translates to:
  /// **'Moving'**
  String get movingLabel;

  /// No description provided for @movingItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String movingItemsCount(int count);

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @noTags.
  ///
  /// In en, this message translates to:
  /// **'No tags yet'**
  String get noTags;

  /// No description provided for @noTagsMessage.
  ///
  /// In en, this message translates to:
  /// **'Add tags when editing a password entry.'**
  String get noTagsMessage;

  /// No description provided for @sortAndFilter.
  ///
  /// In en, this message translates to:
  /// **'Sort & Filter'**
  String get sortAndFilter;

  /// No description provided for @applyToFolders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get applyToFolders;

  /// No description provided for @applyToEntries.
  ///
  /// In en, this message translates to:
  /// **'Passwords'**
  String get applyToEntries;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @sortByCreationTime.
  ///
  /// In en, this message translates to:
  /// **'Sort by creation time'**
  String get sortByCreationTime;

  /// No description provided for @sortByLastModified.
  ///
  /// In en, this message translates to:
  /// **'Sort by last modified'**
  String get sortByLastModified;

  /// No description provided for @sortByName.
  ///
  /// In en, this message translates to:
  /// **'Sort by name'**
  String get sortByName;

  /// No description provided for @sortByCustomOrder.
  ///
  /// In en, this message translates to:
  /// **'Custom order'**
  String get sortByCustomOrder;

  /// No description provided for @reverseOrder.
  ///
  /// In en, this message translates to:
  /// **'Reverse order'**
  String get reverseOrder;

  /// No description provided for @reverseOrderFoldersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Display folders in reverse order.'**
  String get reverseOrderFoldersSubtitle;

  /// No description provided for @reverseOrderEntriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Display passwords in reverse order.'**
  String get reverseOrderEntriesSubtitle;

  /// No description provided for @reverseOrderCardsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Display cards in reverse order.'**
  String get reverseOrderCardsSubtitle;

  /// No description provided for @reverseOrderCryptoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Display wallets in reverse order.'**
  String get reverseOrderCryptoSubtitle;

  /// No description provided for @addTagHint.
  ///
  /// In en, this message translates to:
  /// **'Add a tag'**
  String get addTagHint;

  /// No description provided for @deleteSelectedConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} selected items?'**
  String deleteSelectedConfirm(int count);

  /// No description provided for @totpSecretLabel.
  ///
  /// In en, this message translates to:
  /// **'TOTP secret / otpauth'**
  String get totpSecretLabel;

  /// No description provided for @scanTotpQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get scanTotpQr;

  /// No description provided for @scanTotpQrHint.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the authenticator QR code'**
  String get scanTotpQrHint;

  /// No description provided for @invalidTotpQr.
  ///
  /// In en, this message translates to:
  /// **'This QR code is not a valid TOTP authenticator code'**
  String get invalidTotpQr;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to scan QR codes'**
  String get cameraPermissionDenied;

  /// No description provided for @storePasskeyMetadata.
  ///
  /// In en, this message translates to:
  /// **'Passkey'**
  String get storePasskeyMetadata;

  /// No description provided for @passkeyCreatedInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Create passkeys with the OpenKey browser extension or via system Autofill / Credential Provider on mobile when OpenKey is unlocked.'**
  String get passkeyCreatedInBrowser;

  /// No description provided for @rpId.
  ///
  /// In en, this message translates to:
  /// **'RP ID'**
  String get rpId;

  /// No description provided for @credentialId.
  ///
  /// In en, this message translates to:
  /// **'Credential ID'**
  String get credentialId;

  /// No description provided for @addPasskeyItem.
  ///
  /// In en, this message translates to:
  /// **'No passkey yet'**
  String get addPasskeyItem;

  /// No description provided for @bytesLabel.
  ///
  /// In en, this message translates to:
  /// **'{n} bytes'**
  String bytesLabel(int n);

  /// No description provided for @addEncryptedAttachment.
  ///
  /// In en, this message translates to:
  /// **'Add encrypted attachment'**
  String get addEncryptedAttachment;

  /// No description provided for @expiryHint.
  ///
  /// In en, this message translates to:
  /// **'MM/YY'**
  String get expiryHint;

  /// No description provided for @autoLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Lock the vault after you leave the app.'**
  String get autoLockSubtitle;

  /// No description provided for @serverUrl.
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get serverUrl;

  /// No description provided for @serverUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://openkey.example.com'**
  String get serverUrlHint;

  /// No description provided for @serverSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Register or log in to sync encrypted vault ciphertext only.'**
  String get serverSheetSubtitle;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account on this server'**
  String get registerSubtitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with this vault auth hash'**
  String get loginSubtitle;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncing;

  /// No description provided for @syncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Push and pull encrypted changes'**
  String get syncSubtitle;

  /// No description provided for @syncComplete.
  ///
  /// In en, this message translates to:
  /// **'Sync complete'**
  String get syncComplete;

  /// No description provided for @extensionLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Extension link payload copied'**
  String get extensionLinkCopied;

  /// No description provided for @biometricUnlockEnabled.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock enabled'**
  String get biometricUnlockEnabled;

  /// No description provided for @biometricUnlockDisabled.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock disabled'**
  String get biometricUnlockDisabled;

  /// No description provided for @biometricsUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update biometrics: {error}'**
  String biometricsUpdateFailed(String error);

  /// No description provided for @bitwardenJson.
  ///
  /// In en, this message translates to:
  /// **'Bitwarden JSON'**
  String get bitwardenJson;

  /// No description provided for @bitwardenJsonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export from Bitwarden → import here'**
  String get bitwardenJsonSubtitle;

  /// No description provided for @openKeyJson.
  ///
  /// In en, this message translates to:
  /// **'OpenKey JSON'**
  String get openKeyJson;

  /// No description provided for @openKeyJsonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Backup exported from OpenKey'**
  String get openKeyJsonSubtitle;

  /// No description provided for @chromeCsv.
  ///
  /// In en, this message translates to:
  /// **'Chrome CSV'**
  String get chromeCsv;

  /// No description provided for @chromeCsvSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Passwords exported from Chrome'**
  String get chromeCsvSubtitle;

  /// No description provided for @lastPassCsv.
  ///
  /// In en, this message translates to:
  /// **'LastPass CSV'**
  String get lastPassCsv;

  /// No description provided for @lastPassCsvSubtitle.
  ///
  /// In en, this message translates to:
  /// **'CSV export from LastPass'**
  String get lastPassCsvSubtitle;

  /// No description provided for @keePassKdbx.
  ///
  /// In en, this message translates to:
  /// **'KeePass (.kdbx)'**
  String get keePassKdbx;

  /// No description provided for @keePassKdbxSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Encrypted KeePass / KeePassXC database'**
  String get keePassKdbxSubtitle;

  /// No description provided for @keePassPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Database password'**
  String get keePassPasswordHint;

  /// No description provided for @keePassKeyFile.
  ///
  /// In en, this message translates to:
  /// **'Key file (optional)'**
  String get keePassKeyFile;

  /// No description provided for @keePassUnlockFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the KeePass database. Check the password and key file.'**
  String get keePassUnlockFailed;

  /// No description provided for @onePasswordCsv.
  ///
  /// In en, this message translates to:
  /// **'1Password CSV'**
  String get onePasswordCsv;

  /// No description provided for @onePasswordCsvSubtitle.
  ///
  /// In en, this message translates to:
  /// **'CSV export from 1Password'**
  String get onePasswordCsvSubtitle;

  /// No description provided for @importingPasswords.
  ///
  /// In en, this message translates to:
  /// **'Importing…'**
  String get importingPasswords;

  /// No description provided for @importingProgress.
  ///
  /// In en, this message translates to:
  /// **'Importing {done} of {total}…'**
  String importingProgress(int done, int total);

  /// No description provided for @importedItems.
  ///
  /// In en, this message translates to:
  /// **'Imported {n} items'**
  String importedItems(int n);

  /// No description provided for @failureUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get failureUnknown;

  /// No description provided for @failureNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection.'**
  String get failureNetwork;

  /// No description provided for @failureUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized. Please sign in again.'**
  String get failureUnauthorized;

  /// No description provided for @failureNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found.'**
  String get failureNotFound;

  /// No description provided for @failureServer.
  ///
  /// In en, this message translates to:
  /// **'Server error.'**
  String get failureServer;

  /// No description provided for @failureInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or master password.'**
  String get failureInvalidCredentials;

  /// No description provided for @failureVaultLocked.
  ///
  /// In en, this message translates to:
  /// **'Vault is locked.'**
  String get failureVaultLocked;

  /// No description provided for @failureVaultAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'A vault already exists on this device.'**
  String get failureVaultAlreadyExists;

  /// No description provided for @failureDecryptionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not decrypt vault data.'**
  String get failureDecryptionFailed;

  /// No description provided for @failureSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed.'**
  String get failureSyncFailed;

  /// No description provided for @failureCreateCollection.
  ///
  /// In en, this message translates to:
  /// **'Failed to create collection.'**
  String get failureCreateCollection;

  /// No description provided for @failureUpdateCollection.
  ///
  /// In en, this message translates to:
  /// **'Failed to update collection.'**
  String get failureUpdateCollection;

  /// No description provided for @failureDeleteCollection.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete collection.'**
  String get failureDeleteCollection;

  /// No description provided for @failureGetCollections.
  ///
  /// In en, this message translates to:
  /// **'Failed to load collections.'**
  String get failureGetCollections;

  /// No description provided for @failureCreateEntry.
  ///
  /// In en, this message translates to:
  /// **'Failed to create entry.'**
  String get failureCreateEntry;

  /// No description provided for @failureUpdateEntry.
  ///
  /// In en, this message translates to:
  /// **'Failed to update entry.'**
  String get failureUpdateEntry;

  /// No description provided for @failureDeleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete entry.'**
  String get failureDeleteEntry;

  /// No description provided for @failureGetEntries.
  ///
  /// In en, this message translates to:
  /// **'Failed to load entries.'**
  String get failureGetEntries;

  /// No description provided for @failureNoVault.
  ///
  /// In en, this message translates to:
  /// **'No vault found. Create one first.'**
  String get failureNoVault;

  /// No description provided for @failureConnectServerFirst.
  ///
  /// In en, this message translates to:
  /// **'Connect to a server in Settings first.'**
  String get failureConnectServerFirst;

  /// No description provided for @failureAttachmentTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Attachment exceeds 20 MB limit.'**
  String get failureAttachmentTooLarge;

  /// No description provided for @failureAttachmentMissing.
  ///
  /// In en, this message translates to:
  /// **'Attachment ciphertext missing.'**
  String get failureAttachmentMissing;

  /// No description provided for @failureAccountEmailExists.
  ///
  /// In en, this message translates to:
  /// **'That email already has a vault on this device.'**
  String get failureAccountEmailExists;

  /// No description provided for @root.
  ///
  /// In en, this message translates to:
  /// **'Root'**
  String get root;

  /// No description provided for @selectedItems.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get selectedItems;

  /// No description provided for @authenticatorTotp.
  ///
  /// In en, this message translates to:
  /// **'Authenticator (TOTP)'**
  String get authenticatorTotp;

  /// No description provided for @openKeyPro.
  ///
  /// In en, this message translates to:
  /// **'OpenKey Pro'**
  String get openKeyPro;

  /// No description provided for @proSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock premium features and support OpenKey development.'**
  String get proSubtitle;

  /// No description provided for @premiumFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium feature'**
  String get premiumFeatureTitle;

  /// No description provided for @premiumFeatureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to unlock this premium feature.'**
  String get premiumFeatureSubtitle;

  /// No description provided for @premiumFeatureContent.
  ///
  /// In en, this message translates to:
  /// **'This is a premium feature. Subscribe to access it.'**
  String get premiumFeatureContent;

  /// No description provided for @premiumBadge.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get premiumBadge;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @upgradeNow.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now'**
  String get upgradeNow;

  /// No description provided for @oops.
  ///
  /// In en, this message translates to:
  /// **'Oops!'**
  String get oops;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @subscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscriptionTitle;

  /// No description provided for @subscriptionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a plan that works for you.'**
  String get subscriptionSubtitle;

  /// No description provided for @manageYourSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage your subscription'**
  String get manageYourSubscription;

  /// No description provided for @manageSubscriptionAction.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get manageSubscriptionAction;

  /// No description provided for @subIsActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Your subscription is active'**
  String get subIsActiveTitle;

  /// No description provided for @subIsNotActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Your subscription is inactive'**
  String get subIsNotActiveTitle;

  /// No description provided for @thanksForSubscribing.
  ///
  /// In en, this message translates to:
  /// **'Thanks for subscribing!'**
  String get thanksForSubscribing;

  /// No description provided for @subIsCancelled.
  ///
  /// In en, this message translates to:
  /// **'Your subscription is cancelled and will not renew.'**
  String get subIsCancelled;

  /// No description provided for @subIsPaused.
  ///
  /// In en, this message translates to:
  /// **'Your subscription is paused.'**
  String get subIsPaused;

  /// No description provided for @restorePurchase.
  ///
  /// In en, this message translates to:
  /// **'Restore purchase'**
  String get restorePurchase;

  /// No description provided for @viewPlansPaywall.
  ///
  /// In en, this message translates to:
  /// **'View subscription options'**
  String get viewPlansPaywall;

  /// No description provided for @openCustomerCenter.
  ///
  /// In en, this message translates to:
  /// **'Manage in Customer Center'**
  String get openCustomerCenter;

  /// No description provided for @subscriptionDesktopNote.
  ///
  /// In en, this message translates to:
  /// **'In-app purchases are available on Android, iOS, and macOS. On Windows and Linux, sign in with the same OpenKey account to unlock Pro after subscribing on a mobile or Mac device.'**
  String get subscriptionDesktopNote;

  /// No description provided for @subscriptionRefreshStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh subscription status'**
  String get subscriptionRefreshStatus;

  /// No description provided for @subscriptionNoInternetMsg.
  ///
  /// In en, this message translates to:
  /// **'There\'s a problem with your internet connection. Check your network and try again.'**
  String get subscriptionNoInternetMsg;

  /// No description provided for @subscriptionRegionBlockedMsg.
  ///
  /// In en, this message translates to:
  /// **'Subscription services aren\'t reachable in your region. Connect to a VPN and try again.'**
  String get subscriptionRegionBlockedMsg;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @lifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get lifetime;

  /// No description provided for @monthlySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-renew, cancel anytime'**
  String get monthlySubtitle;

  /// No description provided for @yearlySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-renew, best value, cancel anytime'**
  String get yearlySubtitle;

  /// No description provided for @lifetimeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One-time purchase, yours forever'**
  String get lifetimeSubtitle;

  /// No description provided for @monthlyPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'{price}/mo'**
  String monthlyPriceLabel(String price);

  /// No description provided for @yearlyPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'{price}/yr'**
  String yearlyPriceLabel(String price);

  /// No description provided for @lifetimePriceLabel.
  ///
  /// In en, this message translates to:
  /// **'{price}'**
  String lifetimePriceLabel(String price);

  /// No description provided for @monthlySubscribeLabel.
  ///
  /// In en, this message translates to:
  /// **'Subscribe for {price} / month'**
  String monthlySubscribeLabel(String price);

  /// No description provided for @yearlySubscribeLabel.
  ///
  /// In en, this message translates to:
  /// **'Subscribe for {price} / year'**
  String yearlySubscribeLabel(String price);

  /// No description provided for @lifetimeSubscribeLabel.
  ///
  /// In en, this message translates to:
  /// **'Buy lifetime for {price}'**
  String lifetimeSubscribeLabel(String price);

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'Best Value'**
  String get bestValue;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @onboardingFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'Know this before you start'**
  String get onboardingFaqTitle;

  /// No description provided for @onboardingFaqSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The questions people ask most about OpenKey. Tap any to expand — then create your vault.'**
  String get onboardingFaqSubtitle;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your keys. Your vault.'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'OpenKey keeps passwords, codes, and cards in one encrypted home — built for everyday use.'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingWelcomePhrase1.
  ///
  /// In en, this message translates to:
  /// **'Zero-knowledge by design'**
  String get onboardingWelcomePhrase1;

  /// No description provided for @onboardingWelcomePhrase2.
  ///
  /// In en, this message translates to:
  /// **'Autofill in one tap'**
  String get onboardingWelcomePhrase2;

  /// No description provided for @onboardingWelcomePhrase3.
  ///
  /// In en, this message translates to:
  /// **'Self-hosted when you want'**
  String get onboardingWelcomePhrase3;

  /// No description provided for @onboardingSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Nobody else can read it'**
  String get onboardingSecurityTitle;

  /// No description provided for @onboardingSecuritySubtitle.
  ///
  /// In en, this message translates to:
  /// **'End-to-end encryption means your master password never leaves this device. We store ciphertext only.'**
  String get onboardingSecuritySubtitle;

  /// No description provided for @onboardingAutofillTitle.
  ///
  /// In en, this message translates to:
  /// **'Fill once. Trust forever.'**
  String get onboardingAutofillTitle;

  /// No description provided for @onboardingAutofillSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in across apps and sites without hunting for passwords. Autofill makes OpenKey part of every day.'**
  String get onboardingAutofillSubtitle;

  /// No description provided for @onboardingAllInOneTitle.
  ///
  /// In en, this message translates to:
  /// **'One app. Whole vault.'**
  String get onboardingAllInOneTitle;

  /// No description provided for @onboardingAllInOneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Passwords, authenticator codes, payment cards, crypto wallets, and developer secrets — replace the clutter with a single trusted vault.'**
  String get onboardingAllInOneSubtitle;

  /// No description provided for @onboardingFeaturePasswords.
  ///
  /// In en, this message translates to:
  /// **'Passwords'**
  String get onboardingFeaturePasswords;

  /// No description provided for @onboardingFeatureCrypto.
  ///
  /// In en, this message translates to:
  /// **'Crypto'**
  String get onboardingFeatureCrypto;

  /// No description provided for @onboardingFeatureAutofill.
  ///
  /// In en, this message translates to:
  /// **'Autofill'**
  String get onboardingFeatureAutofill;

  /// No description provided for @onboardingFeatureSelfHost.
  ///
  /// In en, this message translates to:
  /// **'Self-host.'**
  String get onboardingFeatureSelfHost;

  /// No description provided for @onboardingFooterHint.
  ///
  /// In en, this message translates to:
  /// **'Takes under a minute. You can skip anytime.'**
  String get onboardingFooterHint;

  /// No description provided for @onboardingLetsGo.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Go!'**
  String get onboardingLetsGo;

  /// No description provided for @onboardingStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboardingStepOf(int current, int total);

  /// No description provided for @onboardingWelcomeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Welcome\nto OpenKey.'**
  String get onboardingWelcomeHeadline;

  /// No description provided for @onboardingWelcomeLead.
  ///
  /// In en, this message translates to:
  /// **'Let\'s set everything up for you'**
  String get onboardingWelcomeLead;

  /// No description provided for @onboardingEcosystemTitle.
  ///
  /// In en, this message translates to:
  /// **'Your\ncomplete\nvault.'**
  String get onboardingEcosystemTitle;

  /// No description provided for @onboardingEcosystemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Passwords, codes, and cards — encrypted and ready wherever you sign in.'**
  String get onboardingEcosystemSubtitle;

  /// No description provided for @onboardingStyleTitle.
  ///
  /// In en, this message translates to:
  /// **'Style it\nyour way.'**
  String get onboardingStyleTitle;

  /// No description provided for @onboardingEnableAutofillTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable\nAutofill.'**
  String get onboardingEnableAutofillTitle;

  /// No description provided for @onboardingAutofillCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Password Autofill'**
  String get onboardingAutofillCardTitle;

  /// No description provided for @onboardingAutofillCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill logins in apps and sites from your vault.'**
  String get onboardingAutofillCardSubtitle;

  /// No description provided for @onboardingAutofillGranted.
  ///
  /// In en, this message translates to:
  /// **'Autofill is ready'**
  String get onboardingAutofillGranted;

  /// No description provided for @onboardingFinishBadge.
  ///
  /// In en, this message translates to:
  /// **'Setup complete'**
  String get onboardingFinishBadge;

  /// No description provided for @onboardingFinishTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to\nlock in.'**
  String get onboardingFinishTitle;

  /// No description provided for @onboardingFinishSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a master password and start saving what matters — your vault is one step away.'**
  String get onboardingFinishSubtitle;

  /// No description provided for @onboardingCreateVault.
  ///
  /// In en, this message translates to:
  /// **'Create vault'**
  String get onboardingCreateVault;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data. Please try again.'**
  String get errorLoadingData;

  /// No description provided for @retryAgain.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryAgain;

  /// No description provided for @autoRenewLabel.
  ///
  /// In en, this message translates to:
  /// **'Auto-renewal'**
  String get autoRenewLabel;

  /// No description provided for @cancelledLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelledLabel;

  /// No description provided for @pausedLabel.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get pausedLabel;

  /// No description provided for @supportAppDevelopmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Support development'**
  String get supportAppDevelopmentTitle;

  /// No description provided for @supportAppDevelopmentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your subscription helps us keep improving OpenKey.'**
  String get supportAppDevelopmentSubtitle;

  /// No description provided for @limitEntriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Entry limit reached'**
  String get limitEntriesTitle;

  /// No description provided for @limitCollectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Collection limit reached'**
  String get limitCollectionsTitle;

  /// No description provided for @limitWalletsTitle.
  ///
  /// In en, this message translates to:
  /// **'Card limit reached'**
  String get limitWalletsTitle;

  /// No description provided for @limitCryptoWalletsTitle.
  ///
  /// In en, this message translates to:
  /// **'Crypto wallet limit reached'**
  String get limitCryptoWalletsTitle;

  /// No description provided for @limitSecretsTitle.
  ///
  /// In en, this message translates to:
  /// **'Secret limit reached'**
  String get limitSecretsTitle;

  /// No description provided for @limitReachedContent.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used {usage} out of {limit} {feature}. Upgrade to Pro for unlimited access.'**
  String limitReachedContent(int usage, int limit, String feature);

  /// No description provided for @limitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Free plan includes up to {limit} {feature}.'**
  String limitSubtitle(int limit, String feature);

  /// No description provided for @entries.
  ///
  /// In en, this message translates to:
  /// **'entries'**
  String get entries;

  /// No description provided for @collections.
  ///
  /// In en, this message translates to:
  /// **'collections'**
  String get collections;

  /// No description provided for @cards.
  ///
  /// In en, this message translates to:
  /// **'cards'**
  String get cards;

  /// No description provided for @cryptoWalletsFeature.
  ///
  /// In en, this message translates to:
  /// **'crypto wallets'**
  String get cryptoWalletsFeature;

  /// No description provided for @secretsFeature.
  ///
  /// In en, this message translates to:
  /// **'secrets'**
  String get secretsFeature;

  /// No description provided for @expiresOn.
  ///
  /// In en, this message translates to:
  /// **'Expires on {date}'**
  String expiresOn(String date);

  /// No description provided for @unlockUnlimitedEntriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited entries'**
  String get unlockUnlimitedEntriesTitle;

  /// No description provided for @unlockUnlimitedEntriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Store as many passwords and logins as you need.'**
  String get unlockUnlimitedEntriesSubtitle;

  /// No description provided for @unlockUnlimitedCollectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited collections'**
  String get unlockUnlimitedCollectionsTitle;

  /// No description provided for @unlockUnlimitedCollectionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Organize your vault with as many folders as you want.'**
  String get unlockUnlimitedCollectionsSubtitle;

  /// No description provided for @unlockUnlimitedWalletsTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited cards'**
  String get unlockUnlimitedWalletsTitle;

  /// No description provided for @unlockUnlimitedWalletsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save as many payment cards as you need.'**
  String get unlockUnlimitedWalletsSubtitle;

  /// No description provided for @unlockUnlimitedCryptoWalletsTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited crypto wallets'**
  String get unlockUnlimitedCryptoWalletsTitle;

  /// No description provided for @unlockUnlimitedCryptoWalletsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Store addresses, keys, and seed phrases without limits.'**
  String get unlockUnlimitedCryptoWalletsSubtitle;

  /// No description provided for @unlockUnlimitedSecretsTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited developer secrets'**
  String get unlockUnlimitedSecretsTitle;

  /// No description provided for @unlockUnlimitedSecretsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Store SSH keys, API tokens, and .env snippets without limits.'**
  String get unlockUnlimitedSecretsSubtitle;

  /// No description provided for @unlockSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Server sync'**
  String get unlockSyncTitle;

  /// No description provided for @unlockSyncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect your self-hosted server and sync across devices.'**
  String get unlockSyncSubtitle;

  /// No description provided for @unlockAttachmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get unlockAttachmentsTitle;

  /// No description provided for @unlockAttachmentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Attach encrypted files to vault entries.'**
  String get unlockAttachmentsSubtitle;

  /// No description provided for @unlockImportExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import & export'**
  String get unlockImportExportTitle;

  /// No description provided for @unlockImportExportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Move data in and out of OpenKey.'**
  String get unlockImportExportSubtitle;

  /// No description provided for @unknownFailureMsg.
  ///
  /// In en, this message translates to:
  /// **'An unknown error has occurred.'**
  String get unknownFailureMsg;

  /// No description provided for @purchaseCancelledMsg.
  ///
  /// In en, this message translates to:
  /// **'The purchase was cancelled.'**
  String get purchaseCancelledMsg;

  /// No description provided for @storeProblemMsg.
  ///
  /// In en, this message translates to:
  /// **'There was a problem with the store.'**
  String get storeProblemMsg;

  /// No description provided for @purchaseNotAllowedMsg.
  ///
  /// In en, this message translates to:
  /// **'Purchases are not allowed on this device.'**
  String get purchaseNotAllowedMsg;

  /// No description provided for @purchaseInvalidMsg.
  ///
  /// In en, this message translates to:
  /// **'The purchase is invalid.'**
  String get purchaseInvalidMsg;

  /// No description provided for @productNotAvailableForPurchaseMsg.
  ///
  /// In en, this message translates to:
  /// **'This product is not available for purchase.'**
  String get productNotAvailableForPurchaseMsg;

  /// No description provided for @productAlreadyPurchasedMsg.
  ///
  /// In en, this message translates to:
  /// **'This product has already been purchased.'**
  String get productAlreadyPurchasedMsg;

  /// No description provided for @receiptAlreadyInUseMsg.
  ///
  /// In en, this message translates to:
  /// **'This receipt is already in use.'**
  String get receiptAlreadyInUseMsg;

  /// No description provided for @invalidReceiptMsg.
  ///
  /// In en, this message translates to:
  /// **'The receipt is invalid.'**
  String get invalidReceiptMsg;

  /// No description provided for @missingReceiptFileMsg.
  ///
  /// In en, this message translates to:
  /// **'The receipt file is missing.'**
  String get missingReceiptFileMsg;

  /// No description provided for @networkErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'A network error occurred. Please check your connection.'**
  String get networkErrorMsg;

  /// No description provided for @invalidCredentialsMsg.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials provided.'**
  String get invalidCredentialsMsg;

  /// No description provided for @unexpectedBackendResponseMsg.
  ///
  /// In en, this message translates to:
  /// **'Unexpected response from the backend.'**
  String get unexpectedBackendResponseMsg;

  /// No description provided for @receiptInUseByOtherSubscriberMsg.
  ///
  /// In en, this message translates to:
  /// **'The receipt is in use by another subscriber.'**
  String get receiptInUseByOtherSubscriberMsg;

  /// No description provided for @invalidAppUserIdMsg.
  ///
  /// In en, this message translates to:
  /// **'The app user ID is invalid.'**
  String get invalidAppUserIdMsg;

  /// No description provided for @operationAlreadyInProgressMsg.
  ///
  /// In en, this message translates to:
  /// **'An operation is already in progress.'**
  String get operationAlreadyInProgressMsg;

  /// No description provided for @unknownBackendErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred on the server.'**
  String get unknownBackendErrorMsg;

  /// No description provided for @invalidAppleSubscriptionKeyMsg.
  ///
  /// In en, this message translates to:
  /// **'The Apple subscription key is invalid.'**
  String get invalidAppleSubscriptionKeyMsg;

  /// No description provided for @ineligibleMsg.
  ///
  /// In en, this message translates to:
  /// **'You are not eligible for this purchase.'**
  String get ineligibleMsg;

  /// No description provided for @insufficientPermissionsMsg.
  ///
  /// In en, this message translates to:
  /// **'You do not have sufficient permissions.'**
  String get insufficientPermissionsMsg;

  /// No description provided for @paymentPendingMsg.
  ///
  /// In en, this message translates to:
  /// **'Payment is pending.'**
  String get paymentPendingMsg;

  /// No description provided for @invalidSubscriberAttributesMsg.
  ///
  /// In en, this message translates to:
  /// **'Subscriber attributes are invalid.'**
  String get invalidSubscriberAttributesMsg;

  /// No description provided for @logOutWithAnonymousUserMsg.
  ///
  /// In en, this message translates to:
  /// **'Cannot log out with an anonymous user.'**
  String get logOutWithAnonymousUserMsg;

  /// No description provided for @configurationErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'There is a configuration error.'**
  String get configurationErrorMsg;

  /// No description provided for @unsupportedErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'This operation is not supported.'**
  String get unsupportedErrorMsg;

  /// No description provided for @emptySubscriberAttributesMsg.
  ///
  /// In en, this message translates to:
  /// **'Subscriber attributes are empty.'**
  String get emptySubscriberAttributesMsg;

  /// No description provided for @productDiscountMissingIdentifierMsg.
  ///
  /// In en, this message translates to:
  /// **'Product discount identifier is missing.'**
  String get productDiscountMissingIdentifierMsg;

  /// No description provided for @unknownNonNativeErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'An unknown non-native error occurred.'**
  String get unknownNonNativeErrorMsg;

  /// No description provided for @productDiscountMissingSubscriptionGroupIdentifierMsg.
  ///
  /// In en, this message translates to:
  /// **'Product discount subscription group identifier is missing.'**
  String get productDiscountMissingSubscriptionGroupIdentifierMsg;

  /// No description provided for @customerInfoErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'Failed to retrieve customer information.'**
  String get customerInfoErrorMsg;

  /// No description provided for @systemInfoErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'Failed to retrieve system information.'**
  String get systemInfoErrorMsg;

  /// No description provided for @beginRefundRequestErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'Failed to begin refund request.'**
  String get beginRefundRequestErrorMsg;

  /// No description provided for @productRequestTimeoutMsg.
  ///
  /// In en, this message translates to:
  /// **'Product request timed out.'**
  String get productRequestTimeoutMsg;

  /// No description provided for @apiEndpointBlockedMsg.
  ///
  /// In en, this message translates to:
  /// **'API endpoint is blocked.'**
  String get apiEndpointBlockedMsg;

  /// No description provided for @invalidPromotionalOfferMsg.
  ///
  /// In en, this message translates to:
  /// **'The promotional offer is invalid.'**
  String get invalidPromotionalOfferMsg;

  /// No description provided for @offlineConnectionMsg.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please connect and try again.'**
  String get offlineConnectionMsg;

  /// No description provided for @featureNotAvailableInCustomEntitlementsComputationModeMsg.
  ///
  /// In en, this message translates to:
  /// **'This feature is not available in custom entitlements computation mode.'**
  String get featureNotAvailableInCustomEntitlementsComputationModeMsg;

  /// No description provided for @signatureVerificationFailedMsg.
  ///
  /// In en, this message translates to:
  /// **'Signature verification failed.'**
  String get signatureVerificationFailedMsg;

  /// No description provided for @featureNotSupportedWithStoreKit1Msg.
  ///
  /// In en, this message translates to:
  /// **'This feature is not supported with StoreKit 1.'**
  String get featureNotSupportedWithStoreKit1Msg;

  /// No description provided for @invalidWebPurchaseTokenMsg.
  ///
  /// In en, this message translates to:
  /// **'The web purchase token is invalid.'**
  String get invalidWebPurchaseTokenMsg;

  /// No description provided for @purchaseBelongsToOtherUserMsg.
  ///
  /// In en, this message translates to:
  /// **'This purchase belongs to another user.'**
  String get purchaseBelongsToOtherUserMsg;

  /// No description provided for @expiredWebPurchaseTokenMsg.
  ///
  /// In en, this message translates to:
  /// **'The web purchase token has expired.'**
  String get expiredWebPurchaseTokenMsg;

  /// No description provided for @testStoreSimulatedPurchaseErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'Test store simulated purchase error.'**
  String get testStoreSimulatedPurchaseErrorMsg;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About the App'**
  String get aboutApp;

  /// No description provided for @aboutAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn more about OpenKey and its development.'**
  String get aboutAppSubtitle;

  /// No description provided for @developerName.
  ///
  /// In en, this message translates to:
  /// **'OpenSelfHosting'**
  String get developerName;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Open-source software you host yourself'**
  String get developer;

  /// No description provided for @rateUsIn.
  ///
  /// In en, this message translates to:
  /// **'Rate us on {storeName}'**
  String rateUsIn(String storeName);

  /// No description provided for @doYouLikeTheAppRateUs.
  ///
  /// In en, this message translates to:
  /// **'Do you like the app? Rate us!'**
  String get doYouLikeTheAppRateUs;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// No description provided for @openLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open licenses'**
  String get openLicenses;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read our privacy policy'**
  String get privacyPolicySubtitle;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @termsOfServiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read our terms of service'**
  String get termsOfServiceSubtitle;

  /// No description provided for @pricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get pricing;

  /// No description provided for @pricingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Free vs OpenKey Pro plans'**
  String get pricingSubtitle;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copied;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @contactSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get in touch with us for support or feedback.'**
  String get contactSubtitle;

  /// No description provided for @telegram.
  ///
  /// In en, this message translates to:
  /// **'Telegram'**
  String get telegram;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @localBackupRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get localBackupRestoreTitle;

  /// No description provided for @localBackupRestoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an encrypted full-vault backup (.okbak), or restore one. Includes the database, settings, and attachments.'**
  String get localBackupRestoreSubtitle;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export Backup'**
  String get exportBackup;

  /// No description provided for @exportBackupSubtitleEmpty.
  ///
  /// In en, this message translates to:
  /// **'Create an encrypted local backup and choose where to save it.'**
  String get exportBackupSubtitleEmpty;

  /// No description provided for @exportBackupSubtitleLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest export: {path}'**
  String exportBackupSubtitleLatest(String path);

  /// No description provided for @importBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore Backup'**
  String get importBackup;

  /// No description provided for @importBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Replace this vault with an encrypted OpenKey backup (.okbak).'**
  String get importBackupSubtitle;

  /// No description provided for @confirmRestore.
  ///
  /// In en, this message translates to:
  /// **'Confirm Restore'**
  String get confirmRestore;

  /// No description provided for @confirmRestoreMessage.
  ///
  /// In en, this message translates to:
  /// **'Restoring replaces the local database, settings, and attachments with the backup. Enter the master password used for that backup to decrypt it.'**
  String get confirmRestoreMessage;

  /// No description provided for @creatingBackup.
  ///
  /// In en, this message translates to:
  /// **'Creating backup…'**
  String get creatingBackup;

  /// No description provided for @creatingBackupBody.
  ///
  /// In en, this message translates to:
  /// **'Compressing and encrypting your full vault.'**
  String get creatingBackupBody;

  /// No description provided for @restoringBackupProgress.
  ///
  /// In en, this message translates to:
  /// **'Restoring backup…'**
  String get restoringBackupProgress;

  /// No description provided for @restoringBackupBody.
  ///
  /// In en, this message translates to:
  /// **'Decrypting and restoring your vault.'**
  String get restoringBackupBody;

  /// No description provided for @restoringBackupVerifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying master password…'**
  String get restoringBackupVerifying;

  /// No description provided for @restoringBackupDecrypting.
  ///
  /// In en, this message translates to:
  /// **'Decrypting backup data…'**
  String get restoringBackupDecrypting;

  /// No description provided for @restoringBackupWriting.
  ///
  /// In en, this message translates to:
  /// **'Writing restored vault…'**
  String get restoringBackupWriting;

  /// No description provided for @restoringBackupUnlocking.
  ///
  /// In en, this message translates to:
  /// **'Opening restored vault…'**
  String get restoringBackupUnlocking;

  /// No description provided for @backupComplete.
  ///
  /// In en, this message translates to:
  /// **'Backup complete'**
  String get backupComplete;

  /// No description provided for @backupCompleteLocalBody.
  ///
  /// In en, this message translates to:
  /// **'Your encrypted backup was saved successfully.'**
  String get backupCompleteLocalBody;

  /// No description provided for @backupCompleteLocalDetail.
  ///
  /// In en, this message translates to:
  /// **'Keep this file somewhere safe. You need the master password to restore it.'**
  String get backupCompleteLocalDetail;

  /// No description provided for @backupError.
  ///
  /// In en, this message translates to:
  /// **'Backup error'**
  String get backupError;

  /// No description provided for @restoreCompleted.
  ///
  /// In en, this message translates to:
  /// **'Restore complete'**
  String get restoreCompleted;

  /// No description provided for @restoreCompletedBody.
  ///
  /// In en, this message translates to:
  /// **'Your vault was restored from the encrypted backup.'**
  String get restoreCompletedBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bn',
    'en',
    'es',
    'fr',
    'hi',
    'pt',
    'ru',
    'ur',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'ur':
      return AppLocalizationsUr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
