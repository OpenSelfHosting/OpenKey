import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@lazySingleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
    this._setupVault,
    this._unlockVault,
    this._unlockWithKey,
    this._lockVault,
    this._resetLocalVault,
    this._restoreFromServer,
    this._registerServer,
    this._loginServer,
    this._authRepository,
  ) : super(
        AuthState.initial(
          _authRepository.hasVault,
          email: _authRepository.email,
          passwordHint: sl<VaultMetadataStore>().passwordHint,
          accounts: _authRepository.accounts,
          activeAccountId: _authRepository.activeAccountId,
          avatarPath: sl<VaultMetadataStore>().activeAccount?.avatarPath,
        ),
      ) {
    on<AuthStarted>(_onStarted);
    on<AuthSetupRequested>(_onSetup);
    on<AuthUnlockRequested>(_onUnlock);
    on<AuthBiometricUnlockRequested>(_onBiometricUnlock);
    on<AuthLockRequested>(_onLock);
    on<AuthResetLocalVaultRequested>(_onResetLocalVault);
    on<AuthRestoreFromServerRequested>(_onRestoreFromServer);
    on<AuthRegisterServerRequested>(_onRegisterServer);
    on<AuthLoginServerRequested>(_onLoginServer);
    on<AuthRestoreFromBackupRequested>(_onRestoreFromBackup);
    on<AuthSwitchAccountRequested>(_onSwitchAccount);
    on<AuthRemoveAccountRequested>(_onRemoveAccount);
    on<AuthAccountsChanged>(_onAccountsChanged);
    on<AuthAddAccountRequested>(_onAddAccount);
    on<AuthAddAccountCancelled>(_onAddAccountCancelled);
  }

  final SetupVaultUsecase _setupVault;
  final UnlockVaultUsecase _unlockVault;
  final UnlockWithVaultKeyUsecase _unlockWithKey;
  final LockVaultUsecase _lockVault;
  final ResetLocalVaultUsecase _resetLocalVault;
  final RestoreVaultFromServerUsecase _restoreFromServer;
  final RegisterServerUsecase _registerServer;
  final LoginServerUsecase _loginServer;
  final AuthRepository _authRepository;

  /// Reloads per-account settings and icon caches.
  Future<void> _rehydrateAccountScopedState() async {
    if (sl.isRegistered<SettingsCubit>()) {
      await sl<SettingsCubit>().hydrate();
    }
    CustomIcons.clearDecodeCache();
    FaviconFetcher.clearMemory();
    AppIconFetcher.clearMemory();
  }

  Future<void> _awaitLockStep(String name, Future<void> Function() run) async {
    okDebugLog('[add-account] $name start');
    final sw = Stopwatch()..start();
    try {
      await run().timeout(const Duration(seconds: 8));
      okDebugLog('[add-account] $name ok (${sw.elapsedMilliseconds}ms)');
    } catch (e, st) {
      okDebugLog(
        '[add-account] $name failed after ${sw.elapsedMilliseconds}ms: $e\n$st',
      );
    }
  }

  Future<void> _performLock({bool traced = false}) async {
    if (!traced) {
      await sl<NativeMessagingHost>().stop();
      await sl<AutofillBridge>().clearCredentials();
      await _stopVaultWatchers();
      await _lockVault();
      return;
    }
    await _awaitLockStep('nativeMessaging.stop', () async {
      await sl<NativeMessagingHost>().stop();
    });
    await _awaitLockStep('autofill.clear', () async {
      await sl<AutofillBridge>().clearCredentials();
    });
    await _awaitLockStep('watchers.stop', _stopVaultWatchers);
    await _awaitLockStep('vault.lock', () async {
      await _lockVault();
    });
  }

  void _onStarted(AuthStarted event, Emitter<AuthState> emit) {
    emit(
      _withAccounts(
        AuthState.initial(
          _authRepository.hasVault,
          email: _authRepository.email,
          passwordHint: sl<VaultMetadataStore>().passwordHint,
        ),
      ),
    );
  }

  AuthState _withAccounts(AuthState next) {
    final meta = sl<VaultMetadataStore>();
    return next.copyWith(
      hasVault: _authRepository.hasVault,
      email: _authRepository.email ?? next.email,
      accounts: meta.accounts,
      activeAccountId: meta.activeAccountId,
      avatarPath: meta.activeAccount?.avatarPath,
      clearAvatar: meta.activeAccount?.avatarPath == null,
    );
  }

  Future<void> _onSetup(
    AuthSetupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _setupVault(
      SetupVaultParams(
        email: event.email,
        masterPassword: event.masterPassword,
        passwordHint: event.passwordHint,
      ),
    );
    await result.fold(
      (f) async => emit(state.copyWith(status: AuthStatus.failure, error: f)),
      (_) async {
        var serverConnected = false;
        AppFailure? serverError;
        final serverUrl = event.serverUrl?.trim();
        if (serverUrl != null && serverUrl.isNotEmpty) {
          final linked = await _registerServer(serverUrl);
          linked.fold((f) => serverError = f, (_) => serverConnected = true);
        }

        await sl<NativeMessagingHost>().start();
        await sl<AutofillBridge>().syncCredentials();
        if (serverConnected) {
          unawaited(sl<SyncService>().syncIfConnected());
        }
        await _rehydrateAccountScopedState();

        final hint = event.passwordHint?.trim();

        // Local vault always succeeds; optional server link is best-effort.
        // Surface link errors without blocking entry to the vault.
        emit(
          _withAccounts(
            state.copyWith(
              status: AuthStatus.unlocked,
              hasVault: true,
              email: event.email.trim().toLowerCase(),
              failedUnlockAttempts: 0,
              passwordHint: (hint == null || hint.isEmpty) ? null : hint,
              clearPasswordHint: hint == null || hint.isEmpty,
              serverConnected: serverConnected,
              error: serverError,
              clearError: serverError == null,
              addingAccount: false,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onUnlock(
    AuthUnlockRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _unlockVault(event.masterPassword);
    await result.fold(
      (f) async => emit(
        state.copyWith(
          status: AuthStatus.failure,
          error: f,
          failedUnlockAttempts: state.failedUnlockAttempts + 1,
          passwordHint: sl<VaultMetadataStore>().passwordHint,
        ),
      ),
      (_) async {
        await sl<NativeMessagingHost>().start();
        await sl<AutofillBridge>().syncCredentials();
        _startVaultWatchers();

        emit(
          _withAccounts(
            state.copyWith(
              status: AuthStatus.unlocked,
              hasVault: true,
              email: _authRepository.email,
              failedUnlockAttempts: 0,
              addingAccount: false,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onBiometricUnlock(
    AuthBiometricUnlockRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final s = lookupAppLocalizations(sl<SettingsCubit>().state.locale.locale);
    final payload = await sl<BiometricUnlockService>().unlockWithBiometrics(
      s: s,
    );
    if (payload == null) {
      // Cancel or failed auth — stay on unlock without a hard error snackbar.
      emit(
        state.copyWith(
          status: AuthStatus.locked,
          hasVault: true,
          clearError: true,
        ),
      );
      return;
    }
    final result = await _unlockWithKey(
      UnlockWithVaultKeyParams(
        vaultKey: payload.vaultKey,
        authHash: payload.authHash,
      ),
    );
    await result.fold(
      (f) async => emit(
        state.copyWith(
          status: AuthStatus.failure,
          error: f,
          failedUnlockAttempts: state.failedUnlockAttempts + 1,
        ),
      ),
      (_) async {
        await sl<NativeMessagingHost>().start();
        await sl<AutofillBridge>().syncCredentials();
        _startVaultWatchers();

        emit(
          _withAccounts(
            state.copyWith(
              status: AuthStatus.unlocked,
              hasVault: true,
              email: _authRepository.email,
              failedUnlockAttempts: 0,
              addingAccount: false,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onLock(AuthLockRequested event, Emitter<AuthState> emit) async {
    await _performLock();
    emit(
      _withAccounts(
        state.copyWith(
          status: AuthStatus.locked,
          hasVault: true,
          email: _authRepository.email,
          passwordHint: sl<VaultMetadataStore>().passwordHint,
          addingAccount: false,
        ),
      ),
    );
  }

  Future<void> _onAddAccount(
    AuthAddAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    okDebugLog(
      '[add-account] event status=${state.status} '
      'unlocked=${state.isUnlocked} adding=${state.addingAccount} '
      'hasVault=${state.hasVault}',
    );
    if (state.addingAccount) {
      okDebugLog('[add-account] already in flow — re-open setup');
      AppRouter.routes.go('${AppRoutes.setup.path}?addAccount=1');
      return;
    }

    // Flag first so GoRouter can leave the vault shell, then lock. Closing the
    // DB while Settings/Account is still mounted hangs the isolate.
    emit(state.copyWith(addingAccount: true));
    okDebugLog('[add-account] flagged addingAccount=true, opening setup');
    try {
      AppRouter.routes.go('${AppRoutes.setup.path}?addAccount=1');
    } catch (e, st) {
      okDebugLog('[add-account] router.go failed: $e\n$st');
    }
    await Future<void>.delayed(Duration.zero);

    okDebugLog('[add-account] locking after navigation');
    await _performLock(traced: true);
    emit(
      _withAccounts(
        state.copyWith(
          status: AuthStatus.locked,
          hasVault: true,
          email: _authRepository.email,
          passwordHint: sl<VaultMetadataStore>().passwordHint,
          addingAccount: true,
        ),
      ),
    );
    okDebugLog(
      '[add-account] locked status=${state.status} adding=${state.addingAccount}',
    );
  }

  void _onAddAccountCancelled(
    AuthAddAccountCancelled event,
    Emitter<AuthState> emit,
  ) {
    okDebugLog(
      '[add-account] cancel status=${state.status} adding=${state.addingAccount}',
    );
    emit(state.copyWith(addingAccount: false));
  }

  Future<void> _onResetLocalVault(
    AuthResetLocalVaultRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    await sl<NativeMessagingHost>().stop();
    await sl<AutofillBridge>().clearCredentials();
    await _stopVaultWatchers();

    final result = await _resetLocalVault();
    result.fold(
      (f) => emit(state.copyWith(status: AuthStatus.failure, error: f)),
      (_) {
        if (_authRepository.hasVault) {
          emit(
            _withAccounts(
              state.copyWith(
                status: AuthStatus.locked,
                failedUnlockAttempts: 0,
                clearError: true,
                passwordHint: sl<VaultMetadataStore>().passwordHint,
                clearPasswordHint:
                    sl<VaultMetadataStore>().passwordHint == null,
              ),
            ),
          );
        } else {
          emit(
            const AuthState(
              status: AuthStatus.unknown,
              hasVault: false,
              failedUnlockAttempts: 0,
            ),
          );
        }
      },
    );
  }

  Future<void> _onRestoreFromServer(
    AuthRestoreFromServerRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _restoreFromServer(
      RestoreVaultFromServerParams(
        serverUrl: event.serverUrl,
        email: event.email,
        masterPassword: event.masterPassword,
      ),
    );
    await result.fold(
      (f) async => emit(state.copyWith(status: AuthStatus.failure, error: f)),
      (_) async {
        await sl<NativeMessagingHost>().start();
        await sl<AutofillBridge>().syncCredentials();
        unawaited(sl<SyncService>().syncIfConnected());

        emit(
          _withAccounts(
            state.copyWith(
              status: AuthStatus.unlocked,
              hasVault: true,
              email: event.email.trim().toLowerCase(),
              failedUnlockAttempts: 0,
              serverConnected: true,
              passwordHint: sl<VaultMetadataStore>().passwordHint,
              clearError: true,
              addingAccount: false,
            ),
          ),
        );
      },
    );
  }

  Future<void> _stopVaultWatchers() async {
    await sl<CollectionBloc>().stopWatching();
    await sl<EntryBloc>().stopWatching();
    await sl<WalletBloc>().stopWatching();
    await sl<CryptoBloc>().stopWatching();
    await sl<SecretsBloc>().stopWatching();
    // Let detached Drift cancels flush before the DB isolate is shut down.
    await Future<void>.delayed(Duration.zero);
  }

  /// Re-subscribe Drift watches after the encrypted DB is opened.
  void _startVaultWatchers({bool resetNavigation = false}) {
    sl<CollectionBloc>().add(
      CollectionStarted(resetNavigation: resetNavigation),
    );
    sl<EntryBloc>().add(
      EntryStarted(
        collectionUuid: resetNavigation ? kVaultRootScope : null,
        forceReload: true,
      ),
    );
    sl<WalletBloc>().add(const WalletStarted());
    sl<CryptoBloc>().add(const CryptoStarted());
    sl<SecretsBloc>().add(const SecretsStarted());
  }

  Future<void> _onRegisterServer(
    AuthRegisterServerRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _registerServer(event.serverUrl);
    result.fold(
      (f) => emit(state.copyWith(status: AuthStatus.failure, error: f)),
      (_) => emit(
        state.copyWith(status: AuthStatus.unlocked, serverConnected: true),
      ),
    );
  }

  Future<void> _onLoginServer(
    AuthLoginServerRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _loginServer(event.serverUrl);
    result.fold(
      (f) => emit(state.copyWith(status: AuthStatus.failure, error: f)),
      (_) => emit(
        state.copyWith(status: AuthStatus.unlocked, serverConnected: true),
      ),
    );
  }

  Future<void> _onRestoreFromBackup(
    AuthRestoreFromBackupRequested event,
    Emitter<AuthState> emit,
  ) async {
    void report(BackupRestoreStage stage) {
      try {
        event.onProgress?.call(stage);
      } catch (_) {}
    }

    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    await sl<NativeMessagingHost>().stop();
    await sl<AutofillBridge>().clearCredentials();
    // Stop Drift watches before the restore service closes the DB, but do NOT
    // lock/tear down the live vault until the backup password is verified.
    await _stopVaultWatchers();

    try {
      report(BackupRestoreStage.verifyingPassword);
      final vaultKey = await sl<BackupRestoreService>()
          .restoreEncryptedBackupBytes(
            bytes: event.bytes,
            masterPassword: event.masterPassword,
            onProgress: report,
          );

      report(BackupRestoreStage.unlocking);
      final result = await _unlockWithKey(
        UnlockWithVaultKeyParams(vaultKey: vaultKey),
      );
      await result.fold(
        (f) async => emit(
          state.copyWith(
            status: AuthStatus.failure,
            error: f,
            hasVault: _authRepository.hasVault,
          ),
        ),
        (_) async {
          await sl<NativeMessagingHost>().start();
          await sl<AutofillBridge>().syncCredentials();
          unawaited(sl<SyncService>().syncIfConnected());
          _startVaultWatchers(resetNavigation: true);
          await _rehydrateAccountScopedState();

          emit(
            _withAccounts(
              state.copyWith(
                status: AuthStatus.unlocked,
                hasVault: true,
                email: _authRepository.email,
                passwordHint: sl<VaultMetadataStore>().passwordHint,
                failedUnlockAttempts: 0,
                clearError: true,
                addingAccount: false,
              ),
            ),
          );
        },
      );
    } catch (e) {
      // Decrypt/verify failed before the live DB was replaced — resume session.
      final canResume =
          sl<VaultSession>().isUnlocked && sl<DatabaseManager>().isOpen;
      if (canResume) {
        _startVaultWatchers();
        unawaited(sl<NativeMessagingHost>().start());
        unawaited(sl<AutofillBridge>().syncCredentials());
        emit(
          state.copyWith(
            status: AuthStatus.unlocked,
            error: FailureMessage(
              e is BackupRestoreException ? e.message : e.toString(),
            ),
            hasVault: _authRepository.hasVault,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.failure,
            error: FailureMessage(
              e is BackupRestoreException ? e.message : e.toString(),
            ),
            hasVault: _authRepository.hasVault,
          ),
        );
      }
    }
  }

  Future<void> _onSwitchAccount(
    AuthSwitchAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (event.accountId == _authRepository.activeAccountId) return;
    final wasUnlocked = state.isUnlocked;
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    if (wasUnlocked) {
      await sl<NativeMessagingHost>().stop();
      await sl<AutofillBridge>().clearCredentials();
      await _stopVaultWatchers();
      await _lockVault();
    }
    final result = await _authRepository.switchAccount(event.accountId);
    await result.fold(
      (f) async => emit(
        _withAccounts(state.copyWith(status: AuthStatus.locked, error: f)),
      ),
      (_) async {
        await _rehydrateAccountScopedState();
        emit(
          _withAccounts(
            state.copyWith(
              status: AuthStatus.locked,
              failedUnlockAttempts: 0,
              clearError: true,
              passwordHint: sl<VaultMetadataStore>().passwordHint,
              clearPasswordHint: sl<VaultMetadataStore>().passwordHint == null,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onRemoveAccount(
    AuthRemoveAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    final removingActive = event.accountId == _authRepository.activeAccountId;
    if (removingActive) {
      emit(state.copyWith(status: AuthStatus.loading, clearError: true));
      await sl<NativeMessagingHost>().stop();
      await sl<AutofillBridge>().clearCredentials();
      await _stopVaultWatchers();
    }
    final result = await _authRepository.removeAccount(event.accountId);
    await result.fold(
      (f) async => emit(state.copyWith(status: AuthStatus.failure, error: f)),
      (_) async {
        await _rehydrateAccountScopedState();
        if (_authRepository.hasVault) {
          emit(
            _withAccounts(
              state.copyWith(
                status: AuthStatus.locked,
                failedUnlockAttempts: 0,
                clearError: true,
                passwordHint: sl<VaultMetadataStore>().passwordHint,
                clearPasswordHint:
                    sl<VaultMetadataStore>().passwordHint == null,
              ),
            ),
          );
        } else {
          emit(
            const AuthState(
              status: AuthStatus.unknown,
              hasVault: false,
              failedUnlockAttempts: 0,
            ),
          );
        }
      },
    );
  }

  void _onAccountsChanged(AuthAccountsChanged event, Emitter<AuthState> emit) {
    emit(
      _withAccounts(
        state,
      ).copyWith(avatarGeneration: state.avatarGeneration + 1),
    );
  }
}
