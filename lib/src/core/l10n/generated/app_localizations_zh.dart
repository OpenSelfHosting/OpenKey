// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get settings => '设置';

  @override
  String get appearance => '外观';

  @override
  String get appearanceSubtitle => '主题、颜色、字体和语言';

  @override
  String get themeMode => '主题模式';

  @override
  String get system => '系统';

  @override
  String get light => '浅色';

  @override
  String get dark => '深色';

  @override
  String get language => '语言';

  @override
  String get fonts => '字体';

  @override
  String get displayFont => '显示字体';

  @override
  String get defaultFont => '默认';

  @override
  String get arabicFont => '阿拉伯语';

  @override
  String get developerFont => '开发者';

  @override
  String get technicalFont => '技术';

  @override
  String get standardFont => '标准';

  @override
  String get defaultFontDes => '应用程序的默认字体。';

  @override
  String get arabicFontDes => '针对阿拉伯文字优化的字体。';

  @override
  String get developerFontDes => '为开发者设计的字体。';

  @override
  String get technicalFontDes => '适合技术内容的字体。';

  @override
  String get standardFontDes => '通用标准字体。';

  @override
  String get googleSansFlexFont => 'Google Sans Flex';

  @override
  String get googleSansFlexFontDes => '面向 Material 3 Expressive 的谷歌品牌可变字体。';

  @override
  String get robotoFlexFont => 'Roboto Flex';

  @override
  String get robotoFlexFontDes => 'Material Design 可变字体，支持字重、宽度和视觉尺寸。';

  @override
  String get figtreeFont => 'Figtree';

  @override
  String get figtreeFontDes => '常与 Material You 主题搭配的柔和几何无衬线字体。';

  @override
  String get nunitoFont => 'Nunito';

  @override
  String get nunitoFontDes =>
      'A rounded geometric sans with a friendly, modern tone.';

  @override
  String get dynamicColors => '动态颜色';

  @override
  String get dynamicColorsSubtitle => '根据所选色种生成主题';

  @override
  String get colorScheme => '配色方案';

  @override
  String get colorSchemeSubtitle => '选择色种和调色板风格';

  @override
  String get highContrast => '高对比度';

  @override
  String get highContrastSubtitle => '提高对比度以便阅读';

  @override
  String get security => '安全';

  @override
  String get securitySubtitle => '自动锁定、生物识别、自动填充和主密码';

  @override
  String get account => '账户';

  @override
  String get accountPageTitle => '账户';

  @override
  String get accountPhoto => '头像';

  @override
  String get changeAccountPhoto => '更换照片';

  @override
  String get removeAccountPhoto => '移除照片';

  @override
  String get changeEmail => '更改邮箱';

  @override
  String get changeEmailSubtitle => '将重新封装保险库密钥。之后需用新邮箱解锁。';

  @override
  String get newEmail => '新邮箱';

  @override
  String get emailChanged => '邮箱已更新';

  @override
  String get switchAccount => '切换账户';

  @override
  String get addAccount => '添加账户';

  @override
  String get addAccountSubtitle => '在此设备上创建或登录另一个保险库';

  @override
  String get removeAccountFromDevice => '从此设备移除';

  @override
  String get removeAccountFromDeviceSubtitle => '删除此本地保险库。已关联的服务器账户不会被删除。';

  @override
  String get removeAccountConfirm => '此保险库及其项目将从此设备移除。此操作无法撤销。';

  @override
  String get otherAccounts => '其他账户';

  @override
  String get useThisAccount => '使用此账户';

  @override
  String get currentAccount => '当前账户';

  @override
  String get chooseAccount => '选择账户';

  @override
  String get switchingAccount => '正在切换账户…';

  @override
  String get welcomeBackShort => '欢迎回来';

  @override
  String get tools => '工具';

  @override
  String get help => '帮助';

  @override
  String get autoLock => '自动锁定';

  @override
  String minutesLabel(num n) {
    return '$n 分钟';
  }

  @override
  String get autoLockOff => '关闭';

  @override
  String get blockScreenshot => '阻止屏幕截图';

  @override
  String get blockScreenshotSubtitle => '阻止对本应用截屏或录屏。';

  @override
  String get blockScreenshotLinuxNote => '在 Linux 上为尽力而为 — 合成器仍可能允许截屏。';

  @override
  String get biometricUnlock => '生物识别解锁';

  @override
  String get autofillService => '自动填充服务';

  @override
  String get autofillEnabled => 'OpenKey 是您的密码与通行密钥提供方';

  @override
  String get autofillDisabled => '在自动填充中启用 OpenKey 密码，并在凭证提供方中启用通行密钥';

  @override
  String get autofillDisabledBrowser => '安装 OpenKey 浏览器扩展并解锁保险箱';

  @override
  String get autofillSaveTitle => '保存密码';

  @override
  String get autofillSaveSubtitle => '将此登录信息保存到 OpenKey 保险库？';

  @override
  String get autofillSaved => '密码已保存';

  @override
  String get autofillRequireBiometric => '自动填充需生物识别';

  @override
  String get autofillRequireBiometricSubtitle => '在应用和网站中填写密码前要求指纹或面容。';

  @override
  String get autofillRequireBiometricReason => '通过 OpenKey 确认自动填充';

  @override
  String get autofillRequireBiometricEnabled => '已启用自动填充生物识别确认';

  @override
  String get autofillRequireBiometricDisabled => '已关闭自动填充生物识别确认';

  @override
  String get autofillInline => '内嵌到键盘';

  @override
  String get autofillInlineSubtitle => '在键盘候选栏中显示建议。';

  @override
  String get autofillPopup => '在输入框上方弹出';

  @override
  String get autofillPopupSubtitle => '在输入框上方显示下拉列表。';

  @override
  String get androidApp => 'Android 应用';

  @override
  String get androidAppHint => '应用包名，例如 com.example.app';

  @override
  String get biometricUnlockReason => '解锁您的 OpenKey 保险库';

  @override
  String get enableBiometricUnlockReason => '启用生物识别解锁';

  @override
  String get biometricHint => '验证您的身份';

  @override
  String get biometricNotRecognized => '未识别。请重试。';

  @override
  String get goToSettings => '前往设置';

  @override
  String get biometricGoToSettingsDescription => '设备尚未设置生物识别。请前往设置注册指纹或面容。';

  @override
  String get unlock => '解锁';

  @override
  String get unlocking => '正在解锁…';

  @override
  String get masterPassword => '主密码';

  @override
  String get unlockSubtitle => '输入主密码以解锁。';

  @override
  String welcomeBack(String email) {
    return '欢迎回来，$email';
  }

  @override
  String get fieldRequired => '必填';

  @override
  String get resetLocalVault => '重置本地保险库';

  @override
  String get resetLocalVaultTitle => '重置本地保险库？';

  @override
  String get resetLocalVaultSubtitle => '永久删除此设备上存储的所有保险库数据。';

  @override
  String get resetLocalVaultConfirm =>
      '此设备上的所有密码和保险库数据将被永久删除，以便创建新保险库。不会删除服务器数据。此操作无法撤销。';

  @override
  String get dangerZone => '危险操作';

  @override
  String get reset => '重置';

  @override
  String get createVault => '创建保险库';

  @override
  String get creatingVault => '正在创建…';

  @override
  String get setupSubtitle => '创建加密保险库。主密码不会离开此设备。';

  @override
  String get setupSignInSubtitle => '登录您的自托管 OpenKey 服务器，以在此设备上恢复保险库。';

  @override
  String get setupModeCreate => '创建';

  @override
  String get setupModeSignIn => '登录';

  @override
  String get setupModeRestore => '恢复';

  @override
  String get setupSignInAction => '登录';

  @override
  String get setupSigningIn => '正在登录…';

  @override
  String get setupRestoreSubtitle => '从加密的 OpenKey 备份（.okbak）恢复保险库。';

  @override
  String get setupRestoreAction => '恢复保险库';

  @override
  String get setupRestoreChooseFile => '选择备份文件';

  @override
  String get setupRestoreChooseFileSubtitle => '请选择加密的 .okbak 文件。';

  @override
  String setupRestoreBackupAccount(String email) {
    return '此备份属于 $email';
  }

  @override
  String get setupRestoreNeedFile => '请先选择备份文件';

  @override
  String get setupLinkSelfHostedTitle => '关联自托管服务器';

  @override
  String get setupLinkSelfHostedSubtitle => '可选。注册此保险库以便跨设备同步。';

  @override
  String get setupLinkServerHelper => '创建后，您的保险库将注册到此服务器。';

  @override
  String get setupSignInServerHelper => '已有您账户的 OpenKey 服务器 URL。';

  @override
  String get setupChooserTitle => '你想如何开始？';

  @override
  String get setupChooserSubtitle => '创建保险库、登录或恢复备份。';

  @override
  String get setupChooseCreateTitle => '创建保险库';

  @override
  String get setupChooseCreateSubtitle => '在此设备上新建加密保险库。';

  @override
  String get setupChooseSignInTitle => '登录';

  @override
  String get setupChooseSignInSubtitle => '从自托管 OpenKey 服务器恢复。';

  @override
  String get setupChooseRestoreTitle => '恢复备份';

  @override
  String get setupChooseRestoreSubtitle => '打开加密的 .okbak 文件。';

  @override
  String get invalidServerUrl => '请输入以 http:// 或 https:// 开头的有效 URL';

  @override
  String get confirmMasterPassword => '确认主密码';

  @override
  String get email => '电子邮件';

  @override
  String get invalidEmail => '请输入有效的电子邮件';

  @override
  String get invalidEmailFormat => '电子邮件地址无效';

  @override
  String get invalidUrlFormat => '无效的网址。请使用类似 https://example.com 的格式';

  @override
  String get invalidPhoneFormat => '无效的电话号码';

  @override
  String get invalidPinFormat => 'PIN 必须为 4–12 位数字';

  @override
  String get invalidNumberFormat => '只能输入数字';

  @override
  String get invalidCardFormat => '无效的卡号';

  @override
  String get invalidIpFormat => '无效的 IP 地址';

  @override
  String get invalidWalletFormat => '无效的钱包地址';

  @override
  String get invalidRecoveryCodesFormat => '无效的恢复代码';

  @override
  String get fixFieldErrors => '保存前请修正标出的字段';

  @override
  String get passwordTooShort => '至少 8 个字符';

  @override
  String get passwordsDoNotMatch => '密码不匹配';

  @override
  String get passwordTooShortStrong => '至少 12 个字符';

  @override
  String get passwordTooWeak => '请使用更长的字母、数字和符号组合';

  @override
  String get masterPasswordHelper => '建议使用 12 个以上混合类型字符';

  @override
  String get passwordHintOptional => '密码提示（可选）';

  @override
  String get passwordHintHelper => '仅作模糊提醒 — 切勿包含密码本身';

  @override
  String passwordHintReveal(String hint) {
    return '提示：$hint';
  }

  @override
  String get setupZeroKnowledgeBanner => '零知识加密：OpenKey 无法读取或重置您的保险库。';

  @override
  String get vaultNoticesTitle => '创建保险库之前';

  @override
  String get vaultNoticesSubtitle => '请确认以下要点以继续。';

  @override
  String get vaultNoticeNoRecovery => '如果忘记主密码，将无法恢复数据。';

  @override
  String get vaultNoticeLocalEncryption => '保险库在此设备上加密；主密码绝不会以明文离开设备。';

  @override
  String get vaultNoticeBackups => '定期加密备份是防止设备丢失的唯一办法。';

  @override
  String get vaultNoticeDeviceTransfer => '迁移到新设备需要恢复备份或可选的服务器同步。';

  @override
  String get acceptAllNotices => '全部接受';

  @override
  String get server => '自托管服务器';

  @override
  String get notConnected => '未连接';

  @override
  String get data => '数据与共享';

  @override
  String get dataSubtitle => '服务器、备份、导入/导出与共享';

  @override
  String get importExport => '导入与导出';

  @override
  String get importExportSubtitle => '将密码移入或移出保险库';

  @override
  String get importTab => '导入';

  @override
  String get exportTab => '导出';

  @override
  String get importPasswords => '导入密码';

  @override
  String get importPasswordsSubtitle => '条目使用此设备上的保险库密钥加密。';

  @override
  String get exportPasswords => '导出密码';

  @override
  String get exportPasswordsSubtitle => '在此设备上解密条目并保存未加密文件。';

  @override
  String get exportingPasswords => '正在导出…';

  @override
  String get exportBitwardenSubtitle => '未加密的 Bitwarden JSON';

  @override
  String get exportChromeSubtitle => '兼容 Chrome 的 CSV';

  @override
  String get exportLastPassSubtitle => '兼容 LastPass 的 CSV';

  @override
  String get exportOnePasswordSubtitle => '兼容 1Password 的 CSV';

  @override
  String get exportKeePassSubtitle => '加密的 KeePass / KeePassXC 数据库 (.kdbx)';

  @override
  String get exportOpenKeySubtitle => '未加密的 OpenKey JSON，含文件夹与完整条目数据';

  @override
  String get exportedItems => '保险库已导出';

  @override
  String exportedToPath(String path) {
    return '已导出到 $path';
  }

  @override
  String get changeMasterPassword => '更改主密码';

  @override
  String get changeMasterPasswordSubtitle => '重新包装保险库密钥。条目仍使用同一保险库密钥加密。';

  @override
  String get currentMasterPassword => '当前主密码';

  @override
  String get newMasterPassword => '新主密码';

  @override
  String get masterPasswordUnchanged => '请选择不同的密码';

  @override
  String get masterPasswordChanged => '主密码已更新';

  @override
  String get deleteServerAccount => '删除服务器账户';

  @override
  String get deleteServerAccountSubtitle => '从服务器删除您的密文。此设备保留本地保险库。';

  @override
  String get deleteServerAccountWarning => '此操作无法撤销。服务器上的同步数据将被永久删除。';

  @override
  String get serverAccountDeleted => '服务器账户已删除';

  @override
  String get browserExtension => '浏览器扩展';

  @override
  String get browserExtensionSubtitle => '将 Chrome / Edge / Firefox 连接到已解锁的保险箱';

  @override
  String get browserExtensionSheetSubtitle =>
      '从 chrome://extensions（开发者模式）粘贴未打包的 Chrome 扩展 ID。Firefox 会自动使用固定 ID。';

  @override
  String get chromeExtensionId => 'Chrome 扩展 ID';

  @override
  String get chromeExtensionIdHint => '显示在 chrome://extensions 扩展名称下方';

  @override
  String get connectBrowserExtension => '连接扩展';

  @override
  String get copyOfflineExtensionLink => '复制离线保险箱链接';

  @override
  String get extensionLinkClipboardWarning =>
      '这会将保险库解锁材料复制到剪贴板。其他应用可以读取，直到您清除剪贴板或一分钟后自动清除。';

  @override
  String get browserExtensionHostReady =>
      '原生主机已注册。保持 OpenKey 解锁，然后在扩展中点击“使用桌面应用”。';

  @override
  String get browserExtensionHostHint => '解锁保险箱，粘贴 Chrome 扩展 ID，然后连接。';

  @override
  String get browserExtensionHostFailed => '无法注册原生主机。请解锁保险箱后重试。';

  @override
  String get cliTitle => 'CLI';

  @override
  String get cliSubtitle => '安装 OpenKey CLI，然后在保险库解锁时运行连接命令。';

  @override
  String get cliTermuxTitle => 'Termux / CLI';

  @override
  String get cliTermuxSubtitle => '在 Termux 中安装 OpenKey CLI，然后在保险库解锁时运行连接命令。';

  @override
  String get cliTermuxInstall => '安装';

  @override
  String get cliTermuxConnect => '连接';

  @override
  String get cliTermuxUnavailable => '请解锁保险库以显示连接命令。';

  @override
  String get aboutPrivacy => 'OpenKey 对密码进行端到端加密。主密码和保险库密钥不会离开此设备。';

  @override
  String get localVault => '本地保险库';

  @override
  String get followDevice => '跟随设备外观';

  @override
  String get passwordGenerator => '密码生成器';

  @override
  String get generatedPassword => '生成的密码';

  @override
  String get passwordLength => '长度';

  @override
  String charactersLabel(int n) {
    return '$n 个字符';
  }

  @override
  String get includeUppercase => '大写字母';

  @override
  String get includeLowercase => '小写字母';

  @override
  String get includeDigits => '数字';

  @override
  String get includeSymbols => '符号';

  @override
  String get avoidAmbiguous => '避免易混淆字符';

  @override
  String get avoidAmbiguousSubtitle => '排除 I、l、1、O、0、o、|';

  @override
  String get regenerate => '重新生成';

  @override
  String get copyPassword => '复制';

  @override
  String get passwordCopied => '密码已复制';

  @override
  String get passwordGeneratorSubtitle => '生成强且唯一的密码';

  @override
  String get usePassword => '使用此密码';

  @override
  String get generateOptions => '选项';

  @override
  String get characterSets => '字符集';

  @override
  String get passwordStrengthWeak => '弱';

  @override
  String get passwordStrengthFair => '一般';

  @override
  String get passwordStrengthStrong => '强';

  @override
  String get generatorTitle => '生成器';

  @override
  String get generatorSubtitle => '生成密码、用户名和邮箱';

  @override
  String get generatorModePassword => '密码';

  @override
  String get generatorModeUsername => '用户名';

  @override
  String get generatorModeEmail => '邮箱';

  @override
  String get generatedUsername => '生成的用户名';

  @override
  String get generatedEmail => '生成的邮箱';

  @override
  String get usernameStyle => '样式';

  @override
  String get usernameStyleWords => '词语';

  @override
  String get usernameStyleRandom => '随机';

  @override
  String get usernameCapitalize => '首字母大写';

  @override
  String get usernameIncludeDigits => '添加数字';

  @override
  String get usernameSeparator => '分隔符';

  @override
  String get usernameSeparatorNone => '无';

  @override
  String get emailType => '邮箱类型';

  @override
  String get emailTypeRandom => '随机';

  @override
  String get emailTypePlus => '别名地址';

  @override
  String get emailDomain => '域名';

  @override
  String get emailDomainHint => 'yourdomain.com';

  @override
  String get emailPlusBase => '你的邮箱';

  @override
  String get emailPlusBaseHint => 'you@gmail.com';

  @override
  String get emailPlusHelp => '生成 you+tag@gmail.com，便于在收件箱中筛选注册邮件。';

  @override
  String get emailRandomHelp => '在你控制的域名上生成唯一地址，例如 catch-all。';

  @override
  String get passwordDetails => '密码详情';

  @override
  String get untitled => '未命名';

  @override
  String get credentials => '凭据';

  @override
  String get username => '用户名';

  @override
  String get password => '密码';

  @override
  String get website => '网站';

  @override
  String get notes => '备注';

  @override
  String get authenticator => '验证器';

  @override
  String get passkey => '通行密钥';

  @override
  String get attachments => '附件';

  @override
  String get downloadAttachment => '下载';

  @override
  String get previewAttachment => '预览';

  @override
  String get openAttachment => '打开';

  @override
  String get playVideo => '播放视频';

  @override
  String get pausePlayback => '暂停';

  @override
  String get openingAttachment => '正在打开附件…';

  @override
  String attachmentSaved(String name) {
    return '已保存 $name';
  }

  @override
  String get couldNotOpenAttachment => '无法打开此附件。';

  @override
  String get attachmentNotPreviewable => '此文件类型无法预览。你可以改为下载。';

  @override
  String get copyUsername => '复制用户名';

  @override
  String get showPassword => '显示密码';

  @override
  String get hidePassword => '隐藏密码';

  @override
  String get tapToCopy => '点按即可复制';

  @override
  String get edit => '编辑';

  @override
  String get delete => '删除';

  @override
  String get cancel => '取消';

  @override
  String get deleteEntry => '删除条目？';

  @override
  String get deleteEntryConfirm => '这将从保险库中永久删除该密码。';

  @override
  String get entryNotFound => '未找到条目';

  @override
  String get entryNotFoundMessage => '此密码可能已被删除。';

  @override
  String get goBack => '返回';

  @override
  String get synced => '已同步';

  @override
  String get pendingSync => '待同步';

  @override
  String revisionLabel(int n) {
    return '修订 $n';
  }

  @override
  String valueCopied(String label) {
    return '已复制$label';
  }

  @override
  String get vault => '保险库';

  @override
  String get items => '项目';

  @override
  String get itemsHubSubtitle => '卡片、加密货币钱包和密钥。';

  @override
  String get itemsCardsSubtitle => '支付卡和账单详情';

  @override
  String get itemsCryptoSubtitle => '地址、密钥和助记词';

  @override
  String get itemsSecretsSubtitle => 'SSH 密钥、API 令牌和 .env 片段';

  @override
  String itemsCountLabel(int count) {
    return '已保存 $count 项';
  }

  @override
  String get wallets => '钱包';

  @override
  String get searchCards => '搜索卡片';

  @override
  String get noCardsYet => '暂无卡片';

  @override
  String get noCardsYetMessage => '添加卡片以安全存储。';

  @override
  String get addCard => '添加卡片';

  @override
  String get editCard => '编辑卡片';

  @override
  String get save => '保存';

  @override
  String get cardDetails => '卡片详情';

  @override
  String get cardName => '卡片名称';

  @override
  String get cardHolder => '持卡人';

  @override
  String get cardNumber => '卡号';

  @override
  String get cardExpiry => '有效期';

  @override
  String get cardCvc => 'CVC';

  @override
  String get copyNumber => '复制卡号';

  @override
  String get copyCvc => '复制 CVC';

  @override
  String get tapCardToFlip => '点按卡片翻转';

  @override
  String get deleteCard => '删除卡片？';

  @override
  String get deleteCardConfirm => '这将从钱包中永久删除该卡片。';

  @override
  String get cardNotFound => '未找到卡片';

  @override
  String get cardNotFoundMessage => '此卡片可能已被删除。';

  @override
  String get bank => '银行';

  @override
  String get banks => '银行';

  @override
  String get otherBank => '其他';

  @override
  String get addBank => '添加银行';

  @override
  String get newBank => '新银行';

  @override
  String get bankName => '银行名称';

  @override
  String get renameBank => '重命名银行';

  @override
  String get deleteBank => '删除银行？';

  @override
  String get deleteBankConfirm => '移除此银行分组？卡片可移至「其他」。';

  @override
  String get deleteBankAndClear => '删除并取消卡片分配';

  @override
  String get moveToBank => '移至银行';

  @override
  String get noBanksYet => '暂无银行';

  @override
  String get createBankHint => '创建银行以整理支付卡。';

  @override
  String get bankCreated => '已创建银行';

  @override
  String get cardMoved => '已移动卡片';

  @override
  String get emptyBank => '此银行暂无卡片';

  @override
  String get paymentCards => '卡片';

  @override
  String get cryptoWallets => '加密货币';

  @override
  String get searchCryptoWallets => '搜索加密钱包';

  @override
  String get noCryptoWalletsYet => '暂无加密钱包';

  @override
  String get noCryptoWalletsYetMessage => '添加钱包以安全存储密钥。';

  @override
  String get addCryptoWallet => '添加加密钱包';

  @override
  String get editCryptoWallet => '编辑加密钱包';

  @override
  String get cryptoNetwork => '网络';

  @override
  String get cryptoWalletName => '钱包名称';

  @override
  String get walletAddress => '地址';

  @override
  String get privateKey => '私钥';

  @override
  String get seedPhrase => '助记词';

  @override
  String get cryptoDetails => '钱包详情';

  @override
  String get copyAddress => '复制地址';

  @override
  String get deleteCryptoWallet => '删除加密钱包？';

  @override
  String get deleteCryptoWalletConfirm => '这将从保险库中永久删除该钱包及其密钥。';

  @override
  String get cryptoWalletNotFound => '未找到加密钱包';

  @override
  String get cryptoWalletNotFoundMessage => '此钱包可能已被删除。';

  @override
  String get folders => '文件夹';

  @override
  String get otherFolder => '其他';

  @override
  String get addFolder => '添加文件夹';

  @override
  String get newFolder => '新建文件夹';

  @override
  String get folderName => '文件夹名称';

  @override
  String get renameFolder => '重命名文件夹';

  @override
  String get deleteFolder => '删除文件夹？';

  @override
  String get deleteFolderConfirm => '移除此文件夹分组？钱包可移至“其他”。';

  @override
  String get deleteFolderAndClear => '删除并取消钱包归属';

  @override
  String get moveToFolder => '移至文件夹';

  @override
  String get noFoldersYet => '暂无文件夹';

  @override
  String get createFolderHint => '创建文件夹以整理加密钱包。';

  @override
  String get folderCreated => '已创建文件夹';

  @override
  String get cryptoWalletMoved => '已移动钱包';

  @override
  String get emptyFolder => '此文件夹暂无钱包';

  @override
  String get secrets => '开发者密钥';

  @override
  String get searchSecrets => '搜索密钥';

  @override
  String get noSecretsYet => '尚无密钥';

  @override
  String get noSecretsYetMessage => '安全存储 SSH 密钥、API 令牌和 .env 片段。';

  @override
  String get addSecret => '添加密钥';

  @override
  String get editSecret => '编辑密钥';

  @override
  String get secretKind => '类型';

  @override
  String get secretKindSsh => 'SSH 密钥';

  @override
  String get secretKindApiToken => 'API 令牌';

  @override
  String get secretKindEnv => '.env 片段';

  @override
  String get secretKindOther => '其他';

  @override
  String get secretName => '名称';

  @override
  String get secretUsername => '用户名';

  @override
  String get secretHost => '主机';

  @override
  String get secretEndpoint => '端点 / URL';

  @override
  String get publicKey => '公钥';

  @override
  String get apiToken => 'API 令牌';

  @override
  String get envContent => '.env 内容';

  @override
  String get secretValue => '密钥';

  @override
  String get passphrase => '密码短语';

  @override
  String get secretDetails => '密钥详情';

  @override
  String get copySecret => '复制密钥';

  @override
  String get deleteSecret => '删除密钥？';

  @override
  String get deleteSecretConfirm => '这将从保险库中永久删除该密钥。';

  @override
  String get secretNotFound => '未找到密钥';

  @override
  String get secretNotFoundMessage => '此密钥可能已被删除。';

  @override
  String get reverseOrderSecretsSubtitle => '按倒序显示密钥。';

  @override
  String get device => '设备';

  @override
  String get devices => '设备';

  @override
  String get otherDevice => '其他';

  @override
  String get addDevice => '添加设备';

  @override
  String get newDevice => '新设备';

  @override
  String get deviceName => '设备名称';

  @override
  String get renameDevice => '重命名设备';

  @override
  String get deleteDevice => '删除设备？';

  @override
  String get deleteDeviceConfirm => '移除此设备分组？密钥可移至“其他”。';

  @override
  String get deleteDeviceAndClear => '删除并取消分配密钥';

  @override
  String get moveToDevice => '移至设备';

  @override
  String get noDevicesYet => '尚无设备';

  @override
  String get createDeviceHint => '创建设备以整理每台机器上的密钥。';

  @override
  String get deviceCreated => '设备已创建';

  @override
  String get secretMoved => '密钥已移动';

  @override
  String get emptyDevice => '此设备上没有密钥';

  @override
  String get faq => '常见问题';

  @override
  String get faqSubtitle => '加密、解锁、同步等';

  @override
  String get faqEncryptionQ => '我的数据是否加密？';

  @override
  String get faqEncryptionA =>
      '是的。OpenKey 在本设备上对保险库进行端到端加密。主密码和保险库密钥绝不以明文离开设备。';

  @override
  String get faqForgotPasswordQ => '如果忘记主密码怎么办？';

  @override
  String get faqForgotPasswordA =>
      '没有主密码就无法恢复。由于零知识加密，OpenKey 无法重置它。请安全备份您的密码。';

  @override
  String get faqOfflineQ => 'OpenKey 可以离线使用吗？';

  @override
  String get faqOfflineA => '可以。保险库保存在本地，无需网络即可解锁。可选服务器仅用于同步和共享。';

  @override
  String get faqAutoLockQ => '自动锁定如何工作？';

  @override
  String get faqAutoLockA =>
      '离开应用但未关闭时，OpenKey 会计算离开时长。超过设置中选择的时间后，保险库会锁定，需用主密码或生物识别再次解锁。关闭应用会立即结束会话。';

  @override
  String get faqBiometricQ => '生物识别解锁安全吗？';

  @override
  String get faqBiometricA => '安全。生物识别用于解锁保存在设备安全硬件中的密钥。主密码不会被替换，您随时仍可用它解锁。';

  @override
  String get faqSyncQ => '什么是自托管同步？';

  @override
  String get faqSyncA =>
      '你可以运行自己的 OpenKey 服务器。设备发送加密的保险库数据以便远程保持同步。服务器只存储密文，看不到明文。主密码留在每台设备上。';

  @override
  String get faqBackupQ => '备份与恢复如何工作？';

  @override
  String get faqBackupA =>
      '在设置 → 备份与恢复中，你可以把完整保险库副本保存到本机。OpenKey 会将数据库、应用设置和附件打包成压缩文件，再用保险库密钥加密（.okbak）。没有主密码谁也无法读取该文件。恢复会解密该文件并用备份替换本地保险库 — 请把密码和 .okbak 文件放在安全的地方。';

  @override
  String get appName => 'OpenKey';

  @override
  String get copy => '复制';

  @override
  String get create => '创建';

  @override
  String get generate => '生成';

  @override
  String get name => '名称';

  @override
  String get title => '标题';

  @override
  String get lock => '锁定';

  @override
  String get all => '全部';

  @override
  String get entry => '条目';

  @override
  String get collection => '集合';

  @override
  String get searchPasswords => '搜索密码';

  @override
  String get noPasswordsYet => '暂无密码';

  @override
  String get noPasswordsYetMessage => '添加条目或创建集合。';

  @override
  String get newCollection => '新建集合';

  @override
  String get newEntry => '新建条目';

  @override
  String get editEntry => '编辑条目';

  @override
  String get chooseFields => '字段';

  @override
  String get chooseFieldsSubtitle => '开关字段，然后拖动以调整顺序';

  @override
  String get done => '完成';

  @override
  String get phone => '电话';

  @override
  String get pin => 'PIN';

  @override
  String get number => '数字';

  @override
  String get address => '地址';

  @override
  String get ipAddress => 'IP 地址';

  @override
  String get dateYmd => '日期';

  @override
  String get dateYm => '月 / 年';

  @override
  String get recoveryCodes => '恢复代码';

  @override
  String get customText => '文本';

  @override
  String get additionalFields => '其他字段';

  @override
  String get emptyCollection => '空集合';

  @override
  String get emptyCollectionMessage => '向此集合添加密码条目。';

  @override
  String get editCollection => '编辑集合';

  @override
  String get deleteCollection => '删除集合';

  @override
  String get deleteCollectionConfirm => '此集合中的条目将从文件夹中移除（不会删除）。继续？';

  @override
  String get chooseIcon => '选择图标';

  @override
  String get icons => '图标';

  @override
  String get brands => '品牌';

  @override
  String get suggestedIcon => '建议图标';

  @override
  String get fromDevice => '从设备选择';

  @override
  String get customIcon => '自定义图标';

  @override
  String get editIcon => '编辑图标';

  @override
  String get cropOrRotate => '裁剪/旋转';

  @override
  String get rotate => '旋转';

  @override
  String get flip => '翻转';

  @override
  String get ratio => '比例';

  @override
  String get filter => '滤镜';

  @override
  String get blur => '模糊';

  @override
  String get discardChanges => '放弃更改？';

  @override
  String get discardChangesMessage => '你的编辑将会丢失。';

  @override
  String get discard => '放弃';

  @override
  String get undo => '撤销';

  @override
  String get redo => '重做';

  @override
  String get more => '更多';

  @override
  String get back => '返回';

  @override
  String get preparingImage => '正在准备图片…';

  @override
  String get search => '搜索';

  @override
  String get noFolder => '无文件夹';

  @override
  String get folder => '文件夹';

  @override
  String entriesCount(int count) {
    return '$count 个条目';
  }

  @override
  String get moveTo => '移动到';

  @override
  String get moveHere => '移到此处';

  @override
  String get movingLabel => '正在移动';

  @override
  String movingItemsCount(int count) {
    return '$count 项';
  }

  @override
  String get tags => '标签';

  @override
  String get noTags => '暂无标签';

  @override
  String get noTagsMessage => '编辑密码条目时添加标签。';

  @override
  String get sortAndFilter => '排序与筛选';

  @override
  String get applyToFolders => '文件夹';

  @override
  String get applyToEntries => '密码';

  @override
  String get sortBy => '排序方式';

  @override
  String get options => '选项';

  @override
  String get sortByCreationTime => '按创建时间排序';

  @override
  String get sortByLastModified => '按最后修改排序';

  @override
  String get sortByName => '按名称排序';

  @override
  String get sortByCustomOrder => '自定义顺序';

  @override
  String get reverseOrder => '倒序';

  @override
  String get reverseOrderFoldersSubtitle => '以倒序显示文件夹。';

  @override
  String get reverseOrderEntriesSubtitle => '以倒序显示密码。';

  @override
  String get reverseOrderCardsSubtitle => '以倒序显示卡片。';

  @override
  String get reverseOrderCryptoSubtitle => '以倒序显示钱包。';

  @override
  String get addTagHint => '添加标签';

  @override
  String deleteSelectedConfirm(int count) {
    return '删除选中的 $count 项？';
  }

  @override
  String get totpSecretLabel => 'TOTP 密钥 / otpauth';

  @override
  String get scanTotpQr => '扫描二维码';

  @override
  String get scanTotpQrHint => '将相机对准身份验证器二维码';

  @override
  String get invalidTotpQr => '此二维码不是有效的 TOTP 身份验证器代码';

  @override
  String get cameraPermissionDenied => '扫描二维码需要相机权限';

  @override
  String get storePasskeyMetadata => '通行密钥';

  @override
  String get passkeyCreatedInBrowser =>
      '可通过解锁的 OpenKey 浏览器扩展，或在移动端启用 OpenKey 自动填充/凭证提供方后创建通行密钥。';

  @override
  String get rpId => 'RP ID';

  @override
  String get credentialId => '凭证 ID';

  @override
  String get addPasskeyItem => '尚无通行密钥';

  @override
  String bytesLabel(int n) {
    return '$n 字节';
  }

  @override
  String get addEncryptedAttachment => '添加加密附件';

  @override
  String get expiryHint => '月/年';

  @override
  String get autoLockSubtitle => '离开应用后锁定保险库。';

  @override
  String get serverUrl => '服务器 URL';

  @override
  String get serverUrlHint => 'https://openkey.example.com';

  @override
  String get serverSheetSubtitle => '注册或登录以仅同步加密的保险库密文。';

  @override
  String get register => '注册';

  @override
  String get registerSubtitle => '在此服务器上创建账户';

  @override
  String get login => '登录';

  @override
  String get loginSubtitle => '使用此保险库认证哈希登录';

  @override
  String get syncNow => '立即同步';

  @override
  String get syncing => '正在同步…';

  @override
  String get syncSubtitle => '推送和拉取加密更改';

  @override
  String get syncComplete => '同步完成';

  @override
  String get extensionLinkCopied => '已复制扩展链接数据';

  @override
  String get biometricUnlockEnabled => '已启用生物识别解锁';

  @override
  String get biometricUnlockDisabled => '已关闭生物识别解锁';

  @override
  String biometricsUpdateFailed(String error) {
    return '无法更新生物识别：$error';
  }

  @override
  String get bitwardenJson => 'Bitwarden JSON';

  @override
  String get bitwardenJsonSubtitle => '从 Bitwarden 导出 → 在此导入';

  @override
  String get openKeyJson => 'OpenKey JSON';

  @override
  String get openKeyJsonSubtitle => '从 OpenKey 导出的备份';

  @override
  String get chromeCsv => 'Chrome CSV';

  @override
  String get chromeCsvSubtitle => '从 Chrome 导出的密码';

  @override
  String get lastPassCsv => 'LastPass CSV';

  @override
  String get lastPassCsvSubtitle => '从 LastPass 导出的 CSV';

  @override
  String get keePassKdbx => 'KeePass (.kdbx)';

  @override
  String get keePassKdbxSubtitle => '加密的 KeePass / KeePassXC 数据库';

  @override
  String get keePassPasswordHint => '数据库密码';

  @override
  String get keePassKeyFile => '密钥文件（可选）';

  @override
  String get keePassUnlockFailed => '无法打开 KeePass 数据库。请检查密码和密钥文件。';

  @override
  String get onePasswordCsv => '1Password CSV';

  @override
  String get onePasswordCsvSubtitle => '从 1Password 导出的 CSV';

  @override
  String get importingPasswords => '正在导入…';

  @override
  String importingProgress(int done, int total) {
    return '正在导入 $done / $total…';
  }

  @override
  String importedItems(int n) {
    return '已导入 $n 项';
  }

  @override
  String get failureUnknown => '出了点问题。';

  @override
  String get failureNetwork => '网络错误。请检查连接。';

  @override
  String get failureUnauthorized => '未授权。请重新登录。';

  @override
  String get failureNotFound => '未找到。';

  @override
  String get failureServer => '服务器错误。';

  @override
  String get failureInvalidCredentials => '邮箱或主密码无效。';

  @override
  String get failureVaultLocked => '保险库已锁定。';

  @override
  String get failureVaultAlreadyExists => '此设备上已有保险库。';

  @override
  String get failureDecryptionFailed => '无法解密保险库数据。';

  @override
  String get failureSyncFailed => '同步失败。';

  @override
  String get failureCreateCollection => '创建集合失败。';

  @override
  String get failureUpdateCollection => '更新集合失败。';

  @override
  String get failureDeleteCollection => '删除集合失败。';

  @override
  String get failureGetCollections => '加载集合失败。';

  @override
  String get failureCreateEntry => '创建条目失败。';

  @override
  String get failureUpdateEntry => '更新条目失败。';

  @override
  String get failureDeleteEntry => '删除条目失败。';

  @override
  String get failureGetEntries => '加载条目失败。';

  @override
  String get failureNoVault => '未找到保险库。请先创建一个。';

  @override
  String get failureConnectServerFirst => '请先在设置中连接服务器。';

  @override
  String get failureAttachmentTooLarge => '附件超过 20 MB 限制。';

  @override
  String get failureAttachmentMissing => '缺少附件密文。';

  @override
  String get failureAccountEmailExists => '该邮箱在此设备上已有保险库。';

  @override
  String get root => '根目录';

  @override
  String get selectedItems => '已选择';

  @override
  String get authenticatorTotp => '验证器（TOTP）';

  @override
  String get openKeyPro => 'OpenKey Pro';

  @override
  String get proSubtitle => '解锁高级功能并支持 OpenKey 开发。';

  @override
  String get premiumFeatureTitle => '高级功能';

  @override
  String get premiumFeatureSubtitle => '订阅以解锁此高级功能。';

  @override
  String get premiumFeatureContent => '这是高级功能。订阅后即可使用。';

  @override
  String get premiumBadge => 'Pro';

  @override
  String get subscribe => '订阅';

  @override
  String get upgradeNow => '立即升级';

  @override
  String get oops => '出错了！';

  @override
  String get subscription => '订阅';

  @override
  String get subscriptionTitle => '订阅';

  @override
  String get subscriptionSubtitle => '选择适合您的方案。';

  @override
  String get manageYourSubscription => '管理您的订阅';

  @override
  String get manageSubscriptionAction => '管理订阅';

  @override
  String get subIsActiveTitle => '您的订阅已激活';

  @override
  String get subIsNotActiveTitle => '您的订阅未激活';

  @override
  String get thanksForSubscribing => '感谢订阅！';

  @override
  String get subIsCancelled => '您的订阅已取消，将不会续订。';

  @override
  String get subIsPaused => '您的订阅已暂停。';

  @override
  String get restorePurchase => '恢复购买';

  @override
  String get viewPlansPaywall => '查看订阅选项';

  @override
  String get openCustomerCenter => '在客户中心管理';

  @override
  String get subscriptionDesktopNote =>
      '应用内购买适用于 Android、iOS 和 macOS。在 Windows 和 Linux 上，请使用同一 OpenKey 账户登录，以便在手机或 Mac 订阅后解锁 Pro。';

  @override
  String get subscriptionRefreshStatus => '刷新订阅状态';

  @override
  String get subscriptionNoInternetMsg => '网络连接有问题。请检查网络后重试。';

  @override
  String get subscriptionRegionBlockedMsg => '您所在地区无法使用订阅服务。请连接 VPN 后重试。';

  @override
  String get monthly => '每月';

  @override
  String get yearly => '每年';

  @override
  String get lifetime => '终身';

  @override
  String get monthlySubtitle => '自动续订，随时取消';

  @override
  String get yearlySubtitle => '自动续订，最超值，随时取消';

  @override
  String get lifetimeSubtitle => '一次性购买，永久拥有';

  @override
  String monthlyPriceLabel(String price) {
    return '$price/月';
  }

  @override
  String yearlyPriceLabel(String price) {
    return '$price/年';
  }

  @override
  String lifetimePriceLabel(String price) {
    return '$price';
  }

  @override
  String monthlySubscribeLabel(String price) {
    return '以 $price / 月订阅';
  }

  @override
  String yearlySubscribeLabel(String price) {
    return '以 $price / 年订阅';
  }

  @override
  String lifetimeSubscribeLabel(String price) {
    return '以 $price 购买终身版';
  }

  @override
  String get bestValue => '最超值';

  @override
  String get skip => '跳过';

  @override
  String get getStarted => '开始使用';

  @override
  String get onboardingFaqTitle => '开始前须知';

  @override
  String get onboardingFaqSubtitle => '关于 OpenKey 最常见的问题。点按展开 — 然后创建您的保险库。';

  @override
  String get onboardingNext => '下一步';

  @override
  String get onboardingWelcomeTitle => '您的密钥。您的保险库。';

  @override
  String get onboardingWelcomeSubtitle =>
      'OpenKey 将密码、验证码和卡片保存在一个加密空间 — 专为日常使用而设计。';

  @override
  String get onboardingWelcomePhrase1 => '零知识设计';

  @override
  String get onboardingWelcomePhrase2 => '一键自动填充';

  @override
  String get onboardingWelcomePhrase3 => '随时自托管';

  @override
  String get onboardingSecurityTitle => '他人无法读取';

  @override
  String get onboardingSecuritySubtitle => '端到端加密意味着主密码永不离开此设备。我们只存储密文。';

  @override
  String get onboardingAutofillTitle => '填充一次。永久信任。';

  @override
  String get onboardingAutofillSubtitle =>
      '在应用和网站中登录而无需寻找密码。自动填充让 OpenKey 融入日常。';

  @override
  String get onboardingAllInOneTitle => '一个应用。完整保险库。';

  @override
  String get onboardingAllInOneSubtitle =>
      '密码、验证器代码、支付卡、加密货币钱包和开发者密钥 — 用一个可信保险库取代杂乱。';

  @override
  String get onboardingFeaturePasswords => '密码';

  @override
  String get onboardingFeatureCrypto => '加密货币';

  @override
  String get onboardingFeatureAutofill => '自动填充';

  @override
  String get onboardingFeatureSelfHost => '自托管。';

  @override
  String get onboardingFooterHint => '不到一分钟。可随时跳过。';

  @override
  String get onboardingLetsGo => '开始！';

  @override
  String onboardingStepOf(int current, int total) {
    return '第 $current 步，共 $total 步';
  }

  @override
  String get onboardingWelcomeHeadline => '欢迎使用\nOpenKey。';

  @override
  String get onboardingWelcomeLead => '我们来帮你完成设置';

  @override
  String get onboardingEcosystemTitle => '完整的\n保险库。';

  @override
  String get onboardingEcosystemSubtitle => '密码、验证码和卡片 — 加密保存，随时登录可用。';

  @override
  String get onboardingStyleTitle => '按你的\n方式呈现。';

  @override
  String get onboardingEnableAutofillTitle => '启用\n自动填充。';

  @override
  String get onboardingAutofillCardTitle => '密码自动填充';

  @override
  String get onboardingAutofillCardSubtitle => '从保险库填写应用和网站的登录信息。';

  @override
  String get onboardingAutofillGranted => '自动填充已就绪';

  @override
  String get onboardingFinishBadge => '设置完成';

  @override
  String get onboardingFinishTitle => '可以\n上锁了。';

  @override
  String get onboardingFinishSubtitle => '创建主密码并开始保存重要内容 — 保险库只差一步。';

  @override
  String get onboardingCreateVault => '创建保险库';

  @override
  String get errorLoadingData => '加载数据出错。请重试。';

  @override
  String get retryAgain => '重试';

  @override
  String get autoRenewLabel => '自动续订';

  @override
  String get cancelledLabel => '已取消';

  @override
  String get pausedLabel => '已暂停';

  @override
  String get supportAppDevelopmentTitle => '支持开发';

  @override
  String get supportAppDevelopmentSubtitle => '您的订阅帮助我们持续改进 OpenKey。';

  @override
  String get limitEntriesTitle => '已达条目上限';

  @override
  String get limitCollectionsTitle => '已达集合上限';

  @override
  String get limitWalletsTitle => '已达卡片上限';

  @override
  String get limitCryptoWalletsTitle => '已达加密货币钱包上限';

  @override
  String get limitSecretsTitle => '已达密钥上限';

  @override
  String limitReachedContent(int usage, int limit, String feature) {
    return '您已使用 $usage / $limit 个$feature。升级到 Pro 可无限使用。';
  }

  @override
  String limitSubtitle(int limit, String feature) {
    return '免费方案最多包含 $limit 个$feature。';
  }

  @override
  String get entries => '条目';

  @override
  String get collections => '集合';

  @override
  String get cards => '卡片';

  @override
  String get cryptoWalletsFeature => '加密货币钱包';

  @override
  String get secretsFeature => '密钥';

  @override
  String expiresOn(String date) {
    return '到期日：$date';
  }

  @override
  String get unlockUnlimitedEntriesTitle => '无限条目';

  @override
  String get unlockUnlimitedEntriesSubtitle => '按需存储任意数量的密码和登录信息。';

  @override
  String get unlockUnlimitedCollectionsTitle => '无限集合';

  @override
  String get unlockUnlimitedCollectionsSubtitle => '用任意数量的文件夹整理保险库。';

  @override
  String get unlockUnlimitedWalletsTitle => '无限卡片';

  @override
  String get unlockUnlimitedWalletsSubtitle => '按需保存任意数量的支付卡。';

  @override
  String get unlockUnlimitedCryptoWalletsTitle => '无限加密货币钱包';

  @override
  String get unlockUnlimitedCryptoWalletsSubtitle => '无限制存储地址、密钥和助记词。';

  @override
  String get unlockUnlimitedSecretsTitle => '无限开发者密钥';

  @override
  String get unlockUnlimitedSecretsSubtitle => '无限制存储 SSH 密钥、API 令牌和 .env 片段。';

  @override
  String get unlockSyncTitle => '服务器同步';

  @override
  String get unlockSyncSubtitle => '连接自托管服务器并跨设备同步。';

  @override
  String get unlockAttachmentsTitle => '附件';

  @override
  String get unlockAttachmentsSubtitle => '将加密文件附加到保险库条目。';

  @override
  String get unlockImportExportTitle => '导入与导出';

  @override
  String get unlockImportExportSubtitle => '将数据导入或导出 OpenKey。';

  @override
  String get unknownFailureMsg => '发生未知错误。';

  @override
  String get purchaseCancelledMsg => '购买已取消。';

  @override
  String get storeProblemMsg => '商店出现问题。';

  @override
  String get purchaseNotAllowedMsg => '此设备不允许购买。';

  @override
  String get purchaseInvalidMsg => '购买无效。';

  @override
  String get productNotAvailableForPurchaseMsg => '此产品不可购买。';

  @override
  String get productAlreadyPurchasedMsg => '此产品已购买。';

  @override
  String get receiptAlreadyInUseMsg => '此收据已在使用中。';

  @override
  String get invalidReceiptMsg => '收据无效。';

  @override
  String get missingReceiptFileMsg => '缺少收据文件。';

  @override
  String get networkErrorMsg => '发生网络错误。请检查连接。';

  @override
  String get invalidCredentialsMsg => '提供的凭据无效。';

  @override
  String get unexpectedBackendResponseMsg => '后端返回了意外响应。';

  @override
  String get receiptInUseByOtherSubscriberMsg => '收据正被其他订阅者使用。';

  @override
  String get invalidAppUserIdMsg => '应用用户 ID 无效。';

  @override
  String get operationAlreadyInProgressMsg => '操作已在进行中。';

  @override
  String get unknownBackendErrorMsg => '服务器发生未知错误。';

  @override
  String get invalidAppleSubscriptionKeyMsg => 'Apple 订阅密钥无效。';

  @override
  String get ineligibleMsg => '您不符合此购买条件。';

  @override
  String get insufficientPermissionsMsg => '您没有足够的权限。';

  @override
  String get paymentPendingMsg => '付款待处理。';

  @override
  String get invalidSubscriberAttributesMsg => '订阅者属性无效。';

  @override
  String get logOutWithAnonymousUserMsg => '无法注销匿名用户。';

  @override
  String get configurationErrorMsg => '存在配置错误。';

  @override
  String get unsupportedErrorMsg => '不支持此操作。';

  @override
  String get emptySubscriberAttributesMsg => '订阅者属性为空。';

  @override
  String get productDiscountMissingIdentifierMsg => '缺少产品折扣标识符。';

  @override
  String get unknownNonNativeErrorMsg => '发生未知的非原生错误。';

  @override
  String get productDiscountMissingSubscriptionGroupIdentifierMsg =>
      '缺少产品折扣订阅组标识符。';

  @override
  String get customerInfoErrorMsg => '无法获取客户信息。';

  @override
  String get systemInfoErrorMsg => '无法获取系统信息。';

  @override
  String get beginRefundRequestErrorMsg => '无法开始退款请求。';

  @override
  String get productRequestTimeoutMsg => '产品请求超时。';

  @override
  String get apiEndpointBlockedMsg => 'API 端点被阻止。';

  @override
  String get invalidPromotionalOfferMsg => '促销优惠无效。';

  @override
  String get offlineConnectionMsg => '无网络连接。请连接后重试。';

  @override
  String get featureNotAvailableInCustomEntitlementsComputationModeMsg =>
      '此功能在自定义权益计算模式下不可用。';

  @override
  String get signatureVerificationFailedMsg => '签名验证失败。';

  @override
  String get featureNotSupportedWithStoreKit1Msg => '此功能不支持 StoreKit 1。';

  @override
  String get invalidWebPurchaseTokenMsg => '网页购买令牌无效。';

  @override
  String get purchaseBelongsToOtherUserMsg => '此购买属于其他用户。';

  @override
  String get expiredWebPurchaseTokenMsg => '网页购买令牌已过期。';

  @override
  String get testStoreSimulatedPurchaseErrorMsg => '测试商店模拟购买错误。';

  @override
  String get aboutApp => '关于应用';

  @override
  String get aboutAppSubtitle => '了解更多关于 OpenKey 及其开发的信息。';

  @override
  String get developerName => 'OpenSelfHosting';

  @override
  String get developer => '开源自托管软件';

  @override
  String rateUsIn(String storeName) {
    return '在 $storeName 为我们评分';
  }

  @override
  String get doYouLikeTheAppRateUs => '喜欢这款应用？请为我们评分！';

  @override
  String get licenses => '许可证';

  @override
  String get openLicenses => '打开许可证';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get privacyPolicySubtitle => '阅读我们的隐私政策';

  @override
  String get termsOfService => '服务条款';

  @override
  String get termsOfServiceSubtitle => '阅读我们的服务条款';

  @override
  String get pricing => '价格';

  @override
  String get pricingSubtitle => '免费版与 OpenKey Pro 方案';

  @override
  String get copied => '已复制到剪贴板';

  @override
  String get contact => '联系';

  @override
  String get contactSubtitle => '如需支持或反馈，请与我们联系。';

  @override
  String get telegram => 'Telegram';

  @override
  String get ok => 'OK';

  @override
  String get localBackupRestoreTitle => '备份与恢复';

  @override
  String get localBackupRestoreSubtitle =>
      '创建加密的完整保险库备份（.okbak），或从备份恢复。包含数据库、设置和附件。';

  @override
  String get exportBackup => '导出备份';

  @override
  String get exportBackupSubtitleEmpty => '创建加密的本地备份并选择保存位置。';

  @override
  String exportBackupSubtitleLatest(String path) {
    return '最近一次导出：$path';
  }

  @override
  String get importBackup => '恢复备份';

  @override
  String get importBackupSubtitle => '用加密的 OpenKey 备份（.okbak）替换此保险库。';

  @override
  String get confirmRestore => '确认恢复';

  @override
  String get confirmRestoreMessage => '恢复会用备份替换本地数据库、设置和附件。请输入该备份的主密码以解密。';

  @override
  String get creatingBackup => '正在创建备份…';

  @override
  String get creatingBackupBody => '正在压缩并加密整个保险库。';

  @override
  String get restoringBackupProgress => '正在恢复备份…';

  @override
  String get restoringBackupBody => '正在解密并恢复你的保险库。';

  @override
  String get restoringBackupVerifying => '正在验证主密码…';

  @override
  String get restoringBackupDecrypting => '正在解密备份数据…';

  @override
  String get restoringBackupWriting => '正在写入恢复的保险库…';

  @override
  String get restoringBackupUnlocking => '正在打开恢复的保险库…';

  @override
  String get backupComplete => '备份完成';

  @override
  String get backupCompleteLocalBody => '加密备份已成功保存。';

  @override
  String get backupCompleteLocalDetail => '请将此文件放在安全的地方。恢复时需要主密码。';

  @override
  String get backupError => '备份错误';

  @override
  String get restoreCompleted => '恢复完成';

  @override
  String get restoreCompletedBody => '已从加密备份恢复你的保险库。';
}
