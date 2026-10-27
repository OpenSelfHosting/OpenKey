import 'package:openkey_app/src/src.dart';

class CreateCollectionParams {
  const CreateCollectionParams({
    required this.name,
    this.icon = CollectionIcons.defaultKey,
    this.color,
    this.parentUuid,
  });

  final String name;
  final String icon;
  final int? color;
  final String? parentUuid;
}

abstract class CollectionRepository {
  Stream<List<VaultCollection>> watchCollections();
  FutureFailureOr<List<VaultCollection>> getCollections();
  FutureFailureOr<VaultCollection> createCollection(
    CreateCollectionParams params,
  );
  FutureFailureOr<VaultCollection> updateCollection(VaultCollection collection);
  FutureFailureOr<void> moveCollections({
    required List<String> uuids,
    String? parentUuid,
  });
  FutureFailureOr<void> deleteCollection(String uuid);
}

abstract class EntryRepository {
  /// Scope:
  /// - `__root__` / omitted null meaning root → entries with no folder
  /// - `__all__` → every password entry
  /// - uuid → entries in that folder
  Stream<List<VaultEntry>> watchEntries({String? collectionUuid});
  FutureFailureOr<List<VaultEntry>> getEntries({String? collectionUuid});
  FutureFailureOr<VaultEntry?> getEntry(String uuid);
  FutureFailureOr<VaultEntry> createEntry(VaultEntry entry);

  /// Encrypts and inserts many entries in one DB batch (one watcher emit).
  /// [onProgress] reports encryption progress as `(done, total)`.
  FutureFailureOr<int> createEntries(
    List<VaultEntry> entries, {
    void Function(int done, int total)? onProgress,
  });

  FutureFailureOr<VaultEntry> updateEntry(VaultEntry entry);
  /// Folder move only — updates [collectionUuid] without re-encrypting payloads.
  FutureFailureOr<void> moveEntries({
    required List<String> uuids,
    String? collectionUuid,
  });
  FutureFailureOr<void> deleteEntry(String uuid);
}

/// Sentinel for vault root (entries not in any folder).
const kVaultRootScope = '__root__';
