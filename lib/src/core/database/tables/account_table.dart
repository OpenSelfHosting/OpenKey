import 'package:drift/drift.dart';

/// Local account row — encrypted vault key + sync metadata.
/// Sensitive field payloads live in collections/entries tables.
class AccountTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get email => text()();
  TextColumn get salt => text()();
  TextColumn get kdfParams => text()();
  TextColumn get wrappedVaultKey => text()();
  TextColumn get serverUserId => text().nullable()();
  TextColumn get accessToken => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now())();
}
