import 'package:drift/drift.dart';

class EntryTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get collectionUuid => text().nullable()();
  /// AES-GCM ciphertext of JSON payload (title, username, password, urls, notes).
  TextColumn get encryptedPayload => text()();
  IntColumn get revision => integer().withDefault(const Constant(1))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now())();
}
