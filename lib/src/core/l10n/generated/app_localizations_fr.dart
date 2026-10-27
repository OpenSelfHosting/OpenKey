// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get settings => 'Paramètres';

  @override
  String get appearance => 'Apparence';

  @override
  String get appearanceSubtitle => 'Thème, couleurs, polices et langue';

  @override
  String get themeMode => 'Mode du thème';

  @override
  String get system => 'Système';

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';

  @override
  String get language => 'Langue';

  @override
  String get fonts => 'Polices';

  @override
  String get displayFont => 'Police d’affichage';

  @override
  String get defaultFont => 'Par défaut';

  @override
  String get arabicFont => 'Arabe';

  @override
  String get developerFont => 'Développeur';

  @override
  String get technicalFont => 'Technique';

  @override
  String get standardFont => 'Classique';

  @override
  String get defaultFontDes => 'La police par défaut de l’application.';

  @override
  String get arabicFontDes => 'Une police optimisée pour l’écriture arabe.';

  @override
  String get developerFontDes => 'Une police conçue pour les développeurs.';

  @override
  String get technicalFontDes => 'Une police adaptée au contenu technique.';

  @override
  String get standardFontDes => 'Une police standard pour un usage général.';

  @override
  String get googleSansFlexFont => 'Google Sans Flex';

  @override
  String get googleSansFlexFontDes =>
      'La police de marque expressive de Google pour Material 3 Expressive.';

  @override
  String get robotoFlexFont => 'Roboto Flex';

  @override
  String get robotoFlexFontDes =>
      'Police variable Material Design avec graisse, largeur et taille optique.';

  @override
  String get figtreeFont => 'Figtree';

  @override
  String get figtreeFontDes =>
      'Une sans géométrique douce, souvent associée à Material You.';

  @override
  String get nunitoFont => 'Nunito';

  @override
  String get nunitoFontDes =>
      'A rounded geometric sans with a friendly, modern tone.';

  @override
  String get dynamicColors => 'Couleurs dynamiques';

  @override
  String get dynamicColorsSubtitle =>
      'Créer le thème à partir d’une couleur choisie';

  @override
  String get colorScheme => 'Palette de couleurs';

  @override
  String get colorSchemeSubtitle => 'Choisir une couleur et un style';

  @override
  String get highContrast => 'Contraste élevé';

  @override
  String get highContrastSubtitle =>
      'Augmenter le contraste pour la lisibilité';

  @override
  String get security => 'Sécurité';

  @override
  String get securitySubtitle =>
      'Verrouillage auto, biométrie, remplissage auto et mot de passe maître';

  @override
  String get account => 'Compte';

  @override
  String get accountPageTitle => 'Compte';

  @override
  String get accountPhoto => 'Photo de profil';

  @override
  String get changeAccountPhoto => 'Changer la photo';

  @override
  String get removeAccountPhoto => 'Supprimer la photo';

  @override
  String get changeEmail => 'Changer l’e-mail';

  @override
  String get changeEmailSubtitle =>
      'Réenveloppe la clé du coffre. Vous déverrouillerez avec le nouvel e-mail.';

  @override
  String get newEmail => 'Nouvel e-mail';

  @override
  String get emailChanged => 'E-mail mis à jour';

  @override
  String get switchAccount => 'Changer de compte';

  @override
  String get addAccount => 'Ajouter un compte';

  @override
  String get addAccountSubtitle =>
      'Créez ou connectez-vous à un autre coffre sur cet appareil';

  @override
  String get removeAccountFromDevice => 'Retirer de cet appareil';

  @override
  String get removeAccountFromDeviceSubtitle =>
      'Supprime ce coffre local. Un compte serveur lié n’est pas supprimé.';

  @override
  String get removeAccountConfirm =>
      'Ce coffre et ses éléments seront retirés de cet appareil. Cette action est irréversible.';

  @override
  String get otherAccounts => 'Autres comptes';

  @override
  String get useThisAccount => 'Utiliser ce compte';

  @override
  String get currentAccount => 'Compte actuel';

  @override
  String get chooseAccount => 'Choisir un compte';

  @override
  String get switchingAccount => 'Changement de compte…';

  @override
  String get welcomeBackShort => 'Bon retour';

  @override
  String get tools => 'Outils';

  @override
  String get help => 'Aide';

  @override
  String get autoLock => 'Verrouillage auto';

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
  String get autoLockOff => 'Désactivé';

  @override
  String get blockScreenshot => 'Bloquer les captures d’écran';

  @override
  String get blockScreenshotSubtitle =>
      'Empêche les captures et enregistrements d’écran de l’app.';

  @override
  String get blockScreenshotLinuxNote =>
      'Sous Linux, meilleur effort — le compositeur peut encore autoriser les captures.';

  @override
  String get biometricUnlock => 'Déverrouillage biométrique';

  @override
  String get autofillService => 'Service de remplissage auto';

  @override
  String get autofillEnabled =>
      'OpenKey est votre fournisseur de mots de passe et passkeys';

  @override
  String get autofillDisabled =>
      'Activez OpenKey pour les mots de passe (Remplissage auto) et les passkeys (fournisseur d’identifiants)';

  @override
  String get autofillDisabledBrowser =>
      'Installez l’extension OpenKey et déverrouillez le coffre';

  @override
  String get autofillSaveTitle => 'Enregistrer le mot de passe';

  @override
  String get autofillSaveSubtitle =>
      'Enregistrer cet identifiant dans votre coffre OpenKey ?';

  @override
  String get autofillSaved => 'Mot de passe enregistré';

  @override
  String get autofillRequireBiometric =>
      'Exiger la biométrie pour le remplissage auto';

  @override
  String get autofillRequireBiometricSubtitle =>
      'Demander l’empreinte ou le visage avant de remplir les mots de passe dans les apps et sites.';

  @override
  String get autofillRequireBiometricReason =>
      'Confirmer le remplissage auto avec OpenKey';

  @override
  String get autofillRequireBiometricEnabled =>
      'Confirmation biométrique du remplissage auto activée';

  @override
  String get autofillRequireBiometricDisabled =>
      'Confirmation biométrique du remplissage auto désactivée';

  @override
  String get autofillInline => 'Dans le clavier';

  @override
  String get autofillInlineSubtitle =>
      'Afficher les suggestions dans la barre du clavier.';

  @override
  String get autofillPopup => 'Au-dessus du champ';

  @override
  String get autofillPopupSubtitle =>
      'Afficher un menu déroulant au-dessus du champ de saisie.';

  @override
  String get androidApp => 'Application Android';

  @override
  String get androidAppHint => 'Nom du paquet, ex. com.example.app';

  @override
  String get biometricUnlockReason => 'Déverrouillez votre coffre OpenKey';

  @override
  String get enableBiometricUnlockReason =>
      'Activer le déverrouillage biométrique';

  @override
  String get biometricHint => 'Vérifiez votre identité';

  @override
  String get biometricNotRecognized => 'Non reconnu. Réessayez.';

  @override
  String get goToSettings => 'Ouvrir les paramètres';

  @override
  String get biometricGoToSettingsDescription =>
      'L’authentification biométrique n’est pas configurée. Ouvrez les paramètres pour enregistrer une empreinte ou un visage.';

  @override
  String get unlock => 'Déverrouiller';

  @override
  String get unlocking => 'Déverrouillage…';

  @override
  String get masterPassword => 'Mot de passe maître';

  @override
  String get unlockSubtitle =>
      'Saisissez votre mot de passe maître pour déverrouiller.';

  @override
  String welcomeBack(String email) {
    return 'Bon retour, $email';
  }

  @override
  String get fieldRequired => 'Obligatoire';

  @override
  String get resetLocalVault => 'Réinitialiser le coffre local';

  @override
  String get resetLocalVaultTitle => 'Réinitialiser le coffre local ?';

  @override
  String get resetLocalVaultSubtitle =>
      'Supprime définitivement toutes les données du coffre sur cet appareil.';

  @override
  String get resetLocalVaultConfirm =>
      'Tous les mots de passe et données du coffre sur cet appareil seront définitivement supprimés afin d’en créer un nouveau. Les données serveur ne sont pas supprimées. Irréversible.';

  @override
  String get dangerZone => 'Zone de danger';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get createVault => 'Créer le coffre';

  @override
  String get creatingVault => 'Création…';

  @override
  String get setupSubtitle =>
      'Créez votre coffre chiffré. Votre mot de passe maître ne quitte jamais cet appareil.';

  @override
  String get setupSignInSubtitle =>
      'Connectez-vous à votre serveur OpenKey auto-hébergé pour restaurer ce coffre sur l’appareil.';

  @override
  String get setupModeCreate => 'Créer';

  @override
  String get setupModeSignIn => 'Se connecter';

  @override
  String get setupModeRestore => 'Restaurer';

  @override
  String get setupSignInAction => 'Se connecter';

  @override
  String get setupSigningIn => 'Connexion…';

  @override
  String get setupRestoreSubtitle =>
      'Restaurez votre coffre depuis une sauvegarde OpenKey chiffrée (.okbak).';

  @override
  String get setupRestoreAction => 'Restaurer le coffre';

  @override
  String get setupRestoreChooseFile => 'Choisir le fichier de sauvegarde';

  @override
  String get setupRestoreChooseFileSubtitle =>
      'Sélectionnez un fichier .okbak chiffré.';

  @override
  String setupRestoreBackupAccount(String email) {
    return 'Cette sauvegarde appartient à $email';
  }

  @override
  String get setupRestoreNeedFile =>
      'Choisissez d’abord un fichier de sauvegarde';

  @override
  String get setupLinkSelfHostedTitle => 'Lier un serveur auto-hébergé';

  @override
  String get setupLinkSelfHostedSubtitle =>
      'Facultatif. Enregistrez ce coffre pour la sync entre appareils.';

  @override
  String get setupLinkServerHelper =>
      'Votre coffre sera enregistré sur ce serveur après création.';

  @override
  String get setupSignInServerHelper =>
      'URL du serveur OpenKey qui possède déjà votre compte.';

  @override
  String get setupChooserTitle => 'Comment voulez-vous commencer ?';

  @override
  String get setupChooserSubtitle =>
      'Créez un coffre, connectez-vous ou restaurez une sauvegarde.';

  @override
  String get setupChooseCreateTitle => 'Créer un coffre';

  @override
  String get setupChooseCreateSubtitle =>
      'Nouveau coffre chiffré sur cet appareil.';

  @override
  String get setupChooseSignInTitle => 'Se connecter';

  @override
  String get setupChooseSignInSubtitle =>
      'Restaurez depuis votre serveur OpenKey auto-hébergé.';

  @override
  String get setupChooseRestoreTitle => 'Restaurer une sauvegarde';

  @override
  String get setupChooseRestoreSubtitle => 'Ouvrez un fichier .okbak chiffré.';

  @override
  String get invalidServerUrl =>
      'Entrez une URL valide commençant par http:// ou https://';

  @override
  String get confirmMasterPassword => 'Confirmer le mot de passe maître';

  @override
  String get email => 'E-mail';

  @override
  String get invalidEmail => 'Saisissez une adresse e-mail valide';

  @override
  String get invalidEmailFormat => 'Adresse e-mail invalide';

  @override
  String get invalidUrlFormat =>
      'URL invalide. Utilisez un format comme https://example.com';

  @override
  String get invalidPhoneFormat => 'Numéro de téléphone invalide';

  @override
  String get invalidPinFormat => 'Le code PIN doit comporter 4 à 12 chiffres';

  @override
  String get invalidNumberFormat => 'Saisissez uniquement des chiffres';

  @override
  String get invalidCardFormat => 'Numéro de carte invalide';

  @override
  String get invalidIpFormat => 'Adresse IP invalide';

  @override
  String get invalidWalletFormat => 'Adresse de portefeuille invalide';

  @override
  String get invalidRecoveryCodesFormat => 'Codes de récupération invalides';

  @override
  String get fixFieldErrors =>
      'Corrigez les champs surlignés avant d’enregistrer';

  @override
  String get passwordTooShort => 'Au moins 8 caractères';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get passwordTooShortStrong => 'Au moins 12 caractères';

  @override
  String get passwordTooWeak =>
      'Utilisez un mélange plus long de lettres, chiffres et symboles';

  @override
  String get masterPasswordHelper =>
      '12 caractères ou plus de types mixtes recommandés';

  @override
  String get passwordHintOptional => 'Indice de mot de passe (facultatif)';

  @override
  String get passwordHintHelper =>
      'Un simple rappel vague — n’incluez jamais le mot de passe';

  @override
  String passwordHintReveal(String hint) {
    return 'Indice : $hint';
  }

  @override
  String get setupZeroKnowledgeBanner =>
      'Chiffrement zero-knowledge : OpenKey ne peut ni lire ni réinitialiser votre coffre.';

  @override
  String get vaultNoticesTitle => 'Avant de créer votre coffre';

  @override
  String get vaultNoticesSubtitle =>
      'Veuillez accepter ces points pour continuer.';

  @override
  String get vaultNoticeNoRecovery =>
      'Si vous oubliez votre mot de passe maître, vos données ne pourront pas être récupérées.';

  @override
  String get vaultNoticeLocalEncryption =>
      'Votre coffre est chiffré sur cet appareil ; le mot de passe maître n’en sort jamais en clair.';

  @override
  String get vaultNoticeBackups =>
      'Des sauvegardes chiffrées régulières sont le seul rempart contre la perte de l’appareil.';

  @override
  String get vaultNoticeDeviceTransfer =>
      'Changer d’appareil nécessite une restauration de sauvegarde ou une synchronisation serveur optionnelle.';

  @override
  String get acceptAllNotices => 'Tout accepter';

  @override
  String get server => 'Serveur auto-hébergé';

  @override
  String get notConnected => 'Non connecté';

  @override
  String get data => 'Données et partage';

  @override
  String get dataSubtitle => 'Serveur, sauvegarde, import/export et partage';

  @override
  String get importExport => 'Importer et exporter';

  @override
  String get importExportSubtitle =>
      'Déplacez des mots de passe vers ou hors du coffre';

  @override
  String get importTab => 'Importer';

  @override
  String get exportTab => 'Exporter';

  @override
  String get importPasswords => 'Importer des mots de passe';

  @override
  String get importPasswordsSubtitle =>
      'Les entrées sont chiffrées avec la clé du coffre sur cet appareil.';

  @override
  String get exportPasswords => 'Exporter des mots de passe';

  @override
  String get exportPasswordsSubtitle =>
      'Déchiffre les entrées sur cet appareil et enregistre un fichier non chiffré.';

  @override
  String get exportingPasswords => 'Exportation…';

  @override
  String get exportBitwardenSubtitle => 'JSON Bitwarden non chiffré';

  @override
  String get exportChromeSubtitle => 'CSV compatible avec Chrome';

  @override
  String get exportLastPassSubtitle => 'CSV compatible avec LastPass';

  @override
  String get exportOnePasswordSubtitle => 'CSV compatible avec 1Password';

  @override
  String get exportKeePassSubtitle =>
      'Base KeePass / KeePassXC chiffrée (.kdbx)';

  @override
  String get exportOpenKeySubtitle =>
      'JSON OpenKey non chiffré avec dossiers et données complètes';

  @override
  String get exportedItems => 'Coffre exporté';

  @override
  String exportedToPath(String path) {
    return 'Exporté vers $path';
  }

  @override
  String get changeMasterPassword => 'Changer le mot de passe maître';

  @override
  String get changeMasterPasswordSubtitle =>
      'Réenveloppe la clé du coffre. Les entrées restent chiffrées avec la même clé.';

  @override
  String get currentMasterPassword => 'Mot de passe maître actuel';

  @override
  String get newMasterPassword => 'Nouveau mot de passe maître';

  @override
  String get masterPasswordUnchanged => 'Choisissez un mot de passe différent';

  @override
  String get masterPasswordChanged => 'Mot de passe maître mis à jour';

  @override
  String get deleteServerAccount => 'Supprimer le compte serveur';

  @override
  String get deleteServerAccountSubtitle =>
      'Supprime votre chiffrement du serveur. Cet appareil conserve le coffre local.';

  @override
  String get deleteServerAccountWarning =>
      'Cette action est irréversible. Les données synchronisées sur le serveur seront définitivement supprimées.';

  @override
  String get serverAccountDeleted => 'Compte serveur supprimé';

  @override
  String get browserExtension => 'Extension de navigateur';

  @override
  String get browserExtensionSubtitle =>
      'Connectez Chrome / Edge / Firefox au coffre déverrouillé';

  @override
  String get browserExtensionSheetSubtitle =>
      'Collez l’ID de l’extension Chrome non empaquetée depuis chrome://extensions (mode développeur). Firefox utilise un ID fixe automatiquement.';

  @override
  String get chromeExtensionId => 'ID de l’extension Chrome';

  @override
  String get chromeExtensionIdHint =>
      'Affiché sous le nom de l’extension sur chrome://extensions';

  @override
  String get connectBrowserExtension => 'Connecter l’extension';

  @override
  String get copyOfflineExtensionLink => 'Copier le lien hors ligne du coffre';

  @override
  String get extensionLinkClipboardWarning =>
      'Ceci copie le matériel de déverrouillage du coffre dans le presse-papiers. D\'autres applications peuvent le lire jusqu\'à effacement ou nettoyage automatique après une minute.';

  @override
  String get browserExtensionHostReady =>
      'Hôte natif enregistré. Gardez OpenKey déverrouillé, puis touchez « Utiliser l’app bureau » dans l’extension.';

  @override
  String get browserExtensionHostHint =>
      'Déverrouillez le coffre, collez l’ID Chrome, puis connectez.';

  @override
  String get browserExtensionHostFailed =>
      'Impossible d’enregistrer l’hôte natif. Déverrouillez le coffre et réessayez.';

  @override
  String get cliTitle => 'CLI';

  @override
  String get cliSubtitle =>
      'Installez la CLI OpenKey, puis exécutez la commande de connexion pendant que le coffre est déverrouillé.';

  @override
  String get cliTermuxTitle => 'Termux / CLI';

  @override
  String get cliTermuxSubtitle =>
      'Installez la CLI OpenKey dans Termux, puis exécutez la commande de connexion pendant que le coffre est déverrouillé.';

  @override
  String get cliTermuxInstall => 'Installation';

  @override
  String get cliTermuxConnect => 'Connexion';

  @override
  String get cliTermuxUnavailable =>
      'Déverrouillez le coffre pour afficher la commande de connexion.';

  @override
  String get aboutPrivacy =>
      'OpenKey chiffre vos mots de passe de bout en bout. Votre mot de passe maître et la clé du coffre ne quittent jamais cet appareil.';

  @override
  String get localVault => 'Coffre local';

  @override
  String get followDevice => 'Suivre l’apparence de l’appareil';

  @override
  String get passwordGenerator => 'Générateur de mots de passe';

  @override
  String get generatedPassword => 'Mot de passe généré';

  @override
  String get passwordLength => 'Longueur';

  @override
  String charactersLabel(int n) {
    return '$n caractères';
  }

  @override
  String get includeUppercase => 'Majuscules';

  @override
  String get includeLowercase => 'Minuscules';

  @override
  String get includeDigits => 'Chiffres';

  @override
  String get includeSymbols => 'Symboles';

  @override
  String get avoidAmbiguous => 'Éviter les caractères ambigus';

  @override
  String get avoidAmbiguousSubtitle => 'Exclure I, l, 1, O, 0, o, |';

  @override
  String get regenerate => 'Régénérer';

  @override
  String get copyPassword => 'Copier';

  @override
  String get passwordCopied => 'Mot de passe copié';

  @override
  String get passwordGeneratorSubtitle =>
      'Générez un mot de passe fort et unique';

  @override
  String get usePassword => 'Utiliser le mot de passe';

  @override
  String get generateOptions => 'Options';

  @override
  String get characterSets => 'Jeux de caractères';

  @override
  String get passwordStrengthWeak => 'Faible';

  @override
  String get passwordStrengthFair => 'Correct';

  @override
  String get passwordStrengthStrong => 'Fort';

  @override
  String get generatorTitle => 'Générateur';

  @override
  String get generatorSubtitle =>
      'Créez des mots de passe, identifiants et e-mails';

  @override
  String get generatorModePassword => 'Mot de passe';

  @override
  String get generatorModeUsername => 'Identifiant';

  @override
  String get generatorModeEmail => 'E-mail';

  @override
  String get generatedUsername => 'Identifiant généré';

  @override
  String get generatedEmail => 'E-mail généré';

  @override
  String get usernameStyle => 'Style';

  @override
  String get usernameStyleWords => 'Mots';

  @override
  String get usernameStyleRandom => 'Aléatoire';

  @override
  String get usernameCapitalize => 'Majuscules';

  @override
  String get usernameIncludeDigits => 'Ajouter des chiffres';

  @override
  String get usernameSeparator => 'Séparateur';

  @override
  String get usernameSeparatorNone => 'Aucun';

  @override
  String get emailType => 'Type d’e-mail';

  @override
  String get emailTypeRandom => 'Aléatoire';

  @override
  String get emailTypePlus => 'Adresse plus';

  @override
  String get emailDomain => 'Domaine';

  @override
  String get emailDomainHint => 'votredomaine.com';

  @override
  String get emailPlusBase => 'Votre e-mail';

  @override
  String get emailPlusBaseHint => 'vous@gmail.com';

  @override
  String get emailPlusHelp =>
      'Crée vous+tag@gmail.com pour filtrer les inscriptions dans votre boîte.';

  @override
  String get emailRandomHelp =>
      'Crée une adresse unique sur un domaine que vous contrôlez, comme un catch-all.';

  @override
  String get passwordDetails => 'Détails du mot de passe';

  @override
  String get untitled => 'Sans titre';

  @override
  String get credentials => 'Identifiants';

  @override
  String get username => 'Nom d’utilisateur';

  @override
  String get password => 'Mot de passe';

  @override
  String get website => 'Site web';

  @override
  String get notes => 'Notes';

  @override
  String get authenticator => 'Authentificateur';

  @override
  String get passkey => 'Clé d’accès';

  @override
  String get attachments => 'Pièces jointes';

  @override
  String get downloadAttachment => 'Télécharger';

  @override
  String get previewAttachment => 'Aperçu';

  @override
  String get openAttachment => 'Ouvrir';

  @override
  String get playVideo => 'Lire la vidéo';

  @override
  String get pausePlayback => 'Pause';

  @override
  String get openingAttachment => 'Ouverture de la pièce jointe…';

  @override
  String attachmentSaved(String name) {
    return '$name enregistré';
  }

  @override
  String get couldNotOpenAttachment =>
      'Impossible d’ouvrir cette pièce jointe.';

  @override
  String get attachmentNotPreviewable =>
      'Aperçu indisponible pour ce type de fichier. Vous pouvez le télécharger.';

  @override
  String get copyUsername => 'Copier l’identifiant';

  @override
  String get showPassword => 'Afficher le mot de passe';

  @override
  String get hidePassword => 'Masquer le mot de passe';

  @override
  String get tapToCopy => 'Appuyez pour copier';

  @override
  String get edit => 'Modifier';

  @override
  String get delete => 'Supprimer';

  @override
  String get cancel => 'Annuler';

  @override
  String get deleteEntry => 'Supprimer l’entrée ?';

  @override
  String get deleteEntryConfirm =>
      'Cela supprime définitivement le mot de passe de votre coffre.';

  @override
  String get entryNotFound => 'Entrée introuvable';

  @override
  String get entryNotFoundMessage =>
      'Ce mot de passe a peut-être été supprimé.';

  @override
  String get goBack => 'Retour';

  @override
  String get synced => 'Synchronisé';

  @override
  String get pendingSync => 'Sync en attente';

  @override
  String revisionLabel(int n) {
    return 'Révision $n';
  }

  @override
  String valueCopied(String label) {
    return '$label copié';
  }

  @override
  String get vault => 'Coffre';

  @override
  String get items => 'Éléments';

  @override
  String get itemsHubSubtitle => 'Cartes, portefeuilles crypto et secrets.';

  @override
  String get itemsCardsSubtitle =>
      'Cartes de paiement et détails de facturation';

  @override
  String get itemsCryptoSubtitle => 'Adresses, clés et phrases de récupération';

  @override
  String get itemsSecretsSubtitle => 'Clés SSH, jetons API et extraits .env';

  @override
  String itemsCountLabel(int count) {
    return '$count enregistrés';
  }

  @override
  String get wallets => 'Portefeuilles';

  @override
  String get searchCards => 'Rechercher des cartes';

  @override
  String get noCardsYet => 'Aucune carte pour l’instant';

  @override
  String get noCardsYetMessage =>
      'Ajoutez une carte pour la stocker en sécurité.';

  @override
  String get addCard => 'Ajouter une carte';

  @override
  String get editCard => 'Modifier la carte';

  @override
  String get save => 'Enregistrer';

  @override
  String get cardDetails => 'Détails de la carte';

  @override
  String get cardName => 'Nom de la carte';

  @override
  String get cardHolder => 'Titulaire';

  @override
  String get cardNumber => 'Numéro de carte';

  @override
  String get cardExpiry => 'Expiration';

  @override
  String get cardCvc => 'CVC';

  @override
  String get copyNumber => 'Copier le numéro';

  @override
  String get copyCvc => 'Copier le CVC';

  @override
  String get tapCardToFlip => 'Appuyez sur la carte pour la retourner';

  @override
  String get deleteCard => 'Supprimer la carte ?';

  @override
  String get deleteCardConfirm =>
      'Cela supprime définitivement la carte de votre portefeuille.';

  @override
  String get cardNotFound => 'Carte introuvable';

  @override
  String get cardNotFoundMessage => 'Cette carte a peut-être été supprimée.';

  @override
  String get bank => 'Banque';

  @override
  String get banks => 'Banques';

  @override
  String get otherBank => 'Autre';

  @override
  String get addBank => 'Ajouter une banque';

  @override
  String get newBank => 'Nouvelle banque';

  @override
  String get bankName => 'Nom de la banque';

  @override
  String get renameBank => 'Renommer la banque';

  @override
  String get deleteBank => 'Supprimer la banque ?';

  @override
  String get deleteBankConfirm =>
      'Retirer ce groupe de banque ? Les cartes peuvent être déplacées vers Autre.';

  @override
  String get deleteBankAndClear => 'Supprimer et retirer les cartes';

  @override
  String get moveToBank => 'Déplacer vers une banque';

  @override
  String get noBanksYet => 'Aucune banque pour l’instant';

  @override
  String get createBankHint => 'Créez une banque pour organiser vos cartes.';

  @override
  String get bankCreated => 'Banque créée';

  @override
  String get cardMoved => 'Carte déplacée';

  @override
  String get emptyBank => 'Aucune carte dans cette banque';

  @override
  String get paymentCards => 'Cartes';

  @override
  String get cryptoWallets => 'Crypto';

  @override
  String get searchCryptoWallets => 'Rechercher des portefeuilles crypto';

  @override
  String get noCryptoWalletsYet => 'Aucun portefeuille crypto';

  @override
  String get noCryptoWalletsYetMessage =>
      'Ajoutez un portefeuille pour stocker les clés en sécurité.';

  @override
  String get addCryptoWallet => 'Ajouter un portefeuille crypto';

  @override
  String get editCryptoWallet => 'Modifier le portefeuille crypto';

  @override
  String get cryptoNetwork => 'Réseau';

  @override
  String get cryptoWalletName => 'Nom du portefeuille';

  @override
  String get walletAddress => 'Adresse';

  @override
  String get privateKey => 'Clé privée';

  @override
  String get seedPhrase => 'Phrase de récupération';

  @override
  String get cryptoDetails => 'Détails du portefeuille';

  @override
  String get copyAddress => 'Copier l’adresse';

  @override
  String get deleteCryptoWallet => 'Supprimer le portefeuille crypto ?';

  @override
  String get deleteCryptoWalletConfirm =>
      'Cela supprime définitivement le portefeuille et ses secrets de votre coffre.';

  @override
  String get cryptoWalletNotFound => 'Portefeuille crypto introuvable';

  @override
  String get cryptoWalletNotFoundMessage =>
      'Ce portefeuille a peut-être été supprimé.';

  @override
  String get folders => 'Dossiers';

  @override
  String get otherFolder => 'Autre';

  @override
  String get addFolder => 'Ajouter un dossier';

  @override
  String get newFolder => 'Nouveau dossier';

  @override
  String get folderName => 'Nom du dossier';

  @override
  String get renameFolder => 'Renommer le dossier';

  @override
  String get deleteFolder => 'Supprimer le dossier ?';

  @override
  String get deleteFolderConfirm =>
      'Supprimer ce groupe de dossier ? Les portefeuilles peuvent être déplacés vers Autre.';

  @override
  String get deleteFolderAndClear => 'Supprimer et retirer les portefeuilles';

  @override
  String get moveToFolder => 'Déplacer vers un dossier';

  @override
  String get noFoldersYet => 'Aucun dossier pour le moment';

  @override
  String get createFolderHint =>
      'Créez un dossier pour organiser vos portefeuilles crypto.';

  @override
  String get folderCreated => 'Dossier créé';

  @override
  String get cryptoWalletMoved => 'Portefeuille déplacé';

  @override
  String get emptyFolder => 'Aucun portefeuille dans ce dossier';

  @override
  String get secrets => 'Secrets';

  @override
  String get searchSecrets => 'Rechercher des secrets';

  @override
  String get noSecretsYet => 'Aucun secret pour l’instant';

  @override
  String get noSecretsYetMessage =>
      'Stockez en sécurité des clés SSH, jetons API et extraits .env.';

  @override
  String get addSecret => 'Ajouter un secret';

  @override
  String get editSecret => 'Modifier le secret';

  @override
  String get secretKind => 'Type';

  @override
  String get secretKindSsh => 'Clé SSH';

  @override
  String get secretKindApiToken => 'Jeton API';

  @override
  String get secretKindEnv => 'Extrait .env';

  @override
  String get secretKindOther => 'Autre';

  @override
  String get secretName => 'Nom';

  @override
  String get secretUsername => 'Nom d’utilisateur';

  @override
  String get secretHost => 'Hôte';

  @override
  String get secretEndpoint => 'Point de terminaison / URL';

  @override
  String get publicKey => 'Clé publique';

  @override
  String get apiToken => 'Jeton API';

  @override
  String get envContent => 'Contenu .env';

  @override
  String get secretValue => 'Secret';

  @override
  String get passphrase => 'Phrase secrète';

  @override
  String get secretDetails => 'Détails du secret';

  @override
  String get copySecret => 'Copier le secret';

  @override
  String get deleteSecret => 'Supprimer le secret ?';

  @override
  String get deleteSecretConfirm =>
      'Cela supprime définitivement le secret de votre coffre.';

  @override
  String get secretNotFound => 'Secret introuvable';

  @override
  String get secretNotFoundMessage => 'Ce secret a peut-être été supprimé.';

  @override
  String get reverseOrderSecretsSubtitle =>
      'Afficher les secrets en ordre inverse.';

  @override
  String get device => 'Appareil';

  @override
  String get devices => 'Appareils';

  @override
  String get otherDevice => 'Autre';

  @override
  String get addDevice => 'Ajouter un appareil';

  @override
  String get newDevice => 'Nouvel appareil';

  @override
  String get deviceName => 'Nom de l’appareil';

  @override
  String get renameDevice => 'Renommer l’appareil';

  @override
  String get deleteDevice => 'Supprimer l’appareil ?';

  @override
  String get deleteDeviceConfirm =>
      'Retirer ce groupe d’appareil ? Les secrets peuvent être déplacés vers Autre.';

  @override
  String get deleteDeviceAndClear => 'Supprimer et désassigner les secrets';

  @override
  String get moveToDevice => 'Déplacer vers l’appareil';

  @override
  String get noDevicesYet => 'Aucun appareil pour l’instant';

  @override
  String get createDeviceHint =>
      'Créez un appareil pour organiser les secrets de chaque machine.';

  @override
  String get deviceCreated => 'Appareil créé';

  @override
  String get secretMoved => 'Secret déplacé';

  @override
  String get emptyDevice => 'Aucun secret sur cet appareil';

  @override
  String get faq => 'Questions fréquentes';

  @override
  String get faqSubtitle => 'Chiffrement, déverrouillage, sync et plus';

  @override
  String get faqEncryptionQ => 'Mes données sont-elles chiffrées ?';

  @override
  String get faqEncryptionA =>
      'Oui. OpenKey chiffre votre coffre de bout en bout sur cet appareil. Votre mot de passe maître et la clé du coffre ne quittent jamais l’appareil en clair.';

  @override
  String get faqForgotPasswordQ => 'Et si j’oublie mon mot de passe maître ?';

  @override
  String get faqForgotPasswordA =>
      'Sans votre mot de passe maître, aucune récupération n’est possible. Grâce au chiffrement zero-knowledge, OpenKey ne peut pas le réinitialiser. Conservez une sauvegarde sécurisée.';

  @override
  String get faqOfflineQ => 'OpenKey fonctionne-t-il hors ligne ?';

  @override
  String get faqOfflineA =>
      'Oui. Votre coffre est stocké localement et se déverrouille sans réseau. Un serveur optionnel n’est utile que pour la sync et le partage.';

  @override
  String get faqAutoLockQ => 'Comment fonctionne le verrouillage auto ?';

  @override
  String get faqAutoLockA =>
      'Lorsque vous quittez l’application sans la fermer, OpenKey compte le temps d’absence. Après la durée choisie dans Paramètres, le coffre se verrouille ; il faudra le mot de passe maître ou la biométrie. Fermer l’application termine la session immédiatement.';

  @override
  String get faqBiometricQ => 'Le déverrouillage biométrique est-il sûr ?';

  @override
  String get faqBiometricA =>
      'Oui. La biométrie déverrouille une clé dans le matériel sécurisé. Elle ne remplace pas le mot de passe maître — vous pouvez toujours l’utiliser.';

  @override
  String get faqSyncQ => 'Qu’est-ce que la synchro auto-hébergée ?';

  @override
  String get faqSyncA =>
      'Vous pouvez faire tourner votre propre serveur OpenKey. Les appareils envoient des données de coffre chiffrées pour rester synchronisés à distance. Le serveur ne stocke que du texte chiffré et ne voit jamais les secrets en clair. Le mot de passe maître reste sur chaque appareil.';

  @override
  String get faqBackupQ =>
      'Comment fonctionnent la sauvegarde et la restauration ?';

  @override
  String get faqBackupA =>
      'Dans Paramètres → Sauvegarde et restauration, vous pouvez enregistrer une copie complète du coffre sur cet appareil. OpenKey regroupe la base de données, les réglages et les pièces jointes dans un fichier compressé, puis le chiffre avec la clé du coffre (.okbak). Personne ne peut lire le fichier sans votre mot de passe maître. La restauration déchiffre ce fichier et remplace le coffre local par la sauvegarde — conservez le mot de passe et le fichier .okbak en lieu sûr.';

  @override
  String get appName => 'OpenKey';

  @override
  String get copy => 'Copier';

  @override
  String get create => 'Créer';

  @override
  String get generate => 'Générer';

  @override
  String get name => 'Nom';

  @override
  String get title => 'Titre';

  @override
  String get lock => 'Verrouiller';

  @override
  String get all => 'Tout';

  @override
  String get entry => 'Entrée';

  @override
  String get collection => 'Collection';

  @override
  String get searchPasswords => 'Rechercher des mots de passe';

  @override
  String get noPasswordsYet => 'Aucun mot de passe pour l’instant';

  @override
  String get noPasswordsYetMessage =>
      'Ajoutez une entrée ou créez une collection.';

  @override
  String get newCollection => 'Nouvelle collection';

  @override
  String get newEntry => 'Nouvelle entrée';

  @override
  String get editEntry => 'Modifier l’entrée';

  @override
  String get chooseFields => 'Champs';

  @override
  String get chooseFieldsSubtitle =>
      'Activez ou désactivez les champs, puis glissez pour les réordonner';

  @override
  String get done => 'Terminé';

  @override
  String get phone => 'Téléphone';

  @override
  String get pin => 'Code PIN';

  @override
  String get number => 'Nombre';

  @override
  String get address => 'Adresse';

  @override
  String get ipAddress => 'Adresse IP';

  @override
  String get dateYmd => 'Date';

  @override
  String get dateYm => 'Mois / année';

  @override
  String get recoveryCodes => 'Codes de récupération';

  @override
  String get customText => 'Texte';

  @override
  String get additionalFields => 'Champs supplémentaires';

  @override
  String get emptyCollection => 'Collection vide';

  @override
  String get emptyCollectionMessage =>
      'Ajoutez une entrée de mot de passe à cette collection.';

  @override
  String get editCollection => 'Modifier la collection';

  @override
  String get deleteCollection => 'Supprimer la collection';

  @override
  String get deleteCollectionConfirm =>
      'Les entrées de cette collection seront retirées du dossier (pas supprimées). Continuer ?';

  @override
  String get chooseIcon => 'Choisir une icône';

  @override
  String get icons => 'Icônes';

  @override
  String get brands => 'Marques';

  @override
  String get suggestedIcon => 'Icône suggérée';

  @override
  String get fromDevice => 'Depuis l’appareil';

  @override
  String get customIcon => 'Icône personnalisée';

  @override
  String get editIcon => 'Modifier l’icône';

  @override
  String get cropOrRotate => 'Recadrer / Pivoter';

  @override
  String get rotate => 'Pivoter';

  @override
  String get flip => 'Retourner';

  @override
  String get ratio => 'Ratio';

  @override
  String get filter => 'Filtre';

  @override
  String get blur => 'Flou';

  @override
  String get discardChanges => 'Abandonner les modifications ?';

  @override
  String get discardChangesMessage => 'Vos modifications seront perdues.';

  @override
  String get discard => 'Abandonner';

  @override
  String get undo => 'Annuler';

  @override
  String get redo => 'Rétablir';

  @override
  String get more => 'Plus';

  @override
  String get back => 'Retour';

  @override
  String get preparingImage => 'Préparation de l’image…';

  @override
  String get search => 'Rechercher';

  @override
  String get noFolder => 'Aucun dossier';

  @override
  String get folder => 'Dossier';

  @override
  String entriesCount(int count) {
    return '$count entrées';
  }

  @override
  String get moveTo => 'Déplacer vers';

  @override
  String get moveHere => 'Déplacer ici';

  @override
  String get movingLabel => 'Déplacement';

  @override
  String movingItemsCount(int count) {
    return '$count éléments';
  }

  @override
  String get tags => 'Étiquettes';

  @override
  String get noTags => 'Aucun tag pour l’instant';

  @override
  String get noTagsMessage => 'Ajoutez des tags en modifiant une entrée.';

  @override
  String get sortAndFilter => 'Trier et filtrer';

  @override
  String get applyToFolders => 'Dossiers';

  @override
  String get applyToEntries => 'Mots de passe';

  @override
  String get sortBy => 'Trier par';

  @override
  String get options => 'Options';

  @override
  String get sortByCreationTime => 'Trier par date de création';

  @override
  String get sortByLastModified => 'Trier par dernière modification';

  @override
  String get sortByName => 'Trier par nom';

  @override
  String get sortByCustomOrder => 'Ordre personnalisé';

  @override
  String get reverseOrder => 'Ordre inversé';

  @override
  String get reverseOrderFoldersSubtitle =>
      'Afficher les dossiers en ordre inverse.';

  @override
  String get reverseOrderEntriesSubtitle =>
      'Afficher les mots de passe en ordre inverse.';

  @override
  String get reverseOrderCardsSubtitle =>
      'Afficher les cartes en ordre inverse.';

  @override
  String get reverseOrderCryptoSubtitle =>
      'Afficher les portefeuilles en ordre inverse.';

  @override
  String get addTagHint => 'Ajouter un tag';

  @override
  String deleteSelectedConfirm(int count) {
    return 'Supprimer $count éléments sélectionnés ?';
  }

  @override
  String get totpSecretLabel => 'Secret TOTP / otpauth';

  @override
  String get scanTotpQr => 'Scanner le code QR';

  @override
  String get scanTotpQrHint =>
      'Pointez la caméra vers le code QR de l\'authentificateur';

  @override
  String get invalidTotpQr => 'Ce code QR n\'est pas un code TOTP valide';

  @override
  String get cameraPermissionDenied =>
      'L\'autorisation de la caméra est requise pour scanner les codes QR';

  @override
  String get storePasskeyMetadata => 'Clé d’accès';

  @override
  String get passkeyCreatedInBrowser =>
      'Créez des passkeys avec l’extension OpenKey ou via le remplissage auto / fournisseur d’identifiants sur mobile lorsque OpenKey est déverrouillé.';

  @override
  String get rpId => 'RP ID';

  @override
  String get credentialId => 'ID d’identifiant';

  @override
  String get addPasskeyItem => 'Pas encore de passkey';

  @override
  String bytesLabel(int n) {
    return '$n octets';
  }

  @override
  String get addEncryptedAttachment => 'Ajouter une pièce jointe chiffrée';

  @override
  String get expiryHint => 'MM/AA';

  @override
  String get autoLockSubtitle =>
      'Verrouille le coffre après avoir quitté l’application.';

  @override
  String get serverUrl => 'URL du serveur';

  @override
  String get serverUrlHint => 'https://openkey.example.com';

  @override
  String get serverSheetSubtitle =>
      'Inscrivez-vous ou connectez-vous pour synchroniser uniquement le chiffrement du coffre.';

  @override
  String get register => 'S’inscrire';

  @override
  String get registerSubtitle => 'Créer un compte sur ce serveur';

  @override
  String get login => 'Connexion';

  @override
  String get loginSubtitle =>
      'Connectez-vous avec le hachage d’auth de ce coffre';

  @override
  String get syncNow => 'Synchroniser maintenant';

  @override
  String get syncing => 'Synchronisation…';

  @override
  String get syncSubtitle => 'Envoyer et recevoir les changements chiffrés';

  @override
  String get syncComplete => 'Synchronisation terminée';

  @override
  String get extensionLinkCopied => 'Charge utile du lien d’extension copiée';

  @override
  String get biometricUnlockEnabled => 'Déverrouillage biométrique activé';

  @override
  String get biometricUnlockDisabled => 'Déverrouillage biométrique désactivé';

  @override
  String biometricsUpdateFailed(String error) {
    return 'Impossible de mettre à jour la biométrie : $error';
  }

  @override
  String get bitwardenJson => 'Bitwarden JSON';

  @override
  String get bitwardenJsonSubtitle =>
      'Exporter depuis Bitwarden → importer ici';

  @override
  String get openKeyJson => 'OpenKey JSON';

  @override
  String get openKeyJsonSubtitle => 'Sauvegarde exportée depuis OpenKey';

  @override
  String get chromeCsv => 'Chrome CSV';

  @override
  String get chromeCsvSubtitle => 'Mots de passe exportés depuis Chrome';

  @override
  String get lastPassCsv => 'LastPass CSV';

  @override
  String get lastPassCsvSubtitle => 'Export CSV depuis LastPass';

  @override
  String get keePassKdbx => 'KeePass (.kdbx)';

  @override
  String get keePassKdbxSubtitle => 'Base KeePass / KeePassXC chiffrée';

  @override
  String get keePassPasswordHint => 'Mot de passe de la base';

  @override
  String get keePassKeyFile => 'Fichier clé (optionnel)';

  @override
  String get keePassUnlockFailed =>
      'Impossible d’ouvrir la base KeePass. Vérifiez le mot de passe et le fichier clé.';

  @override
  String get onePasswordCsv => '1Password CSV';

  @override
  String get onePasswordCsvSubtitle => 'Export CSV depuis 1Password';

  @override
  String get importingPasswords => 'Importation…';

  @override
  String importingProgress(int done, int total) {
    return 'Importation de $done sur $total…';
  }

  @override
  String importedItems(int n) {
    return '$n éléments importés';
  }

  @override
  String get failureUnknown => 'Une erreur s’est produite.';

  @override
  String get failureNetwork => 'Erreur réseau. Vérifiez votre connexion.';

  @override
  String get failureUnauthorized => 'Non autorisé. Veuillez vous reconnecter.';

  @override
  String get failureNotFound => 'Introuvable.';

  @override
  String get failureServer => 'Erreur serveur.';

  @override
  String get failureInvalidCredentials =>
      'E-mail ou mot de passe maître invalide.';

  @override
  String get failureVaultLocked => 'Le coffre est verrouillé.';

  @override
  String get failureVaultAlreadyExists =>
      'Un coffre existe déjà sur cet appareil.';

  @override
  String get failureDecryptionFailed =>
      'Impossible de déchiffrer les données du coffre.';

  @override
  String get failureSyncFailed => 'Échec de la synchronisation.';

  @override
  String get failureCreateCollection =>
      'Échec de la création de la collection.';

  @override
  String get failureUpdateCollection =>
      'Échec de la mise à jour de la collection.';

  @override
  String get failureDeleteCollection =>
      'Échec de la suppression de la collection.';

  @override
  String get failureGetCollections => 'Échec du chargement des collections.';

  @override
  String get failureCreateEntry => 'Échec de la création de l’entrée.';

  @override
  String get failureUpdateEntry => 'Échec de la mise à jour de l’entrée.';

  @override
  String get failureDeleteEntry => 'Échec de la suppression de l’entrée.';

  @override
  String get failureGetEntries => 'Échec du chargement des entrées.';

  @override
  String get failureNoVault => 'Aucun coffre trouvé. Créez-en un d’abord.';

  @override
  String get failureConnectServerFirst =>
      'Connectez d’abord un serveur dans Paramètres.';

  @override
  String get failureAttachmentTooLarge =>
      'La pièce jointe dépasse la limite de 20 Mo.';

  @override
  String get failureAttachmentMissing =>
      'Chiffrement de la pièce jointe manquant.';

  @override
  String get failureAccountEmailExists =>
      'Cet e-mail a déjà un coffre sur cet appareil.';

  @override
  String get root => 'Racine';

  @override
  String get selectedItems => 'sélectionnés';

  @override
  String get authenticatorTotp => 'Authentificateur (TOTP)';

  @override
  String get openKeyPro => 'OpenKey Pro';

  @override
  String get proSubtitle =>
      'Débloquez les fonctions premium et soutenez le développement d’OpenKey.';

  @override
  String get premiumFeatureTitle => 'Fonctionnalité premium';

  @override
  String get premiumFeatureSubtitle =>
      'Abonnez-vous pour débloquer cette fonctionnalité premium.';

  @override
  String get premiumFeatureContent =>
      'Ceci est une fonctionnalité premium. Abonnez-vous pour y accéder.';

  @override
  String get premiumBadge => 'Pro';

  @override
  String get subscribe => 'S’abonner';

  @override
  String get upgradeNow => 'Passer à Pro';

  @override
  String get oops => 'Oups !';

  @override
  String get subscription => 'Abonnement';

  @override
  String get subscriptionTitle => 'Abonnement';

  @override
  String get subscriptionSubtitle => 'Choisissez une offre qui vous convient.';

  @override
  String get manageYourSubscription => 'Gérer votre abonnement';

  @override
  String get manageSubscriptionAction => 'Gérer l’abonnement';

  @override
  String get subIsActiveTitle => 'Votre abonnement est actif';

  @override
  String get subIsNotActiveTitle => 'Votre abonnement est inactif';

  @override
  String get thanksForSubscribing => 'Merci de votre abonnement !';

  @override
  String get subIsCancelled =>
      'Votre abonnement est annulé et ne sera pas renouvelé.';

  @override
  String get subIsPaused => 'Votre abonnement est en pause.';

  @override
  String get restorePurchase => 'Restaurer l’achat';

  @override
  String get viewPlansPaywall => 'Voir les options d’abonnement';

  @override
  String get openCustomerCenter => 'Gérer dans le centre client';

  @override
  String get subscriptionDesktopNote =>
      'Les achats intégrés sont disponibles sur Android, iOS et macOS. Sous Windows et Linux, connectez-vous avec le même compte OpenKey pour débloquer Pro après un abonnement sur mobile ou Mac.';

  @override
  String get subscriptionRefreshStatus => 'Actualiser l’état de l’abonnement';

  @override
  String get subscriptionNoInternetMsg =>
      'Problème de connexion Internet. Vérifiez le réseau et réessayez.';

  @override
  String get subscriptionRegionBlockedMsg =>
      'Les services d’abonnement ne sont pas accessibles dans votre région. Connectez-vous à un VPN et réessayez.';

  @override
  String get monthly => 'Mensuel';

  @override
  String get yearly => 'Annuel';

  @override
  String get lifetime => 'À vie';

  @override
  String get monthlySubtitle => 'Renouvellement auto, résiliez à tout moment';

  @override
  String get yearlySubtitle =>
      'Renouvellement auto, meilleur rapport, résiliez à tout moment';

  @override
  String get lifetimeSubtitle => 'Achat unique, à vous pour toujours';

  @override
  String monthlyPriceLabel(String price) {
    return '$price/mois';
  }

  @override
  String yearlyPriceLabel(String price) {
    return '$price/an';
  }

  @override
  String lifetimePriceLabel(String price) {
    return '$price';
  }

  @override
  String monthlySubscribeLabel(String price) {
    return 'S’abonner pour $price / mois';
  }

  @override
  String yearlySubscribeLabel(String price) {
    return 'S’abonner pour $price / an';
  }

  @override
  String lifetimeSubscribeLabel(String price) {
    return 'Acheter à vie pour $price';
  }

  @override
  String get bestValue => 'Meilleure offre';

  @override
  String get skip => 'Passer';

  @override
  String get getStarted => 'Commencer';

  @override
  String get onboardingFaqTitle => 'À savoir avant de commencer';

  @override
  String get onboardingFaqSubtitle =>
      'Les questions les plus fréquentes sur OpenKey. Appuyez pour développer — puis créez votre coffre.';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingWelcomeTitle => 'Vos clés. Votre coffre.';

  @override
  String get onboardingWelcomeSubtitle =>
      'OpenKey regroupe mots de passe, codes et cartes dans un espace chiffré — conçu pour le quotidien.';

  @override
  String get onboardingWelcomePhrase1 => 'Zéro connaissance par conception';

  @override
  String get onboardingWelcomePhrase2 =>
      'Remplissage automatique en un toucher';

  @override
  String get onboardingWelcomePhrase3 => 'Auto-hébergé quand vous voulez';

  @override
  String get onboardingSecurityTitle => 'Personne d’autre ne peut le lire';

  @override
  String get onboardingSecuritySubtitle =>
      'Le chiffrement de bout en bout signifie que votre mot de passe maître ne quitte jamais cet appareil. Nous ne stockons que du texte chiffré.';

  @override
  String get onboardingAutofillTitle =>
      'Remplissez une fois. Faites confiance toujours.';

  @override
  String get onboardingAutofillSubtitle =>
      'Connectez-vous aux apps et sites sans chercher vos mots de passe. Le remplissage automatique intègre OpenKey au quotidien.';

  @override
  String get onboardingAllInOneTitle => 'Une app. Tout le coffre.';

  @override
  String get onboardingAllInOneSubtitle =>
      'Mots de passe, codes d’authentification, cartes, portefeuilles crypto et secrets développeur — remplacez le désordre par un seul coffre de confiance.';

  @override
  String get onboardingFeaturePasswords => 'Mots de passe';

  @override
  String get onboardingFeatureCrypto => 'Crypto';

  @override
  String get onboardingFeatureAutofill => 'Remplissage auto';

  @override
  String get onboardingFeatureSelfHost => 'Auto-hébergé.';

  @override
  String get onboardingFooterHint =>
      'Moins d’une minute. Vous pouvez passer à tout moment.';

  @override
  String get onboardingLetsGo => 'C’est parti !';

  @override
  String onboardingStepOf(int current, int total) {
    return 'Étape $current sur $total';
  }

  @override
  String get onboardingWelcomeHeadline => 'Bienvenue\nsur OpenKey.';

  @override
  String get onboardingWelcomeLead => 'Configurons tout pour vous';

  @override
  String get onboardingEcosystemTitle => 'Votre\ncoffre\ncomplet.';

  @override
  String get onboardingEcosystemSubtitle =>
      'Mots de passe, codes et cartes — chiffrés et prêts partout où vous vous connectez.';

  @override
  String get onboardingStyleTitle => 'À votre\nstyle.';

  @override
  String get onboardingEnableAutofillTitle => 'Activez\nle remplissage.';

  @override
  String get onboardingAutofillCardTitle => 'Remplissage des mots de passe';

  @override
  String get onboardingAutofillCardSubtitle =>
      'Remplissez vos connexions dans les apps et sites depuis votre coffre.';

  @override
  String get onboardingAutofillGranted => 'Le remplissage est prêt';

  @override
  String get onboardingFinishBadge => 'Configuration terminée';

  @override
  String get onboardingFinishTitle => 'Prêt à\nverrouiller.';

  @override
  String get onboardingFinishSubtitle =>
      'Créez un mot de passe maître et commencez à enregistrer l’essentiel — votre coffre est à un pas.';

  @override
  String get onboardingCreateVault => 'Créer le coffre';

  @override
  String get errorLoadingData => 'Erreur de chargement. Veuillez réessayer.';

  @override
  String get retryAgain => 'Réessayer';

  @override
  String get autoRenewLabel => 'Renouvellement automatique';

  @override
  String get cancelledLabel => 'Annulé';

  @override
  String get pausedLabel => 'En pause';

  @override
  String get supportAppDevelopmentTitle => 'Soutenir le développement';

  @override
  String get supportAppDevelopmentSubtitle =>
      'Votre abonnement nous aide à améliorer OpenKey.';

  @override
  String get limitEntriesTitle => 'Limite d’entrées atteinte';

  @override
  String get limitCollectionsTitle => 'Limite de collections atteinte';

  @override
  String get limitWalletsTitle => 'Limite de cartes atteinte';

  @override
  String get limitCryptoWalletsTitle =>
      'Limite de portefeuilles crypto atteinte';

  @override
  String get limitSecretsTitle => 'Limite de secrets atteinte';

  @override
  String limitReachedContent(int usage, int limit, String feature) {
    return 'Vous avez utilisé $usage sur $limit $feature. Passez à Pro pour un accès illimité.';
  }

  @override
  String limitSubtitle(int limit, String feature) {
    return 'L’offre gratuite inclut jusqu’à $limit $feature.';
  }

  @override
  String get entries => 'entrées';

  @override
  String get collections => 'collections';

  @override
  String get cards => 'cartes';

  @override
  String get cryptoWalletsFeature => 'portefeuilles crypto';

  @override
  String get secretsFeature => 'secrets';

  @override
  String expiresOn(String date) {
    return 'Expire le $date';
  }

  @override
  String get unlockUnlimitedEntriesTitle => 'Entrées illimitées';

  @override
  String get unlockUnlimitedEntriesSubtitle =>
      'Stockez autant de mots de passe et identifiants que nécessaire.';

  @override
  String get unlockUnlimitedCollectionsTitle => 'Collections illimitées';

  @override
  String get unlockUnlimitedCollectionsSubtitle =>
      'Organisez votre coffre avec autant de dossiers que vous voulez.';

  @override
  String get unlockUnlimitedWalletsTitle => 'Cartes illimitées';

  @override
  String get unlockUnlimitedWalletsSubtitle =>
      'Enregistrez autant de cartes de paiement que nécessaire.';

  @override
  String get unlockUnlimitedCryptoWalletsTitle =>
      'Portefeuilles crypto illimités';

  @override
  String get unlockUnlimitedCryptoWalletsSubtitle =>
      'Stockez adresses, clés et phrases de récupération sans limites.';

  @override
  String get unlockUnlimitedSecretsTitle => 'Secrets développeur illimités';

  @override
  String get unlockUnlimitedSecretsSubtitle =>
      'Stockez clés SSH, jetons API et extraits .env sans limites.';

  @override
  String get unlockSyncTitle => 'Sync serveur';

  @override
  String get unlockSyncSubtitle =>
      'Connectez votre serveur auto-hébergé et synchronisez entre appareils.';

  @override
  String get unlockAttachmentsTitle => 'Pièces jointes';

  @override
  String get unlockAttachmentsSubtitle =>
      'Joignez des fichiers chiffrés aux entrées du coffre.';

  @override
  String get unlockImportExportTitle => 'Import et export';

  @override
  String get unlockImportExportSubtitle =>
      'Importez et exportez des données avec OpenKey.';

  @override
  String get unknownFailureMsg => 'Une erreur inconnue s’est produite.';

  @override
  String get purchaseCancelledMsg => 'L’achat a été annulé.';

  @override
  String get storeProblemMsg => 'Un problème est survenu avec le magasin.';

  @override
  String get purchaseNotAllowedMsg =>
      'Les achats ne sont pas autorisés sur cet appareil.';

  @override
  String get purchaseInvalidMsg => 'L’achat n’est pas valide.';

  @override
  String get productNotAvailableForPurchaseMsg =>
      'Ce produit n’est pas disponible à l’achat.';

  @override
  String get productAlreadyPurchasedMsg => 'Ce produit a déjà été acheté.';

  @override
  String get receiptAlreadyInUseMsg => 'Ce reçu est déjà utilisé.';

  @override
  String get invalidReceiptMsg => 'Le reçu n’est pas valide.';

  @override
  String get missingReceiptFileMsg => 'Le fichier de reçu est manquant.';

  @override
  String get networkErrorMsg =>
      'Une erreur réseau s’est produite. Vérifiez votre connexion.';

  @override
  String get invalidCredentialsMsg => 'Identifiants invalides.';

  @override
  String get unexpectedBackendResponseMsg => 'Réponse inattendue du serveur.';

  @override
  String get receiptInUseByOtherSubscriberMsg =>
      'Le reçu est utilisé par un autre abonné.';

  @override
  String get invalidAppUserIdMsg => 'L’ID utilisateur de l’app est invalide.';

  @override
  String get operationAlreadyInProgressMsg =>
      'Une opération est déjà en cours.';

  @override
  String get unknownBackendErrorMsg =>
      'Une erreur inconnue s’est produite sur le serveur.';

  @override
  String get invalidAppleSubscriptionKeyMsg =>
      'La clé d’abonnement Apple est invalide.';

  @override
  String get ineligibleMsg => 'Vous n’êtes pas éligible à cet achat.';

  @override
  String get insufficientPermissionsMsg =>
      'Vous n’avez pas les permissions suffisantes.';

  @override
  String get paymentPendingMsg => 'Le paiement est en attente.';

  @override
  String get invalidSubscriberAttributesMsg =>
      'Les attributs d’abonné sont invalides.';

  @override
  String get logOutWithAnonymousUserMsg =>
      'Impossible de se déconnecter avec un utilisateur anonyme.';

  @override
  String get configurationErrorMsg => 'Il y a une erreur de configuration.';

  @override
  String get unsupportedErrorMsg =>
      'Cette opération n’est pas prise en charge.';

  @override
  String get emptySubscriberAttributesMsg =>
      'Les attributs d’abonné sont vides.';

  @override
  String get productDiscountMissingIdentifierMsg =>
      'L’identifiant de remise du produit est manquant.';

  @override
  String get unknownNonNativeErrorMsg =>
      'Une erreur non native inconnue s’est produite.';

  @override
  String get productDiscountMissingSubscriptionGroupIdentifierMsg =>
      'L’identifiant de groupe d’abonnement de la remise est manquant.';

  @override
  String get customerInfoErrorMsg =>
      'Échec de la récupération des informations client.';

  @override
  String get systemInfoErrorMsg =>
      'Échec de la récupération des informations système.';

  @override
  String get beginRefundRequestErrorMsg =>
      'Échec du démarrage de la demande de remboursement.';

  @override
  String get productRequestTimeoutMsg => 'Délai de la demande produit dépassé.';

  @override
  String get apiEndpointBlockedMsg => 'Le point de terminaison API est bloqué.';

  @override
  String get invalidPromotionalOfferMsg =>
      'L’offre promotionnelle est invalide.';

  @override
  String get offlineConnectionMsg =>
      'Pas de connexion Internet. Connectez-vous et réessayez.';

  @override
  String get featureNotAvailableInCustomEntitlementsComputationModeMsg =>
      'Cette fonctionnalité n’est pas disponible en mode de calcul des droits personnalisé.';

  @override
  String get signatureVerificationFailedMsg =>
      'Échec de la vérification de signature.';

  @override
  String get featureNotSupportedWithStoreKit1Msg =>
      'Cette fonctionnalité n’est pas prise en charge avec StoreKit 1.';

  @override
  String get invalidWebPurchaseTokenMsg => 'Le jeton d’achat web est invalide.';

  @override
  String get purchaseBelongsToOtherUserMsg =>
      'Cet achat appartient à un autre utilisateur.';

  @override
  String get expiredWebPurchaseTokenMsg => 'Le jeton d’achat web a expiré.';

  @override
  String get testStoreSimulatedPurchaseErrorMsg =>
      'Erreur d’achat simulé du magasin de test.';

  @override
  String get aboutApp => 'À propos de l’app';

  @override
  String get aboutAppSubtitle =>
      'En savoir plus sur OpenKey et son développement.';

  @override
  String get developerName => 'OpenSelfHosting';

  @override
  String get developer => 'Des logiciels open source que vous hébergez';

  @override
  String rateUsIn(String storeName) {
    return 'Notez-nous sur $storeName';
  }

  @override
  String get doYouLikeTheAppRateUs => 'Vous aimez l’app ? Notez-nous !';

  @override
  String get licenses => 'Licences';

  @override
  String get openLicenses => 'Ouvrir les licences';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get privacyPolicySubtitle => 'Lire notre politique de confidentialité';

  @override
  String get termsOfService => 'Conditions d’utilisation';

  @override
  String get termsOfServiceSubtitle => 'Lire nos conditions d’utilisation';

  @override
  String get pricing => 'Tarifs';

  @override
  String get pricingSubtitle => 'Offres Gratuit vs OpenKey Pro';

  @override
  String get copied => 'Copié dans le presse-papiers';

  @override
  String get contact => 'Contact';

  @override
  String get contactSubtitle => 'Contactez-nous pour de l’aide ou des retours.';

  @override
  String get telegram => 'Telegram';

  @override
  String get ok => 'OK';

  @override
  String get localBackupRestoreTitle => 'Sauvegarde et restauration';

  @override
  String get localBackupRestoreSubtitle =>
      'Créez une sauvegarde chiffrée du coffre entier (.okbak), ou restaurez-en une. Inclut la base de données, les réglages et les pièces jointes.';

  @override
  String get exportBackup => 'Exporter la sauvegarde';

  @override
  String get exportBackupSubtitleEmpty =>
      'Créez une sauvegarde locale chiffrée et choisissez où l’enregistrer.';

  @override
  String exportBackupSubtitleLatest(String path) {
    return 'Dernier export : $path';
  }

  @override
  String get importBackup => 'Restaurer la sauvegarde';

  @override
  String get importBackupSubtitle =>
      'Remplacez ce coffre par une sauvegarde OpenKey chiffrée (.okbak).';

  @override
  String get confirmRestore => 'Confirmer la restauration';

  @override
  String get confirmRestoreMessage =>
      'La restauration remplace la base locale, les réglages et les pièces jointes par la sauvegarde. Saisissez le mot de passe maître de cette sauvegarde pour la déchiffrer.';

  @override
  String get creatingBackup => 'Création de la sauvegarde…';

  @override
  String get creatingBackupBody =>
      'Compression et chiffrement de tout le coffre.';

  @override
  String get restoringBackupProgress => 'Restauration de la sauvegarde…';

  @override
  String get restoringBackupBody =>
      'Déchiffrement et restauration de votre coffre.';

  @override
  String get restoringBackupVerifying => 'Vérification du mot de passe maître…';

  @override
  String get restoringBackupDecrypting =>
      'Déchiffrement des données de sauvegarde…';

  @override
  String get restoringBackupWriting => 'Écriture du coffre restauré…';

  @override
  String get restoringBackupUnlocking => 'Ouverture du coffre restauré…';

  @override
  String get backupComplete => 'Sauvegarde terminée';

  @override
  String get backupCompleteLocalBody =>
      'Votre sauvegarde chiffrée a été enregistrée.';

  @override
  String get backupCompleteLocalDetail =>
      'Conservez ce fichier en lieu sûr. Le mot de passe maître est requis pour le restaurer.';

  @override
  String get backupError => 'Erreur de sauvegarde';

  @override
  String get restoreCompleted => 'Restauration terminée';

  @override
  String get restoreCompletedBody =>
      'Votre coffre a été restauré depuis la sauvegarde chiffrée.';
}
