// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get settings => 'الإعدادات';

  @override
  String get appearance => 'المظهر';

  @override
  String get appearanceSubtitle => 'السمة والألوان والخطوط واللغة';

  @override
  String get themeMode => 'وضع السمة';

  @override
  String get system => 'النظام';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get language => 'اللغة';

  @override
  String get fonts => 'الخطوط';

  @override
  String get displayFont => 'خط العرض';

  @override
  String get defaultFont => 'افتراضي';

  @override
  String get arabicFont => 'عربي';

  @override
  String get developerFont => 'مطور';

  @override
  String get technicalFont => 'تقني';

  @override
  String get standardFont => 'قياسي';

  @override
  String get defaultFontDes => 'الخط الافتراضي للتطبيق.';

  @override
  String get arabicFontDes => 'خط مُحسَّن للكتابة العربية.';

  @override
  String get developerFontDes => 'خط مصمم للمطورين.';

  @override
  String get technicalFontDes => 'خط مناسب للمحتوى التقني.';

  @override
  String get standardFontDes => 'خط قياسي للاستخدام العام.';

  @override
  String get googleSansFlexFont => 'Google Sans Flex';

  @override
  String get googleSansFlexFontDes =>
      'خط العلامة التعبيري من Google لـ Material 3 Expressive.';

  @override
  String get robotoFlexFont => 'Roboto Flex';

  @override
  String get robotoFlexFontDes =>
      'خط Material Design المتغير مع الوزن والعرض والحجم البصري.';

  @override
  String get figtreeFont => 'Figtree';

  @override
  String get figtreeFontDes =>
      'خط هندسي ناعم يُستخدم غالباً مع سمات Material You.';

  @override
  String get nunitoFont => 'Nunito';

  @override
  String get nunitoFontDes =>
      'A rounded geometric sans with a friendly, modern tone.';

  @override
  String get dynamicColors => 'ألوان ديناميكية';

  @override
  String get dynamicColorsSubtitle => 'إنشاء السمة من لون أساسي مختار';

  @override
  String get colorScheme => 'نظام الألوان';

  @override
  String get colorSchemeSubtitle => 'اختر لوناً أساسياً ونمط لوحة';

  @override
  String get highContrast => 'تباين عالٍ';

  @override
  String get highContrastSubtitle => 'زيادة التباين لتحسين القراءة';

  @override
  String get security => 'الأمان';

  @override
  String get securitySubtitle =>
      'القفل التلقائي والقياسات الحيوية والتعبئة التلقائية وكلمة المرور الرئيسية';

  @override
  String get account => 'الحساب';

  @override
  String get accountPageTitle => 'الحساب';

  @override
  String get accountPhoto => 'صورة الحساب';

  @override
  String get changeAccountPhoto => 'تغيير الصورة';

  @override
  String get removeAccountPhoto => 'إزالة الصورة';

  @override
  String get changeEmail => 'تغيير البريد';

  @override
  String get changeEmailSubtitle =>
      'يعيد تغليف مفتاح الخزنة. ستفتح بالقفل بالبريد الجديد.';

  @override
  String get newEmail => 'البريد الجديد';

  @override
  String get emailChanged => 'تم تحديث البريد';

  @override
  String get switchAccount => 'تبديل الحساب';

  @override
  String get addAccount => 'إضافة حساب';

  @override
  String get addAccountSubtitle => 'أنشئ أو سجّل خزنة أخرى على هذا الجهاز';

  @override
  String get removeAccountFromDevice => 'إزالة من هذا الجهاز';

  @override
  String get removeAccountFromDeviceSubtitle =>
      'يحذف هذه الخزنة المحلية. حساب الخادم المرتبط لا يُحذف.';

  @override
  String get removeAccountConfirm =>
      'ستُحذف هذه الخزنة وعناصرها من هذا الجهاز. لا يمكن التراجع.';

  @override
  String get otherAccounts => 'حسابات أخرى';

  @override
  String get useThisAccount => 'استخدام هذا الحساب';

  @override
  String get currentAccount => 'الحساب الحالي';

  @override
  String get chooseAccount => 'اختيار حساب';

  @override
  String get switchingAccount => 'جارٍ تبديل الحساب…';

  @override
  String get welcomeBackShort => 'مرحباً بعودتك';

  @override
  String get tools => 'الأدوات';

  @override
  String get help => 'المساعدة';

  @override
  String get autoLock => 'القفل التلقائي';

  @override
  String minutesLabel(num n) {
    return '$n دقيقة';
  }

  @override
  String get autoLockOff => 'إيقاف';

  @override
  String get blockScreenshot => 'حظر لقطات الشاشة';

  @override
  String get blockScreenshotSubtitle =>
      'منع التقاط لقطات الشاشة وتسجيل الشاشة للتطبيق.';

  @override
  String get blockScreenshotLinuxNote =>
      'على Linux بأفضل جهد — قد يسمح مدير النوافذ بالتقاط الشاشة.';

  @override
  String get biometricUnlock => 'فتح بالبصمة';

  @override
  String get autofillService => 'خدمة الملء التلقائي';

  @override
  String get autofillEnabled =>
      'OpenKey هو مزوّد كلمات المرور ومفاتيح المرور لديك';

  @override
  String get autofillDisabled =>
      'فعّل OpenKey لكلمات المرور (الملء التلقائي) ومفاتيح المرور (مزوّد الاعتمادات)';

  @override
  String get autofillDisabledBrowser =>
      'ثبّت إضافة OpenKey للمتصفح وافتح الخزنة';

  @override
  String get autofillSaveTitle => 'حفظ كلمة المرور';

  @override
  String get autofillSaveSubtitle => 'حفظ بيانات الدخول هذه في خزنة OpenKey؟';

  @override
  String get autofillSaved => 'تم حفظ كلمة المرور';

  @override
  String get autofillRequireBiometric => 'طلب البصمة للملء التلقائي';

  @override
  String get autofillRequireBiometricSubtitle =>
      'اطلب البصمة أو الوجه قبل ملء كلمات المرور في التطبيقات والمواقع.';

  @override
  String get autofillRequireBiometricReason =>
      'أكّد الملء التلقائي عبر OpenKey';

  @override
  String get autofillRequireBiometricEnabled =>
      'تم تفعيل تأكيد الملء التلقائي بالبصمة';

  @override
  String get autofillRequireBiometricDisabled =>
      'تم إيقاف تأكيد الملء التلقائي بالبصمة';

  @override
  String get autofillInline => 'مضمّن في لوحة المفاتيح';

  @override
  String get autofillInlineSubtitle =>
      'عرض الاقتراحات في شريط لوحة المفاتيح. يوقف القائمة المنبثقة فوق الحقل.';

  @override
  String get autofillPopup => 'منبثق فوق الحقل';

  @override
  String get autofillPopupSubtitle =>
      'عرض قائمة منسدلة فوق حقل الإدخال. يوقف اقتراحات لوحة المفاتيح.';

  @override
  String get androidApp => 'تطبيق أندرويد';

  @override
  String get androidAppHint => 'اسم الحزمة، مثل com.example.app';

  @override
  String get biometricUnlockReason => 'افتح خزنة OpenKey';

  @override
  String get enableBiometricUnlockReason => 'تفعيل الفتح بالبصمة';

  @override
  String get biometricHint => 'تحقّق من هويتك';

  @override
  String get biometricNotRecognized => 'لم يُتعرّف. حاول مرة أخرى.';

  @override
  String get goToSettings => 'الانتقال إلى الإعدادات';

  @override
  String get biometricGoToSettingsDescription =>
      'لم يُعدّ المصادقة بالبصمة على جهازك. انتقل إلى الإعدادات لتسجيل بصمة أو وجه.';

  @override
  String get unlock => 'فتح';

  @override
  String get unlocking => 'جاري الفتح…';

  @override
  String get masterPassword => 'كلمة المرور الرئيسية';

  @override
  String get unlockSubtitle => 'أدخل كلمة المرور الرئيسية لفتح الخزنة.';

  @override
  String welcomeBack(String email) {
    return 'مرحباً بعودتك، $email';
  }

  @override
  String get fieldRequired => 'مطلوب';

  @override
  String get resetLocalVault => 'إعادة تعيين الخزنة المحلية';

  @override
  String get resetLocalVaultTitle => 'إعادة تعيين الخزنة المحلية؟';

  @override
  String get resetLocalVaultSubtitle =>
      'يحذف نهائياً جميع بيانات الخزنة المخزّنة على هذا الجهاز.';

  @override
  String get resetLocalVaultConfirm =>
      'سيتم حذف جميع كلمات المرور وبيانات الخزنة على هذا الجهاز نهائياً لإنشاء خزنة جديدة. لن تُحذف بيانات الخادم. لا يمكن التراجع.';

  @override
  String get dangerZone => 'منطقة الخطر';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get createVault => 'إنشاء خزنة';

  @override
  String get creatingVault => 'جاري الإنشاء…';

  @override
  String get setupSubtitle =>
      'أنشئ خزنتك المشفّرة. كلمة المرور الرئيسية لا تغادر هذا الجهاز أبداً.';

  @override
  String get setupSignInSubtitle =>
      'سجّل الدخول إلى خادم OpenKey المستضاف ذاتياً لاستعادة هذه الخزنة على الجهاز.';

  @override
  String get setupModeCreate => 'إنشاء';

  @override
  String get setupModeSignIn => 'تسجيل الدخول';

  @override
  String get setupModeRestore => 'استعادة';

  @override
  String get setupSignInAction => 'تسجيل الدخول';

  @override
  String get setupSigningIn => 'جاري تسجيل الدخول…';

  @override
  String get setupRestoreSubtitle =>
      'استعد خزنتك من نسخة OpenKey مشفّرة (.okbak).';

  @override
  String get setupRestoreAction => 'استعادة الخزنة';

  @override
  String get setupRestoreChooseFile => 'اختيار ملف النسخة';

  @override
  String get setupRestoreChooseFileSubtitle => 'اختر ملف .okbak مشفّر.';

  @override
  String setupRestoreBackupAccount(String email) {
    return 'هذه النسخة لحساب $email';
  }

  @override
  String get setupRestoreNeedFile => 'اختر ملف النسخة أولاً';

  @override
  String get setupLinkSelfHostedTitle => 'ربط خادم مستضاف ذاتياً';

  @override
  String get setupLinkSelfHostedSubtitle =>
      'اختياري. سجّل هذه الخزنة للمزامنة بين الأجهزة.';

  @override
  String get setupLinkServerHelper =>
      'سيتم تسجيل خزنتك على هذا الخادم بعد الإنشاء.';

  @override
  String get setupSignInServerHelper =>
      'رابط خادم OpenKey الذي يحتوي حسابك مسبقاً.';

  @override
  String get setupChooserTitle => 'كيف تريد أن تبدأ؟';

  @override
  String get setupChooserSubtitle =>
      'أنشئ خزنة أو سجّل الدخول أو استعد نسخة احتياطية.';

  @override
  String get setupChooseCreateTitle => 'إنشاء خزنة';

  @override
  String get setupChooseCreateSubtitle => 'خزنة مشفّرة جديدة على هذا الجهاز.';

  @override
  String get setupChooseSignInTitle => 'تسجيل الدخول';

  @override
  String get setupChooseSignInSubtitle =>
      'استعد من خادم OpenKey المستضاف ذاتياً.';

  @override
  String get setupChooseRestoreTitle => 'استعادة نسخة احتياطية';

  @override
  String get setupChooseRestoreSubtitle => 'افتح ملف .okbak مشفّر.';

  @override
  String get invalidServerUrl =>
      'أدخل رابطاً صالحاً يبدأ بـ http:// أو https://';

  @override
  String get confirmMasterPassword => 'تأكيد كلمة المرور الرئيسية';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get invalidEmail => 'أدخل بريداً إلكترونياً صالحاً';

  @override
  String get invalidEmailFormat => 'بريد إلكتروني غير صالح';

  @override
  String get invalidUrlFormat =>
      'رابط غير صالح. استخدم صيغة مثل https://example.com';

  @override
  String get invalidPhoneFormat => 'رقم هاتف غير صالح';

  @override
  String get invalidPinFormat => 'يجب أن يتكون رمز PIN من 4–12 رقماً';

  @override
  String get invalidNumberFormat => 'أدخل أرقاماً فقط';

  @override
  String get invalidCardFormat => 'رقم بطاقة غير صالح';

  @override
  String get invalidIpFormat => 'عنوان IP غير صالح';

  @override
  String get invalidWalletFormat => 'عنوان محفظة غير صالح';

  @override
  String get invalidRecoveryCodesFormat => 'رموز استرداد غير صالحة';

  @override
  String get fixFieldErrors => 'صحّح الحقول المميزة قبل الحفظ';

  @override
  String get passwordTooShort => '8 أحرف على الأقل';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get passwordTooShortStrong => '12 حرفاً على الأقل';

  @override
  String get passwordTooWeak => 'استخدم مزيجاً أطول من الأحرف والأرقام والرموز';

  @override
  String get masterPasswordHelper => 'يُفضّل 12 حرفاً فأكثر بأنواع مختلطة';

  @override
  String get passwordHintOptional => 'تلميح كلمة المرور (اختياري)';

  @override
  String get passwordHintHelper =>
      'تذكير غامض فقط — لا تُضمّن كلمة المرور نفسها أبداً';

  @override
  String passwordHintReveal(String hint) {
    return 'التلميح: $hint';
  }

  @override
  String get setupZeroKnowledgeBanner =>
      'تشفير صفري المعرفة: لا تستطيع OpenKey قراءة خزنتك أو إعادة تعيينها.';

  @override
  String get vaultNoticesTitle => 'قبل إنشاء خزنتك';

  @override
  String get vaultNoticesSubtitle => 'يرجى الإقرار بهذه النقاط للمتابعة.';

  @override
  String get vaultNoticeNoRecovery =>
      'إذا نسيت كلمة المرور الرئيسية، لا يمكن استعادة بياناتك.';

  @override
  String get vaultNoticeLocalEncryption =>
      'تُشفَّر خزنتك على هذا الجهاز؛ وكلمة المرور الرئيسية لا تغادره كنص واضح أبداً.';

  @override
  String get vaultNoticeBackups =>
      'النسخ الاحتياطية المشفّرة المنتظمة هي الوسيلة الوحيدة للحماية من فقدان الجهاز.';

  @override
  String get vaultNoticeDeviceTransfer =>
      'الانتقال إلى جهاز جديد يتطلب استعادة نسخة احتياطية أو مزامنة اختيارية مع الخادم.';

  @override
  String get acceptAllNotices => 'قبول الكل';

  @override
  String get server => 'خادم مستضاف ذاتياً';

  @override
  String get notConnected => 'غير متصل';

  @override
  String get data => 'البيانات والمشاركة';

  @override
  String get dataSubtitle =>
      'الخادم والنسخ الاحتياطي والاستيراد/التصدير والمشاركة';

  @override
  String get importExport => 'الاستيراد والتصدير';

  @override
  String get importExportSubtitle => 'انقل كلمات المرور إلى خزنتك أو منها';

  @override
  String get importTab => 'استيراد';

  @override
  String get exportTab => 'تصدير';

  @override
  String get importPasswords => 'استيراد كلمات المرور';

  @override
  String get importPasswordsSubtitle =>
      'تُشفَّر الإدخالات بمفتاح خزنتك على هذا الجهاز.';

  @override
  String get exportPasswords => 'تصدير كلمات المرور';

  @override
  String get exportPasswordsSubtitle =>
      'يفك تشفير الإدخالات على هذا الجهاز ويحفظ ملف تصدير.';

  @override
  String get exportingPasswords => 'جارٍ التصدير…';

  @override
  String get exportBitwardenSubtitle => 'JSON غير مشفّر من Bitwarden';

  @override
  String get exportChromeSubtitle => 'CSV متوافق مع Chrome';

  @override
  String get exportLastPassSubtitle => 'CSV متوافق مع LastPass';

  @override
  String get exportOnePasswordSubtitle => 'CSV متوافق مع 1Password';

  @override
  String get exportKeePassSubtitle =>
      'قاعدة بيانات KeePass / KeePassXC مشفّرة (.kdbx)';

  @override
  String get exportOpenKeySubtitle =>
      'JSON غير مشفّر بصيغة OpenKey مع المجلدات وبيانات الإدخالات كاملة';

  @override
  String get exportedItems => 'تم تصدير الخزنة';

  @override
  String exportedToPath(String path) {
    return 'تم التصدير إلى $path';
  }

  @override
  String get changeMasterPassword => 'تغيير كلمة المرور الرئيسية';

  @override
  String get changeMasterPasswordSubtitle =>
      'يعيد تغليف مفتاح الخزنة. تبقى الإدخالات مشفّرة بنفس مفتاح الخزنة.';

  @override
  String get currentMasterPassword => 'كلمة المرور الرئيسية الحالية';

  @override
  String get newMasterPassword => 'كلمة المرور الرئيسية الجديدة';

  @override
  String get masterPasswordUnchanged => 'اختر كلمة مرور مختلفة';

  @override
  String get masterPasswordChanged => 'تم تحديث كلمة المرور الرئيسية';

  @override
  String get deleteServerAccount => 'حذف الحساب من السيرفر';

  @override
  String get deleteServerAccountSubtitle =>
      'يزيل بياناتك المشفّرة من السيرفر. يبقى الخزنة المحلية على هذا الجهاز.';

  @override
  String get deleteServerAccountWarning =>
      'لا يمكن التراجع عن هذا. ستُحذف البيانات المتزامنة على السيرفر نهائياً.';

  @override
  String get serverAccountDeleted => 'تم حذف حساب السيرفر';

  @override
  String get browserExtension => 'إضافة المتصفح';

  @override
  String get browserExtensionSubtitle =>
      'اربط Chrome / Edge / Firefox بالخزنة المفتوحة';

  @override
  String get browserExtensionSheetSubtitle =>
      'الصق معرّف إضافة Chrome غير المعبأة من chrome://extensions (وضع المطوّر). Firefox يستخدم معرّفاً ثابتاً تلقائياً.';

  @override
  String get chromeExtensionId => 'معرّف إضافة Chrome';

  @override
  String get chromeExtensionIdHint =>
      'يظهر تحت اسم الإضافة في chrome://extensions';

  @override
  String get connectBrowserExtension => 'ربط الإضافة';

  @override
  String get copyOfflineExtensionLink => 'نسخ رابط الخزنة دون اتصال';

  @override
  String get extensionLinkClipboardWarning =>
      'ينسخ هذا مواد فك الخزنة إلى الحافظة. يمكن لأي تطبيق قراءتها حتى تمسح الحافظة أو تُمسح تلقائياً بعد دقيقة واحدة.';

  @override
  String get browserExtensionHostReady =>
      'تم تسجيل المضيف الأصلي. أبقِ OpenKey مفتوحاً، ثم اضغط «استخدم تطبيق سطح المكتب» في الإضافة.';

  @override
  String get browserExtensionHostHint =>
      'افتح الخزنة، الصق معرّف Chrome، ثم اربط.';

  @override
  String get browserExtensionHostFailed =>
      'تعذّر تسجيل المضيف الأصلي. افتح الخزنة وحاول مجدداً.';

  @override
  String get cliTitle => 'CLI';

  @override
  String get cliSubtitle =>
      'ثبّت أداة OpenKey، ثم نفّذ أمر الاتصال المناسب لهذا النظام والخزنة مفتوحة.';

  @override
  String get cliTermuxTitle => 'Termux / CLI';

  @override
  String get cliTermuxSubtitle =>
      'ثبّت أداة OpenKey في Termux، ثم نفّذ أمر الاتصال والخزنة مفتوحة.';

  @override
  String get cliTermuxInstall => 'التثبيت';

  @override
  String get cliTermuxConnect => 'الاتصال';

  @override
  String get cliTermuxUnavailable => 'افتح الخزنة لعرض أمر الاتصال.';

  @override
  String get aboutPrivacy =>
      'يشفّر OpenKey كلمات المرور من طرف إلى طرف. كلمة المرور الرئيسية ومفتاح الخزنة لا يغادران هذا الجهاز.';

  @override
  String get localVault => 'خزنة محلية';

  @override
  String get followDevice => 'اتباع مظهر الجهاز';

  @override
  String get passwordGenerator => 'مولّد كلمات المرور';

  @override
  String get generatedPassword => 'كلمة المرور المُنشأة';

  @override
  String get passwordLength => 'الطول';

  @override
  String charactersLabel(int n) {
    return '$n حرفاً';
  }

  @override
  String get includeUppercase => 'أحرف كبيرة';

  @override
  String get includeLowercase => 'أحرف صغيرة';

  @override
  String get includeDigits => 'أرقام';

  @override
  String get includeSymbols => 'رموز';

  @override
  String get avoidAmbiguous => 'تجنّب الأحرف الملتبسة';

  @override
  String get avoidAmbiguousSubtitle => 'استبعاد I و l و 1 و O و 0 و o و |';

  @override
  String get regenerate => 'إعادة الإنشاء';

  @override
  String get copyPassword => 'نسخ';

  @override
  String get passwordCopied => 'تم نسخ كلمة المرور';

  @override
  String get passwordGeneratorSubtitle => 'أنشئ كلمة مرور قوية وفريدة';

  @override
  String get usePassword => 'استخدام كلمة المرور';

  @override
  String get generateOptions => 'خيارات';

  @override
  String get characterSets => 'مجموعات الأحرف';

  @override
  String get passwordStrengthWeak => 'ضعيفة';

  @override
  String get passwordStrengthFair => 'متوسطة';

  @override
  String get passwordStrengthStrong => 'قوية';

  @override
  String get generatorTitle => 'المولّد';

  @override
  String get generatorSubtitle =>
      'أنشئ كلمات مرور وأسماء مستخدمين وعناوين بريد';

  @override
  String get generatorModePassword => 'كلمة المرور';

  @override
  String get generatorModeUsername => 'المستخدم';

  @override
  String get generatorModeEmail => 'البريد';

  @override
  String get generatedUsername => 'اسم المستخدم المُنشأ';

  @override
  String get generatedEmail => 'البريد المُنشأ';

  @override
  String get usernameStyle => 'النمط';

  @override
  String get usernameStyleWords => 'كلمات';

  @override
  String get usernameStyleRandom => 'عشوائي';

  @override
  String get usernameCapitalize => 'أحرف كبيرة';

  @override
  String get usernameIncludeDigits => 'إضافة أرقام';

  @override
  String get usernameSeparator => 'الفاصل';

  @override
  String get usernameSeparatorNone => 'بدون';

  @override
  String get emailType => 'نوع البريد';

  @override
  String get emailTypeRandom => 'عشوائي';

  @override
  String get emailTypePlus => 'عنوان بلس';

  @override
  String get emailDomain => 'النطاق';

  @override
  String get emailDomainHint => 'yourdomain.com';

  @override
  String get emailPlusBase => 'بريدك';

  @override
  String get emailPlusBaseHint => 'you@gmail.com';

  @override
  String get emailPlusHelp =>
      'ينشئ you+tag@gmail.com لتصفية حسابات المواقع في صندوقك.';

  @override
  String get emailRandomHelp =>
      'ينشئ عنواناً فريداً على نطاق تتحكم به، مثل نطاق catch-all.';

  @override
  String get passwordDetails => 'تفاصيل كلمة المرور';

  @override
  String get untitled => 'بدون عنوان';

  @override
  String get credentials => 'بيانات الدخول';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get password => 'كلمة المرور';

  @override
  String get website => 'الموقع';

  @override
  String get notes => 'ملاحظات';

  @override
  String get authenticator => 'المصادقة الثنائية';

  @override
  String get passkey => 'مفتاح المرور';

  @override
  String get attachments => 'المرفقات';

  @override
  String get downloadAttachment => 'تنزيل';

  @override
  String get previewAttachment => 'معاينة';

  @override
  String get openAttachment => 'فتح';

  @override
  String get playVideo => 'تشغيل الفيديو';

  @override
  String get pausePlayback => 'إيقاف مؤقت';

  @override
  String get openingAttachment => 'جارٍ فتح المرفق…';

  @override
  String attachmentSaved(String name) {
    return 'تم حفظ $name';
  }

  @override
  String get couldNotOpenAttachment => 'تعذّر فتح هذا المرفق.';

  @override
  String get attachmentNotPreviewable =>
      'لا يمكن معاينة هذا النوع من الملفات. يمكنك تنزيله بدلاً من ذلك.';

  @override
  String get copyUsername => 'نسخ اسم المستخدم';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get tapToCopy => 'اضغط للنسخ';

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get cancel => 'إلغاء';

  @override
  String get deleteEntry => 'حذف الإدخال؟';

  @override
  String get deleteEntryConfirm =>
      'سيؤدي هذا إلى إزالة كلمة المرور نهائياً من خزنتك.';

  @override
  String get entryNotFound => 'الإدخال غير موجود';

  @override
  String get entryNotFoundMessage => 'ربما تم حذف كلمة المرور هذه.';

  @override
  String get goBack => 'رجوع';

  @override
  String get synced => 'متزامن';

  @override
  String get pendingSync => 'بانتظار المزامنة';

  @override
  String revisionLabel(int n) {
    return 'المراجعة $n';
  }

  @override
  String valueCopied(String label) {
    return 'تم نسخ $label';
  }

  @override
  String get vault => 'الخزنة';

  @override
  String get items => 'العناصر';

  @override
  String get itemsHubSubtitle => 'البطاقات، محافظ الكريبتو، والأسرار.';

  @override
  String get itemsCardsSubtitle => 'بطاقات الدفع وتفاصيل الفوترة';

  @override
  String get itemsCryptoSubtitle => 'العناوين والمفاتيح وعبارات الاسترداد';

  @override
  String get itemsSecretsSubtitle => 'مفاتيح SSH وتوكنات API ومقاطع .env';

  @override
  String itemsCountLabel(int count) {
    return '$count محفوظ';
  }

  @override
  String get wallets => 'المحافظ';

  @override
  String get searchCards => 'البحث في البطاقات';

  @override
  String get noCardsYet => 'لا توجد بطاقات بعد';

  @override
  String get noCardsYetMessage => 'أضف بطاقة لحفظها بأمان.';

  @override
  String get addCard => 'إضافة بطاقة';

  @override
  String get editCard => 'تعديل البطاقة';

  @override
  String get save => 'حفظ';

  @override
  String get cardDetails => 'تفاصيل البطاقة';

  @override
  String get cardName => 'اسم البطاقة';

  @override
  String get cardHolder => 'حامل البطاقة';

  @override
  String get cardNumber => 'رقم البطاقة';

  @override
  String get cardExpiry => 'الانتهاء';

  @override
  String get cardCvc => 'CVC';

  @override
  String get copyNumber => 'نسخ الرقم';

  @override
  String get copyCvc => 'نسخ CVC';

  @override
  String get tapCardToFlip => 'اضغط على البطاقة لقلبها';

  @override
  String get deleteCard => 'حذف البطاقة؟';

  @override
  String get deleteCardConfirm =>
      'سيؤدي هذا إلى إزالة البطاقة نهائياً من محفظتك.';

  @override
  String get cardNotFound => 'البطاقة غير موجودة';

  @override
  String get cardNotFoundMessage => 'ربما تم حذف هذه البطاقة.';

  @override
  String get bank => 'البنك';

  @override
  String get banks => 'البنوك';

  @override
  String get otherBank => 'أخرى';

  @override
  String get addBank => 'إضافة بنك';

  @override
  String get newBank => 'بنك جديد';

  @override
  String get bankName => 'اسم البنك';

  @override
  String get renameBank => 'إعادة تسمية البنك';

  @override
  String get deleteBank => 'حذف البنك؟';

  @override
  String get deleteBankConfirm =>
      'إزالة مجموعة هذا البنك؟ يمكن نقل البطاقات إلى «أخرى».';

  @override
  String get deleteBankAndClear => 'حذف وإلغاء تعيين البطاقات';

  @override
  String get moveToBank => 'نقل إلى بنك';

  @override
  String get noBanksYet => 'لا توجد بنوك بعد';

  @override
  String get createBankHint => 'أنشئ بنكاً لتنظيم بطاقاتك.';

  @override
  String get bankCreated => 'تم إنشاء البنك';

  @override
  String get cardMoved => 'تم نقل البطاقة';

  @override
  String get emptyBank => 'لا بطاقات في هذا البنك';

  @override
  String get paymentCards => 'البطاقات';

  @override
  String get cryptoWallets => 'العملات';

  @override
  String get searchCryptoWallets => 'البحث في محافظ العملات';

  @override
  String get noCryptoWalletsYet => 'لا توجد محافظ عملات بعد';

  @override
  String get noCryptoWalletsYetMessage => 'أضف محفظة لحفظ المفاتيح بأمان.';

  @override
  String get addCryptoWallet => 'إضافة محفظة عملات';

  @override
  String get editCryptoWallet => 'تعديل محفظة العملات';

  @override
  String get cryptoNetwork => 'الشبكة';

  @override
  String get cryptoWalletName => 'اسم المحفظة';

  @override
  String get walletAddress => 'العنوان';

  @override
  String get privateKey => 'المفتاح الخاص';

  @override
  String get seedPhrase => 'عبارة الاسترداد';

  @override
  String get cryptoDetails => 'تفاصيل المحفظة';

  @override
  String get copyAddress => 'نسخ العنوان';

  @override
  String get deleteCryptoWallet => 'حذف محفظة العملات؟';

  @override
  String get deleteCryptoWalletConfirm =>
      'سيؤدي هذا إلى إزالة المحفظة وأسرارها نهائياً من خزنتك.';

  @override
  String get cryptoWalletNotFound => 'محفظة العملات غير موجودة';

  @override
  String get cryptoWalletNotFoundMessage => 'ربما تم حذف هذه المحفظة.';

  @override
  String get folders => 'المجلدات';

  @override
  String get otherFolder => 'أخرى';

  @override
  String get addFolder => 'إضافة مجلد';

  @override
  String get newFolder => 'مجلد جديد';

  @override
  String get folderName => 'اسم المجلد';

  @override
  String get renameFolder => 'إعادة تسمية المجلد';

  @override
  String get deleteFolder => 'حذف المجلد؟';

  @override
  String get deleteFolderConfirm =>
      'إزالة مجموعة المجلد هذه؟ يمكن نقل المحافظ إلى أخرى.';

  @override
  String get deleteFolderAndClear => 'حذف وإلغاء تعيين المحافظ';

  @override
  String get moveToFolder => 'نقل إلى مجلد';

  @override
  String get noFoldersYet => 'لا توجد مجلدات بعد';

  @override
  String get createFolderHint => 'أنشئ مجلداً لتنظيم محافظ العملات.';

  @override
  String get folderCreated => 'تم إنشاء المجلد';

  @override
  String get cryptoWalletMoved => 'تم نقل المحفظة';

  @override
  String get emptyFolder => 'لا محافظ في هذا المجلد';

  @override
  String get secrets => 'الأسرار';

  @override
  String get searchSecrets => 'البحث في الأسرار';

  @override
  String get noSecretsYet => 'لا توجد أسرار بعد';

  @override
  String get noSecretsYetMessage =>
      'احفظ مفاتيح SSH وتوكنات API ومقاطع .env بأمان.';

  @override
  String get addSecret => 'إضافة سر';

  @override
  String get editSecret => 'تعديل السر';

  @override
  String get secretKind => 'النوع';

  @override
  String get secretKindSsh => 'مفتاح SSH';

  @override
  String get secretKindApiToken => 'توكن API';

  @override
  String get secretKindEnv => 'مقطع .env';

  @override
  String get secretKindOther => 'أخرى';

  @override
  String get secretName => 'الاسم';

  @override
  String get secretUsername => 'اسم المستخدم';

  @override
  String get secretHost => 'المضيف';

  @override
  String get secretEndpoint => 'نقطة النهاية / الرابط';

  @override
  String get publicKey => 'المفتاح العام';

  @override
  String get apiToken => 'توكن API';

  @override
  String get envContent => 'محتوى .env';

  @override
  String get secretValue => 'السر';

  @override
  String get passphrase => 'عبارة المرور';

  @override
  String get secretDetails => 'تفاصيل السر';

  @override
  String get copySecret => 'نسخ السر';

  @override
  String get deleteSecret => 'حذف السر؟';

  @override
  String get deleteSecretConfirm => 'سيُزال هذا السر نهائيًا من خزنتك.';

  @override
  String get secretNotFound => 'السر غير موجود';

  @override
  String get secretNotFoundMessage => 'ربما تم حذف هذا السر.';

  @override
  String get reverseOrderSecretsSubtitle => 'عرض الأسرار بترتيب عكسي.';

  @override
  String get device => 'الجهاز';

  @override
  String get devices => 'الأجهزة';

  @override
  String get otherDevice => 'أخرى';

  @override
  String get addDevice => 'إضافة جهاز';

  @override
  String get newDevice => 'جهاز جديد';

  @override
  String get deviceName => 'اسم الجهاز';

  @override
  String get renameDevice => 'إعادة تسمية الجهاز';

  @override
  String get deleteDevice => 'حذف الجهاز؟';

  @override
  String get deleteDeviceConfirm =>
      'إزالة مجموعة هذا الجهاز؟ يمكن نقل الأسرار إلى «أخرى».';

  @override
  String get deleteDeviceAndClear => 'حذف وإلغاء تعيين الأسرار';

  @override
  String get moveToDevice => 'نقل إلى جهاز';

  @override
  String get noDevicesYet => 'لا توجد أجهزة بعد';

  @override
  String get createDeviceHint => 'أنشئ جهازاً لتنظيم أسرار كل جهاز.';

  @override
  String get deviceCreated => 'تم إنشاء الجهاز';

  @override
  String get secretMoved => 'تم نقل السر';

  @override
  String get emptyDevice => 'لا أسرار على هذا الجهاز';

  @override
  String get faq => 'الأسئلة الشائعة';

  @override
  String get faqSubtitle => 'التشفير والفتح والمزامنة والنسخ الاحتياطي والمزيد';

  @override
  String get faqEncryptionQ => 'هل بياناتي مشفّرة؟';

  @override
  String get faqEncryptionA =>
      'نعم. يشفّر OpenKey خزنتك من طرف إلى طرف على هذا الجهاز. كلمة المرور الرئيسية ومفتاح الخزنة لا يغادران الجهاز كنص واضح.';

  @override
  String get faqForgotPasswordQ => 'ماذا لو نسيت كلمة المرور الرئيسية؟';

  @override
  String get faqForgotPasswordA =>
      'لا يمكن الاستعادة بدون كلمة المرور الرئيسية. بسبب التشفير بدون معرفة، لا يستطيع OpenKey إعادة تعيينها. احتفظ بنسخة احتياطية آمنة من كلمة المرور.';

  @override
  String get faqOfflineQ => 'هل يعمل OpenKey دون اتصال؟';

  @override
  String get faqOfflineA =>
      'نعم. تُخزَّن خزنتك محلياً وتُفتح دون اتصال بالشبكة. الخادم الاختياري مطلوب فقط للمزامنة والمشاركة.';

  @override
  String get faqAutoLockQ => 'كيف يعمل القفل التلقائي؟';

  @override
  String get faqAutoLockA =>
      'عند مغادرة التطبيق دون إغلاقه، يُحتسب وقت غيابك. بعد المدة التي تختارها في الإعدادات تُقفل الخزنة وتحتاج كلمة المرور الرئيسية أو البصمة لفتحها مجدداً. إغلاق التطبيق ينهي الجلسة فوراً.';

  @override
  String get faqBiometricQ => 'هل الفتح بالبصمة آمن؟';

  @override
  String get faqBiometricA =>
      'نعم. البصمة تفتح مفتاحاً مخزّناً في العتاد الآمن للجهاز. لا تستبدل كلمة المرور الرئيسية — يمكنك الفتح بها في أي وقت.';

  @override
  String get faqSyncQ => 'ما هي المزامنة عبر خادم ذاتي؟';

  @override
  String get faqSyncA =>
      'يمكنك تشغيل خادم OpenKey بنفسك. ترسل الأجهزة بيانات الخزنة المشفّرة لتبقى متزامنة عن بُعد. الخادم يخزّن النص المشفّر فقط ولا يرى أسرارك كنص واضح. كلمة المرور الرئيسية تبقى على كل جهاز.';

  @override
  String get faqBackupQ => 'كيف يعمل النسخ الاحتياطي والاستعادة؟';

  @override
  String get faqBackupA =>
      'من الإعدادات ← النسخ الاحتياطي والاستعادة يمكنك حفظ نسخة كاملة من الخزنة على الجهاز. يجمع OpenKey قاعدة البيانات وإعدادات التطبيق والمرفقات في ملف مضغوط، ثم يشفّره بمفتاح الخزنة (.okbak). لا يمكن قراءة الملف بدون كلمة المرور الرئيسية. عند الاستعادة يُفك التشفير وتُستبدل الخزنة المحلية بالنسخة — فاحتفظ بكلمة المرور وملف .okbak في مكان آمن.';

  @override
  String get appName => 'OpenKey';

  @override
  String get copy => 'نسخ';

  @override
  String get create => 'إنشاء';

  @override
  String get generate => 'توليد';

  @override
  String get name => 'الاسم';

  @override
  String get title => 'العنوان';

  @override
  String get lock => 'قفل';

  @override
  String get all => 'الكل';

  @override
  String get entry => 'إدخال';

  @override
  String get collection => 'مجموعة';

  @override
  String get searchPasswords => 'البحث في كلمات المرور';

  @override
  String get noPasswordsYet => 'لا توجد كلمات مرور بعد';

  @override
  String get noPasswordsYetMessage => 'أضف إدخالاً أو أنشئ مجموعة.';

  @override
  String get newCollection => 'مجموعة جديدة';

  @override
  String get newEntry => 'إدخال جديد';

  @override
  String get editEntry => 'تعديل الإدخال';

  @override
  String get chooseFields => 'الحقول';

  @override
  String get chooseFieldsSubtitle =>
      'فعّل أو ألغِ تفعيل الحقول، ثم اسحبها لإعادة ترتيبها';

  @override
  String get done => 'تم';

  @override
  String get phone => 'الهاتف';

  @override
  String get pin => 'رمز PIN';

  @override
  String get number => 'رقم';

  @override
  String get address => 'العنوان';

  @override
  String get ipAddress => 'عنوان IP';

  @override
  String get dateYmd => 'التاريخ';

  @override
  String get dateYm => 'شهر / سنة';

  @override
  String get recoveryCodes => 'رموز الاسترداد';

  @override
  String get customText => 'نص';

  @override
  String get additionalFields => 'حقول إضافية';

  @override
  String get emptyCollection => 'مجموعة فارغة';

  @override
  String get emptyCollectionMessage => 'أضف إدخال كلمة مرور إلى هذه المجموعة.';

  @override
  String get editCollection => 'تعديل المجموعة';

  @override
  String get deleteCollection => 'حذف المجموعة';

  @override
  String get deleteCollectionConfirm =>
      'ستُزال الإدخالات من هذا المجلد (لن تُحذف). هل تريد المتابعة؟';

  @override
  String get chooseIcon => 'اختر أيقونة';

  @override
  String get icons => 'أيقونات';

  @override
  String get brands => 'علامات تجارية';

  @override
  String get suggestedIcon => 'الأيقونة المقترحة';

  @override
  String get fromDevice => 'من الجهاز';

  @override
  String get customIcon => 'أيقونة مخصصة';

  @override
  String get editIcon => 'تعديل الأيقونة';

  @override
  String get cropOrRotate => 'قص / تدوير';

  @override
  String get rotate => 'تدوير';

  @override
  String get flip => 'قلب';

  @override
  String get ratio => 'النسبة';

  @override
  String get filter => 'فلتر';

  @override
  String get blur => 'ضبابية';

  @override
  String get discardChanges => 'تجاهل التغييرات؟';

  @override
  String get discardChangesMessage => 'ستُفقد تعديلاتك.';

  @override
  String get discard => 'تجاهل';

  @override
  String get undo => 'تراجع';

  @override
  String get redo => 'إعادة';

  @override
  String get more => 'المزيد';

  @override
  String get back => 'رجوع';

  @override
  String get preparingImage => 'جارٍ تجهيز الصورة…';

  @override
  String get search => 'بحث';

  @override
  String get noFolder => 'بدون مجلد';

  @override
  String get folder => 'مجلد';

  @override
  String entriesCount(int count) {
    return '$count إدخالات';
  }

  @override
  String get moveTo => 'نقل إلى';

  @override
  String get moveHere => 'نقل هنا';

  @override
  String get movingLabel => 'جاري النقل';

  @override
  String movingItemsCount(int count) {
    return '$count عناصر';
  }

  @override
  String get tags => 'الوسوم';

  @override
  String get noTags => 'لا توجد وسوم بعد';

  @override
  String get noTagsMessage => 'أضف الوسوم عند تعديل إدخال كلمة المرور.';

  @override
  String get sortAndFilter => 'فرز وتصفية';

  @override
  String get applyToFolders => 'المجلدات';

  @override
  String get applyToEntries => 'كلمات المرور';

  @override
  String get sortBy => 'ترتيب حسب';

  @override
  String get options => 'خيارات';

  @override
  String get sortByCreationTime => 'الترتيب حسب وقت الإنشاء';

  @override
  String get sortByLastModified => 'الترتيب حسب آخر تعديل';

  @override
  String get sortByName => 'الترتيب حسب الاسم';

  @override
  String get sortByCustomOrder => 'ترتيب مخصص';

  @override
  String get reverseOrder => 'ترتيب عكسي';

  @override
  String get reverseOrderFoldersSubtitle => 'عرض المجلدات بترتيب عكسي.';

  @override
  String get reverseOrderEntriesSubtitle => 'عرض كلمات المرور بترتيب عكسي.';

  @override
  String get reverseOrderCardsSubtitle => 'عرض البطاقات بترتيب عكسي.';

  @override
  String get reverseOrderCryptoSubtitle => 'عرض المحافظ بترتيب عكسي.';

  @override
  String get addTagHint => 'أضف وسماً';

  @override
  String deleteSelectedConfirm(int count) {
    return 'حذف $count عناصر محددة؟';
  }

  @override
  String get totpSecretLabel => 'سر TOTP / otpauth';

  @override
  String get scanTotpQr => 'مسح رمز QR';

  @override
  String get scanTotpQrHint => 'وجّه الكاميرا نحو رمز QR للمصادقة الثنائية';

  @override
  String get invalidTotpQr => 'رمز QR هذا ليس رمز مصادقة TOTP صالحاً';

  @override
  String get cameraPermissionDenied => 'يلزم إذن الكاميرا لمسح رموز QR';

  @override
  String get storePasskeyMetadata => 'مفتاح مرور';

  @override
  String get passkeyCreatedInBrowser =>
      'أنشئ مفاتيح المرور عبر إضافة OpenKey للمتصفح أو عبر الملء التلقائي / مزوّد الاعتمادات على الموبايل والخزنة مفتوحة.';

  @override
  String get rpId => 'معرّف RP';

  @override
  String get credentialId => 'معرّف الاعتماد';

  @override
  String get addPasskeyItem => 'لا يوجد مفتاح مرور بعد';

  @override
  String bytesLabel(int n) {
    return '$n بايت';
  }

  @override
  String get addEncryptedAttachment => 'إضافة مرفق مشفّر';

  @override
  String get expiryHint => 'شش/سس';

  @override
  String get autoLockSubtitle => 'أقفل الخزنة بعد مغادرة التطبيق.';

  @override
  String get serverUrl => 'رابط الخادم';

  @override
  String get serverUrlHint => 'https://openkey.example.com';

  @override
  String get serverSheetSubtitle =>
      'سجّل أو سجّل الدخول لمزامنة نص الخزنة المشفّر فقط.';

  @override
  String get register => 'تسجيل';

  @override
  String get registerSubtitle => 'إنشاء حساب على هذا الخادم';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get loginSubtitle => 'سجّل الدخول باستخدام بصمة مصادقة هذه الخزنة';

  @override
  String get syncNow => 'مزامنة الآن';

  @override
  String get syncing => 'جاري المزامنة…';

  @override
  String get syncSubtitle => 'دفع وسحب التغييرات المشفّرة';

  @override
  String get syncComplete => 'اكتملت المزامنة';

  @override
  String get extensionLinkCopied => 'تم نسخ بيانات رابط الإضافة';

  @override
  String get biometricUnlockEnabled => 'تم تفعيل الفتح بالبصمة';

  @override
  String get biometricUnlockDisabled => 'تم إيقاف الفتح بالبصمة';

  @override
  String biometricsUpdateFailed(String error) {
    return 'تعذّر تحديث البصمة: $error';
  }

  @override
  String get bitwardenJson => 'Bitwarden JSON';

  @override
  String get bitwardenJsonSubtitle => 'صدّر من Bitwarden ← استورد هنا';

  @override
  String get openKeyJson => 'OpenKey JSON';

  @override
  String get openKeyJsonSubtitle => 'نسخة احتياطية مُصدَّرة من OpenKey';

  @override
  String get chromeCsv => 'Chrome CSV';

  @override
  String get chromeCsvSubtitle => 'كلمات مرور مصدّرة من Chrome';

  @override
  String get lastPassCsv => 'LastPass CSV';

  @override
  String get lastPassCsvSubtitle => 'تصدير CSV من LastPass';

  @override
  String get keePassKdbx => 'KeePass (.kdbx)';

  @override
  String get keePassKdbxSubtitle => 'قاعدة بيانات KeePass / KeePassXC مشفّرة';

  @override
  String get keePassPasswordHint => 'كلمة مرور قاعدة البيانات';

  @override
  String get keePassKeyFile => 'ملف مفتاح (اختياري)';

  @override
  String get keePassUnlockFailed =>
      'تعذّر فتح قاعدة KeePass. تحقق من كلمة المرور وملف المفتاح.';

  @override
  String get onePasswordCsv => '1Password CSV';

  @override
  String get onePasswordCsvSubtitle => 'تصدير CSV من 1Password';

  @override
  String get importingPasswords => 'جاري الاستيراد…';

  @override
  String importingProgress(int done, int total) {
    return 'جاري استيراد $done من $total…';
  }

  @override
  String importedItems(int n) {
    return 'تم استيراد $n عنصر';
  }

  @override
  String get failureUnknown => 'حدث خطأ ما.';

  @override
  String get failureNetwork => 'خطأ في الشبكة. تحقق من اتصالك.';

  @override
  String get failureUnauthorized => 'غير مصرّح. يرجى تسجيل الدخول مجدداً.';

  @override
  String get failureNotFound => 'غير موجود.';

  @override
  String get failureServer => 'خطأ في الخادم.';

  @override
  String get failureInvalidCredentials =>
      'البريد أو كلمة المرور الرئيسية غير صحيحة.';

  @override
  String get failureVaultLocked => 'الخزنة مقفلة.';

  @override
  String get failureVaultAlreadyExists => 'توجد خزنة بالفعل على هذا الجهاز.';

  @override
  String get failureDecryptionFailed => 'تعذّر فك تشفير بيانات الخزنة.';

  @override
  String get failureSyncFailed => 'فشلت المزامنة.';

  @override
  String get failureCreateCollection => 'فشل إنشاء المجموعة.';

  @override
  String get failureUpdateCollection => 'فشل تحديث المجموعة.';

  @override
  String get failureDeleteCollection => 'فشل حذف المجموعة.';

  @override
  String get failureGetCollections => 'فشل تحميل المجموعات.';

  @override
  String get failureCreateEntry => 'فشل إنشاء الإدخال.';

  @override
  String get failureUpdateEntry => 'فشل تحديث الإدخال.';

  @override
  String get failureDeleteEntry => 'فشل حذف الإدخال.';

  @override
  String get failureGetEntries => 'فشل تحميل الإدخالات.';

  @override
  String get failureNoVault => 'لم يتم العثور على خزنة. أنشئ واحدة أولاً.';

  @override
  String get failureConnectServerFirst => 'اربط خادماً أولاً من الإعدادات.';

  @override
  String get failureAttachmentTooLarge => 'المرفق يتجاوز حد 20 ميغابايت.';

  @override
  String get failureAttachmentMissing => 'نص المرفق المشفّر مفقود.';

  @override
  String get failureAccountEmailExists =>
      'هذا البريد لديه خزنة بالفعل على هذا الجهاز.';

  @override
  String get root => 'الجذر';

  @override
  String get selectedItems => 'محددة';

  @override
  String get authenticatorTotp => 'المصادقة الثنائية (TOTP)';

  @override
  String get openKeyPro => 'OpenKey Pro';

  @override
  String get proSubtitle => 'افتح الميزات المتقدمة وادعم تطوير OpenKey.';

  @override
  String get premiumFeatureTitle => 'ميزة مميزة';

  @override
  String get premiumFeatureSubtitle => 'اشترك لفتح هذه الميزة المميزة.';

  @override
  String get premiumFeatureContent => 'هذه ميزة مميزة. اشترك للوصول إليها.';

  @override
  String get premiumBadge => 'Pro';

  @override
  String get subscribe => 'اشترك';

  @override
  String get upgradeNow => 'الترقية الآن';

  @override
  String get oops => 'عذراً!';

  @override
  String get subscription => 'الاشتراك';

  @override
  String get subscriptionTitle => 'الاشتراك';

  @override
  String get subscriptionSubtitle => 'اختر خطة تناسبك.';

  @override
  String get manageYourSubscription => 'إدارة اشتراكك';

  @override
  String get manageSubscriptionAction => 'إدارة الاشتراك';

  @override
  String get subIsActiveTitle => 'اشتراكك نشط';

  @override
  String get subIsNotActiveTitle => 'اشتراكك غير نشط';

  @override
  String get thanksForSubscribing => 'شكراً لاشتراكك!';

  @override
  String get subIsCancelled => 'تم إلغاء اشتراكك ولن يتجدد.';

  @override
  String get subIsPaused => 'اشتراكك متوقف مؤقتاً.';

  @override
  String get restorePurchase => 'استعادة الشراء';

  @override
  String get viewPlansPaywall => 'عرض خيارات الاشتراك';

  @override
  String get openCustomerCenter => 'الإدارة من مركز العملاء';

  @override
  String get subscriptionDesktopNote =>
      'المشتريات داخل التطبيق متاحة على Android و iOS و macOS. على Windows و Linux سجّل الدخول بنفس حساب OpenKey لتفعيل Pro بعد الاشتراك من الجوال أو الـ Mac.';

  @override
  String get subscriptionRefreshStatus => 'تحديث حالة الاشتراك';

  @override
  String get subscriptionNoInternetMsg =>
      'هناك مشكلة في الاتصال بالإنترنت. تحقق من الشبكة وحاول مجدداً.';

  @override
  String get subscriptionRegionBlockedMsg =>
      'خدمات الاشتراك غير متاحة في منطقتك حالياً. اتصل بـ VPN ثم حاول مجدداً.';

  @override
  String get monthly => 'شهري';

  @override
  String get yearly => 'سنوي';

  @override
  String get lifetime => 'مدى الحياة';

  @override
  String get monthlySubtitle => 'تجديد تلقائي، إلغاء في أي وقت';

  @override
  String get yearlySubtitle => 'تجديد تلقائي، أفضل قيمة، إلغاء في أي وقت';

  @override
  String get lifetimeSubtitle => 'شراء لمرة واحدة، لك إلى الأبد';

  @override
  String monthlyPriceLabel(String price) {
    return '$price/شهر';
  }

  @override
  String yearlyPriceLabel(String price) {
    return '$price/سنة';
  }

  @override
  String lifetimePriceLabel(String price) {
    return '$price';
  }

  @override
  String monthlySubscribeLabel(String price) {
    return 'اشترك مقابل $price / شهرياً';
  }

  @override
  String yearlySubscribeLabel(String price) {
    return 'اشترك مقابل $price / سنوياً';
  }

  @override
  String lifetimeSubscribeLabel(String price) {
    return 'شراء مدى الحياة مقابل $price';
  }

  @override
  String get bestValue => 'أفضل قيمة';

  @override
  String get skip => 'تخطي';

  @override
  String get getStarted => 'ابدأ';

  @override
  String get onboardingFaqTitle => 'اعرف هذا قبل أن تبدأ';

  @override
  String get onboardingFaqSubtitle =>
      'أكثر الأسئلة شيوعاً عن OpenKey. اضغط أي سؤال للتفاصيل — ثم أنشئ خزنتك.';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingWelcomeTitle => 'مفاتيحك. خزنتك.';

  @override
  String get onboardingWelcomeSubtitle =>
      'OpenKey يجمع كلمات المرور والرموز والبطاقات في مكان مشفّر واحد — مصمم للاستخدام اليومي.';

  @override
  String get onboardingWelcomePhrase1 => 'معرفة صفرية بالتصميم';

  @override
  String get onboardingWelcomePhrase2 => 'تعبئة تلقائية بلمسة';

  @override
  String get onboardingWelcomePhrase3 => 'استضافة ذاتية متى شئت';

  @override
  String get onboardingSecurityTitle => 'لا أحد غيرك يقرأه';

  @override
  String get onboardingSecuritySubtitle =>
      'التشفير من طرف إلى طرف يعني أن كلمة المرور الرئيسية لا تغادر جهازك أبداً. نخزّن النص المشفّر فقط.';

  @override
  String get onboardingAutofillTitle => 'عبّئ مرة. وثق دائماً.';

  @override
  String get onboardingAutofillSubtitle =>
      'سجّل الدخول عبر التطبيقات والمواقع دون البحث عن كلمات المرور. التعبئة التلقائية تجعل OpenKey جزءاً من يومك.';

  @override
  String get onboardingAllInOneTitle => 'تطبيق واحد. خزنة كاملة.';

  @override
  String get onboardingAllInOneSubtitle =>
      'كلمات مرور، رموز مصادقة، بطاقات دفع، محافظ كريبتو، وأسرار المطوّرين — استبدل الفوضى بخزنة موثوقة واحدة.';

  @override
  String get onboardingFeaturePasswords => 'كلمات المرور';

  @override
  String get onboardingFeatureCrypto => 'كريبتو';

  @override
  String get onboardingFeatureAutofill => 'تعبئة تلقائية';

  @override
  String get onboardingFeatureSelfHost => 'استضافة ذاتية.';

  @override
  String get onboardingFooterHint => 'أقل من دقيقة. يمكنك التخطي في أي وقت.';

  @override
  String get onboardingLetsGo => 'لنبدأ!';

  @override
  String onboardingStepOf(int current, int total) {
    return 'الخطوة $current من $total';
  }

  @override
  String get onboardingWelcomeHeadline => 'مرحباً\nفي OpenKey.';

  @override
  String get onboardingWelcomeLead => 'دعنا نجهّز كل شيء لك';

  @override
  String get onboardingEcosystemTitle => 'خزنتك\nالكاملة.';

  @override
  String get onboardingEcosystemSubtitle =>
      'كلمات مرور ورموز وبطاقات — مشفّرة وجاهزة أينما سجّلت الدخول.';

  @override
  String get onboardingStyleTitle => 'صمّمها\nعلى ذوقك.';

  @override
  String get onboardingEnableAutofillTitle => 'فعّل\nالتعبئة التلقائية.';

  @override
  String get onboardingAutofillCardTitle => 'تعبئة كلمات المرور';

  @override
  String get onboardingAutofillCardSubtitle =>
      'املأ تسجيلات الدخول في التطبيقات والمواقع من خزنتك.';

  @override
  String get onboardingAutofillGranted => 'التعبئة التلقائية جاهزة';

  @override
  String get onboardingFinishBadge => 'اكتمل الإعداد';

  @override
  String get onboardingFinishTitle => 'جاهز\nللقفل.';

  @override
  String get onboardingFinishSubtitle =>
      'أنشئ كلمة مرور رئيسية وابدأ بحفظ ما يهمك — خزنتك على بعد خطوة.';

  @override
  String get onboardingCreateVault => 'إنشاء خزنة';

  @override
  String get errorLoadingData => 'خطأ في تحميل البيانات. حاول مجدداً.';

  @override
  String get retryAgain => 'إعادة المحاولة';

  @override
  String get autoRenewLabel => 'تجديد تلقائي';

  @override
  String get cancelledLabel => 'ملغى';

  @override
  String get pausedLabel => 'متوقف';

  @override
  String get supportAppDevelopmentTitle => 'ادعم التطوير';

  @override
  String get supportAppDevelopmentSubtitle =>
      'اشتراكك يساعدنا على تحسين OpenKey باستمرار.';

  @override
  String get limitEntriesTitle => 'تم بلوغ حد الإدخالات';

  @override
  String get limitCollectionsTitle => 'تم بلوغ حد المجموعات';

  @override
  String get limitWalletsTitle => 'تم بلوغ حد البطاقات';

  @override
  String get limitCryptoWalletsTitle => 'تم بلوغ حد محافظ العملات';

  @override
  String get limitSecretsTitle => 'تم بلوغ حد الأسرار';

  @override
  String limitReachedContent(int usage, int limit, String feature) {
    return 'لقد استخدمت $usage من أصل $limit $feature. ترقَّ إلى Pro للوصول غير المحدود.';
  }

  @override
  String limitSubtitle(int limit, String feature) {
    return 'الخطة المجانية تتضمن حتى $limit $feature.';
  }

  @override
  String get entries => 'إدخالات';

  @override
  String get collections => 'مجموعات';

  @override
  String get cards => 'بطاقات';

  @override
  String get cryptoWalletsFeature => 'محافظ عملات';

  @override
  String get secretsFeature => 'أسرار';

  @override
  String expiresOn(String date) {
    return 'ينتهي في $date';
  }

  @override
  String get unlockUnlimitedEntriesTitle => 'إدخالات غير محدودة';

  @override
  String get unlockUnlimitedEntriesSubtitle =>
      'احفظ أي عدد تحتاجه من كلمات المرور وتسجيلات الدخول.';

  @override
  String get unlockUnlimitedCollectionsTitle => 'مجموعات غير محدودة';

  @override
  String get unlockUnlimitedCollectionsSubtitle =>
      'نظّم خزنتك بأي عدد من المجلدات.';

  @override
  String get unlockUnlimitedWalletsTitle => 'بطاقات غير محدودة';

  @override
  String get unlockUnlimitedWalletsSubtitle =>
      'احفظ أي عدد تحتاجه من بطاقات الدفع.';

  @override
  String get unlockUnlimitedCryptoWalletsTitle => 'محافظ عملات غير محدودة';

  @override
  String get unlockUnlimitedCryptoWalletsSubtitle =>
      'احفظ العناوين والمفاتيح وعبارات الاسترداد بلا حدود.';

  @override
  String get unlockUnlimitedSecretsTitle => 'أسرار مطوّرين غير محدودة';

  @override
  String get unlockUnlimitedSecretsSubtitle =>
      'احفظ مفاتيح SSH وتوكنات API ومقاطع .env بلا حدود.';

  @override
  String get unlockSyncTitle => 'مزامنة الخادم';

  @override
  String get unlockSyncSubtitle => 'اربط خادمك الذاتي وزامن عبر الأجهزة.';

  @override
  String get unlockAttachmentsTitle => 'المرفقات';

  @override
  String get unlockAttachmentsSubtitle => 'أرفق ملفات مشفّرة بإدخالات الخزنة.';

  @override
  String get unlockImportExportTitle => 'الاستيراد والتصدير';

  @override
  String get unlockImportExportSubtitle => 'انقل البيانات من وإلى OpenKey.';

  @override
  String get unknownFailureMsg => 'حدث خطأ غير معروف.';

  @override
  String get purchaseCancelledMsg => 'تم إلغاء عملية الشراء.';

  @override
  String get storeProblemMsg => 'حدثت مشكلة في المتجر.';

  @override
  String get purchaseNotAllowedMsg => 'المشتريات غير مسموحة على هذا الجهاز.';

  @override
  String get purchaseInvalidMsg => 'عملية الشراء غير صالحة.';

  @override
  String get productNotAvailableForPurchaseMsg => 'هذا المنتج غير متاح للشراء.';

  @override
  String get productAlreadyPurchasedMsg => 'تم شراء هذا المنتج مسبقاً.';

  @override
  String get receiptAlreadyInUseMsg => 'هذا الإيصال مستخدم بالفعل.';

  @override
  String get invalidReceiptMsg => 'الإيصال غير صالح.';

  @override
  String get missingReceiptFileMsg => 'ملف الإيصال مفقود.';

  @override
  String get networkErrorMsg => 'حدث خطأ في الشبكة. تحقق من اتصالك.';

  @override
  String get invalidCredentialsMsg => 'بيانات الاعتماد غير صالحة.';

  @override
  String get unexpectedBackendResponseMsg => 'استجابة غير متوقعة من الخادم.';

  @override
  String get receiptInUseByOtherSubscriberMsg => 'الإيصال مستخدم من مشترك آخر.';

  @override
  String get invalidAppUserIdMsg => 'معرّف مستخدم التطبيق غير صالح.';

  @override
  String get operationAlreadyInProgressMsg => 'هناك عملية قيد التنفيذ بالفعل.';

  @override
  String get unknownBackendErrorMsg => 'حدث خطأ غير معروف على الخادم.';

  @override
  String get invalidAppleSubscriptionKeyMsg => 'مفتاح اشتراك Apple غير صالح.';

  @override
  String get ineligibleMsg => 'أنت غير مؤهل لهذا الشراء.';

  @override
  String get insufficientPermissionsMsg => 'ليس لديك صلاحيات كافية.';

  @override
  String get paymentPendingMsg => 'الدفع قيد الانتظار.';

  @override
  String get invalidSubscriberAttributesMsg => 'سمات المشترك غير صالحة.';

  @override
  String get logOutWithAnonymousUserMsg =>
      'لا يمكن تسجيل الخروج لمستخدم مجهول.';

  @override
  String get configurationErrorMsg => 'هناك خطأ في الإعدادات.';

  @override
  String get unsupportedErrorMsg => 'هذه العملية غير مدعومة.';

  @override
  String get emptySubscriberAttributesMsg => 'سمات المشترك فارغة.';

  @override
  String get productDiscountMissingIdentifierMsg => 'معرّف خصم المنتج مفقود.';

  @override
  String get unknownNonNativeErrorMsg => 'حدث خطأ غير أصلي غير معروف.';

  @override
  String get productDiscountMissingSubscriptionGroupIdentifierMsg =>
      'معرّف مجموعة اشتراك خصم المنتج مفقود.';

  @override
  String get customerInfoErrorMsg => 'فشل جلب معلومات العميل.';

  @override
  String get systemInfoErrorMsg => 'فشل جلب معلومات النظام.';

  @override
  String get beginRefundRequestErrorMsg => 'فشل بدء طلب الاسترداد.';

  @override
  String get productRequestTimeoutMsg => 'انتهت مهلة طلب المنتج.';

  @override
  String get apiEndpointBlockedMsg => 'نقطة نهاية واجهة البرمجة محظورة.';

  @override
  String get invalidPromotionalOfferMsg => 'العرض الترويجي غير صالح.';

  @override
  String get offlineConnectionMsg =>
      'لا يوجد اتصال بالإنترنت. اتصل وحاول مجدداً.';

  @override
  String get featureNotAvailableInCustomEntitlementsComputationModeMsg =>
      'هذه الميزة غير متاحة في وضع حساب الاستحقاقات المخصص.';

  @override
  String get signatureVerificationFailedMsg => 'فشل التحقق من التوقيع.';

  @override
  String get featureNotSupportedWithStoreKit1Msg =>
      'هذه الميزة غير مدعومة مع StoreKit 1.';

  @override
  String get invalidWebPurchaseTokenMsg => 'رمز الشراء عبر الويب غير صالح.';

  @override
  String get purchaseBelongsToOtherUserMsg => 'هذا الشراء يخص مستخدماً آخر.';

  @override
  String get expiredWebPurchaseTokenMsg => 'انتهت صلاحية رمز الشراء عبر الويب.';

  @override
  String get testStoreSimulatedPurchaseErrorMsg =>
      'خطأ شراء محاكى من متجر الاختبار.';

  @override
  String get aboutApp => 'حول التطبيق';

  @override
  String get aboutAppSubtitle => 'تعرف أكثر على OpenKey وتطويره.';

  @override
  String get developerName => 'OpenSelfHosting';

  @override
  String get developer => 'برمجيات مفتوحة المصدر تستضيفها بنفسك';

  @override
  String rateUsIn(String storeName) {
    return 'قيّمنا على $storeName';
  }

  @override
  String get doYouLikeTheAppRateUs => 'هل أعجبك التطبيق؟ قيّمنا!';

  @override
  String get licenses => 'التراخيص';

  @override
  String get openLicenses => 'فتح التراخيص';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get privacyPolicySubtitle => 'اقرأ سياسة الخصوصية الخاصة بنا';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get termsOfServiceSubtitle => 'اقرأ شروط الخدمة الخاصة بنا';

  @override
  String get pricing => 'التسعير';

  @override
  String get pricingSubtitle => 'المجاني مقابل خطط OpenKey Pro';

  @override
  String get copied => 'تم النسخ إلى الحافظة';

  @override
  String get contact => 'تواصل معنا';

  @override
  String get contactSubtitle => 'تواصل معنا للدعم أو الملاحظات.';

  @override
  String get telegram => 'تيليجرام';

  @override
  String get ok => 'موافق';

  @override
  String get localBackupRestoreTitle => 'النسخ الاحتياطي والاستعادة';

  @override
  String get localBackupRestoreSubtitle =>
      'أنشئ نسخة مشفّرة كاملة للخزنة (.okbak) أو استعد منها. تشمل قاعدة البيانات والإعدادات والمرفقات.';

  @override
  String get exportBackup => 'تصدير نسخة احتياطية';

  @override
  String get exportBackupSubtitleEmpty =>
      'أنشئ نسخة مشفّرة محلياً واختر مكان حفظها.';

  @override
  String exportBackupSubtitleLatest(String path) {
    return 'آخر تصدير: $path';
  }

  @override
  String get importBackup => 'استعادة نسخة احتياطية';

  @override
  String get importBackupSubtitle =>
      'استبدل هذه الخزنة بنسخة OpenKey مشفّرة (.okbak).';

  @override
  String get confirmRestore => 'تأكيد الاستعادة';

  @override
  String get confirmRestoreMessage =>
      'الاستعادة تستبدل قاعدة البيانات المحلية والإعدادات والمرفقات بالنسخة. أدخل كلمة المرور الرئيسية المستخدمة لتلك النسخة لفك التشفير.';

  @override
  String get creatingBackup => 'جارٍ إنشاء النسخة…';

  @override
  String get creatingBackupBody => 'ضغط وتشفير خزنتك بالكامل.';

  @override
  String get restoringBackupProgress => 'جارٍ استعادة النسخة…';

  @override
  String get restoringBackupBody => 'فك التشفير واستعادة الخزنة.';

  @override
  String get restoringBackupVerifying => 'جارٍ التحقق من كلمة المرور الرئيسية…';

  @override
  String get restoringBackupDecrypting => 'جارٍ فك تشفير بيانات النسخة…';

  @override
  String get restoringBackupWriting => 'جارٍ كتابة الخزنة المستعادة…';

  @override
  String get restoringBackupUnlocking => 'جارٍ فتح الخزنة المستعادة…';

  @override
  String get backupComplete => 'اكتمل النسخ الاحتياطي';

  @override
  String get backupCompleteLocalBody => 'تم حفظ النسخة المشفّرة بنجاح.';

  @override
  String get backupCompleteLocalDetail =>
      'احتفظ بهذا الملف في مكان آمن. تحتاج كلمة المرور الرئيسية لاستعادته.';

  @override
  String get backupError => 'خطأ في النسخ الاحتياطي';

  @override
  String get restoreCompleted => 'اكتملت الاستعادة';

  @override
  String get restoreCompletedBody => 'تمت استعادة خزنتك من النسخة المشفّرة.';
}
