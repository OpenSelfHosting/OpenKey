import 'package:drift/drift.dart';

class PendingSyncTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()();
  TextColumn get operationType => text()();
  TextColumn get entityUuid => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();
}
