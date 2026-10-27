// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get settings => 'Настройки';

  @override
  String get appearance => 'Оформление';

  @override
  String get appearanceSubtitle => 'Тема, цвета, шрифты и язык';

  @override
  String get themeMode => 'Режим темы';

  @override
  String get system => 'Системная';

  @override
  String get light => 'Светлая';

  @override
  String get dark => 'Тёмная';

  @override
  String get language => 'Язык';

  @override
  String get fonts => 'Шрифты';

  @override
  String get displayFont => 'Шрифт отображения';

  @override
  String get defaultFont => 'По умолчанию';

  @override
  String get arabicFont => 'Арабский';

  @override
  String get developerFont => 'Для разработчиков';

  @override
  String get technicalFont => 'Технический';

  @override
  String get standardFont => 'Стандартный';

  @override
  String get defaultFontDes => 'Шрифт приложения по умолчанию.';

  @override
  String get arabicFontDes => 'Шрифт, оптимизированный для арабского письма.';

  @override
  String get developerFontDes => 'Шрифт, разработанный для разработчиков.';

  @override
  String get technicalFontDes => 'Шрифт для технического содержания.';

  @override
  String get standardFontDes => 'Стандартный шрифт общего назначения.';

  @override
  String get googleSansFlexFont => 'Google Sans Flex';

  @override
  String get googleSansFlexFontDes =>
      'Выразительный фирменный шрифт Google для Material 3 Expressive.';

  @override
  String get robotoFlexFont => 'Roboto Flex';

  @override
  String get robotoFlexFontDes =>
      'Переменный шрифт Material Design с начертанием, шириной и оптическим размером.';

  @override
  String get figtreeFont => 'Figtree';

  @override
  String get figtreeFontDes =>
      'Мягкий геометрический гротеск, часто с темами Material You.';

  @override
  String get nunitoFont => 'Nunito';

  @override
  String get nunitoFontDes =>
      'A rounded geometric sans with a friendly, modern tone.';

  @override
  String get dynamicColors => 'Динамические цвета';

  @override
  String get dynamicColorsSubtitle => 'Создать тему из выбранного цвета';

  @override
  String get colorScheme => 'Цветовая схема';

  @override
  String get colorSchemeSubtitle => 'Выберите цвет и стиль палитры';

  @override
  String get highContrast => 'Высокий контраст';

  @override
  String get highContrastSubtitle => 'Увеличить контраст для удобства чтения';

  @override
  String get security => 'Безопасность';

  @override
  String get securitySubtitle =>
      'Автоблокировка, биометрия, автозаполнение и мастер-пароль';

  @override
  String get account => 'Аккаунт';

  @override
  String get accountPageTitle => 'Аккаунт';

  @override
  String get accountPhoto => 'Фото профиля';

  @override
  String get changeAccountPhoto => 'Сменить фото';

  @override
  String get removeAccountPhoto => 'Удалить фото';

  @override
  String get changeEmail => 'Изменить почту';

  @override
  String get changeEmailSubtitle =>
      'Повторно оборачивает ключ хранилища. Вход будет с новым адресом.';

  @override
  String get newEmail => 'Новая почта';

  @override
  String get emailChanged => 'Почта обновлена';

  @override
  String get switchAccount => 'Сменить аккаунт';

  @override
  String get addAccount => 'Добавить аккаунт';

  @override
  String get addAccountSubtitle =>
      'Создайте или войдите в другое хранилище на этом устройстве';

  @override
  String get removeAccountFromDevice => 'Удалить с этого устройства';

  @override
  String get removeAccountFromDeviceSubtitle =>
      'Удаляет это локальное хранилище. Связанная учётная запись на сервере не удаляется.';

  @override
  String get removeAccountConfirm =>
      'Это хранилище и его элементы будут удалены с этого устройства. Это действие нельзя отменить.';

  @override
  String get otherAccounts => 'Другие аккаунты';

  @override
  String get useThisAccount => 'Использовать этот аккаунт';

  @override
  String get currentAccount => 'Текущий аккаунт';

  @override
  String get chooseAccount => 'Выбрать аккаунт';

  @override
  String get switchingAccount => 'Переключение аккаунта…';

  @override
  String get welcomeBackShort => 'С возвращением';

  @override
  String get tools => 'Инструменты';

  @override
  String get help => 'Справка';

  @override
  String get autoLock => 'Автоблокировка';

  @override
  String minutesLabel(num n) {
    return '$n мин.';
  }

  @override
  String get autoLockOff => 'Выкл.';

  @override
  String get blockScreenshot => 'Блокировать скриншоты';

  @override
  String get blockScreenshotSubtitle =>
      'Запретить скриншоты и запись экрана приложения.';

  @override
  String get blockScreenshotLinuxNote =>
      'В Linux — по возможности; композитор всё ещё может разрешить захват.';

  @override
  String get biometricUnlock => 'Биометрическая разблокировка';

  @override
  String get autofillService => 'Служба автозаполнения';

  @override
  String get autofillEnabled =>
      'OpenKey — ваш провайдер паролей и ключей доступа';

  @override
  String get autofillDisabled =>
      'Включите OpenKey для паролей (автозаполнение) и ключей (поставщик учётных данных)';

  @override
  String get autofillDisabledBrowser =>
      'Установите расширение OpenKey и разблокируйте хранилище';

  @override
  String get autofillSaveTitle => 'Сохранить пароль';

  @override
  String get autofillSaveSubtitle => 'Сохранить этот вход в хранилище OpenKey?';

  @override
  String get autofillSaved => 'Пароль сохранён';

  @override
  String get autofillRequireBiometric =>
      'Требовать биометрию для автозаполнения';

  @override
  String get autofillRequireBiometricSubtitle =>
      'Запрашивать отпечаток или лицо перед заполнением паролей в приложениях и на сайтах.';

  @override
  String get autofillRequireBiometricReason =>
      'Подтвердите автозаполнение через OpenKey';

  @override
  String get autofillRequireBiometricEnabled =>
      'Биометрическое подтверждение автозаполнения включено';

  @override
  String get autofillRequireBiometricDisabled =>
      'Биометрическое подтверждение автозаполнения выключено';

  @override
  String get autofillInline => 'В клавиатуре';

  @override
  String get autofillInlineSubtitle =>
      'Показывать подсказки в строке клавиатуры.';

  @override
  String get autofillPopup => 'Над полем ввода';

  @override
  String get autofillPopupSubtitle =>
      'Показывать выпадающий список над полем ввода.';

  @override
  String get androidApp => 'Приложение Android';

  @override
  String get androidAppHint => 'Имя пакета, напр. com.example.app';

  @override
  String get biometricUnlockReason => 'Разблокируйте хранилище OpenKey';

  @override
  String get enableBiometricUnlockReason =>
      'Включить биометрическую разблокировку';

  @override
  String get biometricHint => 'Подтвердите личность';

  @override
  String get biometricNotRecognized => 'Не распознано. Попробуйте снова.';

  @override
  String get goToSettings => 'Открыть настройки';

  @override
  String get biometricGoToSettingsDescription =>
      'Биометрическая аутентификация не настроена. Откройте настройки, чтобы добавить отпечаток или лицо.';

  @override
  String get unlock => 'Разблокировать';

  @override
  String get unlocking => 'Разблокировка…';

  @override
  String get masterPassword => 'Мастер-пароль';

  @override
  String get unlockSubtitle => 'Введите мастер-пароль, чтобы разблокировать.';

  @override
  String welcomeBack(String email) {
    return 'С возвращением, $email';
  }

  @override
  String get fieldRequired => 'Обязательно';

  @override
  String get resetLocalVault => 'Сбросить локальное хранилище';

  @override
  String get resetLocalVaultTitle => 'Сбросить локальное хранилище?';

  @override
  String get resetLocalVaultSubtitle =>
      'Безвозвратно удаляет все данные хранилища на этом устройстве.';

  @override
  String get resetLocalVaultConfirm =>
      'Все пароли и данные хранилища на этом устройстве будут безвозвратно удалены, чтобы создать новое. Данные на сервере не удаляются. Действие необратимо.';

  @override
  String get dangerZone => 'Опасная зона';

  @override
  String get reset => 'Сбросить';

  @override
  String get createVault => 'Создать хранилище';

  @override
  String get creatingVault => 'Создание…';

  @override
  String get setupSubtitle =>
      'Создайте зашифрованное хранилище. Мастер-пароль не покидает это устройство.';

  @override
  String get setupSignInSubtitle =>
      'Войдите на свой самостоятельно размещённый сервер OpenKey, чтобы восстановить хранилище на устройстве.';

  @override
  String get setupModeCreate => 'Создать';

  @override
  String get setupModeSignIn => 'Войти';

  @override
  String get setupModeRestore => 'Восстановить';

  @override
  String get setupSignInAction => 'Войти';

  @override
  String get setupSigningIn => 'Вход…';

  @override
  String get setupRestoreSubtitle =>
      'Восстановите хранилище из зашифрованной копии OpenKey (.okbak).';

  @override
  String get setupRestoreAction => 'Восстановить хранилище';

  @override
  String get setupRestoreChooseFile => 'Выбрать файл копии';

  @override
  String get setupRestoreChooseFileSubtitle =>
      'Выберите зашифрованный файл .okbak.';

  @override
  String setupRestoreBackupAccount(String email) {
    return 'Эта копия для $email';
  }

  @override
  String get setupRestoreNeedFile => 'Сначала выберите файл копии';

  @override
  String get setupLinkSelfHostedTitle => 'Привязать свой сервер';

  @override
  String get setupLinkSelfHostedSubtitle =>
      'Необязательно. Зарегистрируйте хранилище для синхронизации между устройствами.';

  @override
  String get setupLinkServerHelper =>
      'Хранилище будет зарегистрировано на этом сервере после создания.';

  @override
  String get setupSignInServerHelper =>
      'URL сервера OpenKey, на котором уже есть ваш аккаунт.';

  @override
  String get setupChooserTitle => 'Как вы хотите начать?';

  @override
  String get setupChooserSubtitle =>
      'Создайте хранилище, войдите или восстановите резервную копию.';

  @override
  String get setupChooseCreateTitle => 'Создать хранилище';

  @override
  String get setupChooseCreateSubtitle =>
      'Новое зашифрованное хранилище на этом устройстве.';

  @override
  String get setupChooseSignInTitle => 'Войти';

  @override
  String get setupChooseSignInSubtitle =>
      'Восстановите с вашего собственного сервера OpenKey.';

  @override
  String get setupChooseRestoreTitle => 'Восстановить копию';

  @override
  String get setupChooseRestoreSubtitle =>
      'Откройте зашифрованный файл .okbak.';

  @override
  String get invalidServerUrl =>
      'Введите действительный URL, начинающийся с http:// или https://';

  @override
  String get confirmMasterPassword => 'Подтвердите мастер-пароль';

  @override
  String get email => 'Эл. почта';

  @override
  String get invalidEmail => 'Введите корректный адрес';

  @override
  String get invalidEmailFormat => 'Некорректный адрес почты';

  @override
  String get invalidUrlFormat =>
      'Некорректный URL. Пример: https://example.com';

  @override
  String get invalidPhoneFormat => 'Некорректный номер телефона';

  @override
  String get invalidPinFormat => 'PIN должен содержать 4–12 цифр';

  @override
  String get invalidNumberFormat => 'Введите только цифры';

  @override
  String get invalidCardFormat => 'Некорректный номер карты';

  @override
  String get invalidIpFormat => 'Некорректный IP-адрес';

  @override
  String get invalidWalletFormat => 'Некорректный адрес кошелька';

  @override
  String get invalidRecoveryCodesFormat => 'Некорректные коды восстановления';

  @override
  String get fixFieldErrors => 'Исправьте отмеченные поля перед сохранением';

  @override
  String get passwordTooShort => 'Не менее 8 символов';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get passwordTooShortStrong => 'Не менее 12 символов';

  @override
  String get passwordTooWeak =>
      'Используйте более длинную смесь букв, цифр и символов';

  @override
  String get masterPasswordHelper => 'Рекомендуется 12+ символов разных типов';

  @override
  String get passwordHintOptional => 'Подсказка к паролю (необязательно)';

  @override
  String get passwordHintHelper =>
      'Только туманная подсказка — никогда не включайте сам пароль';

  @override
  String passwordHintReveal(String hint) {
    return 'Подсказка: $hint';
  }

  @override
  String get setupZeroKnowledgeBanner =>
      'Шифрование с нулевым разглашением: OpenKey не может прочитать или сбросить хранилище.';

  @override
  String get vaultNoticesTitle => 'Перед созданием хранилища';

  @override
  String get vaultNoticesSubtitle =>
      'Подтвердите эти пункты, чтобы продолжить.';

  @override
  String get vaultNoticeNoRecovery =>
      'Если вы забудете мастер-пароль, данные восстановить нельзя.';

  @override
  String get vaultNoticeLocalEncryption =>
      'Хранилище шифруется на этом устройстве; мастер-пароль никогда не уходит с него в открытом виде.';

  @override
  String get vaultNoticeBackups =>
      'Регулярные зашифрованные резервные копии — единственная защита от потери устройства.';

  @override
  String get vaultNoticeDeviceTransfer =>
      'Перенос на новое устройство требует восстановления из резервной копии или опциональной синхронизации с сервером.';

  @override
  String get acceptAllNotices => 'Принять все';

  @override
  String get server => 'Свой сервер';

  @override
  String get notConnected => 'Не подключено';

  @override
  String get data => 'Данные и доступ';

  @override
  String get dataSubtitle =>
      'Сервер, резервное копирование, импорт/экспорт и доступ';

  @override
  String get importExport => 'Импорт и экспорт';

  @override
  String get importExportSubtitle => 'Перенос паролей в хранилище или из него';

  @override
  String get importTab => 'Импорт';

  @override
  String get exportTab => 'Экспорт';

  @override
  String get importPasswords => 'Импорт паролей';

  @override
  String get importPasswordsSubtitle =>
      'Записи шифруются ключом хранилища на этом устройстве.';

  @override
  String get exportPasswords => 'Экспорт паролей';

  @override
  String get exportPasswordsSubtitle =>
      'Расшифровывает записи на этом устройстве и сохраняет незашифрованный файл.';

  @override
  String get exportingPasswords => 'Экспорт…';

  @override
  String get exportBitwardenSubtitle => 'Незашифрованный JSON Bitwarden';

  @override
  String get exportChromeSubtitle => 'CSV, совместимый с Chrome';

  @override
  String get exportLastPassSubtitle => 'CSV, совместимый с LastPass';

  @override
  String get exportOnePasswordSubtitle => 'CSV, совместимый с 1Password';

  @override
  String get exportKeePassSubtitle =>
      'Зашифрованная база KeePass / KeePassXC (.kdbx)';

  @override
  String get exportOpenKeySubtitle =>
      'Незашифрованный JSON OpenKey с папками и полными данными';

  @override
  String get exportedItems => 'Хранилище экспортировано';

  @override
  String exportedToPath(String path) {
    return 'Экспортировано в $path';
  }

  @override
  String get changeMasterPassword => 'Сменить мастер-пароль';

  @override
  String get changeMasterPasswordSubtitle =>
      'Перезаворачивает ключ хранилища. Записи остаются зашифрованы тем же ключом.';

  @override
  String get currentMasterPassword => 'Текущий мастер-пароль';

  @override
  String get newMasterPassword => 'Новый мастер-пароль';

  @override
  String get masterPasswordUnchanged => 'Выберите другой пароль';

  @override
  String get masterPasswordChanged => 'Мастер-пароль обновлён';

  @override
  String get deleteServerAccount => 'Удалить аккаунт на сервере';

  @override
  String get deleteServerAccountSubtitle =>
      'Удаляет ваш шифротекст с сервера. Локальное хранилище на устройстве сохраняется.';

  @override
  String get deleteServerAccountWarning =>
      'Это нельзя отменить. Синхронизированные данные на сервере будут удалены навсегда.';

  @override
  String get serverAccountDeleted => 'Аккаунт на сервере удалён';

  @override
  String get browserExtension => 'Расширение браузера';

  @override
  String get browserExtensionSubtitle =>
      'Подключите Chrome / Edge / Firefox к разблокированному хранилищу';

  @override
  String get browserExtensionSheetSubtitle =>
      'Вставьте ID распакованного расширения Chrome из chrome://extensions (режим разработчика). Firefox использует фиксированный ID автоматически.';

  @override
  String get chromeExtensionId => 'ID расширения Chrome';

  @override
  String get chromeExtensionIdHint =>
      'Отображается под именем расширения на chrome://extensions';

  @override
  String get connectBrowserExtension => 'Подключить расширение';

  @override
  String get copyOfflineExtensionLink => 'Скопировать офлайн-ссылку хранилища';

  @override
  String get extensionLinkClipboardWarning =>
      'Это копирует материал разблокировки хранилища в буфер обмена. Другие приложения могут читать его до очистки или автоочистки через минуту.';

  @override
  String get browserExtensionHostReady =>
      'Нативный хост зарегистрирован. Держите OpenKey разблокированным и нажмите «Использовать приложение» в расширении.';

  @override
  String get browserExtensionHostHint =>
      'Разблокируйте хранилище, вставьте ID Chrome и подключитесь.';

  @override
  String get browserExtensionHostFailed =>
      'Не удалось зарегистрировать нативный хост. Разблокируйте хранилище и повторите.';

  @override
  String get cliTitle => 'CLI';

  @override
  String get cliSubtitle =>
      'Установите CLI OpenKey, затем выполните команду подключения при разблокированном хранилище.';

  @override
  String get cliTermuxTitle => 'Termux / CLI';

  @override
  String get cliTermuxSubtitle =>
      'Установите CLI OpenKey в Termux, затем выполните команду подключения при разблокированном хранилище.';

  @override
  String get cliTermuxInstall => 'Установка';

  @override
  String get cliTermuxConnect => 'Подключение';

  @override
  String get cliTermuxUnavailable =>
      'Разблокируйте хранилище, чтобы показать команду подключения.';

  @override
  String get aboutPrivacy =>
      'OpenKey шифрует пароли сквозным шифрованием. Мастер-пароль и ключ хранилища не покидают устройство.';

  @override
  String get localVault => 'Локальное хранилище';

  @override
  String get followDevice => 'Как на устройстве';

  @override
  String get passwordGenerator => 'Генератор паролей';

  @override
  String get generatedPassword => 'Сгенерированный пароль';

  @override
  String get passwordLength => 'Длина';

  @override
  String charactersLabel(int n) {
    return '$n символов';
  }

  @override
  String get includeUppercase => 'Заглавные буквы';

  @override
  String get includeLowercase => 'Строчные буквы';

  @override
  String get includeDigits => 'Цифры';

  @override
  String get includeSymbols => 'Символы';

  @override
  String get avoidAmbiguous => 'Без неоднозначных символов';

  @override
  String get avoidAmbiguousSubtitle => 'Исключить I, l, 1, O, 0, o, |';

  @override
  String get regenerate => 'Сгенерировать снова';

  @override
  String get copyPassword => 'Копировать';

  @override
  String get passwordCopied => 'Пароль скопирован';

  @override
  String get passwordGeneratorSubtitle => 'Создайте надёжный уникальный пароль';

  @override
  String get usePassword => 'Использовать пароль';

  @override
  String get generateOptions => 'Параметры';

  @override
  String get characterSets => 'Наборы символов';

  @override
  String get passwordStrengthWeak => 'Слабый';

  @override
  String get passwordStrengthFair => 'Средний';

  @override
  String get passwordStrengthStrong => 'Надёжный';

  @override
  String get generatorTitle => 'Генератор';

  @override
  String get generatorSubtitle => 'Создавайте пароли, имена и адреса почты';

  @override
  String get generatorModePassword => 'Пароль';

  @override
  String get generatorModeUsername => 'Имя';

  @override
  String get generatorModeEmail => 'Почта';

  @override
  String get generatedUsername => 'Сгенерированное имя';

  @override
  String get generatedEmail => 'Сгенерированная почта';

  @override
  String get usernameStyle => 'Стиль';

  @override
  String get usernameStyleWords => 'Слова';

  @override
  String get usernameStyleRandom => 'Случайный';

  @override
  String get usernameCapitalize => 'Заглавные';

  @override
  String get usernameIncludeDigits => 'Добавить цифры';

  @override
  String get usernameSeparator => 'Разделитель';

  @override
  String get usernameSeparatorNone => 'Нет';

  @override
  String get emailType => 'Тип почты';

  @override
  String get emailTypeRandom => 'Случайный';

  @override
  String get emailTypePlus => 'Plus-адрес';

  @override
  String get emailDomain => 'Домен';

  @override
  String get emailDomainHint => 'yourdomain.com';

  @override
  String get emailPlusBase => 'Ваша почта';

  @override
  String get emailPlusBaseHint => 'you@gmail.com';

  @override
  String get emailPlusHelp =>
      'Создаёт you+tag@gmail.com, чтобы фильтровать регистрации во входящих.';

  @override
  String get emailRandomHelp =>
      'Создаёт уникальный адрес на домене, которым вы управляете, например catch-all.';

  @override
  String get passwordDetails => 'Сведения о пароле';

  @override
  String get untitled => 'Без названия';

  @override
  String get credentials => 'Учётные данные';

  @override
  String get username => 'Имя пользователя';

  @override
  String get password => 'Пароль';

  @override
  String get website => 'Сайт';

  @override
  String get notes => 'Заметки';

  @override
  String get authenticator => 'Аутентификатор';

  @override
  String get passkey => 'Ключ доступа';

  @override
  String get attachments => 'Вложения';

  @override
  String get downloadAttachment => 'Скачать';

  @override
  String get previewAttachment => 'Просмотр';

  @override
  String get openAttachment => 'Открыть';

  @override
  String get playVideo => 'Воспроизвести видео';

  @override
  String get pausePlayback => 'Пауза';

  @override
  String get openingAttachment => 'Открытие вложения…';

  @override
  String attachmentSaved(String name) {
    return '$name сохранено';
  }

  @override
  String get couldNotOpenAttachment => 'Не удалось открыть это вложение.';

  @override
  String get attachmentNotPreviewable =>
      'Предпросмотр недоступен для этого типа файла. Вы можете скачать его.';

  @override
  String get copyUsername => 'Копировать имя';

  @override
  String get showPassword => 'Показать пароль';

  @override
  String get hidePassword => 'Скрыть пароль';

  @override
  String get tapToCopy => 'Нажмите, чтобы скопировать';

  @override
  String get edit => 'Изменить';

  @override
  String get delete => 'Удалить';

  @override
  String get cancel => 'Отмена';

  @override
  String get deleteEntry => 'Удалить запись?';

  @override
  String get deleteEntryConfirm =>
      'Пароль будет безвозвратно удалён из хранилища.';

  @override
  String get entryNotFound => 'Запись не найдена';

  @override
  String get entryNotFoundMessage => 'Возможно, этот пароль был удалён.';

  @override
  String get goBack => 'Назад';

  @override
  String get synced => 'Синхронизировано';

  @override
  String get pendingSync => 'Ожидает синхронизации';

  @override
  String revisionLabel(int n) {
    return 'Ревизия $n';
  }

  @override
  String valueCopied(String label) {
    return '$label скопирован';
  }

  @override
  String get vault => 'Хранилище';

  @override
  String get items => 'Элементы';

  @override
  String get itemsHubSubtitle => 'Карты, криптокошельки и секреты.';

  @override
  String get itemsCardsSubtitle => 'Платёжные карты и данные для оплаты';

  @override
  String get itemsCryptoSubtitle => 'Адреса, ключи и seed-фразы';

  @override
  String get itemsSecretsSubtitle => 'SSH-ключи, API-токены и фрагменты .env';

  @override
  String itemsCountLabel(int count) {
    return 'Сохранено: $count';
  }

  @override
  String get wallets => 'Кошельки';

  @override
  String get searchCards => 'Поиск карт';

  @override
  String get noCardsYet => 'Пока нет карт';

  @override
  String get noCardsYetMessage => 'Добавьте карту, чтобы хранить её безопасно.';

  @override
  String get addCard => 'Добавить карту';

  @override
  String get editCard => 'Изменить карту';

  @override
  String get save => 'Сохранить';

  @override
  String get cardDetails => 'Данные карты';

  @override
  String get cardName => 'Название карты';

  @override
  String get cardHolder => 'Владелец';

  @override
  String get cardNumber => 'Номер карты';

  @override
  String get cardExpiry => 'Срок';

  @override
  String get cardCvc => 'CVC';

  @override
  String get copyNumber => 'Копировать номер';

  @override
  String get copyCvc => 'Копировать CVC';

  @override
  String get tapCardToFlip => 'Нажмите на карту, чтобы перевернуть';

  @override
  String get deleteCard => 'Удалить карту?';

  @override
  String get deleteCardConfirm =>
      'Карта будет безвозвратно удалена из кошелька.';

  @override
  String get cardNotFound => 'Карта не найдена';

  @override
  String get cardNotFoundMessage => 'Возможно, эта карта была удалена.';

  @override
  String get bank => 'Банк';

  @override
  String get banks => 'Банки';

  @override
  String get otherBank => 'Другое';

  @override
  String get addBank => 'Добавить банк';

  @override
  String get newBank => 'Новый банк';

  @override
  String get bankName => 'Название банка';

  @override
  String get renameBank => 'Переименовать банк';

  @override
  String get deleteBank => 'Удалить банк?';

  @override
  String get deleteBankConfirm =>
      'Удалить эту группу банка? Карты можно переместить в «Другое».';

  @override
  String get deleteBankAndClear => 'Удалить и снять привязку карт';

  @override
  String get moveToBank => 'Переместить в банк';

  @override
  String get noBanksYet => 'Пока нет банков';

  @override
  String get createBankHint => 'Создайте банк, чтобы упорядочить карты.';

  @override
  String get bankCreated => 'Банк создан';

  @override
  String get cardMoved => 'Карта перемещена';

  @override
  String get emptyBank => 'В этом банке нет карт';

  @override
  String get paymentCards => 'Карты';

  @override
  String get cryptoWallets => 'Крипто';

  @override
  String get searchCryptoWallets => 'Поиск криптокошельков';

  @override
  String get noCryptoWalletsYet => 'Пока нет криптокошельков';

  @override
  String get noCryptoWalletsYetMessage =>
      'Добавьте кошелёк, чтобы хранить ключи безопасно.';

  @override
  String get addCryptoWallet => 'Добавить криптокошелёк';

  @override
  String get editCryptoWallet => 'Изменить криптокошелёк';

  @override
  String get cryptoNetwork => 'Сеть';

  @override
  String get cryptoWalletName => 'Название кошелька';

  @override
  String get walletAddress => 'Адрес';

  @override
  String get privateKey => 'Приватный ключ';

  @override
  String get seedPhrase => 'Seed-фраза';

  @override
  String get cryptoDetails => 'Данные кошелька';

  @override
  String get copyAddress => 'Копировать адрес';

  @override
  String get deleteCryptoWallet => 'Удалить криптокошелёк?';

  @override
  String get deleteCryptoWalletConfirm =>
      'Кошелёк и его секреты будут безвозвратно удалены.';

  @override
  String get cryptoWalletNotFound => 'Криптокошелёк не найден';

  @override
  String get cryptoWalletNotFoundMessage =>
      'Возможно, этот кошелёк был удалён.';

  @override
  String get folders => 'Папки';

  @override
  String get otherFolder => 'Другое';

  @override
  String get addFolder => 'Добавить папку';

  @override
  String get newFolder => 'Новая папка';

  @override
  String get folderName => 'Имя папки';

  @override
  String get renameFolder => 'Переименовать папку';

  @override
  String get deleteFolder => 'Удалить папку?';

  @override
  String get deleteFolderConfirm =>
      'Удалить эту группу папки? Кошельки можно переместить в Другое.';

  @override
  String get deleteFolderAndClear => 'Удалить и снять назначение';

  @override
  String get moveToFolder => 'Переместить в папку';

  @override
  String get noFoldersYet => 'Пока нет папок';

  @override
  String get createFolderHint =>
      'Создайте папку, чтобы упорядочить криптокошельки.';

  @override
  String get folderCreated => 'Папка создана';

  @override
  String get cryptoWalletMoved => 'Кошелёк перемещён';

  @override
  String get emptyFolder => 'В этой папке нет кошельков';

  @override
  String get secrets => 'Секреты';

  @override
  String get searchSecrets => 'Поиск секретов';

  @override
  String get noSecretsYet => 'Пока нет секретов';

  @override
  String get noSecretsYetMessage =>
      'Безопасно храните SSH-ключи, API-токены и фрагменты .env.';

  @override
  String get addSecret => 'Добавить секрет';

  @override
  String get editSecret => 'Изменить секрет';

  @override
  String get secretKind => 'Тип';

  @override
  String get secretKindSsh => 'SSH-ключ';

  @override
  String get secretKindApiToken => 'API-токен';

  @override
  String get secretKindEnv => 'Фрагмент .env';

  @override
  String get secretKindOther => 'Другое';

  @override
  String get secretName => 'Имя';

  @override
  String get secretUsername => 'Имя пользователя';

  @override
  String get secretHost => 'Хост';

  @override
  String get secretEndpoint => 'Конечная точка / URL';

  @override
  String get publicKey => 'Открытый ключ';

  @override
  String get apiToken => 'API-токен';

  @override
  String get envContent => 'Содержимое .env';

  @override
  String get secretValue => 'Секрет';

  @override
  String get passphrase => 'Парольная фраза';

  @override
  String get secretDetails => 'Сведения о секрете';

  @override
  String get copySecret => 'Копировать секрет';

  @override
  String get deleteSecret => 'Удалить секрет?';

  @override
  String get deleteSecretConfirm =>
      'Секрет будет безвозвратно удалён из хранилища.';

  @override
  String get secretNotFound => 'Секрет не найден';

  @override
  String get secretNotFoundMessage => 'Этот секрет мог быть удалён.';

  @override
  String get reverseOrderSecretsSubtitle =>
      'Показывать секреты в обратном порядке.';

  @override
  String get device => 'Устройство';

  @override
  String get devices => 'Устройства';

  @override
  String get otherDevice => 'Другое';

  @override
  String get addDevice => 'Добавить устройство';

  @override
  String get newDevice => 'Новое устройство';

  @override
  String get deviceName => 'Имя устройства';

  @override
  String get renameDevice => 'Переименовать устройство';

  @override
  String get deleteDevice => 'Удалить устройство?';

  @override
  String get deleteDeviceConfirm =>
      'Удалить эту группу устройства? Секреты можно перенести в «Другое».';

  @override
  String get deleteDeviceAndClear => 'Удалить и снять назначение секретов';

  @override
  String get moveToDevice => 'Переместить на устройство';

  @override
  String get noDevicesYet => 'Пока нет устройств';

  @override
  String get createDeviceHint =>
      'Создайте устройство, чтобы упорядочить секреты каждой машины.';

  @override
  String get deviceCreated => 'Устройство создано';

  @override
  String get secretMoved => 'Секрет перемещён';

  @override
  String get emptyDevice => 'На этом устройстве нет секретов';

  @override
  String get faq => 'Частые вопросы';

  @override
  String get faqSubtitle => 'Шифрование, разблокировка, синхронизация';

  @override
  String get faqEncryptionQ => 'Мои данные зашифрованы?';

  @override
  String get faqEncryptionA =>
      'Да. OpenKey шифрует хранилище сквозным шифрованием на этом устройстве. Мастер-пароль и ключ хранилища не покидают устройство в открытом виде.';

  @override
  String get faqForgotPasswordQ => 'Что если я забуду мастер-пароль?';

  @override
  String get faqForgotPasswordA =>
      'Без мастер-пароля восстановление невозможно. Из‑за zero-knowledge шифрования OpenKey не может его сбросить. Храните надёжную резервную копию пароля.';

  @override
  String get faqOfflineQ => 'Работает ли OpenKey офлайн?';

  @override
  String get faqOfflineA =>
      'Да. Хранилище локальное и открывается без сети. Опциональный сервер нужен только для синхронизации и обмена.';

  @override
  String get faqAutoLockQ => 'Как работает автоблокировка?';

  @override
  String get faqAutoLockA =>
      'Если вы свернёте приложение, не закрывая его, OpenKey отсчитывает время отсутствия. После выбранного в Настройках интервала хранилище блокируется; снова нужен мастер-пароль или биометрия. Закрытие приложения сразу завершает сессию.';

  @override
  String get faqBiometricQ => 'Безопасна ли биометрическая разблокировка?';

  @override
  String get faqBiometricA =>
      'Да. Биометрия открывает ключ в защищённом железе устройства. Мастер-пароль не заменяется — им можно открыть хранилище в любой момент.';

  @override
  String get faqSyncQ => 'Что такое синхронизация со своим сервером?';

  @override
  String get faqSyncA =>
      'Вы можете запустить свой сервер OpenKey. Устройства отправляют зашифрованные данные хранилища, чтобы синхронизироваться удалённо. Сервер хранит только шифротекст и не видит секреты в открытом виде. Мастер-пароль остаётся на каждом устройстве.';

  @override
  String get faqBackupQ =>
      'Как работают резервное копирование и восстановление?';

  @override
  String get faqBackupA =>
      'В Настройках → Резервное копирование и восстановление можно сохранить полную копию хранилища на этом устройстве. OpenKey упаковывает базу, настройки и вложения в сжатый файл и шифрует его ключом хранилища (.okbak). Без мастер-пароля файл не прочитать. Восстановление расшифровывает файл и заменяет локальное хранилище копией — храните пароль и файл .okbak в надёжном месте.';

  @override
  String get appName => 'OpenKey';

  @override
  String get copy => 'Копировать';

  @override
  String get create => 'Создать';

  @override
  String get generate => 'Сгенерировать';

  @override
  String get name => 'Имя';

  @override
  String get title => 'Название';

  @override
  String get lock => 'Блокировка';

  @override
  String get all => 'Все';

  @override
  String get entry => 'Запись';

  @override
  String get collection => 'Коллекция';

  @override
  String get searchPasswords => 'Поиск паролей';

  @override
  String get noPasswordsYet => 'Пока нет паролей';

  @override
  String get noPasswordsYetMessage => 'Добавьте запись или создайте коллекцию.';

  @override
  String get newCollection => 'Новая коллекция';

  @override
  String get newEntry => 'Новая запись';

  @override
  String get editEntry => 'Изменить запись';

  @override
  String get chooseFields => 'Поля';

  @override
  String get chooseFieldsSubtitle =>
      'Включайте и отключайте поля, затем перетаскивайте для порядка';

  @override
  String get done => 'Готово';

  @override
  String get phone => 'Телефон';

  @override
  String get pin => 'PIN';

  @override
  String get number => 'Число';

  @override
  String get address => 'Адрес';

  @override
  String get ipAddress => 'IP-адрес';

  @override
  String get dateYmd => 'Дата';

  @override
  String get dateYm => 'Месяц / год';

  @override
  String get recoveryCodes => 'Коды восстановления';

  @override
  String get customText => 'Текст';

  @override
  String get additionalFields => 'Дополнительные поля';

  @override
  String get emptyCollection => 'Пустая коллекция';

  @override
  String get emptyCollectionMessage =>
      'Добавьте запись пароля в эту коллекцию.';

  @override
  String get editCollection => 'Изменить коллекцию';

  @override
  String get deleteCollection => 'Удалить коллекцию';

  @override
  String get deleteCollectionConfirm =>
      'Записи будут убраны из папки (не удалены). Продолжить?';

  @override
  String get chooseIcon => 'Выбрать значок';

  @override
  String get icons => 'Значки';

  @override
  String get brands => 'Бренды';

  @override
  String get suggestedIcon => 'Предложенный значок';

  @override
  String get fromDevice => 'С устройства';

  @override
  String get customIcon => 'Свой значок';

  @override
  String get editIcon => 'Изменить значок';

  @override
  String get cropOrRotate => 'Обрезать / Повернуть';

  @override
  String get rotate => 'Повернуть';

  @override
  String get flip => 'Отразить';

  @override
  String get ratio => 'Соотношение';

  @override
  String get filter => 'Фильтр';

  @override
  String get blur => 'Размытие';

  @override
  String get discardChanges => 'Отменить изменения?';

  @override
  String get discardChangesMessage => 'Ваши правки будут потеряны.';

  @override
  String get discard => 'Отменить';

  @override
  String get undo => 'Отменить';

  @override
  String get redo => 'Повторить';

  @override
  String get more => 'Ещё';

  @override
  String get back => 'Назад';

  @override
  String get preparingImage => 'Подготовка изображения…';

  @override
  String get search => 'Поиск';

  @override
  String get noFolder => 'Без папки';

  @override
  String get folder => 'Папка';

  @override
  String entriesCount(int count) {
    return '$count записей';
  }

  @override
  String get moveTo => 'Переместить';

  @override
  String get moveHere => 'Переместить сюда';

  @override
  String get movingLabel => 'Перемещение';

  @override
  String movingItemsCount(int count) {
    return '$count элементов';
  }

  @override
  String get tags => 'Теги';

  @override
  String get noTags => 'Пока нет тегов';

  @override
  String get noTagsMessage => 'Добавляйте теги при редактировании записи.';

  @override
  String get sortAndFilter => 'Сортировка и фильтр';

  @override
  String get applyToFolders => 'Папки';

  @override
  String get applyToEntries => 'Пароли';

  @override
  String get sortBy => 'Сортировать по';

  @override
  String get options => 'Параметры';

  @override
  String get sortByCreationTime => 'По дате создания';

  @override
  String get sortByLastModified => 'По последнему изменению';

  @override
  String get sortByName => 'По имени';

  @override
  String get sortByCustomOrder => 'Свой порядок';

  @override
  String get reverseOrder => 'Обратный порядок';

  @override
  String get reverseOrderFoldersSubtitle =>
      'Показывать папки в обратном порядке.';

  @override
  String get reverseOrderEntriesSubtitle =>
      'Показывать пароли в обратном порядке.';

  @override
  String get reverseOrderCardsSubtitle =>
      'Показывать карты в обратном порядке.';

  @override
  String get reverseOrderCryptoSubtitle =>
      'Показывать кошельки в обратном порядке.';

  @override
  String get addTagHint => 'Добавить тег';

  @override
  String deleteSelectedConfirm(int count) {
    return 'Удалить выбранные элементы ($count)?';
  }

  @override
  String get totpSecretLabel => 'Секрет TOTP / otpauth';

  @override
  String get scanTotpQr => 'Сканировать QR-код';

  @override
  String get scanTotpQrHint => 'Наведите камеру на QR-код аутентификатора';

  @override
  String get invalidTotpQr =>
      'Этот QR-код не является действительным кодом TOTP';

  @override
  String get cameraPermissionDenied =>
      'Для сканирования QR-кодов требуется доступ к камере';

  @override
  String get storePasskeyMetadata => 'Ключ доступа';

  @override
  String get passkeyCreatedInBrowser =>
      'Создавайте ключи через расширение OpenKey или автозаполнение / поставщик учётных данных на мобильном при разблокированном OpenKey.';

  @override
  String get rpId => 'RP ID';

  @override
  String get credentialId => 'ID учётных данных';

  @override
  String get addPasskeyItem => 'Ключа пока нет';

  @override
  String bytesLabel(int n) {
    return '$n байт';
  }

  @override
  String get addEncryptedAttachment => 'Добавить зашифрованное вложение';

  @override
  String get expiryHint => 'ММ/ГГ';

  @override
  String get autoLockSubtitle =>
      'Блокировать хранилище после выхода из приложения.';

  @override
  String get serverUrl => 'URL сервера';

  @override
  String get serverUrlHint => 'https://openkey.example.com';

  @override
  String get serverSheetSubtitle =>
      'Зарегистрируйтесь или войдите, чтобы синхронизировать только шифротекст хранилища.';

  @override
  String get register => 'Регистрация';

  @override
  String get registerSubtitle => 'Создать учётную запись на этом сервере';

  @override
  String get login => 'Вход';

  @override
  String get loginSubtitle => 'Войти с хешем аутентификации этого хранилища';

  @override
  String get syncNow => 'Синхронизировать';

  @override
  String get syncing => 'Синхронизация…';

  @override
  String get syncSubtitle => 'Отправка и получение зашифрованных изменений';

  @override
  String get syncComplete => 'Синхронизация завершена';

  @override
  String get extensionLinkCopied => 'Данные ссылки расширения скопированы';

  @override
  String get biometricUnlockEnabled => 'Биометрическая разблокировка включена';

  @override
  String get biometricUnlockDisabled =>
      'Биометрическая разблокировка отключена';

  @override
  String biometricsUpdateFailed(String error) {
    return 'Не удалось обновить биометрию: $error';
  }

  @override
  String get bitwardenJson => 'Bitwarden JSON';

  @override
  String get bitwardenJsonSubtitle => 'Экспорт из Bitwarden → импорт сюда';

  @override
  String get openKeyJson => 'OpenKey JSON';

  @override
  String get openKeyJsonSubtitle =>
      'Резервная копия, экспортированная из OpenKey';

  @override
  String get chromeCsv => 'Chrome CSV';

  @override
  String get chromeCsvSubtitle => 'Пароли, экспортированные из Chrome';

  @override
  String get lastPassCsv => 'LastPass CSV';

  @override
  String get lastPassCsvSubtitle => 'CSV-экспорт из LastPass';

  @override
  String get keePassKdbx => 'KeePass (.kdbx)';

  @override
  String get keePassKdbxSubtitle => 'Зашифрованная база KeePass / KeePassXC';

  @override
  String get keePassPasswordHint => 'Пароль базы данных';

  @override
  String get keePassKeyFile => 'Ключевой файл (необязательно)';

  @override
  String get keePassUnlockFailed =>
      'Не удалось открыть базу KeePass. Проверьте пароль и ключевой файл.';

  @override
  String get onePasswordCsv => '1Password CSV';

  @override
  String get onePasswordCsvSubtitle => 'CSV-экспорт из 1Password';

  @override
  String get importingPasswords => 'Импорт…';

  @override
  String importingProgress(int done, int total) {
    return 'Импорт $done из $total…';
  }

  @override
  String importedItems(int n) {
    return 'Импортировано элементов: $n';
  }

  @override
  String get failureUnknown => 'Что-то пошло не так.';

  @override
  String get failureNetwork => 'Ошибка сети. Проверьте подключение.';

  @override
  String get failureUnauthorized => 'Нет доступа. Войдите снова.';

  @override
  String get failureNotFound => 'Не найдено.';

  @override
  String get failureServer => 'Ошибка сервера.';

  @override
  String get failureInvalidCredentials => 'Неверный email или мастер-пароль.';

  @override
  String get failureVaultLocked => 'Хранилище заблокировано.';

  @override
  String get failureVaultAlreadyExists =>
      'Хранилище на этом устройстве уже есть.';

  @override
  String get failureDecryptionFailed =>
      'Не удалось расшифровать данные хранилища.';

  @override
  String get failureSyncFailed => 'Синхронизация не удалась.';

  @override
  String get failureCreateCollection => 'Не удалось создать коллекцию.';

  @override
  String get failureUpdateCollection => 'Не удалось обновить коллекцию.';

  @override
  String get failureDeleteCollection => 'Не удалось удалить коллекцию.';

  @override
  String get failureGetCollections => 'Не удалось загрузить коллекции.';

  @override
  String get failureCreateEntry => 'Не удалось создать запись.';

  @override
  String get failureUpdateEntry => 'Не удалось обновить запись.';

  @override
  String get failureDeleteEntry => 'Не удалось удалить запись.';

  @override
  String get failureGetEntries => 'Не удалось загрузить записи.';

  @override
  String get failureNoVault => 'Хранилище не найдено. Сначала создайте его.';

  @override
  String get failureConnectServerFirst =>
      'Сначала подключите сервер в Настройках.';

  @override
  String get failureAttachmentTooLarge => 'Вложение превышает лимит 20 МБ.';

  @override
  String get failureAttachmentMissing => 'Отсутствует шифротекст вложения.';

  @override
  String get failureAccountEmailExists =>
      'У этого адреса уже есть хранилище на этом устройстве.';

  @override
  String get root => 'Корень';

  @override
  String get selectedItems => 'выбрано';

  @override
  String get authenticatorTotp => 'Аутентификатор (TOTP)';

  @override
  String get openKeyPro => 'OpenKey Pro';

  @override
  String get proSubtitle =>
      'Разблокируйте премиум-функции и поддержите разработку OpenKey.';

  @override
  String get premiumFeatureTitle => 'Премиум-функция';

  @override
  String get premiumFeatureSubtitle =>
      'Оформите подписку, чтобы разблокировать эту премиум-функцию.';

  @override
  String get premiumFeatureContent =>
      'Это премиум-функция. Оформите подписку для доступа.';

  @override
  String get premiumBadge => 'Pro';

  @override
  String get subscribe => 'Подписаться';

  @override
  String get upgradeNow => 'Улучшить сейчас';

  @override
  String get oops => 'Ой!';

  @override
  String get subscription => 'Подписка';

  @override
  String get subscriptionTitle => 'Подписка';

  @override
  String get subscriptionSubtitle => 'Выберите подходящий тариф.';

  @override
  String get manageYourSubscription => 'Управление подпиской';

  @override
  String get manageSubscriptionAction => 'Управлять подпиской';

  @override
  String get subIsActiveTitle => 'Ваша подписка активна';

  @override
  String get subIsNotActiveTitle => 'Ваша подписка неактивна';

  @override
  String get thanksForSubscribing => 'Спасибо за подписку!';

  @override
  String get subIsCancelled => 'Подписка отменена и не будет продлена.';

  @override
  String get subIsPaused => 'Ваша подписка приостановлена.';

  @override
  String get restorePurchase => 'Восстановить покупку';

  @override
  String get viewPlansPaywall => 'Посмотреть варианты подписки';

  @override
  String get openCustomerCenter => 'Управлять в Центре клиентов';

  @override
  String get subscriptionDesktopNote =>
      'Встроенные покупки доступны на Android, iOS и macOS. В Windows и Linux войдите с тем же аккаунтом OpenKey, чтобы разблокировать Pro после подписки на телефоне или Mac.';

  @override
  String get subscriptionRefreshStatus => 'Обновить статус подписки';

  @override
  String get subscriptionNoInternetMsg =>
      'Проблема с подключением к интернету. Проверьте сеть и попробуйте снова.';

  @override
  String get subscriptionRegionBlockedMsg =>
      'Сервисы подписки недоступны в вашем регионе. Подключитесь к VPN и попробуйте снова.';

  @override
  String get monthly => 'Ежемесячно';

  @override
  String get yearly => 'Ежегодно';

  @override
  String get lifetime => 'Навсегда';

  @override
  String get monthlySubtitle => 'Автопродление, отмена в любой момент';

  @override
  String get yearlySubtitle =>
      'Автопродление, лучшая цена, отмена в любой момент';

  @override
  String get lifetimeSubtitle => 'Разовая покупка, ваше навсегда';

  @override
  String monthlyPriceLabel(String price) {
    return '$price/мес.';
  }

  @override
  String yearlyPriceLabel(String price) {
    return '$price/год';
  }

  @override
  String lifetimePriceLabel(String price) {
    return '$price';
  }

  @override
  String monthlySubscribeLabel(String price) {
    return 'Подписка за $price / месяц';
  }

  @override
  String yearlySubscribeLabel(String price) {
    return 'Подписка за $price / год';
  }

  @override
  String lifetimeSubscribeLabel(String price) {
    return 'Купить навсегда за $price';
  }

  @override
  String get bestValue => 'Лучшая цена';

  @override
  String get skip => 'Пропустить';

  @override
  String get getStarted => 'Начать';

  @override
  String get onboardingFaqTitle => 'Узнайте перед стартом';

  @override
  String get onboardingFaqSubtitle =>
      'Самые частые вопросы об OpenKey. Нажмите, чтобы раскрыть — затем создайте хранилище.';

  @override
  String get onboardingNext => 'Далее';

  @override
  String get onboardingWelcomeTitle => 'Ваши ключи. Ваше хранилище.';

  @override
  String get onboardingWelcomeSubtitle =>
      'OpenKey хранит пароли, коды и карты в одном зашифрованном месте — для повседневного использования.';

  @override
  String get onboardingWelcomePhrase1 => 'Нулевое знание по замыслу';

  @override
  String get onboardingWelcomePhrase2 => 'Автозаполнение в одно касание';

  @override
  String get onboardingWelcomePhrase3 => 'Свой сервер, когда нужно';

  @override
  String get onboardingSecurityTitle => 'Никто другой не прочитает';

  @override
  String get onboardingSecuritySubtitle =>
      'Сквозное шифрование означает, что мастер-пароль никогда не покидает это устройство. Мы храним только шифротекст.';

  @override
  String get onboardingAutofillTitle => 'Заполните один раз. Доверяйте всегда.';

  @override
  String get onboardingAutofillSubtitle =>
      'Входите в приложения и сайты без поиска паролей. Автозаполнение делает OpenKey частью каждого дня.';

  @override
  String get onboardingAllInOneTitle => 'Одно приложение. Всё хранилище.';

  @override
  String get onboardingAllInOneSubtitle =>
      'Пароли, коды аутентификатора, карты, криптокошельки и секреты разработчика — замените хаос одним надёжным хранилищем.';

  @override
  String get onboardingFeaturePasswords => 'Пароли';

  @override
  String get onboardingFeatureCrypto => 'Крипто';

  @override
  String get onboardingFeatureAutofill => 'Автозаполнение';

  @override
  String get onboardingFeatureSelfHost => 'Свой сервер.';

  @override
  String get onboardingFooterHint =>
      'Менее минуты. Можно пропустить в любой момент.';

  @override
  String get onboardingLetsGo => 'Поехали!';

  @override
  String onboardingStepOf(int current, int total) {
    return 'Шаг $current из $total';
  }

  @override
  String get onboardingWelcomeHeadline => 'Добро пожаловать\nв OpenKey.';

  @override
  String get onboardingWelcomeLead => 'Давайте всё настроим';

  @override
  String get onboardingEcosystemTitle => 'Ваше\nполное\nхранилище.';

  @override
  String get onboardingEcosystemSubtitle =>
      'Пароли, коды и карты — зашифрованы и готовы при любом входе.';

  @override
  String get onboardingStyleTitle => 'Оформите\nпо-своему.';

  @override
  String get onboardingEnableAutofillTitle => 'Включите\nавтозаполнение.';

  @override
  String get onboardingAutofillCardTitle => 'Автозаполнение паролей';

  @override
  String get onboardingAutofillCardSubtitle =>
      'Заполняйте входы в приложениях и на сайтах из хранилища.';

  @override
  String get onboardingAutofillGranted => 'Автозаполнение готово';

  @override
  String get onboardingFinishBadge => 'Настройка завершена';

  @override
  String get onboardingFinishTitle => 'Готово\nк защите.';

  @override
  String get onboardingFinishSubtitle =>
      'Создайте мастер-пароль и начните сохранять важное — хранилище в одном шаге.';

  @override
  String get onboardingCreateVault => 'Создать хранилище';

  @override
  String get errorLoadingData => 'Ошибка загрузки данных. Попробуйте снова.';

  @override
  String get retryAgain => 'Повторить';

  @override
  String get autoRenewLabel => 'Автопродление';

  @override
  String get cancelledLabel => 'Отменена';

  @override
  String get pausedLabel => 'Приостановлена';

  @override
  String get supportAppDevelopmentTitle => 'Поддержать разработку';

  @override
  String get supportAppDevelopmentSubtitle =>
      'Ваша подписка помогает нам улучшать OpenKey.';

  @override
  String get limitEntriesTitle => 'Достигнут лимит записей';

  @override
  String get limitCollectionsTitle => 'Достигнут лимит коллекций';

  @override
  String get limitWalletsTitle => 'Достигнут лимит карт';

  @override
  String get limitCryptoWalletsTitle => 'Достигнут лимит криптокошельков';

  @override
  String get limitSecretsTitle => 'Достигнут лимит секретов';

  @override
  String limitReachedContent(int usage, int limit, String feature) {
    return 'Использовано $usage из $limit $feature. Перейдите на Pro для безлимитного доступа.';
  }

  @override
  String limitSubtitle(int limit, String feature) {
    return 'Бесплатный план включает до $limit $feature.';
  }

  @override
  String get entries => 'записей';

  @override
  String get collections => 'коллекций';

  @override
  String get cards => 'карт';

  @override
  String get cryptoWalletsFeature => 'криптокошельков';

  @override
  String get secretsFeature => 'секретов';

  @override
  String expiresOn(String date) {
    return 'Истекает $date';
  }

  @override
  String get unlockUnlimitedEntriesTitle => 'Безлимитные записи';

  @override
  String get unlockUnlimitedEntriesSubtitle =>
      'Храните столько паролей и логинов, сколько нужно.';

  @override
  String get unlockUnlimitedCollectionsTitle => 'Безлимитные коллекции';

  @override
  String get unlockUnlimitedCollectionsSubtitle =>
      'Организуйте хранилище любым числом папок.';

  @override
  String get unlockUnlimitedWalletsTitle => 'Безлимитные карты';

  @override
  String get unlockUnlimitedWalletsSubtitle =>
      'Сохраняйте столько платёжных карт, сколько нужно.';

  @override
  String get unlockUnlimitedCryptoWalletsTitle => 'Безлимитные криптокошельки';

  @override
  String get unlockUnlimitedCryptoWalletsSubtitle =>
      'Храните адреса, ключи и seed-фразы без ограничений.';

  @override
  String get unlockUnlimitedSecretsTitle => 'Безлимитные секреты разработчика';

  @override
  String get unlockUnlimitedSecretsSubtitle =>
      'Храните SSH-ключи, API-токены и фрагменты .env без ограничений.';

  @override
  String get unlockSyncTitle => 'Синхронизация с сервером';

  @override
  String get unlockSyncSubtitle =>
      'Подключите свой сервер и синхронизируйте устройства.';

  @override
  String get unlockAttachmentsTitle => 'Вложения';

  @override
  String get unlockAttachmentsSubtitle =>
      'Прикрепляйте зашифрованные файлы к записям хранилища.';

  @override
  String get unlockImportExportTitle => 'Импорт и экспорт';

  @override
  String get unlockImportExportSubtitle =>
      'Переносите данные в OpenKey и из него.';

  @override
  String get unknownFailureMsg => 'Произошла неизвестная ошибка.';

  @override
  String get purchaseCancelledMsg => 'Покупка была отменена.';

  @override
  String get storeProblemMsg => 'Возникла проблема с магазином.';

  @override
  String get purchaseNotAllowedMsg =>
      'Покупки на этом устройстве не разрешены.';

  @override
  String get purchaseInvalidMsg => 'Покупка недействительна.';

  @override
  String get productNotAvailableForPurchaseMsg =>
      'Этот продукт недоступен для покупки.';

  @override
  String get productAlreadyPurchasedMsg => 'Этот продукт уже куплен.';

  @override
  String get receiptAlreadyInUseMsg => 'Этот чек уже используется.';

  @override
  String get invalidReceiptMsg => 'Чек недействителен.';

  @override
  String get missingReceiptFileMsg => 'Файл чека отсутствует.';

  @override
  String get networkErrorMsg =>
      'Произошла сетевая ошибка. Проверьте соединение.';

  @override
  String get invalidCredentialsMsg => 'Неверные учётные данные.';

  @override
  String get unexpectedBackendResponseMsg => 'Неожиданный ответ сервера.';

  @override
  String get receiptInUseByOtherSubscriberMsg =>
      'Чек используется другим подписчиком.';

  @override
  String get invalidAppUserIdMsg =>
      'Недействительный ID пользователя приложения.';

  @override
  String get operationAlreadyInProgressMsg => 'Операция уже выполняется.';

  @override
  String get unknownBackendErrorMsg =>
      'На сервере произошла неизвестная ошибка.';

  @override
  String get invalidAppleSubscriptionKeyMsg =>
      'Недействительный ключ подписки Apple.';

  @override
  String get ineligibleMsg => 'Вы не можете совершить эту покупку.';

  @override
  String get insufficientPermissionsMsg => 'Недостаточно прав.';

  @override
  String get paymentPendingMsg => 'Платёж ожидает обработки.';

  @override
  String get invalidSubscriberAttributesMsg =>
      'Недействительные атрибуты подписчика.';

  @override
  String get logOutWithAnonymousUserMsg =>
      'Нельзя выйти из анонимной учётной записи.';

  @override
  String get configurationErrorMsg => 'Ошибка конфигурации.';

  @override
  String get unsupportedErrorMsg => 'Операция не поддерживается.';

  @override
  String get emptySubscriberAttributesMsg => 'Атрибуты подписчика пусты.';

  @override
  String get productDiscountMissingIdentifierMsg =>
      'Отсутствует идентификатор скидки продукта.';

  @override
  String get unknownNonNativeErrorMsg =>
      'Произошла неизвестная ненативная ошибка.';

  @override
  String get productDiscountMissingSubscriptionGroupIdentifierMsg =>
      'Отсутствует идентификатор группы подписки скидки.';

  @override
  String get customerInfoErrorMsg => 'Не удалось получить сведения о клиенте.';

  @override
  String get systemInfoErrorMsg => 'Не удалось получить сведения о системе.';

  @override
  String get beginRefundRequestErrorMsg =>
      'Не удалось начать запрос на возврат.';

  @override
  String get productRequestTimeoutMsg => 'Время запроса продукта истекло.';

  @override
  String get apiEndpointBlockedMsg => 'Конечная точка API заблокирована.';

  @override
  String get invalidPromotionalOfferMsg => 'Промопредложение недействительно.';

  @override
  String get offlineConnectionMsg =>
      'Нет подключения к интернету. Подключитесь и попробуйте снова.';

  @override
  String get featureNotAvailableInCustomEntitlementsComputationModeMsg =>
      'Эта функция недоступна в режиме пользовательского расчёта прав.';

  @override
  String get signatureVerificationFailedMsg => 'Проверка подписи не удалась.';

  @override
  String get featureNotSupportedWithStoreKit1Msg =>
      'Эта функция не поддерживается со StoreKit 1.';

  @override
  String get invalidWebPurchaseTokenMsg =>
      'Недействительный веб-токен покупки.';

  @override
  String get purchaseBelongsToOtherUserMsg =>
      'Эта покупка принадлежит другому пользователю.';

  @override
  String get expiredWebPurchaseTokenMsg =>
      'Срок действия веб-токена покупки истёк.';

  @override
  String get testStoreSimulatedPurchaseErrorMsg =>
      'Ошибка имитации покупки тестового магазина.';

  @override
  String get aboutApp => 'О приложении';

  @override
  String get aboutAppSubtitle => 'Узнайте больше об OpenKey и его разработке.';

  @override
  String get developerName => 'OpenSelfHosting';

  @override
  String get developer => 'ПО с открытым кодом, которое вы размещаете сами';

  @override
  String rateUsIn(String storeName) {
    return 'Оцените нас в $storeName';
  }

  @override
  String get doYouLikeTheAppRateUs => 'Нравится приложение? Оцените нас!';

  @override
  String get licenses => 'Лицензии';

  @override
  String get openLicenses => 'Открыть лицензии';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get privacyPolicySubtitle =>
      'Прочитать нашу политику конфиденциальности';

  @override
  String get termsOfService => 'Условия использования';

  @override
  String get termsOfServiceSubtitle => 'Прочитать наши условия использования';

  @override
  String get pricing => 'Цены';

  @override
  String get pricingSubtitle => 'Бесплатный план и OpenKey Pro';

  @override
  String get copied => 'Скопировано в буфер обмена';

  @override
  String get contact => 'Контакты';

  @override
  String get contactSubtitle => 'Свяжитесь с нами для поддержки или отзывов.';

  @override
  String get telegram => 'Telegram';

  @override
  String get ok => 'OK';

  @override
  String get localBackupRestoreTitle =>
      'Резервное копирование и восстановление';

  @override
  String get localBackupRestoreSubtitle =>
      'Создайте зашифрованную полную копию хранилища (.okbak) или восстановите её. Включает базу, настройки и вложения.';

  @override
  String get exportBackup => 'Экспорт копии';

  @override
  String get exportBackupSubtitleEmpty =>
      'Создайте зашифрованную локальную копию и выберите, куда её сохранить.';

  @override
  String exportBackupSubtitleLatest(String path) {
    return 'Последний экспорт: $path';
  }

  @override
  String get importBackup => 'Восстановить копию';

  @override
  String get importBackupSubtitle =>
      'Замените это хранилище зашифрованной копией OpenKey (.okbak).';

  @override
  String get confirmRestore => 'Подтвердить восстановление';

  @override
  String get confirmRestoreMessage =>
      'Восстановление заменяет локальную базу, настройки и вложения копией. Введите мастер-пароль этой копии, чтобы расшифровать её.';

  @override
  String get creatingBackup => 'Создание копии…';

  @override
  String get creatingBackupBody => 'Сжатие и шифрование всего хранилища.';

  @override
  String get restoringBackupProgress => 'Восстановление копии…';

  @override
  String get restoringBackupBody => 'Расшифровка и восстановление хранилища.';

  @override
  String get restoringBackupVerifying => 'Проверка мастер-пароля…';

  @override
  String get restoringBackupDecrypting => 'Расшифровка данных копии…';

  @override
  String get restoringBackupWriting => 'Запись восстановленного хранилища…';

  @override
  String get restoringBackupUnlocking => 'Открытие восстановленного хранилища…';

  @override
  String get backupComplete => 'Копия создана';

  @override
  String get backupCompleteLocalBody =>
      'Зашифрованная копия успешно сохранена.';

  @override
  String get backupCompleteLocalDetail =>
      'Храните этот файл в надёжном месте. Для восстановления нужен мастер-пароль.';

  @override
  String get backupError => 'Ошибка резервного копирования';

  @override
  String get restoreCompleted => 'Восстановление завершено';

  @override
  String get restoreCompletedBody =>
      'Хранилище восстановлено из зашифрованной копии.';
}
