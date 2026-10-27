part of 'auth_bloc.dart';

enum AuthStatus { unknown, locked, unlocked, loading, failure }

class AuthState extends Equatable {
  const AuthState({
    required this.status,
    required this.hasVault,
    this.email,
    this.error,
    this.serverConnected = false,
    this.failedUnlockAttempts = 0,
    this.passwordHint,
    this.accounts = const [],
    this.activeAccountId,
    this.avatarPath,
    this.addingAccount = false,
    this.avatarGeneration = 0,
  });

  factory AuthState.initial(
    bool hasVault, {
    String? email,
    String? passwordHint,
    List<VaultAccount> accounts = const [],
    String? activeAccountId,
    String? avatarPath,
  }) => AuthState(
    status: hasVault ? AuthStatus.locked : AuthStatus.unknown,
    hasVault: hasVault,
    email: email,
    passwordHint: passwordHint,
    accounts: accounts,
    activeAccountId: activeAccountId,
    avatarPath: avatarPath,
  );

  final AuthStatus status;
  final bool hasVault;
  final String? email;
  final AppFailure? error;
  final bool serverConnected;
  final int failedUnlockAttempts;
  final String? passwordHint;
  final List<VaultAccount> accounts;
  final String? activeAccountId;
  final String? avatarPath;

  /// Increments when the avatar file is rewritten in place so [FileImage]
  /// caches and Equatable state both invalidate.
  final int avatarGeneration;

  /// Locked, but the user is creating or signing in to another local vault.
  final bool addingAccount;

  bool get isUnlocked => status == AuthStatus.unlocked;

  /// Show the optional password hint on the unlock screen when set.
  bool get shouldShowPasswordHint =>
      passwordHint != null && passwordHint!.trim().isNotEmpty;

  AuthState copyWith({
    AuthStatus? status,
    bool? hasVault,
    String? email,
    AppFailure? error,
    bool? serverConnected,
    int? failedUnlockAttempts,
    String? passwordHint,
    List<VaultAccount>? accounts,
    String? activeAccountId,
    String? avatarPath,
    bool? addingAccount,
    int? avatarGeneration,
    bool clearError = false,
    bool clearPasswordHint = false,
    bool clearAvatar = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      hasVault: hasVault ?? this.hasVault,
      email: email ?? this.email,
      error: clearError ? null : (error ?? this.error),
      serverConnected: serverConnected ?? this.serverConnected,
      failedUnlockAttempts: failedUnlockAttempts ?? this.failedUnlockAttempts,
      passwordHint: clearPasswordHint
          ? null
          : (passwordHint ?? this.passwordHint),
      accounts: accounts ?? this.accounts,
      activeAccountId: activeAccountId ?? this.activeAccountId,
      avatarPath: clearAvatar ? null : (avatarPath ?? this.avatarPath),
      addingAccount: addingAccount ?? this.addingAccount,
      avatarGeneration: avatarGeneration ?? this.avatarGeneration,
    );
  }

  @override
  List<Object?> get props => [
    status,
    hasVault,
    email,
    error,
    serverConnected,
    failedUnlockAttempts,
    passwordHint,
    accounts,
    activeAccountId,
    avatarPath,
    addingAccount,
    avatarGeneration,
  ];
}
