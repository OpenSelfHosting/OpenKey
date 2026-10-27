part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthSetupRequested extends AuthEvent {
  const AuthSetupRequested({
    required this.email,
    required this.masterPassword,
    this.passwordHint,
    this.serverUrl,
  });

  final String email;
  final String masterPassword;
  final String? passwordHint;

  /// When set, register this new vault on the self-hosted server after setup.
  final String? serverUrl;

  @override
  List<Object?> get props => [email, passwordHint, serverUrl];
}

class AuthUnlockRequested extends AuthEvent {
  const AuthUnlockRequested({required this.masterPassword});

  final String masterPassword;
}

class AuthBiometricUnlockRequested extends AuthEvent {
  const AuthBiometricUnlockRequested();
}

class AuthLockRequested extends AuthEvent {
  const AuthLockRequested();
}

class AuthResetLocalVaultRequested extends AuthEvent {
  const AuthResetLocalVaultRequested();
}

class AuthRestoreFromServerRequested extends AuthEvent {
  const AuthRestoreFromServerRequested({
    required this.serverUrl,
    required this.email,
    required this.masterPassword,
  });

  final String serverUrl;
  final String email;
  final String masterPassword;

  @override
  List<Object?> get props => [serverUrl, email];
}

class AuthRegisterServerRequested extends AuthEvent {
  const AuthRegisterServerRequested({required this.serverUrl});

  final String serverUrl;

  @override
  List<Object?> get props => [serverUrl];
}

class AuthLoginServerRequested extends AuthEvent {
  const AuthLoginServerRequested({required this.serverUrl});

  final String serverUrl;

  @override
  List<Object?> get props => [serverUrl];
}

class AuthRestoreFromBackupRequested extends AuthEvent {
  const AuthRestoreFromBackupRequested({
    required this.bytes,
    required this.masterPassword,
    this.onProgress,
  });

  final List<int> bytes;
  final String masterPassword;
  final void Function(BackupRestoreStage stage)? onProgress;

  @override
  List<Object?> get props => [masterPassword, bytes.length];
}

class AuthSwitchAccountRequested extends AuthEvent {
  const AuthSwitchAccountRequested(this.accountId);

  final String accountId;

  @override
  List<Object?> get props => [accountId];
}

class AuthRemoveAccountRequested extends AuthEvent {
  const AuthRemoveAccountRequested(this.accountId);

  final String accountId;

  @override
  List<Object?> get props => [accountId];
}

class AuthAccountsChanged extends AuthEvent {
  const AuthAccountsChanged();
}

class AuthAddAccountRequested extends AuthEvent {
  const AuthAddAccountRequested();
}

class AuthAddAccountCancelled extends AuthEvent {
  const AuthAddAccountCancelled();
}
