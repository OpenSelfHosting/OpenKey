// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get settings => 'Ajustes';

  @override
  String get appearance => 'Apariencia';

  @override
  String get appearanceSubtitle => 'Tema, colores, fuentes e idioma';

  @override
  String get themeMode => 'Modo de tema';

  @override
  String get system => 'Sistema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get language => 'Idioma';

  @override
  String get fonts => 'Fuentes';

  @override
  String get displayFont => 'Fuente de visualización';

  @override
  String get defaultFont => 'Predeterminada';

  @override
  String get arabicFont => 'Árabe';

  @override
  String get developerFont => 'Desarrollador';

  @override
  String get technicalFont => 'Técnica';

  @override
  String get standardFont => 'Estándar';

  @override
  String get defaultFontDes => 'La fuente predeterminada de la aplicación.';

  @override
  String get arabicFontDes => 'Una fuente optimizada para la escritura árabe.';

  @override
  String get developerFontDes => 'Una fuente diseñada para desarrolladores.';

  @override
  String get technicalFontDes => 'Una fuente adecuada para contenido técnico.';

  @override
  String get standardFontDes => 'Una fuente estándar de uso general.';

  @override
  String get googleSansFlexFont => 'Google Sans Flex';

  @override
  String get googleSansFlexFontDes =>
      'La tipografía expresiva de marca de Google para Material 3 Expressive.';

  @override
  String get robotoFlexFont => 'Roboto Flex';

  @override
  String get robotoFlexFontDes =>
      'Fuente variable de Material Design con peso, ancho y tamaño óptico.';

  @override
  String get figtreeFont => 'Figtree';

  @override
  String get figtreeFontDes =>
      'Una sans geométrica suave, ideal con temas Material You.';

  @override
  String get nunitoFont => 'Nunito';

  @override
  String get nunitoFontDes =>
      'A rounded geometric sans with a friendly, modern tone.';

  @override
  String get dynamicColors => 'Colores dinámicos';

  @override
  String get dynamicColorsSubtitle =>
      'Crear el tema a partir de un color elegido';

  @override
  String get colorScheme => 'Esquema de color';

  @override
  String get colorSchemeSubtitle => 'Elige un color base y un estilo';

  @override
  String get highContrast => 'Alto contraste';

  @override
  String get highContrastSubtitle => 'Aumenta el contraste para leer mejor';

  @override
  String get security => 'Seguridad';

  @override
  String get securitySubtitle =>
      'Bloqueo automático, biometría, autocompletado y contraseña maestra';

  @override
  String get account => 'Cuenta';

  @override
  String get accountPageTitle => 'Cuenta';

  @override
  String get accountPhoto => 'Foto de perfil';

  @override
  String get changeAccountPhoto => 'Cambiar foto';

  @override
  String get removeAccountPhoto => 'Quitar foto';

  @override
  String get changeEmail => 'Cambiar correo';

  @override
  String get changeEmailSubtitle =>
      'Vuelve a envolver la clave de la bóveda. Desbloquearás con el correo nuevo.';

  @override
  String get newEmail => 'Correo nuevo';

  @override
  String get emailChanged => 'Correo actualizado';

  @override
  String get switchAccount => 'Cambiar de cuenta';

  @override
  String get addAccount => 'Añadir cuenta';

  @override
  String get addAccountSubtitle =>
      'Crea o inicia sesión en otra bóveda en este dispositivo';

  @override
  String get removeAccountFromDevice => 'Quitar de este dispositivo';

  @override
  String get removeAccountFromDeviceSubtitle =>
      'Elimina esta bóveda local. La cuenta del servidor vinculada no se elimina.';

  @override
  String get removeAccountConfirm =>
      'Esta bóveda y sus elementos se eliminarán de este dispositivo. Esta acción no se puede deshacer.';

  @override
  String get otherAccounts => 'Otras cuentas';

  @override
  String get useThisAccount => 'Usar esta cuenta';

  @override
  String get currentAccount => 'Cuenta actual';

  @override
  String get chooseAccount => 'Elegir cuenta';

  @override
  String get switchingAccount => 'Cambiando de cuenta…';

  @override
  String get welcomeBackShort => 'Bienvenido de nuevo';

  @override
  String get tools => 'Herramientas';

  @override
  String get help => 'Ayuda';

  @override
  String get autoLock => 'Bloqueo automático';

  @override
  String minutesLabel(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n minutos',
      one: '$n minuto',
    );
    return '$_temp0';
  }

  @override
  String get autoLockOff => 'Desactivado';

  @override
  String get blockScreenshot => 'Bloquear capturas de pantalla';

  @override
  String get blockScreenshotSubtitle =>
      'Impide capturas y grabaciones de pantalla de la app.';

  @override
  String get blockScreenshotLinuxNote =>
      'En Linux es limitado — el compositor puede permitir capturas.';

  @override
  String get biometricUnlock => 'Desbloqueo biométrico';

  @override
  String get autofillService => 'Servicio de autocompletar';

  @override
  String get autofillEnabled =>
      'OpenKey es tu proveedor de contraseñas y passkeys';

  @override
  String get autofillDisabled =>
      'Activa OpenKey para contraseñas (Autocompletar) y passkeys (proveedor de credenciales)';

  @override
  String get autofillDisabledBrowser =>
      'Instala la extensión de OpenKey y desbloquea la bóveda';

  @override
  String get autofillSaveTitle => 'Guardar contraseña';

  @override
  String get autofillSaveSubtitle =>
      '¿Guardar este acceso en tu bóveda de OpenKey?';

  @override
  String get autofillSaved => 'Contraseña guardada';

  @override
  String get autofillRequireBiometric => 'Pedir biometría para Autocompletar';

  @override
  String get autofillRequireBiometricSubtitle =>
      'Pedir huella o rostro antes de rellenar contraseñas en apps y sitios.';

  @override
  String get autofillRequireBiometricReason =>
      'Confirmar Autocompletar con OpenKey';

  @override
  String get autofillRequireBiometricEnabled =>
      'Confirmación biométrica de Autocompletar activada';

  @override
  String get autofillRequireBiometricDisabled =>
      'Confirmación biométrica de Autocompletar desactivada';

  @override
  String get autofillInline => 'En el teclado';

  @override
  String get autofillInlineSubtitle =>
      'Mostrar sugerencias en la barra del teclado.';

  @override
  String get autofillPopup => 'Encima del campo';

  @override
  String get autofillPopupSubtitle =>
      'Mostrar un menú desplegable sobre el campo de entrada.';

  @override
  String get androidApp => 'App de Android';

  @override
  String get androidAppHint => 'Nombre del paquete, p. ej. com.example.app';

  @override
  String get biometricUnlockReason => 'Desbloquea tu bóveda de OpenKey';

  @override
  String get enableBiometricUnlockReason => 'Activar el desbloqueo biométrico';

  @override
  String get biometricHint => 'Verifica tu identidad';

  @override
  String get biometricNotRecognized => 'No reconocido. Inténtalo de nuevo.';

  @override
  String get goToSettings => 'Ir a ajustes';

  @override
  String get biometricGoToSettingsDescription =>
      'La autenticación biométrica no está configurada. Ve a Ajustes para registrar huella o rostro.';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get unlocking => 'Desbloqueando…';

  @override
  String get masterPassword => 'Contraseña maestra';

  @override
  String get unlockSubtitle =>
      'Introduce tu contraseña maestra para desbloquear.';

  @override
  String welcomeBack(String email) {
    return 'Bienvenido de nuevo, $email';
  }

  @override
  String get fieldRequired => 'Obligatorio';

  @override
  String get resetLocalVault => 'Restablecer bóveda local';

  @override
  String get resetLocalVaultTitle => '¿Restablecer bóveda local?';

  @override
  String get resetLocalVaultSubtitle =>
      'Elimina permanentemente todos los datos de la bóveda en este dispositivo.';

  @override
  String get resetLocalVaultConfirm =>
      'Todas las contraseñas y datos de la bóveda en este dispositivo se eliminarán permanentemente para que puedas crear una nueva. Los datos del servidor no se eliminan. No se puede deshacer.';

  @override
  String get dangerZone => 'Zona de peligro';

  @override
  String get reset => 'Restablecer';

  @override
  String get createVault => 'Crear bóveda';

  @override
  String get creatingVault => 'Creando…';

  @override
  String get setupSubtitle =>
      'Crea tu bóveda cifrada. Tu contraseña maestra nunca sale de este dispositivo.';

  @override
  String get setupSignInSubtitle =>
      'Inicia sesión en tu servidor OpenKey autoalojado para restaurar esta bóveda en el dispositivo.';

  @override
  String get setupModeCreate => 'Crear';

  @override
  String get setupModeSignIn => 'Iniciar sesión';

  @override
  String get setupModeRestore => 'Restaurar';

  @override
  String get setupSignInAction => 'Iniciar sesión';

  @override
  String get setupSigningIn => 'Iniciando sesión…';

  @override
  String get setupRestoreSubtitle =>
      'Restaura tu bóveda desde una copia cifrada de OpenKey (.okbak).';

  @override
  String get setupRestoreAction => 'Restaurar bóveda';

  @override
  String get setupRestoreChooseFile => 'Elegir archivo de copia';

  @override
  String get setupRestoreChooseFileSubtitle =>
      'Selecciona un archivo .okbak cifrado.';

  @override
  String setupRestoreBackupAccount(String email) {
    return 'Esta copia es de $email';
  }

  @override
  String get setupRestoreNeedFile => 'Elige un archivo de copia primero';

  @override
  String get setupLinkSelfHostedTitle => 'Vincular servidor autoalojado';

  @override
  String get setupLinkSelfHostedSubtitle =>
      'Opcional. Registra esta bóveda para sincronizar entre dispositivos.';

  @override
  String get setupLinkServerHelper =>
      'Tu bóveda se registrará en este servidor tras crearla.';

  @override
  String get setupSignInServerHelper =>
      'URL del servidor OpenKey que ya tiene tu cuenta.';

  @override
  String get setupChooserTitle => '¿Cómo quieres empezar?';

  @override
  String get setupChooserSubtitle =>
      'Crea una bóveda, inicia sesión o restaura una copia de seguridad.';

  @override
  String get setupChooseCreateTitle => 'Crear una bóveda';

  @override
  String get setupChooseCreateSubtitle =>
      'Nueva bóveda cifrada en este dispositivo.';

  @override
  String get setupChooseSignInTitle => 'Iniciar sesión';

  @override
  String get setupChooseSignInSubtitle =>
      'Restaura desde tu servidor OpenKey autoalojado.';

  @override
  String get setupChooseRestoreTitle => 'Restaurar copia';

  @override
  String get setupChooseRestoreSubtitle => 'Abre un archivo .okbak cifrado.';

  @override
  String get invalidServerUrl =>
      'Introduce una URL válida que empiece por http:// o https://';

  @override
  String get confirmMasterPassword => 'Confirmar contraseña maestra';

  @override
  String get email => 'Correo';

  @override
  String get invalidEmail => 'Introduce un correo válido';

  @override
  String get invalidEmailFormat => 'Correo electrónico no válido';

  @override
  String get invalidUrlFormat =>
      'URL no válida. Usa un formato como https://example.com';

  @override
  String get invalidPhoneFormat => 'Número de teléfono no válido';

  @override
  String get invalidPinFormat => 'El PIN debe tener entre 4 y 12 dígitos';

  @override
  String get invalidNumberFormat => 'Introduce solo dígitos';

  @override
  String get invalidCardFormat => 'Número de tarjeta no válido';

  @override
  String get invalidIpFormat => 'Dirección IP no válida';

  @override
  String get invalidWalletFormat => 'Dirección de cartera no válida';

  @override
  String get invalidRecoveryCodesFormat => 'Códigos de recuperación no válidos';

  @override
  String get fixFieldErrors => 'Corrige los campos resaltados antes de guardar';

  @override
  String get passwordTooShort => 'Al menos 8 caracteres';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get passwordTooShortStrong => 'Al menos 12 caracteres';

  @override
  String get passwordTooWeak =>
      'Usa una mezcla más larga de letras, números y símbolos';

  @override
  String get masterPasswordHelper =>
      'Se recomiendan 12+ caracteres de tipos mixtos';

  @override
  String get passwordHintOptional => 'Pista de contraseña (opcional)';

  @override
  String get passwordHintHelper =>
      'Solo un recordatorio vago — nunca incluyas la contraseña';

  @override
  String passwordHintReveal(String hint) {
    return 'Pista: $hint';
  }

  @override
  String get setupZeroKnowledgeBanner =>
      'Cifrado de conocimiento cero: OpenKey no puede leer ni restablecer tu bóveda.';

  @override
  String get vaultNoticesTitle => 'Antes de crear tu bóveda';

  @override
  String get vaultNoticesSubtitle => 'Confirma estos puntos para continuar.';

  @override
  String get vaultNoticeNoRecovery =>
      'Si olvidas tu contraseña maestra, tus datos no se pueden recuperar.';

  @override
  String get vaultNoticeLocalEncryption =>
      'Tu bóveda se cifra en este dispositivo; tu contraseña maestra nunca lo abandona en texto plano.';

  @override
  String get vaultNoticeBackups =>
      'Las copias cifradas periódicas son la única protección ante la pérdida del dispositivo.';

  @override
  String get vaultNoticeDeviceTransfer =>
      'Pasar a un dispositivo nuevo requiere restaurar una copia o la sincronización opcional con el servidor.';

  @override
  String get acceptAllNotices => 'Aceptar todo';

  @override
  String get server => 'Servidor autoalojado';

  @override
  String get notConnected => 'No conectado';

  @override
  String get data => 'Datos y uso compartido';

  @override
  String get dataSubtitle =>
      'Servidor, copia de seguridad, importación/exportación y uso compartido';

  @override
  String get importExport => 'Importar y exportar';

  @override
  String get importExportSubtitle =>
      'Mueve contraseñas dentro o fuera de tu bóveda';

  @override
  String get importTab => 'Importar';

  @override
  String get exportTab => 'Exportar';

  @override
  String get importPasswords => 'Importar contraseñas';

  @override
  String get importPasswordsSubtitle =>
      'Las entradas se cifran con la clave de tu bóveda en este dispositivo.';

  @override
  String get exportPasswords => 'Exportar contraseñas';

  @override
  String get exportPasswordsSubtitle =>
      'Descifra las entradas en este dispositivo y guarda un archivo sin cifrar.';

  @override
  String get exportingPasswords => 'Exportando…';

  @override
  String get exportBitwardenSubtitle => 'JSON de Bitwarden sin cifrar';

  @override
  String get exportChromeSubtitle => 'CSV compatible con Chrome';

  @override
  String get exportLastPassSubtitle => 'CSV compatible con LastPass';

  @override
  String get exportOnePasswordSubtitle => 'CSV compatible con 1Password';

  @override
  String get exportKeePassSubtitle =>
      'Base de datos KeePass / KeePassXC cifrada (.kdbx)';

  @override
  String get exportOpenKeySubtitle =>
      'JSON de OpenKey sin cifrar con carpetas y datos completos';

  @override
  String get exportedItems => 'Bóveda exportada';

  @override
  String exportedToPath(String path) {
    return 'Exportado a $path';
  }

  @override
  String get changeMasterPassword => 'Cambiar contraseña maestra';

  @override
  String get changeMasterPasswordSubtitle =>
      'Vuelve a envolver la clave de la bóveda. Las entradas siguen cifradas con la misma clave.';

  @override
  String get currentMasterPassword => 'Contraseña maestra actual';

  @override
  String get newMasterPassword => 'Nueva contraseña maestra';

  @override
  String get masterPasswordUnchanged => 'Elige una contraseña distinta';

  @override
  String get masterPasswordChanged => 'Contraseña maestra actualizada';

  @override
  String get deleteServerAccount => 'Eliminar cuenta del servidor';

  @override
  String get deleteServerAccountSubtitle =>
      'Elimina tu texto cifrado del servidor. Este dispositivo conserva la bóveda local.';

  @override
  String get deleteServerAccountWarning =>
      'Esto no se puede deshacer. Los datos sincronizados en el servidor se eliminarán permanentemente.';

  @override
  String get serverAccountDeleted => 'Cuenta del servidor eliminada';

  @override
  String get browserExtension => 'Extensión del navegador';

  @override
  String get browserExtensionSubtitle =>
      'Conecta Chrome / Edge / Firefox a la bóveda desbloqueada';

  @override
  String get browserExtensionSheetSubtitle =>
      'Pega el ID de la extensión Chrome sin empaquetar desde chrome://extensions (modo desarrollador). Firefox usa un ID fijo automáticamente.';

  @override
  String get chromeExtensionId => 'ID de extensión de Chrome';

  @override
  String get chromeExtensionIdHint =>
      'Aparece bajo el nombre de la extensión en chrome://extensions';

  @override
  String get connectBrowserExtension => 'Conectar extensión';

  @override
  String get copyOfflineExtensionLink => 'Copiar enlace de bóveda sin conexión';

  @override
  String get extensionLinkClipboardWarning =>
      'Esto copia el material de desbloqueo del almacén en el portapapeles. Otras apps pueden leerlo hasta que borres el portapapeles o se limpie automáticamente después de un minuto.';

  @override
  String get browserExtensionHostReady =>
      'Host nativo registrado. Mantén OpenKey desbloqueado y pulsa “Usar app de escritorio” en la extensión.';

  @override
  String get browserExtensionHostHint =>
      'Desbloquea la bóveda, pega el ID de Chrome y conéctate.';

  @override
  String get browserExtensionHostFailed =>
      'No se pudo registrar el host nativo. Desbloquea la bóveda e inténtalo de nuevo.';

  @override
  String get cliTitle => 'CLI';

  @override
  String get cliSubtitle =>
      'Instala la CLI de OpenKey y ejecuta el comando de conexión con la bóveda desbloqueada.';

  @override
  String get cliTermuxTitle => 'Termux / CLI';

  @override
  String get cliTermuxSubtitle =>
      'Instala la CLI de OpenKey en Termux y ejecuta el comando de conexión con la bóveda desbloqueada.';

  @override
  String get cliTermuxInstall => 'Instalar';

  @override
  String get cliTermuxConnect => 'Conectar';

  @override
  String get cliTermuxUnavailable =>
      'Desbloquea la bóveda para mostrar el comando de conexión.';

  @override
  String get aboutPrivacy =>
      'OpenKey cifra tus contraseñas de extremo a extremo. Tu contraseña maestra y la clave de la bóveda nunca salen de este dispositivo.';

  @override
  String get localVault => 'Bóveda local';

  @override
  String get followDevice => 'Seguir la apariencia del dispositivo';

  @override
  String get passwordGenerator => 'Generador de contraseñas';

  @override
  String get generatedPassword => 'Contraseña generada';

  @override
  String get passwordLength => 'Longitud';

  @override
  String charactersLabel(int n) {
    return '$n caracteres';
  }

  @override
  String get includeUppercase => 'Mayúsculas';

  @override
  String get includeLowercase => 'Minúsculas';

  @override
  String get includeDigits => 'Números';

  @override
  String get includeSymbols => 'Símbolos';

  @override
  String get avoidAmbiguous => 'Evitar caracteres ambiguos';

  @override
  String get avoidAmbiguousSubtitle => 'Excluir I, l, 1, O, 0, o, |';

  @override
  String get regenerate => 'Regenerar';

  @override
  String get copyPassword => 'Copiar';

  @override
  String get passwordCopied => 'Contraseña copiada';

  @override
  String get passwordGeneratorSubtitle =>
      'Genera una contraseña fuerte y única';

  @override
  String get usePassword => 'Usar contraseña';

  @override
  String get generateOptions => 'Opciones';

  @override
  String get characterSets => 'Conjuntos de caracteres';

  @override
  String get passwordStrengthWeak => 'Débil';

  @override
  String get passwordStrengthFair => 'Aceptable';

  @override
  String get passwordStrengthStrong => 'Fuerte';

  @override
  String get generatorTitle => 'Generador';

  @override
  String get generatorSubtitle => 'Crea contraseñas, usuarios y correos';

  @override
  String get generatorModePassword => 'Contraseña';

  @override
  String get generatorModeUsername => 'Usuario';

  @override
  String get generatorModeEmail => 'Correo';

  @override
  String get generatedUsername => 'Usuario generado';

  @override
  String get generatedEmail => 'Correo generado';

  @override
  String get usernameStyle => 'Estilo';

  @override
  String get usernameStyleWords => 'Palabras';

  @override
  String get usernameStyleRandom => 'Aleatorio';

  @override
  String get usernameCapitalize => 'Mayúsculas';

  @override
  String get usernameIncludeDigits => 'Añadir números';

  @override
  String get usernameSeparator => 'Separador';

  @override
  String get usernameSeparatorNone => 'Ninguno';

  @override
  String get emailType => 'Tipo de correo';

  @override
  String get emailTypeRandom => 'Aleatorio';

  @override
  String get emailTypePlus => 'Dirección plus';

  @override
  String get emailDomain => 'Dominio';

  @override
  String get emailDomainHint => 'tudominio.com';

  @override
  String get emailPlusBase => 'Tu correo';

  @override
  String get emailPlusBaseHint => 'tu@gmail.com';

  @override
  String get emailPlusHelp =>
      'Crea tu+etiqueta@gmail.com para filtrar registros en tu bandeja.';

  @override
  String get emailRandomHelp =>
      'Crea una dirección única en un dominio que controles, como un catch-all.';

  @override
  String get passwordDetails => 'Detalles de la contraseña';

  @override
  String get untitled => 'Sin título';

  @override
  String get credentials => 'Credenciales';

  @override
  String get username => 'Usuario';

  @override
  String get password => 'Contraseña';

  @override
  String get website => 'Sitio web';

  @override
  String get notes => 'Notas';

  @override
  String get authenticator => 'Autenticador';

  @override
  String get passkey => 'Llave de acceso';

  @override
  String get attachments => 'Adjuntos';

  @override
  String get downloadAttachment => 'Descargar';

  @override
  String get previewAttachment => 'Vista previa';

  @override
  String get openAttachment => 'Abrir';

  @override
  String get playVideo => 'Reproducir vídeo';

  @override
  String get pausePlayback => 'Pausa';

  @override
  String get openingAttachment => 'Abriendo adjunto…';

  @override
  String attachmentSaved(String name) {
    return '$name guardado';
  }

  @override
  String get couldNotOpenAttachment => 'No se pudo abrir este adjunto.';

  @override
  String get attachmentNotPreviewable =>
      'No hay vista previa para este tipo de archivo. Puedes descargarlo.';

  @override
  String get copyUsername => 'Copiar usuario';

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get hidePassword => 'Ocultar contraseña';

  @override
  String get tapToCopy => 'Toca para copiar';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get deleteEntry => '¿Eliminar entrada?';

  @override
  String get deleteEntryConfirm =>
      'Esto elimina permanentemente la contraseña de tu bóveda.';

  @override
  String get entryNotFound => 'Entrada no encontrada';

  @override
  String get entryNotFoundMessage =>
      'Es posible que esta contraseña se haya eliminado.';

  @override
  String get goBack => 'Volver';

  @override
  String get synced => 'Sincronizado';

  @override
  String get pendingSync => 'Sincronización pendiente';

  @override
  String revisionLabel(int n) {
    return 'Revisión $n';
  }

  @override
  String valueCopied(String label) {
    return '$label copiado';
  }

  @override
  String get vault => 'Bóveda';

  @override
  String get items => 'Elementos';

  @override
  String get itemsHubSubtitle => 'Tarjetas, monederos crypto y secretos.';

  @override
  String get itemsCardsSubtitle => 'Tarjetas de pago y datos de facturación';

  @override
  String get itemsCryptoSubtitle => 'Direcciones, claves y frases semilla';

  @override
  String get itemsSecretsSubtitle => 'Claves SSH, tokens API y fragmentos .env';

  @override
  String itemsCountLabel(int count) {
    return '$count guardados';
  }

  @override
  String get wallets => 'Carteras';

  @override
  String get searchCards => 'Buscar tarjetas';

  @override
  String get noCardsYet => 'Aún no hay tarjetas';

  @override
  String get noCardsYetMessage =>
      'Añade una tarjeta para guardarla de forma segura.';

  @override
  String get addCard => 'Añadir tarjeta';

  @override
  String get editCard => 'Editar tarjeta';

  @override
  String get save => 'Guardar';

  @override
  String get cardDetails => 'Detalles de la tarjeta';

  @override
  String get cardName => 'Nombre de la tarjeta';

  @override
  String get cardHolder => 'Titular';

  @override
  String get cardNumber => 'Número de tarjeta';

  @override
  String get cardExpiry => 'Caducidad';

  @override
  String get cardCvc => 'CVC';

  @override
  String get copyNumber => 'Copiar número';

  @override
  String get copyCvc => 'Copiar CVC';

  @override
  String get tapCardToFlip => 'Toca la tarjeta para voltearla';

  @override
  String get deleteCard => '¿Eliminar tarjeta?';

  @override
  String get deleteCardConfirm =>
      'Esto elimina permanentemente la tarjeta de tu cartera.';

  @override
  String get cardNotFound => 'Tarjeta no encontrada';

  @override
  String get cardNotFoundMessage =>
      'Es posible que esta tarjeta se haya eliminado.';

  @override
  String get bank => 'Banco';

  @override
  String get banks => 'Bancos';

  @override
  String get otherBank => 'Otros';

  @override
  String get addBank => 'Añadir banco';

  @override
  String get newBank => 'Nuevo banco';

  @override
  String get bankName => 'Nombre del banco';

  @override
  String get renameBank => 'Renombrar banco';

  @override
  String get deleteBank => '¿Eliminar banco?';

  @override
  String get deleteBankConfirm =>
      '¿Quitar este grupo de banco? Las tarjetas se pueden mover a Otros.';

  @override
  String get deleteBankAndClear => 'Eliminar y desasignar tarjetas';

  @override
  String get moveToBank => 'Mover a banco';

  @override
  String get noBanksYet => 'Aún no hay bancos';

  @override
  String get createBankHint => 'Crea un banco para organizar tus tarjetas.';

  @override
  String get bankCreated => 'Banco creado';

  @override
  String get cardMoved => 'Tarjeta movida';

  @override
  String get emptyBank => 'No hay tarjetas en este banco';

  @override
  String get paymentCards => 'Tarjetas';

  @override
  String get cryptoWallets => 'Cripto';

  @override
  String get searchCryptoWallets => 'Buscar monederos cripto';

  @override
  String get noCryptoWalletsYet => 'Aún no hay monederos cripto';

  @override
  String get noCryptoWalletsYetMessage =>
      'Añade un monedero para guardar claves de forma segura.';

  @override
  String get addCryptoWallet => 'Añadir monedero cripto';

  @override
  String get editCryptoWallet => 'Editar monedero cripto';

  @override
  String get cryptoNetwork => 'Red';

  @override
  String get cryptoWalletName => 'Nombre del monedero';

  @override
  String get walletAddress => 'Dirección';

  @override
  String get privateKey => 'Clave privada';

  @override
  String get seedPhrase => 'Frase semilla';

  @override
  String get cryptoDetails => 'Detalles del monedero';

  @override
  String get copyAddress => 'Copiar dirección';

  @override
  String get deleteCryptoWallet => '¿Eliminar monedero cripto?';

  @override
  String get deleteCryptoWalletConfirm =>
      'Esto elimina permanentemente el monedero y sus secretos de tu bóveda.';

  @override
  String get cryptoWalletNotFound => 'Monedero cripto no encontrado';

  @override
  String get cryptoWalletNotFoundMessage =>
      'Es posible que este monedero se haya eliminado.';

  @override
  String get folders => 'Carpetas';

  @override
  String get otherFolder => 'Otro';

  @override
  String get addFolder => 'Añadir carpeta';

  @override
  String get newFolder => 'Nueva carpeta';

  @override
  String get folderName => 'Nombre de carpeta';

  @override
  String get renameFolder => 'Renombrar carpeta';

  @override
  String get deleteFolder => '¿Eliminar carpeta?';

  @override
  String get deleteFolderConfirm =>
      '¿Quitar este grupo de carpeta? Los monederos se pueden mover a Otro.';

  @override
  String get deleteFolderAndClear => 'Eliminar y desasignar monederos';

  @override
  String get moveToFolder => 'Mover a carpeta';

  @override
  String get noFoldersYet => 'Aún no hay carpetas';

  @override
  String get createFolderHint =>
      'Crea una carpeta para organizar tus monederos cripto.';

  @override
  String get folderCreated => 'Carpeta creada';

  @override
  String get cryptoWalletMoved => 'Monedero movido';

  @override
  String get emptyFolder => 'No hay monederos en esta carpeta';

  @override
  String get secrets => 'Secretos';

  @override
  String get searchSecrets => 'Buscar secretos';

  @override
  String get noSecretsYet => 'Aún no hay secretos';

  @override
  String get noSecretsYetMessage =>
      'Guarda claves SSH, tokens API y fragmentos .env de forma segura.';

  @override
  String get addSecret => 'Añadir secreto';

  @override
  String get editSecret => 'Editar secreto';

  @override
  String get secretKind => 'Tipo';

  @override
  String get secretKindSsh => 'Clave SSH';

  @override
  String get secretKindApiToken => 'Token API';

  @override
  String get secretKindEnv => 'Fragmento .env';

  @override
  String get secretKindOther => 'Otro';

  @override
  String get secretName => 'Nombre';

  @override
  String get secretUsername => 'Usuario';

  @override
  String get secretHost => 'Servidor';

  @override
  String get secretEndpoint => 'Punto de conexión / URL';

  @override
  String get publicKey => 'Clave pública';

  @override
  String get apiToken => 'Token API';

  @override
  String get envContent => 'Contenido .env';

  @override
  String get secretValue => 'Secreto';

  @override
  String get passphrase => 'Frase de contraseña';

  @override
  String get secretDetails => 'Detalles del secreto';

  @override
  String get copySecret => 'Copiar secreto';

  @override
  String get deleteSecret => '¿Eliminar secreto?';

  @override
  String get deleteSecretConfirm =>
      'Esto elimina permanentemente el secreto de tu bóveda.';

  @override
  String get secretNotFound => 'Secreto no encontrado';

  @override
  String get secretNotFoundMessage =>
      'Este secreto puede haber sido eliminado.';

  @override
  String get reverseOrderSecretsSubtitle =>
      'Mostrar secretos en orden inverso.';

  @override
  String get device => 'Dispositivo';

  @override
  String get devices => 'Dispositivos';

  @override
  String get otherDevice => 'Otro';

  @override
  String get addDevice => 'Añadir dispositivo';

  @override
  String get newDevice => 'Nuevo dispositivo';

  @override
  String get deviceName => 'Nombre del dispositivo';

  @override
  String get renameDevice => 'Renombrar dispositivo';

  @override
  String get deleteDevice => '¿Eliminar dispositivo?';

  @override
  String get deleteDeviceConfirm =>
      '¿Quitar este grupo de dispositivo? Los secretos se pueden mover a Otro.';

  @override
  String get deleteDeviceAndClear => 'Eliminar y desasignar secretos';

  @override
  String get moveToDevice => 'Mover a dispositivo';

  @override
  String get noDevicesYet => 'Aún no hay dispositivos';

  @override
  String get createDeviceHint =>
      'Crea un dispositivo para organizar secretos de cada máquina.';

  @override
  String get deviceCreated => 'Dispositivo creado';

  @override
  String get secretMoved => 'Secreto movido';

  @override
  String get emptyDevice => 'No hay secretos en este dispositivo';

  @override
  String get faq => 'Preguntas frecuentes';

  @override
  String get faqSubtitle => 'Cifrado, desbloqueo, sincronización y más';

  @override
  String get faqEncryptionQ => '¿Mis datos están cifrados?';

  @override
  String get faqEncryptionA =>
      'Sí. OpenKey cifra tu bóveda de extremo a extremo en este dispositivo. Tu contraseña maestra y la clave de la bóveda nunca salen del dispositivo en texto plano.';

  @override
  String get faqForgotPasswordQ => '¿Y si olvido mi contraseña maestra?';

  @override
  String get faqForgotPasswordA =>
      'No hay recuperación sin tu contraseña maestra. Por el cifrado de conocimiento cero, OpenKey no puede restablecerla. Guarda una copia segura de tu contraseña.';

  @override
  String get faqOfflineQ => '¿OpenKey funciona sin conexión?';

  @override
  String get faqOfflineA =>
      'Sí. Tu bóveda se guarda en el dispositivo y se desbloquea sin red. Un servidor opcional solo hace falta para sincronizar y compartir.';

  @override
  String get faqAutoLockQ => '¿Cómo funciona el bloqueo automático?';

  @override
  String get faqAutoLockA =>
      'Cuando sales de la app sin cerrarla, OpenKey cuenta el tiempo de ausencia. Tras el tiempo que elijas en Ajustes, la bóveda se bloquea y necesitarás la contraseña maestra o biometría. Cerrar la app termina la sesión de inmediato.';

  @override
  String get faqBiometricQ => '¿Es seguro el desbloqueo biométrico?';

  @override
  String get faqBiometricA =>
      'Sí. La biometría desbloquea una clave en el hardware seguro del dispositivo. No sustituye tu contraseña maestra; puedes usarla cuando quieras.';

  @override
  String get faqSyncQ => '¿Qué es la sincronización con servidor propio?';

  @override
  String get faqSyncA =>
      'Puedes ejecutar tu propio servidor OpenKey. Los dispositivos envían datos cifrados de la bóveda para sincronizarse a distancia. El servidor guarda solo texto cifrado y nunca ve los secretos en claro. La contraseña maestra permanece en cada dispositivo.';

  @override
  String get faqBackupQ => '¿Cómo funciona Copia de seguridad y restauración?';

  @override
  String get faqBackupA =>
      'En Ajustes → Copia de seguridad y restauración puedes guardar una copia completa de la bóveda en este dispositivo. OpenKey empaqueta la base de datos, los ajustes y los adjuntos en un archivo comprimido y lo cifra con la clave de la bóveda (.okbak). Nadie puede leer el archivo sin tu contraseña maestra. Restaurar descifra ese archivo y sustituye la bóveda local por la copia: guarda la contraseña y el archivo .okbak en un lugar seguro.';

  @override
  String get appName => 'OpenKey';

  @override
  String get copy => 'Copiar';

  @override
  String get create => 'Crear';

  @override
  String get generate => 'Generar';

  @override
  String get name => 'Nombre';

  @override
  String get title => 'Título';

  @override
  String get lock => 'Bloquear';

  @override
  String get all => 'Todos';

  @override
  String get entry => 'Entrada';

  @override
  String get collection => 'Colección';

  @override
  String get searchPasswords => 'Buscar contraseñas';

  @override
  String get noPasswordsYet => 'Aún no hay contraseñas';

  @override
  String get noPasswordsYetMessage => 'Añade una entrada o crea una colección.';

  @override
  String get newCollection => 'Nueva colección';

  @override
  String get newEntry => 'Nueva entrada';

  @override
  String get editEntry => 'Editar entrada';

  @override
  String get chooseFields => 'Campos';

  @override
  String get chooseFieldsSubtitle =>
      'Activa o desactiva campos y arrástralos para reordenar';

  @override
  String get done => 'Listo';

  @override
  String get phone => 'Teléfono';

  @override
  String get pin => 'PIN';

  @override
  String get number => 'Número';

  @override
  String get address => 'Dirección';

  @override
  String get ipAddress => 'Dirección IP';

  @override
  String get dateYmd => 'Fecha';

  @override
  String get dateYm => 'Mes / año';

  @override
  String get recoveryCodes => 'Códigos de recuperación';

  @override
  String get customText => 'Texto';

  @override
  String get additionalFields => 'Campos adicionales';

  @override
  String get emptyCollection => 'Colección vacía';

  @override
  String get emptyCollectionMessage =>
      'Añade una entrada de contraseña a esta colección.';

  @override
  String get editCollection => 'Editar colección';

  @override
  String get deleteCollection => 'Eliminar colección';

  @override
  String get deleteCollectionConfirm =>
      'Las entradas de esta colección se quitarán de la carpeta (no se eliminarán). ¿Continuar?';

  @override
  String get chooseIcon => 'Elegir icono';

  @override
  String get icons => 'Iconos';

  @override
  String get brands => 'Marcas';

  @override
  String get suggestedIcon => 'Icono sugerido';

  @override
  String get fromDevice => 'Desde el dispositivo';

  @override
  String get customIcon => 'Icono personalizado';

  @override
  String get editIcon => 'Editar icono';

  @override
  String get cropOrRotate => 'Recortar / Girar';

  @override
  String get rotate => 'Girar';

  @override
  String get flip => 'Voltear';

  @override
  String get ratio => 'Proporción';

  @override
  String get filter => 'Filtro';

  @override
  String get blur => 'Desenfocar';

  @override
  String get discardChanges => '¿Descartar cambios?';

  @override
  String get discardChangesMessage => 'Se perderán tus ediciones.';

  @override
  String get discard => 'Descartar';

  @override
  String get undo => 'Deshacer';

  @override
  String get redo => 'Rehacer';

  @override
  String get more => 'Más';

  @override
  String get back => 'Atrás';

  @override
  String get preparingImage => 'Preparando imagen…';

  @override
  String get search => 'Buscar';

  @override
  String get noFolder => 'Sin carpeta';

  @override
  String get folder => 'Carpeta';

  @override
  String entriesCount(int count) {
    return '$count entradas';
  }

  @override
  String get moveTo => 'Mover a';

  @override
  String get moveHere => 'Mover aquí';

  @override
  String get movingLabel => 'Moviendo';

  @override
  String movingItemsCount(int count) {
    return '$count elementos';
  }

  @override
  String get tags => 'Etiquetas';

  @override
  String get noTags => 'Aún no hay etiquetas';

  @override
  String get noTagsMessage => 'Añade etiquetas al editar una entrada.';

  @override
  String get sortAndFilter => 'Ordenar y filtrar';

  @override
  String get applyToFolders => 'Carpetas';

  @override
  String get applyToEntries => 'Contraseñas';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get options => 'Opciones';

  @override
  String get sortByCreationTime => 'Ordenar por fecha de creación';

  @override
  String get sortByLastModified => 'Ordenar por última modificación';

  @override
  String get sortByName => 'Ordenar por nombre';

  @override
  String get sortByCustomOrder => 'Orden personalizado';

  @override
  String get reverseOrder => 'Orden inverso';

  @override
  String get reverseOrderFoldersSubtitle =>
      'Mostrar carpetas en orden inverso.';

  @override
  String get reverseOrderEntriesSubtitle =>
      'Mostrar contraseñas en orden inverso.';

  @override
  String get reverseOrderCardsSubtitle => 'Mostrar tarjetas en orden inverso.';

  @override
  String get reverseOrderCryptoSubtitle => 'Mostrar carteras en orden inverso.';

  @override
  String get addTagHint => 'Añadir etiqueta';

  @override
  String deleteSelectedConfirm(int count) {
    return '¿Eliminar $count elementos seleccionados?';
  }

  @override
  String get totpSecretLabel => 'Secreto TOTP / otpauth';

  @override
  String get scanTotpQr => 'Escanear código QR';

  @override
  String get scanTotpQrHint => 'Apunta la cámara al código QR del autenticador';

  @override
  String get invalidTotpQr => 'Este código QR no es un código TOTP válido';

  @override
  String get cameraPermissionDenied =>
      'Se requiere permiso de cámara para escanear códigos QR';

  @override
  String get storePasskeyMetadata => 'Llave de acceso';

  @override
  String get passkeyCreatedInBrowser =>
      'Crea passkeys con la extensión de OpenKey o mediante Autocompletar / proveedor de credenciales en el móvil con OpenKey desbloqueado.';

  @override
  String get rpId => 'RP ID';

  @override
  String get credentialId => 'ID de credencial';

  @override
  String get addPasskeyItem => 'Aún no hay passkey';

  @override
  String bytesLabel(int n) {
    return '$n bytes';
  }

  @override
  String get addEncryptedAttachment => 'Añadir adjunto cifrado';

  @override
  String get expiryHint => 'MM/AA';

  @override
  String get autoLockSubtitle => 'Bloquea la bóveda al salir de la app.';

  @override
  String get serverUrl => 'URL del servidor';

  @override
  String get serverUrlHint => 'https://openkey.example.com';

  @override
  String get serverSheetSubtitle =>
      'Regístrate o inicia sesión para sincronizar solo el cifrado de la bóveda.';

  @override
  String get register => 'Registrarse';

  @override
  String get registerSubtitle => 'Crea una cuenta en este servidor';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get loginSubtitle =>
      'Inicia sesión con el hash de autenticación de esta bóveda';

  @override
  String get syncNow => 'Sincronizar ahora';

  @override
  String get syncing => 'Sincronizando…';

  @override
  String get syncSubtitle => 'Enviar y recibir cambios cifrados';

  @override
  String get syncComplete => 'Sincronización completa';

  @override
  String get extensionLinkCopied => 'Payload del enlace de extensión copiado';

  @override
  String get biometricUnlockEnabled => 'Desbloqueo biométrico activado';

  @override
  String get biometricUnlockDisabled => 'Desbloqueo biométrico desactivado';

  @override
  String biometricsUpdateFailed(String error) {
    return 'No se pudo actualizar la biometría: $error';
  }

  @override
  String get bitwardenJson => 'Bitwarden JSON';

  @override
  String get bitwardenJsonSubtitle => 'Exporta desde Bitwarden → importa aquí';

  @override
  String get openKeyJson => 'OpenKey JSON';

  @override
  String get openKeyJsonSubtitle =>
      'Copia de seguridad exportada desde OpenKey';

  @override
  String get chromeCsv => 'Chrome CSV';

  @override
  String get chromeCsvSubtitle => 'Contraseñas exportadas de Chrome';

  @override
  String get lastPassCsv => 'LastPass CSV';

  @override
  String get lastPassCsvSubtitle => 'Exportación CSV de LastPass';

  @override
  String get keePassKdbx => 'KeePass (.kdbx)';

  @override
  String get keePassKdbxSubtitle => 'Base de datos KeePass / KeePassXC cifrada';

  @override
  String get keePassPasswordHint => 'Contraseña de la base de datos';

  @override
  String get keePassKeyFile => 'Archivo de clave (opcional)';

  @override
  String get keePassUnlockFailed =>
      'No se pudo abrir la base KeePass. Comprueba la contraseña y el archivo de clave.';

  @override
  String get onePasswordCsv => '1Password CSV';

  @override
  String get onePasswordCsvSubtitle => 'Exportación CSV de 1Password';

  @override
  String get importingPasswords => 'Importando…';

  @override
  String importingProgress(int done, int total) {
    return 'Importando $done de $total…';
  }

  @override
  String importedItems(int n) {
    return 'Se importaron $n elementos';
  }

  @override
  String get failureUnknown => 'Algo salió mal.';

  @override
  String get failureNetwork => 'Error de red. Comprueba tu conexión.';

  @override
  String get failureUnauthorized => 'No autorizado. Vuelve a iniciar sesión.';

  @override
  String get failureNotFound => 'No encontrado.';

  @override
  String get failureServer => 'Error del servidor.';

  @override
  String get failureInvalidCredentials =>
      'Correo o contraseña maestra no válidos.';

  @override
  String get failureVaultLocked => 'La bóveda está bloqueada.';

  @override
  String get failureVaultAlreadyExists =>
      'Ya existe una bóveda en este dispositivo.';

  @override
  String get failureDecryptionFailed =>
      'No se pudo descifrar los datos de la bóveda.';

  @override
  String get failureSyncFailed => 'Error de sincronización.';

  @override
  String get failureCreateCollection => 'No se pudo crear la colección.';

  @override
  String get failureUpdateCollection => 'No se pudo actualizar la colección.';

  @override
  String get failureDeleteCollection => 'No se pudo eliminar la colección.';

  @override
  String get failureGetCollections => 'No se pudieron cargar las colecciones.';

  @override
  String get failureCreateEntry => 'No se pudo crear la entrada.';

  @override
  String get failureUpdateEntry => 'No se pudo actualizar la entrada.';

  @override
  String get failureDeleteEntry => 'No se pudo eliminar la entrada.';

  @override
  String get failureGetEntries => 'No se pudieron cargar las entradas.';

  @override
  String get failureNoVault => 'No se encontró bóveda. Crea una primero.';

  @override
  String get failureConnectServerFirst =>
      'Conéctate primero a un servidor en Ajustes.';

  @override
  String get failureAttachmentTooLarge =>
      'El adjunto supera el límite de 20 MB.';

  @override
  String get failureAttachmentMissing => 'Falta el cifrado del adjunto.';

  @override
  String get failureAccountEmailExists =>
      'Ese correo ya tiene una bóveda en este dispositivo.';

  @override
  String get root => 'Raíz';

  @override
  String get selectedItems => 'seleccionados';

  @override
  String get authenticatorTotp => 'Autenticador (TOTP)';

  @override
  String get openKeyPro => 'OpenKey Pro';

  @override
  String get proSubtitle =>
      'Desbloquea funciones premium y apoya el desarrollo de OpenKey.';

  @override
  String get premiumFeatureTitle => 'Función premium';

  @override
  String get premiumFeatureSubtitle =>
      'Suscríbete para desbloquear esta función premium.';

  @override
  String get premiumFeatureContent =>
      'Esta es una función premium. Suscríbete para acceder.';

  @override
  String get premiumBadge => 'Pro';

  @override
  String get subscribe => 'Suscribirse';

  @override
  String get upgradeNow => 'Mejorar ahora';

  @override
  String get oops => '¡Vaya!';

  @override
  String get subscription => 'Suscripción';

  @override
  String get subscriptionTitle => 'Suscripción';

  @override
  String get subscriptionSubtitle => 'Elige un plan que te convenga.';

  @override
  String get manageYourSubscription => 'Gestiona tu suscripción';

  @override
  String get manageSubscriptionAction => 'Gestionar suscripción';

  @override
  String get subIsActiveTitle => 'Tu suscripción está activa';

  @override
  String get subIsNotActiveTitle => 'Tu suscripción está inactiva';

  @override
  String get thanksForSubscribing => '¡Gracias por suscribirte!';

  @override
  String get subIsCancelled =>
      'Tu suscripción está cancelada y no se renovará.';

  @override
  String get subIsPaused => 'Tu suscripción está en pausa.';

  @override
  String get restorePurchase => 'Restaurar compra';

  @override
  String get viewPlansPaywall => 'Ver opciones de suscripción';

  @override
  String get openCustomerCenter => 'Gestionar en el Centro de clientes';

  @override
  String get subscriptionDesktopNote =>
      'Las compras integradas están disponibles en Android, iOS y macOS. En Windows y Linux, inicia sesión con la misma cuenta OpenKey para desbloquear Pro tras suscribirte en móvil o Mac.';

  @override
  String get subscriptionRefreshStatus => 'Actualizar estado de suscripción';

  @override
  String get subscriptionNoInternetMsg =>
      'Hay un problema con tu conexión a internet. Comprueba la red e inténtalo de nuevo.';

  @override
  String get subscriptionRegionBlockedMsg =>
      'Los servicios de suscripción no están disponibles en tu región. Conéctate a una VPN e inténtalo de nuevo.';

  @override
  String get monthly => 'Mensual';

  @override
  String get yearly => 'Anual';

  @override
  String get lifetime => 'De por vida';

  @override
  String get monthlySubtitle => 'Renovación automática, cancela cuando quieras';

  @override
  String get yearlySubtitle =>
      'Renovación automática, mejor valor, cancela cuando quieras';

  @override
  String get lifetimeSubtitle => 'Compra única, tuya para siempre';

  @override
  String monthlyPriceLabel(String price) {
    return '$price/mes';
  }

  @override
  String yearlyPriceLabel(String price) {
    return '$price/año';
  }

  @override
  String lifetimePriceLabel(String price) {
    return '$price';
  }

  @override
  String monthlySubscribeLabel(String price) {
    return 'Suscribirse por $price / mes';
  }

  @override
  String yearlySubscribeLabel(String price) {
    return 'Suscribirse por $price / año';
  }

  @override
  String lifetimeSubscribeLabel(String price) {
    return 'Comprar de por vida por $price';
  }

  @override
  String get bestValue => 'Mejor valor';

  @override
  String get skip => 'Omitir';

  @override
  String get getStarted => 'Empezar';

  @override
  String get onboardingFaqTitle => 'Antes de empezar';

  @override
  String get onboardingFaqSubtitle =>
      'Las preguntas más frecuentes sobre OpenKey. Toca para expandir — luego crea tu bóveda.';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingWelcomeTitle => 'Tus claves. Tu bóveda.';

  @override
  String get onboardingWelcomeSubtitle =>
      'OpenKey guarda contraseñas, códigos y tarjetas en un hogar cifrado — pensado para el día a día.';

  @override
  String get onboardingWelcomePhrase1 => 'Cero conocimiento por diseño';

  @override
  String get onboardingWelcomePhrase2 => 'Autocompletar en un toque';

  @override
  String get onboardingWelcomePhrase3 => 'Autoalojado cuando quieras';

  @override
  String get onboardingSecurityTitle => 'Nadie más puede leerlo';

  @override
  String get onboardingSecuritySubtitle =>
      'El cifrado de extremo a extremo significa que tu contraseña maestra nunca sale de este dispositivo. Solo almacenamos texto cifrado.';

  @override
  String get onboardingAutofillTitle => 'Rellena una vez. Confía siempre.';

  @override
  String get onboardingAutofillSubtitle =>
      'Inicia sesión en apps y sitios sin buscar contraseñas. Autocompletar hace de OpenKey parte de cada día.';

  @override
  String get onboardingAllInOneTitle => 'Una app. Toda la bóveda.';

  @override
  String get onboardingAllInOneSubtitle =>
      'Contraseñas, códigos, tarjetas, monederos crypto y secretos de desarrollador — sustituye el desorden por una sola bóveda de confianza.';

  @override
  String get onboardingFeaturePasswords => 'Contraseñas';

  @override
  String get onboardingFeatureCrypto => 'Cripto';

  @override
  String get onboardingFeatureAutofill => 'Autocompletar';

  @override
  String get onboardingFeatureSelfHost => 'Autoalojado.';

  @override
  String get onboardingFooterHint =>
      'Menos de un minuto. Puedes omitir en cualquier momento.';

  @override
  String get onboardingLetsGo => '¡Vamos!';

  @override
  String onboardingStepOf(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String get onboardingWelcomeHeadline => 'Bienvenido\na OpenKey.';

  @override
  String get onboardingWelcomeLead => 'Vamos a configurar todo para ti';

  @override
  String get onboardingEcosystemTitle => 'Tu\nbóveda\ncompleta.';

  @override
  String get onboardingEcosystemSubtitle =>
      'Contraseñas, códigos y tarjetas — cifrados y listos donde inicies sesión.';

  @override
  String get onboardingStyleTitle => 'Estílalo\na tu manera.';

  @override
  String get onboardingEnableAutofillTitle => 'Activa\nAutocompletar.';

  @override
  String get onboardingAutofillCardTitle => 'Autocompletar contraseñas';

  @override
  String get onboardingAutofillCardSubtitle =>
      'Rellena inicios de sesión en apps y sitios desde tu bóveda.';

  @override
  String get onboardingAutofillGranted => 'Autocompletar está listo';

  @override
  String get onboardingFinishBadge => 'Configuración lista';

  @override
  String get onboardingFinishTitle => 'Listo para\ncerrar.';

  @override
  String get onboardingFinishSubtitle =>
      'Crea una contraseña maestra y empieza a guardar lo importante — tu bóveda está a un paso.';

  @override
  String get onboardingCreateVault => 'Crear bóveda';

  @override
  String get errorLoadingData => 'Error al cargar datos. Inténtalo de nuevo.';

  @override
  String get retryAgain => 'Reintentar';

  @override
  String get autoRenewLabel => 'Renovación automática';

  @override
  String get cancelledLabel => 'Cancelada';

  @override
  String get pausedLabel => 'En pausa';

  @override
  String get supportAppDevelopmentTitle => 'Apoyar el desarrollo';

  @override
  String get supportAppDevelopmentSubtitle =>
      'Tu suscripción nos ayuda a seguir mejorando OpenKey.';

  @override
  String get limitEntriesTitle => 'Límite de entradas alcanzado';

  @override
  String get limitCollectionsTitle => 'Límite de colecciones alcanzado';

  @override
  String get limitWalletsTitle => 'Límite de tarjetas alcanzado';

  @override
  String get limitCryptoWalletsTitle => 'Límite de monederos crypto alcanzado';

  @override
  String get limitSecretsTitle => 'Límite de secretos alcanzado';

  @override
  String limitReachedContent(int usage, int limit, String feature) {
    return 'Has usado $usage de $limit $feature. Mejora a Pro para acceso ilimitado.';
  }

  @override
  String limitSubtitle(int limit, String feature) {
    return 'El plan gratuito incluye hasta $limit $feature.';
  }

  @override
  String get entries => 'entradas';

  @override
  String get collections => 'colecciones';

  @override
  String get cards => 'tarjetas';

  @override
  String get cryptoWalletsFeature => 'monederos crypto';

  @override
  String get secretsFeature => 'secretos';

  @override
  String expiresOn(String date) {
    return 'Caduca el $date';
  }

  @override
  String get unlockUnlimitedEntriesTitle => 'Entradas ilimitadas';

  @override
  String get unlockUnlimitedEntriesSubtitle =>
      'Guarda tantas contraseñas e inicios de sesión como necesites.';

  @override
  String get unlockUnlimitedCollectionsTitle => 'Colecciones ilimitadas';

  @override
  String get unlockUnlimitedCollectionsSubtitle =>
      'Organiza tu bóveda con tantas carpetas como quieras.';

  @override
  String get unlockUnlimitedWalletsTitle => 'Tarjetas ilimitadas';

  @override
  String get unlockUnlimitedWalletsSubtitle =>
      'Guarda tantas tarjetas de pago como necesites.';

  @override
  String get unlockUnlimitedCryptoWalletsTitle => 'Monederos crypto ilimitados';

  @override
  String get unlockUnlimitedCryptoWalletsSubtitle =>
      'Guarda direcciones, claves y frases semilla sin límites.';

  @override
  String get unlockUnlimitedSecretsTitle =>
      'Secretos de desarrollador ilimitados';

  @override
  String get unlockUnlimitedSecretsSubtitle =>
      'Guarda claves SSH, tokens API y fragmentos .env sin límites.';

  @override
  String get unlockSyncTitle => 'Sincronización con servidor';

  @override
  String get unlockSyncSubtitle =>
      'Conecta tu servidor autoalojado y sincroniza entre dispositivos.';

  @override
  String get unlockAttachmentsTitle => 'Adjuntos';

  @override
  String get unlockAttachmentsSubtitle =>
      'Adjunta archivos cifrados a entradas de la bóveda.';

  @override
  String get unlockImportExportTitle => 'Importar y exportar';

  @override
  String get unlockImportExportSubtitle => 'Mueve datos hacia y desde OpenKey.';

  @override
  String get unknownFailureMsg => 'Ha ocurrido un error desconocido.';

  @override
  String get purchaseCancelledMsg => 'La compra fue cancelada.';

  @override
  String get storeProblemMsg => 'Hubo un problema con la tienda.';

  @override
  String get purchaseNotAllowedMsg =>
      'Las compras no están permitidas en este dispositivo.';

  @override
  String get purchaseInvalidMsg => 'La compra no es válida.';

  @override
  String get productNotAvailableForPurchaseMsg =>
      'Este producto no está disponible para compra.';

  @override
  String get productAlreadyPurchasedMsg => 'Este producto ya ha sido comprado.';

  @override
  String get receiptAlreadyInUseMsg => 'Este recibo ya está en uso.';

  @override
  String get invalidReceiptMsg => 'El recibo no es válido.';

  @override
  String get missingReceiptFileMsg => 'Falta el archivo del recibo.';

  @override
  String get networkErrorMsg =>
      'Ocurrió un error de red. Comprueba tu conexión.';

  @override
  String get invalidCredentialsMsg => 'Credenciales no válidas.';

  @override
  String get unexpectedBackendResponseMsg =>
      'Respuesta inesperada del servidor.';

  @override
  String get receiptInUseByOtherSubscriberMsg =>
      'El recibo está en uso por otro suscriptor.';

  @override
  String get invalidAppUserIdMsg => 'El ID de usuario de la app no es válido.';

  @override
  String get operationAlreadyInProgressMsg => 'Ya hay una operación en curso.';

  @override
  String get unknownBackendErrorMsg =>
      'Ocurrió un error desconocido en el servidor.';

  @override
  String get invalidAppleSubscriptionKeyMsg =>
      'La clave de suscripción de Apple no es válida.';

  @override
  String get ineligibleMsg => 'No eres elegible para esta compra.';

  @override
  String get insufficientPermissionsMsg => 'No tienes permisos suficientes.';

  @override
  String get paymentPendingMsg => 'El pago está pendiente.';

  @override
  String get invalidSubscriberAttributesMsg =>
      'Los atributos del suscriptor no son válidos.';

  @override
  String get logOutWithAnonymousUserMsg =>
      'No se puede cerrar sesión con un usuario anónimo.';

  @override
  String get configurationErrorMsg => 'Hay un error de configuración.';

  @override
  String get unsupportedErrorMsg => 'Esta operación no es compatible.';

  @override
  String get emptySubscriberAttributesMsg =>
      'Los atributos del suscriptor están vacíos.';

  @override
  String get productDiscountMissingIdentifierMsg =>
      'Falta el identificador del descuento del producto.';

  @override
  String get unknownNonNativeErrorMsg =>
      'Ocurrió un error no nativo desconocido.';

  @override
  String get productDiscountMissingSubscriptionGroupIdentifierMsg =>
      'Falta el identificador del grupo de suscripción del descuento.';

  @override
  String get customerInfoErrorMsg =>
      'No se pudo obtener la información del cliente.';

  @override
  String get systemInfoErrorMsg =>
      'No se pudo obtener la información del sistema.';

  @override
  String get beginRefundRequestErrorMsg =>
      'No se pudo iniciar la solicitud de reembolso.';

  @override
  String get productRequestTimeoutMsg =>
      'La solicitud del producto agotó el tiempo de espera.';

  @override
  String get apiEndpointBlockedMsg => 'El endpoint de la API está bloqueado.';

  @override
  String get invalidPromotionalOfferMsg =>
      'La oferta promocional no es válida.';

  @override
  String get offlineConnectionMsg =>
      'Sin conexión a internet. Conéctate e inténtalo de nuevo.';

  @override
  String get featureNotAvailableInCustomEntitlementsComputationModeMsg =>
      'Esta función no está disponible en el modo de cálculo de derechos personalizado.';

  @override
  String get signatureVerificationFailedMsg =>
      'Falló la verificación de la firma.';

  @override
  String get featureNotSupportedWithStoreKit1Msg =>
      'Esta función no es compatible con StoreKit 1.';

  @override
  String get invalidWebPurchaseTokenMsg =>
      'El token de compra web no es válido.';

  @override
  String get purchaseBelongsToOtherUserMsg =>
      'Esta compra pertenece a otro usuario.';

  @override
  String get expiredWebPurchaseTokenMsg =>
      'El token de compra web ha caducado.';

  @override
  String get testStoreSimulatedPurchaseErrorMsg =>
      'Error de compra simulada de la tienda de prueba.';

  @override
  String get aboutApp => 'Acerca de la app';

  @override
  String get aboutAppSubtitle =>
      'Más información sobre OpenKey y su desarrollo.';

  @override
  String get developerName => 'OpenSelfHosting';

  @override
  String get developer => 'Software de código abierto que tú alojas';

  @override
  String rateUsIn(String storeName) {
    return 'Valóranos en $storeName';
  }

  @override
  String get doYouLikeTheAppRateUs => '¿Te gusta la app? ¡Valóranos!';

  @override
  String get licenses => 'Licencias';

  @override
  String get openLicenses => 'Abrir licencias';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get privacyPolicySubtitle => 'Lee nuestra política de privacidad';

  @override
  String get termsOfService => 'Términos del servicio';

  @override
  String get termsOfServiceSubtitle => 'Lee nuestros términos del servicio';

  @override
  String get pricing => 'Precios';

  @override
  String get pricingSubtitle => 'Planes Gratis frente a OpenKey Pro';

  @override
  String get copied => 'Copiado al portapapeles';

  @override
  String get contact => 'Contacto';

  @override
  String get contactSubtitle => 'Contáctanos para soporte o comentarios.';

  @override
  String get telegram => 'Telegram';

  @override
  String get ok => 'OK';

  @override
  String get localBackupRestoreTitle => 'Copia de seguridad y restauración';

  @override
  String get localBackupRestoreSubtitle =>
      'Crea una copia cifrada de toda la bóveda (.okbak) o restaura una. Incluye la base de datos, los ajustes y los adjuntos.';

  @override
  String get exportBackup => 'Exportar copia';

  @override
  String get exportBackupSubtitleEmpty =>
      'Crea una copia local cifrada y elige dónde guardarla.';

  @override
  String exportBackupSubtitleLatest(String path) {
    return 'Última exportación: $path';
  }

  @override
  String get importBackup => 'Restaurar copia';

  @override
  String get importBackupSubtitle =>
      'Sustituye esta bóveda por una copia cifrada de OpenKey (.okbak).';

  @override
  String get confirmRestore => 'Confirmar restauración';

  @override
  String get confirmRestoreMessage =>
      'Restaurar sustituye la base de datos local, los ajustes y los adjuntos por la copia. Introduce la contraseña maestra de esa copia para descifrarla.';

  @override
  String get creatingBackup => 'Creando copia…';

  @override
  String get creatingBackupBody => 'Comprimiendo y cifrando toda la bóveda.';

  @override
  String get restoringBackupProgress => 'Restaurando copia…';

  @override
  String get restoringBackupBody => 'Descifrando y restaurando tu bóveda.';

  @override
  String get restoringBackupVerifying => 'Verificando la contraseña maestra…';

  @override
  String get restoringBackupDecrypting => 'Descifrando los datos de la copia…';

  @override
  String get restoringBackupWriting => 'Escribiendo la bóveda restaurada…';

  @override
  String get restoringBackupUnlocking => 'Abriendo la bóveda restaurada…';

  @override
  String get backupComplete => 'Copia completada';

  @override
  String get backupCompleteLocalBody =>
      'Tu copia cifrada se guardó correctamente.';

  @override
  String get backupCompleteLocalDetail =>
      'Guarda este archivo en un lugar seguro. Necesitas la contraseña maestra para restaurarlo.';

  @override
  String get backupError => 'Error de copia de seguridad';

  @override
  String get restoreCompleted => 'Restauración completada';

  @override
  String get restoreCompletedBody =>
      'Tu bóveda se restauró desde la copia cifrada.';
}
