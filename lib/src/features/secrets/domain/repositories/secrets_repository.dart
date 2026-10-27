import 'package:openkey_app/src/src.dart';

abstract class SecretsRepository {
  Stream<List<DevSecret>> watchSecrets();
  FutureFailureOr<List<DevSecret>> getSecrets();
  FutureFailureOr<DevSecret?> getSecret(String uuid);
  FutureFailureOr<DevSecret> createSecret(DevSecret secret);
  FutureFailureOr<DevSecret> updateSecret(DevSecret secret);
  FutureFailureOr<void> deleteSecret(String uuid);
}
