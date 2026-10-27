import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:openkey_app/src/src.dart';

class EntryFilter {
  const EntryFilter({this.collectionUuid});
  final String? collectionUuid;
}

@lazySingleton
class GetEntriesUsecase implements UseCase<List<VaultEntry>, EntryFilter> {
  GetEntriesUsecase(this._repository);
  final EntryRepository _repository;

  @override
  FutureFailureOr<List<VaultEntry>> call(EntryFilter params) =>
      _repository.getEntries(collectionUuid: params.collectionUuid);
}

@lazySingleton
class WatchEntriesUsecase {
  WatchEntriesUsecase(this._repository);
  final EntryRepository _repository;

  Stream<List<VaultEntry>> call({String? collectionUuid}) =>
      _repository.watchEntries(collectionUuid: collectionUuid);
}

@lazySingleton
class GetEntryUsecase implements UseCase<VaultEntry?, String> {
  GetEntryUsecase(this._repository);
  final EntryRepository _repository;

  @override
  FutureFailureOr<VaultEntry?> call(String uuid) => _repository.getEntry(uuid);
}

@lazySingleton
class CreateEntryUsecase implements UseCase<VaultEntry, VaultEntry> {
  CreateEntryUsecase(this._repository, this._appReview);
  final EntryRepository _repository;
  final AppReviewService _appReview;

  @override
  FutureFailureOr<VaultEntry> call(VaultEntry entry) async {
    final result = await _repository.createEntry(entry);
    result.fold((_) {}, (_) => unawaited(_maybeRequestReview()));
    return result;
  }

  Future<void> _maybeRequestReview() async {
    if (_appReview.hasRequested) return;
    final entries = await _repository.getEntries(collectionUuid: '__all__');
    entries.fold((_) {}, (list) {
      final count = list
          .where((e) => !ReservedCollections.isReserved(e.collectionUuid))
          .length;
      unawaited(_appReview.maybeRequestAfterEntryCount(count));
    });
  }
}

@lazySingleton
class UpdateEntryUsecase implements UseCase<VaultEntry, VaultEntry> {
  UpdateEntryUsecase(this._repository);
  final EntryRepository _repository;

  @override
  FutureFailureOr<VaultEntry> call(VaultEntry entry) =>
      _repository.updateEntry(entry);
}

class MoveEntriesParams {
  const MoveEntriesParams({
    required this.uuids,
    this.collectionUuid,
  });
  final List<String> uuids;
  final String? collectionUuid;
}

@lazySingleton
class MoveEntriesUsecase implements UseCase<void, MoveEntriesParams> {
  MoveEntriesUsecase(this._repository);
  final EntryRepository _repository;

  @override
  FutureFailureOr<void> call(MoveEntriesParams params) =>
      _repository.moveEntries(
        uuids: params.uuids,
        collectionUuid: params.collectionUuid,
      );
}

@lazySingleton
class DeleteEntryUsecase implements UseCase<void, String> {
  DeleteEntryUsecase(this._repository);
  final EntryRepository _repository;

  @override
  FutureFailureOr<void> call(String uuid) => _repository.deleteEntry(uuid);
}
