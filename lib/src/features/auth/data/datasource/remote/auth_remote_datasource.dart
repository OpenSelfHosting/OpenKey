import 'package:injectable/injectable.dart';
import 'package:openkey_app/src/src.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> register({
    required String email,
    required String authHash,
    required String encryptedVaultKey,
    required Map<String, dynamic> kdfParams,
    required String salt,
  });

  Future<Map<String, dynamic>> prelogin({required String email});

  Future<Map<String, dynamic>> login({
    required String email,
    required String authHash,
  });

  Future<Map<String, dynamic>> me();

  Future<Map<String, dynamic>> refresh({required String refreshToken});

  Future<Map<String, dynamic>> rekey({
    required String currentAuthHash,
    required String authHash,
    required String encryptedVaultKey,
    String? salt,
    Map<String, dynamic>? kdfParams,
  });

  Future<Map<String, dynamic>> changeEmail({
    required String currentAuthHash,
    required String email,
    required String authHash,
    required String encryptedVaultKey,
    String? salt,
    Map<String, dynamic>? kdfParams,
  });

  Future<Map<String, dynamic>> deleteAccount({required String authHash});
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._api);

  final ApiClient _api;

  @override
  Future<Map<String, dynamic>> register({
    required String email,
    required String authHash,
    required String encryptedVaultKey,
    required Map<String, dynamic> kdfParams,
    required String salt,
  }) {
    return _api.post(
      '/auth/register',
      body: {
        'email': email,
        'auth_hash': authHash,
        'encrypted_vault_key': encryptedVaultKey,
        'kdf_params': kdfParams,
        'salt': salt,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> prelogin({required String email}) {
    return _api.post(
      '/auth/prelogin',
      body: {'email': email},
    );
  }

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String authHash,
  }) {
    return _api.post(
      '/auth/login',
      body: {
        'email': email,
        'auth_hash': authHash,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> me() {
    return _api.get('/auth/me', auth: true);
  }

  @override
  Future<Map<String, dynamic>> refresh({required String refreshToken}) {
    return _api.post(
      '/auth/refresh',
      body: {'refresh_token': refreshToken},
    );
  }

  @override
  Future<Map<String, dynamic>> rekey({
    required String currentAuthHash,
    required String authHash,
    required String encryptedVaultKey,
    String? salt,
    Map<String, dynamic>? kdfParams,
  }) {
    return _api.post(
      '/auth/rekey',
      auth: true,
      body: {
        'current_auth_hash': currentAuthHash,
        'auth_hash': authHash,
        'encrypted_vault_key': encryptedVaultKey,
        'salt': ?salt,
        'kdf_params': ?kdfParams,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> changeEmail({
    required String currentAuthHash,
    required String email,
    required String authHash,
    required String encryptedVaultKey,
    String? salt,
    Map<String, dynamic>? kdfParams,
  }) {
    return _api.post(
      '/auth/change-email',
      auth: true,
      body: {
        'current_auth_hash': currentAuthHash,
        'email': email,
        'auth_hash': authHash,
        'encrypted_vault_key': encryptedVaultKey,
        'salt': ?salt,
        'kdf_params': ?kdfParams,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> deleteAccount({required String authHash}) {
    return _api.post(
      '/auth/delete',
      auth: true,
      body: {'auth_hash': authHash},
    );
  }
}
