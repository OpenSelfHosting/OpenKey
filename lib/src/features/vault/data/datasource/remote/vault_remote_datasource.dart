import 'package:injectable/injectable.dart';
import 'package:openkey_app/src/src.dart';

abstract class VaultRemoteDataSource {
  Future<Map<String, dynamic>> sync({
    required List<Map<String, dynamic>> collections,
    required List<Map<String, dynamic>> entries,
    List<Map<String, dynamic>> attachments = const [],
    int sinceRevision = 0,
  });
}

@LazySingleton(as: VaultRemoteDataSource)
class VaultRemoteDataSourceImpl implements VaultRemoteDataSource {
  VaultRemoteDataSourceImpl(this._api);

  final ApiClient _api;

  @override
  Future<Map<String, dynamic>> sync({
    required List<Map<String, dynamic>> collections,
    required List<Map<String, dynamic>> entries,
    List<Map<String, dynamic>> attachments = const [],
    int sinceRevision = 0,
  }) {
    return _api.post(
      '/sync',
      auth: true,
      body: {
        'since_revision': sinceRevision,
        'collections': collections,
        'entries': entries,
        'attachments': attachments,
      },
    );
  }
}
