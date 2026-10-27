// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get settings => 'Configurações';

  @override
  String get appearance => 'Aparência';

  @override
  String get appearanceSubtitle => 'Tema, cores, fontes e idioma';

  @override
  String get themeMode => 'Modo do tema';

  @override
  String get system => 'Sistema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Escuro';

  @override
  String get language => 'Idioma';

  @override
  String get fonts => 'Fontes';

  @override
  String get displayFont => 'Fonte de exibição';

  @override
  String get defaultFont => 'Padrão';

  @override
  String get arabicFont => 'Árabe';

  @override
  String get developerFont => 'Desenvolvedor';

  @override
  String get technicalFont => 'Técnica';

  @override
  String get standardFont => 'Padrão';

  @override
  String get defaultFontDes => 'A fonte padrão do aplicativo.';

  @override
  String get arabicFontDes => 'Uma fonte otimizada para a escrita árabe.';

  @override
  String get developerFontDes => 'Uma fonte projetada para desenvolvedores.';

  @override
  String get technicalFontDes => 'Uma fonte adequada para conteúdo técnico.';

  @override
  String get standardFontDes => 'Uma fonte padrão para uso geral.';

  @override
  String get googleSansFlexFont => 'Google Sans Flex';

  @override
  String get googleSansFlexFontDes =>
      'A tipografia expressiva da marca Google para Material 3 Expressive.';

  @override
  String get robotoFlexFont => 'Roboto Flex';

  @override
  String get robotoFlexFontDes =>
      'Fonte variável do Material Design com peso, largura e tamanho óptico.';

  @override
  String get figtreeFont => 'Figtree';

  @override
  String get figtreeFontDes =>
      'Uma sans geométrica suave, comum com temas Material You.';

  @override
  String get nunitoFont => 'Nunito';

  @override
  String get nunitoFontDes =>
      'A rounded geometric sans with a friendly, modern tone.';

  @override
  String get dynamicColors => 'Cores dinâmicas';

  @override
  String get dynamicColorsSubtitle =>
      'Criar o tema a partir de uma cor escolhida';

  @override
  String get colorScheme => 'Esquema de cores';

  @override
  String get colorSchemeSubtitle => 'Escolha uma cor base e um estilo';

  @override
  String get highContrast => 'Alto contraste';

  @override
  String get highContrastSubtitle => 'Aumentar o contraste para ler melhor';

  @override
  String get security => 'Segurança';

  @override
  String get securitySubtitle =>
      'Bloqueio automático, biometria, preenchimento automático e palavra-passe mestra';

  @override
  String get account => 'Conta';

  @override
  String get accountPageTitle => 'Conta';

  @override
  String get accountPhoto => 'Foto de perfil';

  @override
  String get changeAccountPhoto => 'Alterar foto';

  @override
  String get removeAccountPhoto => 'Remover foto';

  @override
  String get changeEmail => 'Alterar e-mail';

  @override
  String get changeEmailSubtitle =>
      'Reenvolve a chave do cofre. Vai desbloquear com o novo e-mail.';

  @override
  String get newEmail => 'Novo e-mail';

  @override
  String get emailChanged => 'E-mail atualizado';

  @override
  String get switchAccount => 'Trocar de conta';

  @override
  String get addAccount => 'Adicionar conta';

  @override
  String get addAccountSubtitle =>
      'Crie ou inicie sessão noutro cofre neste dispositivo';

  @override
  String get removeAccountFromDevice => 'Remover deste dispositivo';

  @override
  String get removeAccountFromDeviceSubtitle =>
      'Elimina este cofre local. Uma conta de servidor associada não é eliminada.';

  @override
  String get removeAccountConfirm =>
      'Este cofre e os seus itens serão removidos deste dispositivo. Esta ação não pode ser anulada.';

  @override
  String get otherAccounts => 'Outras contas';

  @override
  String get useThisAccount => 'Usar esta conta';

  @override
  String get currentAccount => 'Conta atual';

  @override
  String get chooseAccount => 'Escolher conta';

  @override
  String get switchingAccount => 'A mudar de conta…';

  @override
  String get welcomeBackShort => 'Bem-vindo de volta';

  @override
  String get tools => 'Ferramentas';

  @override
  String get help => 'Ajuda';

  @override
  String get autoLock => 'Bloqueio automático';

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
  String get autoLockOff => 'Desligado';

  @override
  String get blockScreenshot => 'Bloquear capturas de ecrã';

  @override
  String get blockScreenshotSubtitle =>
      'Impede capturas e gravações de ecrã da aplicação.';

  @override
  String get blockScreenshotLinuxNote =>
      'No Linux é melhor esforço — o compositor ainda pode permitir capturas.';

  @override
  String get biometricUnlock => 'Desbloqueio biométrico';

  @override
  String get autofillService => 'Serviço de preenchimento automático';

  @override
  String get autofillEnabled =>
      'OpenKey é o seu fornecedor de palavras-passe e passkeys';

  @override
  String get autofillDisabled =>
      'Ative o OpenKey para palavras-passe (preenchimento automático) e passkeys (fornecedor de credenciais)';

  @override
  String get autofillDisabledBrowser =>
      'Instale a extensão OpenKey e desbloqueie o cofre';

  @override
  String get autofillSaveTitle => 'Guardar palavra-passe';

  @override
  String get autofillSaveSubtitle => 'Guardar este acesso no cofre OpenKey?';

  @override
  String get autofillSaved => 'Palavra-passe guardada';

  @override
  String get autofillRequireBiometric =>
      'Exigir biometria para o Preenchimento automático';

  @override
  String get autofillRequireBiometricSubtitle =>
      'Pedir impressão digital ou rosto antes de preencher palavras-passe em apps e sites.';

  @override
  String get autofillRequireBiometricReason =>
      'Confirmar o Preenchimento automático com o OpenKey';

  @override
  String get autofillRequireBiometricEnabled =>
      'Confirmação biométrica do Preenchimento automático ativada';

  @override
  String get autofillRequireBiometricDisabled =>
      'Confirmação biométrica do Preenchimento automático desativada';

  @override
  String get autofillInline => 'No teclado';

  @override
  String get autofillInlineSubtitle => 'Mostrar sugestões na barra do teclado.';

  @override
  String get autofillPopup => 'Acima do campo';

  @override
  String get autofillPopupSubtitle =>
      'Mostrar um menu pendente sobre o campo de introdução.';

  @override
  String get androidApp => 'App Android';

  @override
  String get androidAppHint => 'Nome do pacote, ex. com.example.app';

  @override
  String get biometricUnlockReason => 'Desbloqueie o seu cofre OpenKey';

  @override
  String get enableBiometricUnlockReason => 'Ativar o desbloqueio biométrico';

  @override
  String get biometricHint => 'Verifique a sua identidade';

  @override
  String get biometricNotRecognized => 'Não reconhecido. Tente novamente.';

  @override
  String get goToSettings => 'Ir às definições';

  @override
  String get biometricGoToSettingsDescription =>
      'A autenticação biométrica não está configurada. Vá às definições para registar impressão digital ou rosto.';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get unlocking => 'A desbloquear…';

  @override
  String get masterPassword => 'Palavra-passe mestra';

  @override
  String get unlockSubtitle =>
      'Introduza a palavra-passe mestra para desbloquear.';

  @override
  String welcomeBack(String email) {
    return 'Bem-vindo de volta, $email';
  }

  @override
  String get fieldRequired => 'Obrigatório';

  @override
  String get resetLocalVault => 'Repor cofre local';

  @override
  String get resetLocalVaultTitle => 'Repor cofre local?';

  @override
  String get resetLocalVaultSubtitle =>
      'Apaga permanentemente todos os dados do cofre neste dispositivo.';

  @override
  String get resetLocalVaultConfirm =>
      'Todas as palavras-passe e dados do cofre neste dispositivo serão apagados permanentemente para poder criar um novo. Os dados do servidor não são apagados. Não pode ser anulado.';

  @override
  String get dangerZone => 'Zona de perigo';

  @override
  String get reset => 'Repor';

  @override
  String get createVault => 'Criar cofre';

  @override
  String get creatingVault => 'A criar…';

  @override
  String get setupSubtitle =>
      'Crie o seu cofre encriptado. A palavra-passe mestra nunca sai deste dispositivo.';

  @override
  String get setupSignInSubtitle =>
      'Inicie sessão no seu servidor OpenKey autoalojado para restaurar este cofre no dispositivo.';

  @override
  String get setupModeCreate => 'Criar';

  @override
  String get setupModeSignIn => 'Iniciar sessão';

  @override
  String get setupModeRestore => 'Restaurar';

  @override
  String get setupSignInAction => 'Iniciar sessão';

  @override
  String get setupSigningIn => 'A iniciar sessão…';

  @override
  String get setupRestoreSubtitle =>
      'Restaure o seu cofre a partir de uma cópia cifrada OpenKey (.okbak).';

  @override
  String get setupRestoreAction => 'Restaurar cofre';

  @override
  String get setupRestoreChooseFile => 'Escolher ficheiro da cópia';

  @override
  String get setupRestoreChooseFileSubtitle =>
      'Selecione um ficheiro .okbak cifrado.';

  @override
  String setupRestoreBackupAccount(String email) {
    return 'Esta cópia é de $email';
  }

  @override
  String get setupRestoreNeedFile => 'Escolha primeiro um ficheiro de cópia';

  @override
  String get setupLinkSelfHostedTitle => 'Associar servidor autoalojado';

  @override
  String get setupLinkSelfHostedSubtitle =>
      'Opcional. Registe este cofre para sincronizar entre dispositivos.';

  @override
  String get setupLinkServerHelper =>
      'O seu cofre será registado neste servidor após a criação.';

  @override
  String get setupSignInServerHelper =>
      'URL do servidor OpenKey que já tem a sua conta.';

  @override
  String get setupChooserTitle => 'Como quer começar?';

  @override
  String get setupChooserSubtitle =>
      'Crie um cofre, inicie sessão ou restaure uma cópia de segurança.';

  @override
  String get setupChooseCreateTitle => 'Criar um cofre';

  @override
  String get setupChooseCreateSubtitle =>
      'Novo cofre encriptado neste dispositivo.';

  @override
  String get setupChooseSignInTitle => 'Iniciar sessão';

  @override
  String get setupChooseSignInSubtitle =>
      'Restaure a partir do seu servidor OpenKey autoalojado.';

  @override
  String get setupChooseRestoreTitle => 'Restaurar cópia';

  @override
  String get setupChooseRestoreSubtitle =>
      'Abra um ficheiro .okbak encriptado.';

  @override
  String get invalidServerUrl =>
      'Introduza um URL válido começado por http:// ou https://';

  @override
  String get confirmMasterPassword => 'Confirmar palavra-passe mestra';

  @override
  String get email => 'E-mail';

  @override
  String get invalidEmail => 'Introduza um e-mail válido';

  @override
  String get invalidEmailFormat => 'E-mail inválido';

  @override
  String get invalidUrlFormat =>
      'URL inválido. Use um formato como https://example.com';

  @override
  String get invalidPhoneFormat => 'Número de telefone inválido';

  @override
  String get invalidPinFormat => 'O PIN deve ter entre 4 e 12 dígitos';

  @override
  String get invalidNumberFormat => 'Introduza apenas dígitos';

  @override
  String get invalidCardFormat => 'Número de cartão inválido';

  @override
  String get invalidIpFormat => 'Endereço IP inválido';

  @override
  String get invalidWalletFormat => 'Endereço de carteira inválido';

  @override
  String get invalidRecoveryCodesFormat => 'Códigos de recuperação inválidos';

  @override
  String get fixFieldErrors => 'Corrija os campos destacados antes de guardar';

  @override
  String get passwordTooShort => 'Pelo menos 8 caracteres';

  @override
  String get passwordsDoNotMatch => 'As palavras-passe não coincidem';

  @override
  String get passwordTooShortStrong => 'Pelo menos 12 caracteres';

  @override
  String get passwordTooWeak =>
      'Use uma mistura mais longa de letras, números e símbolos';

  @override
  String get masterPasswordHelper =>
      'Recomendam-se 12+ caracteres de tipos mistos';

  @override
  String get passwordHintOptional => 'Dica de palavra-passe (opcional)';

  @override
  String get passwordHintHelper =>
      'Apenas um lembrete vago — nunca inclua a própria palavra-passe';

  @override
  String passwordHintReveal(String hint) {
    return 'Dica: $hint';
  }

  @override
  String get setupZeroKnowledgeBanner =>
      'Encriptação zero-knowledge: a OpenKey não consegue ler nem repor o seu cofre.';

  @override
  String get vaultNoticesTitle => 'Antes de criar o seu cofre';

  @override
  String get vaultNoticesSubtitle => 'Confirme estes pontos para continuar.';

  @override
  String get vaultNoticeNoRecovery =>
      'Se esquecer a palavra-passe mestra, os seus dados não podem ser recuperados.';

  @override
  String get vaultNoticeLocalEncryption =>
      'O seu cofre é encriptado neste dispositivo; a palavra-passe mestra nunca sai em texto simples.';

  @override
  String get vaultNoticeBackups =>
      'Cópias de segurança encriptadas regulares são a única proteção contra perda do dispositivo.';

  @override
  String get vaultNoticeDeviceTransfer =>
      'Mudar para um novo dispositivo exige restaurar uma cópia ou sincronização opcional com o servidor.';

  @override
  String get acceptAllNotices => 'Aceitar tudo';

  @override
  String get server => 'Servidor auto-hospedado';

  @override
  String get notConnected => 'Não conectado';

  @override
  String get data => 'Dados e partilha';

  @override
  String get dataSubtitle =>
      'Servidor, cópia de segurança, importação/exportação e partilha';

  @override
  String get importExport => 'Importar e exportar';

  @override
  String get importExportSubtitle =>
      'Mova palavras-passe para dentro ou fora do cofre';

  @override
  String get importTab => 'Importar';

  @override
  String get exportTab => 'Exportar';

  @override
  String get importPasswords => 'Importar palavras-passe';

  @override
  String get importPasswordsSubtitle =>
      'As entradas são encriptadas com a chave do cofre neste dispositivo.';

  @override
  String get exportPasswords => 'Exportar palavras-passe';

  @override
  String get exportPasswordsSubtitle =>
      'Desencripta as entradas neste dispositivo e guarda um ficheiro sem encriptação.';

  @override
  String get exportingPasswords => 'A exportar…';

  @override
  String get exportBitwardenSubtitle => 'JSON Bitwarden sem encriptação';

  @override
  String get exportChromeSubtitle => 'CSV compatível com o Chrome';

  @override
  String get exportLastPassSubtitle => 'CSV compatível com o LastPass';

  @override
  String get exportOnePasswordSubtitle => 'CSV compatível com o 1Password';

  @override
  String get exportKeePassSubtitle =>
      'Base de dados KeePass / KeePassXC encriptada (.kdbx)';

  @override
  String get exportOpenKeySubtitle =>
      'JSON OpenKey sem encriptação com pastas e dados completos';

  @override
  String get exportedItems => 'Cofre exportado';

  @override
  String exportedToPath(String path) {
    return 'Exportado para $path';
  }

  @override
  String get changeMasterPassword => 'Alterar palavra-passe mestra';

  @override
  String get changeMasterPasswordSubtitle =>
      'Reenvolve a chave do cofre. As entradas continuam encriptadas com a mesma chave.';

  @override
  String get currentMasterPassword => 'Palavra-passe mestra atual';

  @override
  String get newMasterPassword => 'Nova palavra-passe mestra';

  @override
  String get masterPasswordUnchanged => 'Escolha uma palavra-passe diferente';

  @override
  String get masterPasswordChanged => 'Palavra-passe mestra atualizada';

  @override
  String get deleteServerAccount => 'Eliminar conta do servidor';

  @override
  String get deleteServerAccountSubtitle =>
      'Remove o seu texto cifrado do servidor. Este dispositivo mantém o cofre local.';

  @override
  String get deleteServerAccountWarning =>
      'Isto não pode ser anulado. Os dados sincronizados no servidor serão eliminados permanentemente.';

  @override
  String get serverAccountDeleted => 'Conta do servidor eliminada';

  @override
  String get browserExtension => 'Extensão do navegador';

  @override
  String get browserExtensionSubtitle =>
      'Ligue o Chrome / Edge / Firefox ao cofre desbloqueado';

  @override
  String get browserExtensionSheetSubtitle =>
      'Cole o ID da extensão Chrome descompactada em chrome://extensions (modo programador). O Firefox usa um ID fixo automaticamente.';

  @override
  String get chromeExtensionId => 'ID da extensão Chrome';

  @override
  String get chromeExtensionIdHint =>
      'Mostrado sob o nome da extensão em chrome://extensions';

  @override
  String get connectBrowserExtension => 'Ligar extensão';

  @override
  String get copyOfflineExtensionLink => 'Copiar ligação offline do cofre';

  @override
  String get extensionLinkClipboardWarning =>
      'Isso copia o material de desbloqueio do cofre para a área de transferência. Outras apps podem lê-lo até limpar ou auto-limpar após um minuto.';

  @override
  String get browserExtensionHostReady =>
      'Host nativo registado. Mantenha o OpenKey desbloqueado e toque em “Usar app de ambiente de trabalho” na extensão.';

  @override
  String get browserExtensionHostHint =>
      'Desbloqueie o cofre, cole o ID do Chrome e ligue.';

  @override
  String get browserExtensionHostFailed =>
      'Não foi possível registar o host nativo. Desbloqueie o cofre e tente novamente.';

  @override
  String get cliTitle => 'CLI';

  @override
  String get cliSubtitle =>
      'Instale a CLI do OpenKey e execute o comando de conexão com o cofre desbloqueado.';

  @override
  String get cliTermuxTitle => 'Termux / CLI';

  @override
  String get cliTermuxSubtitle =>
      'Instale a CLI do OpenKey no Termux e execute o comando de conexão com o cofre desbloqueado.';

  @override
  String get cliTermuxInstall => 'Instalar';

  @override
  String get cliTermuxConnect => 'Conectar';

  @override
  String get cliTermuxUnavailable =>
      'Desbloqueie o cofre para mostrar o comando de conexão.';

  @override
  String get aboutPrivacy =>
      'O OpenKey encripta as suas palavras-passe de ponta a ponta. A palavra-passe mestra e a chave do cofre nunca saem deste dispositivo.';

  @override
  String get localVault => 'Cofre local';

  @override
  String get followDevice => 'Seguir a aparência do dispositivo';

  @override
  String get passwordGenerator => 'Gerador de palavras-passe';

  @override
  String get generatedPassword => 'Palavra-passe gerada';

  @override
  String get passwordLength => 'Comprimento';

  @override
  String charactersLabel(int n) {
    return '$n caracteres';
  }

  @override
  String get includeUppercase => 'Maiúsculas';

  @override
  String get includeLowercase => 'Minúsculas';

  @override
  String get includeDigits => 'Dígitos';

  @override
  String get includeSymbols => 'Símbolos';

  @override
  String get avoidAmbiguous => 'Evitar caracteres ambíguos';

  @override
  String get avoidAmbiguousSubtitle => 'Excluir I, l, 1, O, 0, o, |';

  @override
  String get regenerate => 'Regenerar';

  @override
  String get copyPassword => 'Copiar';

  @override
  String get passwordCopied => 'Palavra-passe copiada';

  @override
  String get passwordGeneratorSubtitle =>
      'Gere uma palavra-passe forte e única';

  @override
  String get usePassword => 'Usar palavra-passe';

  @override
  String get generateOptions => 'Opções';

  @override
  String get characterSets => 'Conjuntos de caracteres';

  @override
  String get passwordStrengthWeak => 'Fraca';

  @override
  String get passwordStrengthFair => 'Razoável';

  @override
  String get passwordStrengthStrong => 'Forte';

  @override
  String get generatorTitle => 'Gerador';

  @override
  String get generatorSubtitle =>
      'Crie palavras-passe, nomes de utilizador e e-mails';

  @override
  String get generatorModePassword => 'Palavra-passe';

  @override
  String get generatorModeUsername => 'Utilizador';

  @override
  String get generatorModeEmail => 'E-mail';

  @override
  String get generatedUsername => 'Nome de utilizador gerado';

  @override
  String get generatedEmail => 'E-mail gerado';

  @override
  String get usernameStyle => 'Estilo';

  @override
  String get usernameStyleWords => 'Palavras';

  @override
  String get usernameStyleRandom => 'Aleatório';

  @override
  String get usernameCapitalize => 'Maiúsculas';

  @override
  String get usernameIncludeDigits => 'Adicionar números';

  @override
  String get usernameSeparator => 'Separador';

  @override
  String get usernameSeparatorNone => 'Nenhum';

  @override
  String get emailType => 'Tipo de e-mail';

  @override
  String get emailTypeRandom => 'Aleatório';

  @override
  String get emailTypePlus => 'Endereço plus';

  @override
  String get emailDomain => 'Domínio';

  @override
  String get emailDomainHint => 'seudominio.com';

  @override
  String get emailPlusBase => 'O seu e-mail';

  @override
  String get emailPlusBaseHint => 'voce@gmail.com';

  @override
  String get emailPlusHelp =>
      'Cria voce+tag@gmail.com para filtrar registos na sua caixa de entrada.';

  @override
  String get emailRandomHelp =>
      'Cria um endereço único num domínio que controla, como um catch-all.';

  @override
  String get passwordDetails => 'Detalhes da palavra-passe';

  @override
  String get untitled => 'Sem título';

  @override
  String get credentials => 'Credenciais';

  @override
  String get username => 'Nome de utilizador';

  @override
  String get password => 'Palavra-passe';

  @override
  String get website => 'Sítio web';

  @override
  String get notes => 'Notas';

  @override
  String get authenticator => 'Autenticador';

  @override
  String get passkey => 'Chave de acesso';

  @override
  String get attachments => 'Anexos';

  @override
  String get downloadAttachment => 'Transferir';

  @override
  String get previewAttachment => 'Pré-visualizar';

  @override
  String get openAttachment => 'Abrir';

  @override
  String get playVideo => 'Reproduzir vídeo';

  @override
  String get pausePlayback => 'Pausa';

  @override
  String get openingAttachment => 'A abrir anexo…';

  @override
  String attachmentSaved(String name) {
    return '$name guardado';
  }

  @override
  String get couldNotOpenAttachment => 'Não foi possível abrir este anexo.';

  @override
  String get attachmentNotPreviewable =>
      'Não é possível pré-visualizar este tipo de ficheiro. Pode transferi-lo.';

  @override
  String get copyUsername => 'Copiar utilizador';

  @override
  String get showPassword => 'Mostrar palavra-passe';

  @override
  String get hidePassword => 'Ocultar palavra-passe';

  @override
  String get tapToCopy => 'Toque para copiar';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get deleteEntry => 'Eliminar entrada?';

  @override
  String get deleteEntryConfirm =>
      'Isto remove permanentemente a palavra-passe do seu cofre.';

  @override
  String get entryNotFound => 'Entrada não encontrada';

  @override
  String get entryNotFoundMessage =>
      'Esta palavra-passe pode ter sido eliminada.';

  @override
  String get goBack => 'Voltar';

  @override
  String get synced => 'Sincronizado';

  @override
  String get pendingSync => 'Sincronização pendente';

  @override
  String revisionLabel(int n) {
    return 'Revisão $n';
  }

  @override
  String valueCopied(String label) {
    return '$label copiado';
  }

  @override
  String get vault => 'Cofre';

  @override
  String get items => 'Itens';

  @override
  String get itemsHubSubtitle => 'Cartões, carteiras crypto e segredos.';

  @override
  String get itemsCardsSubtitle => 'Cartões de pagamento e dados de faturação';

  @override
  String get itemsCryptoSubtitle => 'Endereços, chaves e frases-seed';

  @override
  String get itemsSecretsSubtitle => 'Chaves SSH, tokens API e excertos .env';

  @override
  String itemsCountLabel(int count) {
    return '$count guardados';
  }

  @override
  String get wallets => 'Carteiras';

  @override
  String get searchCards => 'Pesquisar cartões';

  @override
  String get noCardsYet => 'Ainda sem cartões';

  @override
  String get noCardsYetMessage =>
      'Adicione um cartão para o guardar com segurança.';

  @override
  String get addCard => 'Adicionar cartão';

  @override
  String get editCard => 'Editar cartão';

  @override
  String get save => 'Guardar';

  @override
  String get cardDetails => 'Detalhes do cartão';

  @override
  String get cardName => 'Nome do cartão';

  @override
  String get cardHolder => 'Titular';

  @override
  String get cardNumber => 'Número do cartão';

  @override
  String get cardExpiry => 'Validade';

  @override
  String get cardCvc => 'CVC';

  @override
  String get copyNumber => 'Copiar número';

  @override
  String get copyCvc => 'Copiar CVC';

  @override
  String get tapCardToFlip => 'Toque no cartão para virar';

  @override
  String get deleteCard => 'Eliminar cartão?';

  @override
  String get deleteCardConfirm =>
      'Isto remove permanentemente o cartão da sua carteira.';

  @override
  String get cardNotFound => 'Cartão não encontrado';

  @override
  String get cardNotFoundMessage => 'Este cartão pode ter sido eliminado.';

  @override
  String get bank => 'Banco';

  @override
  String get banks => 'Bancos';

  @override
  String get otherBank => 'Outros';

  @override
  String get addBank => 'Adicionar banco';

  @override
  String get newBank => 'Novo banco';

  @override
  String get bankName => 'Nome do banco';

  @override
  String get renameBank => 'Renomear banco';

  @override
  String get deleteBank => 'Eliminar banco?';

  @override
  String get deleteBankConfirm =>
      'Remover este grupo de banco? Os cartões podem ser movidos para Outros.';

  @override
  String get deleteBankAndClear => 'Eliminar e desatribuir cartões';

  @override
  String get moveToBank => 'Mover para banco';

  @override
  String get noBanksYet => 'Ainda sem bancos';

  @override
  String get createBankHint => 'Crie um banco para organizar os seus cartões.';

  @override
  String get bankCreated => 'Banco criado';

  @override
  String get cardMoved => 'Cartão movido';

  @override
  String get emptyBank => 'Sem cartões neste banco';

  @override
  String get paymentCards => 'Cartões';

  @override
  String get cryptoWallets => 'Cripto';

  @override
  String get searchCryptoWallets => 'Pesquisar carteiras cripto';

  @override
  String get noCryptoWalletsYet => 'Ainda sem carteiras cripto';

  @override
  String get noCryptoWalletsYetMessage =>
      'Adicione uma carteira para guardar chaves com segurança.';

  @override
  String get addCryptoWallet => 'Adicionar carteira cripto';

  @override
  String get editCryptoWallet => 'Editar carteira cripto';

  @override
  String get cryptoNetwork => 'Rede';

  @override
  String get cryptoWalletName => 'Nome da carteira';

  @override
  String get walletAddress => 'Endereço';

  @override
  String get privateKey => 'Chave privada';

  @override
  String get seedPhrase => 'Frase-semente';

  @override
  String get cryptoDetails => 'Detalhes da carteira';

  @override
  String get copyAddress => 'Copiar endereço';

  @override
  String get deleteCryptoWallet => 'Eliminar carteira cripto?';

  @override
  String get deleteCryptoWalletConfirm =>
      'Isto remove permanentemente a carteira e os seus segredos do cofre.';

  @override
  String get cryptoWalletNotFound => 'Carteira cripto não encontrada';

  @override
  String get cryptoWalletNotFoundMessage =>
      'Esta carteira pode ter sido eliminada.';

  @override
  String get folders => 'Pastas';

  @override
  String get otherFolder => 'Outro';

  @override
  String get addFolder => 'Adicionar pasta';

  @override
  String get newFolder => 'Nova pasta';

  @override
  String get folderName => 'Nome da pasta';

  @override
  String get renameFolder => 'Renomear pasta';

  @override
  String get deleteFolder => 'Eliminar pasta?';

  @override
  String get deleteFolderConfirm =>
      'Remover este grupo de pasta? As carteiras podem ser movidas para Outro.';

  @override
  String get deleteFolderAndClear => 'Eliminar e desatribuir carteiras';

  @override
  String get moveToFolder => 'Mover para pasta';

  @override
  String get noFoldersYet => 'Ainda sem pastas';

  @override
  String get createFolderHint =>
      'Crie uma pasta para organizar as suas carteiras cripto.';

  @override
  String get folderCreated => 'Pasta criada';

  @override
  String get cryptoWalletMoved => 'Carteira movida';

  @override
  String get emptyFolder => 'Sem carteiras nesta pasta';

  @override
  String get secrets => 'Segredos';

  @override
  String get searchSecrets => 'Pesquisar segredos';

  @override
  String get noSecretsYet => 'Ainda sem segredos';

  @override
  String get noSecretsYetMessage =>
      'Guarde chaves SSH, tokens API e excertos .env com segurança.';

  @override
  String get addSecret => 'Adicionar segredo';

  @override
  String get editSecret => 'Editar segredo';

  @override
  String get secretKind => 'Tipo';

  @override
  String get secretKindSsh => 'Chave SSH';

  @override
  String get secretKindApiToken => 'Token API';

  @override
  String get secretKindEnv => 'Excerto .env';

  @override
  String get secretKindOther => 'Outro';

  @override
  String get secretName => 'Nome';

  @override
  String get secretUsername => 'Nome de utilizador';

  @override
  String get secretHost => 'Anfitrião';

  @override
  String get secretEndpoint => 'Ponto de extremidade / URL';

  @override
  String get publicKey => 'Chave pública';

  @override
  String get apiToken => 'Token API';

  @override
  String get envContent => 'Conteúdo .env';

  @override
  String get secretValue => 'Segredo';

  @override
  String get passphrase => 'Frase-passe';

  @override
  String get secretDetails => 'Detalhes do segredo';

  @override
  String get copySecret => 'Copiar segredo';

  @override
  String get deleteSecret => 'Eliminar segredo?';

  @override
  String get deleteSecretConfirm =>
      'Isto remove permanentemente o segredo do seu cofre.';

  @override
  String get secretNotFound => 'Segredo não encontrado';

  @override
  String get secretNotFoundMessage => 'Este segredo pode ter sido eliminado.';

  @override
  String get reverseOrderSecretsSubtitle =>
      'Mostrar segredos em ordem inversa.';

  @override
  String get device => 'Dispositivo';

  @override
  String get devices => 'Dispositivos';

  @override
  String get otherDevice => 'Outro';

  @override
  String get addDevice => 'Adicionar dispositivo';

  @override
  String get newDevice => 'Novo dispositivo';

  @override
  String get deviceName => 'Nome do dispositivo';

  @override
  String get renameDevice => 'Mudar nome do dispositivo';

  @override
  String get deleteDevice => 'Eliminar dispositivo?';

  @override
  String get deleteDeviceConfirm =>
      'Remover este grupo de dispositivo? Os segredos podem ser movidos para Outro.';

  @override
  String get deleteDeviceAndClear => 'Eliminar e desassociar segredos';

  @override
  String get moveToDevice => 'Mover para dispositivo';

  @override
  String get noDevicesYet => 'Ainda sem dispositivos';

  @override
  String get createDeviceHint =>
      'Crie um dispositivo para organizar segredos de cada máquina.';

  @override
  String get deviceCreated => 'Dispositivo criado';

  @override
  String get secretMoved => 'Segredo movido';

  @override
  String get emptyDevice => 'Sem segredos neste dispositivo';

  @override
  String get faq => 'Perguntas frequentes';

  @override
  String get faqSubtitle => 'Encriptação, desbloqueio, sync e mais';

  @override
  String get faqEncryptionQ => 'Os meus dados estão encriptados?';

  @override
  String get faqEncryptionA =>
      'Sim. O OpenKey encripta o seu cofre de ponta a ponta neste dispositivo. A palavra-passe mestra e a chave do cofre nunca saem do dispositivo em texto simples.';

  @override
  String get faqForgotPasswordQ => 'E se eu esquecer a palavra-passe mestra?';

  @override
  String get faqForgotPasswordA =>
      'Não há recuperação sem a palavra-passe mestra. Devido à encriptação zero-knowledge, o OpenKey não a pode repor. Guarde uma cópia segura da palavra-passe.';

  @override
  String get faqOfflineQ => 'O OpenKey funciona offline?';

  @override
  String get faqOfflineA =>
      'Sim. O cofre fica guardado localmente e desbloqueia sem rede. Um servidor opcional só é preciso para sincronizar e partilhar.';

  @override
  String get faqAutoLockQ => 'Como funciona o bloqueio automático?';

  @override
  String get faqAutoLockA =>
      'Quando sai da aplicação sem a fechar, o OpenKey conta o tempo de ausência. Após o período escolhido em Definições, o cofre bloqueia; precisará da palavra-passe mestra ou biometria. Fechar a aplicação termina a sessão imediatamente.';

  @override
  String get faqBiometricQ => 'O desbloqueio biométrico é seguro?';

  @override
  String get faqBiometricA =>
      'Sim. A biometria desbloqueia uma chave no hardware seguro. Não substitui a palavra-passe mestra — pode usá-la quando quiser.';

  @override
  String get faqSyncQ => 'O que é a sincronização self-hosted?';

  @override
  String get faqSyncA =>
      'Pode correr o seu próprio servidor OpenKey. Os aparelhos enviam dados cifrados do cofre para se manterem sincronizados à distância. O servidor guarda só texto cifrado e nunca vê os segredos em claro. A palavra-passe mestra fica em cada aparelho.';

  @override
  String get faqBackupQ => 'Como funcionam a cópia de segurança e o restauro?';

  @override
  String get faqBackupA =>
      'Em Definições → Cópia de segurança e restauro pode guardar uma cópia completa do cofre neste dispositivo. O OpenKey junta a base de dados, as definições e os anexos num ficheiro comprimido e cifra-o com a chave do cofre (.okbak). Ninguém consegue ler o ficheiro sem a palavra-passe mestra. Restaurar decifra esse ficheiro e substitui o cofre local pela cópia — guarde a palavra-passe e o ficheiro .okbak num sítio seguro.';

  @override
  String get appName => 'OpenKey';

  @override
  String get copy => 'Copiar';

  @override
  String get create => 'Criar';

  @override
  String get generate => 'Gerar';

  @override
  String get name => 'Nome';

  @override
  String get title => 'Título';

  @override
  String get lock => 'Bloquear';

  @override
  String get all => 'Tudo';

  @override
  String get entry => 'Entrada';

  @override
  String get collection => 'Coleção';

  @override
  String get searchPasswords => 'Pesquisar palavras-passe';

  @override
  String get noPasswordsYet => 'Ainda sem palavras-passe';

  @override
  String get noPasswordsYetMessage =>
      'Adicione uma entrada ou crie uma coleção.';

  @override
  String get newCollection => 'Nova coleção';

  @override
  String get newEntry => 'Nova entrada';

  @override
  String get editEntry => 'Editar entrada';

  @override
  String get chooseFields => 'Campos';

  @override
  String get chooseFieldsSubtitle =>
      'Ative ou desative campos e arraste para reordenar';

  @override
  String get done => 'Concluído';

  @override
  String get phone => 'Telefone';

  @override
  String get pin => 'PIN';

  @override
  String get number => 'Número';

  @override
  String get address => 'Morada';

  @override
  String get ipAddress => 'Endereço IP';

  @override
  String get dateYmd => 'Data';

  @override
  String get dateYm => 'Mês / ano';

  @override
  String get recoveryCodes => 'Códigos de recuperação';

  @override
  String get customText => 'Texto';

  @override
  String get additionalFields => 'Campos adicionais';

  @override
  String get emptyCollection => 'Coleção vazia';

  @override
  String get emptyCollectionMessage =>
      'Adicione uma entrada de palavra-passe a esta coleção.';

  @override
  String get editCollection => 'Editar coleção';

  @override
  String get deleteCollection => 'Eliminar coleção';

  @override
  String get deleteCollectionConfirm =>
      'As entradas desta coleção serão removidas da pasta (não eliminadas). Continuar?';

  @override
  String get chooseIcon => 'Escolher ícone';

  @override
  String get icons => 'Ícones';

  @override
  String get brands => 'Marcas';

  @override
  String get suggestedIcon => 'Ícone sugerido';

  @override
  String get fromDevice => 'Do dispositivo';

  @override
  String get customIcon => 'Ícone personalizado';

  @override
  String get editIcon => 'Editar ícone';

  @override
  String get cropOrRotate => 'Recortar / Rodar';

  @override
  String get rotate => 'Rodar';

  @override
  String get flip => 'Inverter';

  @override
  String get ratio => 'Proporção';

  @override
  String get filter => 'Filtro';

  @override
  String get blur => 'Desfocar';

  @override
  String get discardChanges => 'Descartar alterações?';

  @override
  String get discardChangesMessage => 'As suas edições serão perdidas.';

  @override
  String get discard => 'Descartar';

  @override
  String get undo => 'Anular';

  @override
  String get redo => 'Refazer';

  @override
  String get more => 'Mais';

  @override
  String get back => 'Voltar';

  @override
  String get preparingImage => 'A preparar imagem…';

  @override
  String get search => 'Pesquisar';

  @override
  String get noFolder => 'Sem pasta';

  @override
  String get folder => 'Pasta';

  @override
  String entriesCount(int count) {
    return '$count entradas';
  }

  @override
  String get moveTo => 'Mover para';

  @override
  String get moveHere => 'Mover para aqui';

  @override
  String get movingLabel => 'A mover';

  @override
  String movingItemsCount(int count) {
    return '$count itens';
  }

  @override
  String get tags => 'Etiquetas';

  @override
  String get noTags => 'Ainda sem etiquetas';

  @override
  String get noTagsMessage => 'Adicione etiquetas ao editar uma entrada.';

  @override
  String get sortAndFilter => 'Ordenar e filtrar';

  @override
  String get applyToFolders => 'Pastas';

  @override
  String get applyToEntries => 'Senhas';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get options => 'Opções';

  @override
  String get sortByCreationTime => 'Ordenar por data de criação';

  @override
  String get sortByLastModified => 'Ordenar por última alteração';

  @override
  String get sortByName => 'Ordenar por nome';

  @override
  String get sortByCustomOrder => 'Ordem personalizada';

  @override
  String get reverseOrder => 'Ordem inversa';

  @override
  String get reverseOrderFoldersSubtitle => 'Mostrar pastas em ordem inversa.';

  @override
  String get reverseOrderEntriesSubtitle => 'Mostrar senhas em ordem inversa.';

  @override
  String get reverseOrderCardsSubtitle => 'Mostrar cartões em ordem inversa.';

  @override
  String get reverseOrderCryptoSubtitle =>
      'Mostrar carteiras em ordem inversa.';

  @override
  String get addTagHint => 'Adicionar etiqueta';

  @override
  String deleteSelectedConfirm(int count) {
    return 'Eliminar $count itens selecionados?';
  }

  @override
  String get totpSecretLabel => 'Segredo TOTP / otpauth';

  @override
  String get scanTotpQr => 'Digitalizar código QR';

  @override
  String get scanTotpQrHint =>
      'Aponte a câmera para o código QR do autenticador';

  @override
  String get invalidTotpQr => 'Este código QR não é um código TOTP válido';

  @override
  String get cameraPermissionDenied =>
      'A permissão da câmera é necessária para digitalizar códigos QR';

  @override
  String get storePasskeyMetadata => 'Chave de acesso';

  @override
  String get passkeyCreatedInBrowser =>
      'Crie passkeys com a extensão OpenKey ou via preenchimento automático / fornecedor de credenciais no telemóvel com o OpenKey desbloqueado.';

  @override
  String get rpId => 'RP ID';

  @override
  String get credentialId => 'ID da credencial';

  @override
  String get addPasskeyItem => 'Ainda sem passkey';

  @override
  String bytesLabel(int n) {
    return '$n bytes';
  }

  @override
  String get addEncryptedAttachment => 'Adicionar anexo encriptado';

  @override
  String get expiryHint => 'MM/AA';

  @override
  String get autoLockSubtitle =>
      'Bloqueia o cofre depois de sair da aplicação.';

  @override
  String get serverUrl => 'URL do servidor';

  @override
  String get serverUrlHint => 'https://openkey.example.com';

  @override
  String get serverSheetSubtitle =>
      'Registe-se ou inicie sessão para sincronizar apenas o texto cifrado do cofre.';

  @override
  String get register => 'Registar';

  @override
  String get registerSubtitle => 'Criar uma conta neste servidor';

  @override
  String get login => 'Iniciar sessão';

  @override
  String get loginSubtitle =>
      'Inicie sessão com o hash de autenticação deste cofre';

  @override
  String get syncNow => 'Sincronizar agora';

  @override
  String get syncing => 'A sincronizar…';

  @override
  String get syncSubtitle => 'Enviar e receber alterações encriptadas';

  @override
  String get syncComplete => 'Sincronização concluída';

  @override
  String get extensionLinkCopied => 'Payload da ligação da extensão copiado';

  @override
  String get biometricUnlockEnabled => 'Desbloqueio biométrico ativado';

  @override
  String get biometricUnlockDisabled => 'Desbloqueio biométrico desativado';

  @override
  String biometricsUpdateFailed(String error) {
    return 'Não foi possível atualizar a biometria: $error';
  }

  @override
  String get bitwardenJson => 'Bitwarden JSON';

  @override
  String get bitwardenJsonSubtitle => 'Exportar do Bitwarden → importar aqui';

  @override
  String get openKeyJson => 'OpenKey JSON';

  @override
  String get openKeyJsonSubtitle => 'Cópia de segurança exportada do OpenKey';

  @override
  String get chromeCsv => 'Chrome CSV';

  @override
  String get chromeCsvSubtitle => 'Palavras-passe exportadas do Chrome';

  @override
  String get lastPassCsv => 'LastPass CSV';

  @override
  String get lastPassCsvSubtitle => 'Exportação CSV do LastPass';

  @override
  String get keePassKdbx => 'KeePass (.kdbx)';

  @override
  String get keePassKdbxSubtitle =>
      'Base de dados KeePass / KeePassXC encriptada';

  @override
  String get keePassPasswordHint => 'Palavra-passe da base de dados';

  @override
  String get keePassKeyFile => 'Ficheiro de chave (opcional)';

  @override
  String get keePassUnlockFailed =>
      'Não foi possível abrir a base KeePass. Verifique a palavra-passe e o ficheiro de chave.';

  @override
  String get onePasswordCsv => '1Password CSV';

  @override
  String get onePasswordCsvSubtitle => 'Exportação CSV do 1Password';

  @override
  String get importingPasswords => 'A importar…';

  @override
  String importingProgress(int done, int total) {
    return 'A importar $done de $total…';
  }

  @override
  String importedItems(int n) {
    return 'Importados $n itens';
  }

  @override
  String get failureUnknown => 'Algo correu mal.';

  @override
  String get failureNetwork => 'Erro de rede. Verifique a ligação.';

  @override
  String get failureUnauthorized => 'Não autorizado. Inicie sessão novamente.';

  @override
  String get failureNotFound => 'Não encontrado.';

  @override
  String get failureServer => 'Erro do servidor.';

  @override
  String get failureInvalidCredentials =>
      'E-mail ou palavra-passe mestra inválidos.';

  @override
  String get failureVaultLocked => 'O cofre está bloqueado.';

  @override
  String get failureVaultAlreadyExists =>
      'Já existe um cofre neste dispositivo.';

  @override
  String get failureDecryptionFailed =>
      'Não foi possível desencriptar os dados do cofre.';

  @override
  String get failureSyncFailed => 'A sincronização falhou.';

  @override
  String get failureCreateCollection => 'Falha ao criar a coleção.';

  @override
  String get failureUpdateCollection => 'Falha ao atualizar a coleção.';

  @override
  String get failureDeleteCollection => 'Falha ao eliminar a coleção.';

  @override
  String get failureGetCollections => 'Falha ao carregar as coleções.';

  @override
  String get failureCreateEntry => 'Falha ao criar a entrada.';

  @override
  String get failureUpdateEntry => 'Falha ao atualizar a entrada.';

  @override
  String get failureDeleteEntry => 'Falha ao eliminar a entrada.';

  @override
  String get failureGetEntries => 'Falha ao carregar as entradas.';

  @override
  String get failureNoVault => 'Nenhum cofre encontrado. Crie um primeiro.';

  @override
  String get failureConnectServerFirst =>
      'Ligue primeiro um servidor em Definições.';

  @override
  String get failureAttachmentTooLarge => 'O anexo excede o limite de 20 MB.';

  @override
  String get failureAttachmentMissing => 'Texto cifrado do anexo em falta.';

  @override
  String get failureAccountEmailExists =>
      'Esse e-mail já tem um cofre neste dispositivo.';

  @override
  String get root => 'Raiz';

  @override
  String get selectedItems => 'selecionados';

  @override
  String get authenticatorTotp => 'Autenticador (TOTP)';

  @override
  String get openKeyPro => 'OpenKey Pro';

  @override
  String get proSubtitle =>
      'Desbloqueie funcionalidades premium e apoie o desenvolvimento do OpenKey.';

  @override
  String get premiumFeatureTitle => 'Funcionalidade premium';

  @override
  String get premiumFeatureSubtitle =>
      'Subscreva para desbloquear esta funcionalidade premium.';

  @override
  String get premiumFeatureContent =>
      'Esta é uma funcionalidade premium. Subscreva para aceder.';

  @override
  String get premiumBadge => 'Pro';

  @override
  String get subscribe => 'Subscrever';

  @override
  String get upgradeNow => 'Atualizar agora';

  @override
  String get oops => 'Ups!';

  @override
  String get subscription => 'Subscrição';

  @override
  String get subscriptionTitle => 'Subscrição';

  @override
  String get subscriptionSubtitle => 'Escolha um plano que lhe sirva.';

  @override
  String get manageYourSubscription => 'Gerir a sua subscrição';

  @override
  String get manageSubscriptionAction => 'Gerir subscrição';

  @override
  String get subIsActiveTitle => 'A sua subscrição está ativa';

  @override
  String get subIsNotActiveTitle => 'A sua subscrição está inativa';

  @override
  String get thanksForSubscribing => 'Obrigado por subscrever!';

  @override
  String get subIsCancelled =>
      'A sua subscrição está cancelada e não será renovada.';

  @override
  String get subIsPaused => 'A sua subscrição está em pausa.';

  @override
  String get restorePurchase => 'Restaurar compra';

  @override
  String get viewPlansPaywall => 'Ver opções de subscrição';

  @override
  String get openCustomerCenter => 'Gerir no Centro de clientes';

  @override
  String get subscriptionDesktopNote =>
      'As compras na app estão disponíveis em Android, iOS e macOS. No Windows e Linux, inicie sessão com a mesma conta OpenKey para desbloquear o Pro após subscrever no telemóvel ou Mac.';

  @override
  String get subscriptionRefreshStatus => 'Atualizar estado da subscrição';

  @override
  String get subscriptionNoInternetMsg =>
      'Há um problema com a sua ligação à Internet. Verifique a rede e tente novamente.';

  @override
  String get subscriptionRegionBlockedMsg =>
      'Os serviços de subscrição não estão acessíveis na sua região. Ligue-se a uma VPN e tente novamente.';

  @override
  String get monthly => 'Mensal';

  @override
  String get yearly => 'Anual';

  @override
  String get lifetime => 'Vitalício';

  @override
  String get monthlySubtitle => 'Renovação automática, cancele quando quiser';

  @override
  String get yearlySubtitle =>
      'Renovação automática, melhor valor, cancele quando quiser';

  @override
  String get lifetimeSubtitle => 'Compra única, seu para sempre';

  @override
  String monthlyPriceLabel(String price) {
    return '$price/mês';
  }

  @override
  String yearlyPriceLabel(String price) {
    return '$price/ano';
  }

  @override
  String lifetimePriceLabel(String price) {
    return '$price';
  }

  @override
  String monthlySubscribeLabel(String price) {
    return 'Subscrever por $price / mês';
  }

  @override
  String yearlySubscribeLabel(String price) {
    return 'Subscrever por $price / ano';
  }

  @override
  String lifetimeSubscribeLabel(String price) {
    return 'Comprar vitalício por $price';
  }

  @override
  String get bestValue => 'Melhor valor';

  @override
  String get skip => 'Saltar';

  @override
  String get getStarted => 'Começar';

  @override
  String get onboardingFaqTitle => 'Saiba isto antes de começar';

  @override
  String get onboardingFaqSubtitle =>
      'As perguntas mais frequentes sobre o OpenKey. Toque para expandir — depois crie o seu cofre.';

  @override
  String get onboardingNext => 'Seguinte';

  @override
  String get onboardingWelcomeTitle => 'As suas chaves. O seu cofre.';

  @override
  String get onboardingWelcomeSubtitle =>
      'O OpenKey guarda palavras-passe, códigos e cartões num espaço encriptado — feito para o dia a dia.';

  @override
  String get onboardingWelcomePhrase1 => 'Zero-knowledge por design';

  @override
  String get onboardingWelcomePhrase2 =>
      'Preenchimento automático com um toque';

  @override
  String get onboardingWelcomePhrase3 => 'Autoalojado quando quiser';

  @override
  String get onboardingSecurityTitle => 'Ninguém mais consegue ler';

  @override
  String get onboardingSecuritySubtitle =>
      'A encriptação de ponta a ponta significa que a palavra-passe mestra nunca sai deste dispositivo. Guardamos apenas texto cifrado.';

  @override
  String get onboardingAutofillTitle => 'Preencha uma vez. Confie sempre.';

  @override
  String get onboardingAutofillSubtitle =>
      'Inicie sessão em apps e sites sem procurar palavras-passe. O preenchimento automático torna o OpenKey parte do quotidiano.';

  @override
  String get onboardingAllInOneTitle => 'Uma app. Cofre completo.';

  @override
  String get onboardingAllInOneSubtitle =>
      'Palavras-passe, códigos, cartões, carteiras crypto e segredos de programador — substitua a confusão por um único cofre de confiança.';

  @override
  String get onboardingFeaturePasswords => 'Palavras-passe';

  @override
  String get onboardingFeatureCrypto => 'Cripto';

  @override
  String get onboardingFeatureAutofill => 'Preenchimento';

  @override
  String get onboardingFeatureSelfHost => 'Autoalojado.';

  @override
  String get onboardingFooterHint =>
      'Menos de um minuto. Pode saltar a qualquer momento.';

  @override
  String get onboardingLetsGo => 'Vamos!';

  @override
  String onboardingStepOf(int current, int total) {
    return 'Passo $current de $total';
  }

  @override
  String get onboardingWelcomeHeadline => 'Bem-vindo\nao OpenKey.';

  @override
  String get onboardingWelcomeLead => 'Vamos configurar tudo para si';

  @override
  String get onboardingEcosystemTitle => 'O seu\ncofre\ncompleto.';

  @override
  String get onboardingEcosystemSubtitle =>
      'Palavras-passe, códigos e cartões — encriptados e prontos onde iniciar sessão.';

  @override
  String get onboardingStyleTitle => 'Ao seu\nestilo.';

  @override
  String get onboardingEnableAutofillTitle => 'Ative o\npreenchimento.';

  @override
  String get onboardingAutofillCardTitle => 'Preenchimento de palavras-passe';

  @override
  String get onboardingAutofillCardSubtitle =>
      'Preencha inícios de sessão em apps e sites a partir do seu cofre.';

  @override
  String get onboardingAutofillGranted => 'O preenchimento está pronto';

  @override
  String get onboardingFinishBadge => 'Configuração concluída';

  @override
  String get onboardingFinishTitle => 'Pronto para\nfechar.';

  @override
  String get onboardingFinishSubtitle =>
      'Crie uma palavra-passe mestra e comece a guardar o que importa — o cofre está a um passo.';

  @override
  String get onboardingCreateVault => 'Criar cofre';

  @override
  String get errorLoadingData => 'Erro ao carregar dados. Tente novamente.';

  @override
  String get retryAgain => 'Tentar novamente';

  @override
  String get autoRenewLabel => 'Renovação automática';

  @override
  String get cancelledLabel => 'Cancelada';

  @override
  String get pausedLabel => 'Em pausa';

  @override
  String get supportAppDevelopmentTitle => 'Apoiar o desenvolvimento';

  @override
  String get supportAppDevelopmentSubtitle =>
      'A sua subscrição ajuda-nos a melhorar o OpenKey.';

  @override
  String get limitEntriesTitle => 'Limite de entradas atingido';

  @override
  String get limitCollectionsTitle => 'Limite de coleções atingido';

  @override
  String get limitWalletsTitle => 'Limite de cartões atingido';

  @override
  String get limitCryptoWalletsTitle => 'Limite de carteiras crypto atingido';

  @override
  String get limitSecretsTitle => 'Limite de segredos atingido';

  @override
  String limitReachedContent(int usage, int limit, String feature) {
    return 'Usou $usage de $limit $feature. Atualize para Pro para acesso ilimitado.';
  }

  @override
  String limitSubtitle(int limit, String feature) {
    return 'O plano gratuito inclui até $limit $feature.';
  }

  @override
  String get entries => 'entradas';

  @override
  String get collections => 'coleções';

  @override
  String get cards => 'cartões';

  @override
  String get cryptoWalletsFeature => 'carteiras crypto';

  @override
  String get secretsFeature => 'segredos';

  @override
  String expiresOn(String date) {
    return 'Expira em $date';
  }

  @override
  String get unlockUnlimitedEntriesTitle => 'Entradas ilimitadas';

  @override
  String get unlockUnlimitedEntriesSubtitle =>
      'Guarde tantas palavras-passe e logins quanto precisar.';

  @override
  String get unlockUnlimitedCollectionsTitle => 'Coleções ilimitadas';

  @override
  String get unlockUnlimitedCollectionsSubtitle =>
      'Organize o seu cofre com tantas pastas quanto quiser.';

  @override
  String get unlockUnlimitedWalletsTitle => 'Cartões ilimitados';

  @override
  String get unlockUnlimitedWalletsSubtitle =>
      'Guarde tantos cartões de pagamento quanto precisar.';

  @override
  String get unlockUnlimitedCryptoWalletsTitle => 'Carteiras crypto ilimitadas';

  @override
  String get unlockUnlimitedCryptoWalletsSubtitle =>
      'Guarde endereços, chaves e frases-seed sem limites.';

  @override
  String get unlockUnlimitedSecretsTitle =>
      'Segredos de programador ilimitados';

  @override
  String get unlockUnlimitedSecretsSubtitle =>
      'Guarde chaves SSH, tokens API e excertos .env sem limites.';

  @override
  String get unlockSyncTitle => 'Sync do servidor';

  @override
  String get unlockSyncSubtitle =>
      'Ligue o seu servidor autoalojado e sincronize entre dispositivos.';

  @override
  String get unlockAttachmentsTitle => 'Anexos';

  @override
  String get unlockAttachmentsSubtitle =>
      'Anexe ficheiros encriptados a entradas do cofre.';

  @override
  String get unlockImportExportTitle => 'Importar e exportar';

  @override
  String get unlockImportExportSubtitle => 'Mova dados de e para o OpenKey.';

  @override
  String get unknownFailureMsg => 'Ocorreu um erro desconhecido.';

  @override
  String get purchaseCancelledMsg => 'A compra foi cancelada.';

  @override
  String get storeProblemMsg => 'Houve um problema com a loja.';

  @override
  String get purchaseNotAllowedMsg =>
      'Compras não são permitidas neste dispositivo.';

  @override
  String get purchaseInvalidMsg => 'A compra é inválida.';

  @override
  String get productNotAvailableForPurchaseMsg =>
      'Este produto não está disponível para compra.';

  @override
  String get productAlreadyPurchasedMsg => 'Este produto já foi comprado.';

  @override
  String get receiptAlreadyInUseMsg => 'Este recibo já está em uso.';

  @override
  String get invalidReceiptMsg => 'O recibo é inválido.';

  @override
  String get missingReceiptFileMsg => 'Falta o ficheiro do recibo.';

  @override
  String get networkErrorMsg =>
      'Ocorreu um erro de rede. Verifique a sua ligação.';

  @override
  String get invalidCredentialsMsg => 'Credenciais inválidas.';

  @override
  String get unexpectedBackendResponseMsg => 'Resposta inesperada do servidor.';

  @override
  String get receiptInUseByOtherSubscriberMsg =>
      'O recibo está a ser usado por outro subscritor.';

  @override
  String get invalidAppUserIdMsg => 'O ID de utilizador da app é inválido.';

  @override
  String get operationAlreadyInProgressMsg =>
      'Já existe uma operação em curso.';

  @override
  String get unknownBackendErrorMsg =>
      'Ocorreu um erro desconhecido no servidor.';

  @override
  String get invalidAppleSubscriptionKeyMsg =>
      'A chave de subscrição da Apple é inválida.';

  @override
  String get ineligibleMsg => 'Não é elegível para esta compra.';

  @override
  String get insufficientPermissionsMsg => 'Não tem permissões suficientes.';

  @override
  String get paymentPendingMsg => 'O pagamento está pendente.';

  @override
  String get invalidSubscriberAttributesMsg =>
      'Os atributos do subscritor são inválidos.';

  @override
  String get logOutWithAnonymousUserMsg =>
      'Não é possível terminar sessão com um utilizador anónimo.';

  @override
  String get configurationErrorMsg => 'Há um erro de configuração.';

  @override
  String get unsupportedErrorMsg => 'Esta operação não é suportada.';

  @override
  String get emptySubscriberAttributesMsg =>
      'Os atributos do subscritor estão vazios.';

  @override
  String get productDiscountMissingIdentifierMsg =>
      'Falta o identificador de desconto do produto.';

  @override
  String get unknownNonNativeErrorMsg =>
      'Ocorreu um erro não nativo desconhecido.';

  @override
  String get productDiscountMissingSubscriptionGroupIdentifierMsg =>
      'Falta o identificador do grupo de subscrição do desconto.';

  @override
  String get customerInfoErrorMsg => 'Falha ao obter informações do cliente.';

  @override
  String get systemInfoErrorMsg => 'Falha ao obter informações do sistema.';

  @override
  String get beginRefundRequestErrorMsg =>
      'Falha ao iniciar o pedido de reembolso.';

  @override
  String get productRequestTimeoutMsg => 'O pedido do produto expirou.';

  @override
  String get apiEndpointBlockedMsg => 'O endpoint da API está bloqueado.';

  @override
  String get invalidPromotionalOfferMsg => 'A oferta promocional é inválida.';

  @override
  String get offlineConnectionMsg =>
      'Sem ligação à Internet. Ligue-se e tente novamente.';

  @override
  String get featureNotAvailableInCustomEntitlementsComputationModeMsg =>
      'Este recurso não está disponível no modo de cálculo de direitos personalizado.';

  @override
  String get signatureVerificationFailedMsg =>
      'Falha na verificação da assinatura.';

  @override
  String get featureNotSupportedWithStoreKit1Msg =>
      'Este recurso não é suportado com StoreKit 1.';

  @override
  String get invalidWebPurchaseTokenMsg => 'O token de compra web é inválido.';

  @override
  String get purchaseBelongsToOtherUserMsg =>
      'Esta compra pertence a outro utilizador.';

  @override
  String get expiredWebPurchaseTokenMsg => 'O token de compra web expirou.';

  @override
  String get testStoreSimulatedPurchaseErrorMsg =>
      'Erro de compra simulada da loja de teste.';

  @override
  String get aboutApp => 'Acerca da app';

  @override
  String get aboutAppSubtitle =>
      'Saiba mais sobre o OpenKey e o seu desenvolvimento.';

  @override
  String get developerName => 'OpenSelfHosting';

  @override
  String get developer => 'Software de código aberto que você hospeda';

  @override
  String rateUsIn(String storeName) {
    return 'Avalie-nos na $storeName';
  }

  @override
  String get doYouLikeTheAppRateUs => 'Gosta da app? Avalie-nos!';

  @override
  String get licenses => 'Licenças';

  @override
  String get openLicenses => 'Abrir licenças';

  @override
  String get privacyPolicy => 'Política de privacidade';

  @override
  String get privacyPolicySubtitle => 'Ler a nossa política de privacidade';

  @override
  String get termsOfService => 'Termos de serviço';

  @override
  String get termsOfServiceSubtitle => 'Ler os nossos termos de serviço';

  @override
  String get pricing => 'Preços';

  @override
  String get pricingSubtitle => 'Planos Grátis vs OpenKey Pro';

  @override
  String get copied => 'Copiado para a área de transferência';

  @override
  String get contact => 'Contacto';

  @override
  String get contactSubtitle => 'Contacte-nos para suporte ou feedback.';

  @override
  String get telegram => 'Telegram';

  @override
  String get ok => 'OK';

  @override
  String get localBackupRestoreTitle => 'Cópia de segurança e restauro';

  @override
  String get localBackupRestoreSubtitle =>
      'Crie uma cópia cifrada de todo o cofre (.okbak) ou restaure uma. Inclui a base de dados, as definições e os anexos.';

  @override
  String get exportBackup => 'Exportar cópia';

  @override
  String get exportBackupSubtitleEmpty =>
      'Crie uma cópia local cifrada e escolha onde a guardar.';

  @override
  String exportBackupSubtitleLatest(String path) {
    return 'Última exportação: $path';
  }

  @override
  String get importBackup => 'Restaurar cópia';

  @override
  String get importBackupSubtitle =>
      'Substitua este cofre por uma cópia cifrada OpenKey (.okbak).';

  @override
  String get confirmRestore => 'Confirmar restauro';

  @override
  String get confirmRestoreMessage =>
      'Restaurar substitui a base local, as definições e os anexos pela cópia. Introduza a palavra-passe mestra dessa cópia para a decifrar.';

  @override
  String get creatingBackup => 'A criar cópia…';

  @override
  String get creatingBackupBody => 'A comprimir e cifrar todo o cofre.';

  @override
  String get restoringBackupProgress => 'A restaurar cópia…';

  @override
  String get restoringBackupBody => 'A decifrar e restaurar o seu cofre.';

  @override
  String get restoringBackupVerifying => 'A verificar a palavra-passe mestra…';

  @override
  String get restoringBackupDecrypting => 'A decifrar os dados da cópia…';

  @override
  String get restoringBackupWriting => 'A escrever o cofre restaurado…';

  @override
  String get restoringBackupUnlocking => 'A abrir o cofre restaurado…';

  @override
  String get backupComplete => 'Cópia concluída';

  @override
  String get backupCompleteLocalBody =>
      'A sua cópia cifrada foi guardada com êxito.';

  @override
  String get backupCompleteLocalDetail =>
      'Guarde este ficheiro num sítio seguro. Precisa da palavra-passe mestra para o restaurar.';

  @override
  String get backupError => 'Erro na cópia de segurança';

  @override
  String get restoreCompleted => 'Restauro concluído';

  @override
  String get restoreCompletedBody =>
      'O seu cofre foi restaurado a partir da cópia cifrada.';
}
