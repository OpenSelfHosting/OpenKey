import 'package:injectable/injectable.dart';
import 'package:openkey_app/src/src.dart';

@lazySingleton
class GetCollectionsUsecase implements UseCaseNoParams<List<VaultCollection>> {
  GetCollectionsUsecase(this._repository);
  final CollectionRepository _repository;

  @override
  FutureFailureOr<List<VaultCollection>> call() => _repository.getCollections();
}

@lazySingleton
class WatchCollectionsUsecase {
  WatchCollectionsUsecase(this._repository);
  final CollectionRepository _repository;

  Stream<List<VaultCollection>> call() => _repository.watchCollections();
}

@lazySingleton
class CreateCollectionUsecase
    implements UseCase<VaultCollection, CreateCollectionParams> {
  CreateCollectionUsecase(this._repository);
  final CollectionRepository _repository;

  @override
  FutureFailureOr<VaultCollection> call(CreateCollectionParams params) =>
      _repository.createCollection(params);
}

@lazySingleton
class UpdateCollectionUsecase
    implements UseCase<VaultCollection, VaultCollection> {
  UpdateCollectionUsecase(this._repository);
  final CollectionRepository _repository;

  @override
  FutureFailureOr<VaultCollection> call(VaultCollection collection) =>
      _repository.updateCollection(collection);
}

class MoveCollectionsParams {
  const MoveCollectionsParams({
    required this.uuids,
    this.parentUuid,
  });
  final List<String> uuids;
  final String? parentUuid;
}

@lazySingleton
class MoveCollectionsUsecase implements UseCase<void, MoveCollectionsParams> {
  MoveCollectionsUsecase(this._repository);
  final CollectionRepository _repository;

  @override
  FutureFailureOr<void> call(MoveCollectionsParams params) =>
      _repository.moveCollections(
        uuids: params.uuids,
        parentUuid: params.parentUuid,
      );
}

@lazySingleton
class DeleteCollectionUsecase implements UseCase<void, String> {
  DeleteCollectionUsecase(this._repository);
  final CollectionRepository _repository;

  @override
  FutureFailureOr<void> call(String uuid) => _repository.deleteCollection(uuid);
}
