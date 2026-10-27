import 'package:get_it/get_it.dart';
import 'package:openkey_app/src/src.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  final prefsAdapter = SharedPreferencesAdapter(prefs);

  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerSingleton<SharedPreferencesLike>(prefsAdapter);
  final metadataStore = VaultMetadataStore(prefsAdapter);
  await metadataStore.ensureLoaded();
  sl.registerSingleton<VaultMetadataStore>(metadataStore);
  sl.registerSingleton<CryptoService>(CryptoService());
  sl.registerSingleton<VaultSession>(VaultSession());
  sl.registerSingleton<DatabaseManager>(DatabaseManager());
  sl.registerSingleton<ApiClient>(ApiClient());
  sl.registerSingleton<TotpService>(TotpService());
  final biometric = BiometricUnlockService(metadata: metadataStore);
  sl.registerSingleton<BiometricUnlockService>(biometric);
  await biometric.migrateLegacyIfNeeded();
  sl.registerSingleton<ScreenshotProtectionService>(
    ScreenshotProtectionService(),
  );
  sl.registerSingleton<AppReviewService>(AppReviewService(prefsAdapter));

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<VaultRemoteDataSource>(
    () => VaultRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl(), sl(), sl(), sl(), sl()),
  );
  sl.registerLazySingleton<CollectionRepository>(
    () => CollectionRepositoryImpl(sl(), sl(), sl()),
  );
  sl.registerLazySingleton<EntryRepository>(
    () => EntryRepositoryImpl(sl(), sl(), sl()),
  );
  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(sl(), sl(), sl()),
  );
  sl.registerLazySingleton<CryptoRepository>(
    () => CryptoRepositoryImpl(sl(), sl(), sl()),
  );
  sl.registerLazySingleton<SecretsRepository>(
    () => SecretsRepositoryImpl(sl(), sl(), sl()),
  );

  sl.registerLazySingleton(() => SetupVaultUsecase(sl()));
  sl.registerLazySingleton(() => UnlockVaultUsecase(sl()));
  sl.registerLazySingleton(() => UnlockWithVaultKeyUsecase(sl()));
  sl.registerLazySingleton(() => LockVaultUsecase(sl()));
  sl.registerLazySingleton(() => ResetLocalVaultUsecase(sl()));
  sl.registerLazySingleton(() => RestoreVaultFromServerUsecase(sl()));
  sl.registerLazySingleton(() => RegisterServerUsecase(sl()));
  sl.registerLazySingleton(() => LoginServerUsecase(sl()));

  sl.registerLazySingleton(() => GetCollectionsUsecase(sl()));
  sl.registerLazySingleton(() => WatchCollectionsUsecase(sl()));
  sl.registerLazySingleton(() => CreateCollectionUsecase(sl()));
  sl.registerLazySingleton(() => UpdateCollectionUsecase(sl()));
  sl.registerLazySingleton(() => MoveCollectionsUsecase(sl()));
  sl.registerLazySingleton(() => DeleteCollectionUsecase(sl()));

  sl.registerLazySingleton(() => GetEntriesUsecase(sl()));
  sl.registerLazySingleton(() => WatchEntriesUsecase(sl()));
  sl.registerLazySingleton(() => GetEntryUsecase(sl()));
  sl.registerLazySingleton(() => CreateEntryUsecase(sl(), sl()));
  sl.registerLazySingleton(() => UpdateEntryUsecase(sl()));
  sl.registerLazySingleton(() => MoveEntriesUsecase(sl()));
  sl.registerLazySingleton(() => DeleteEntryUsecase(sl()));

  sl.registerLazySingleton(() => AttachmentService(sl(), sl(), sl(), sl()));
  sl.registerLazySingleton(
    () => SyncService(sl(), sl(), sl(), sl(), sl(), sl(), sl()),
  );
  sl.registerLazySingleton(() => ImportService(sl(), sl(), sl()));
  sl.registerLazySingleton(() => ExportService(sl(), sl()));
  sl.registerLazySingleton(
    () => BackupRestoreService(
      databaseManager: sl(),
      session: sl(),
      metadata: sl(),
      crypto: sl(),
      preferences: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => NativeMessagingHost(
      session: sl(),
      entries: sl(),
      wallets: sl(),
      crypto: sl(),
      secrets: sl(),
      collections: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => AutofillBridge(session: sl(), entries: sl(), metadata: sl()),
  );

  sl.registerLazySingleton(
    () => AuthBloc(sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl()),
  );
  // Singletons so lock/reset can cancel the same watch subscriptions used by UI.
  sl.registerLazySingleton(
    () => CollectionBloc(sl(), sl(), sl(), sl(), sl(), sl()),
  );
  sl.registerLazySingleton(() => EntryBloc(sl(), sl(), sl(), sl(), sl(), sl()));
  sl.registerLazySingleton(() => WalletBloc(sl(), sl(), sl()));
  sl.registerLazySingleton(() => CryptoBloc(sl(), sl(), sl()));
  sl.registerLazySingleton(() => SecretsBloc(sl(), sl(), sl()));
  sl.registerLazySingleton(() => SettingsCubit(sl(), sl()));
}
