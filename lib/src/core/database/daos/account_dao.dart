import 'package:drift/drift.dart';
import 'package:openkey_app/src/src.dart';

part 'account_dao.g.dart';

@DriftAccessor(tables: [AccountTable])
class AccountDao extends DatabaseAccessor<AppDatabase>
    with _$AccountDaoMixin {
  AccountDao(super.db);

  Future<AccountTableData?> getAccount() {
    return select(accountTable).getSingleOrNull();
  }

  Future<AccountTableData> upsertAccount(AccountTableCompanion companion) async {
    final existing = await getAccount();
    if (existing == null) {
      return into(accountTable).insertReturning(companion);
    }
    await (update(accountTable)..where((t) => t.id.equals(existing.id)))
        .write(companion);
    return (select(accountTable)..where((t) => t.id.equals(existing.id)))
        .getSingle();
  }

  Future<void> updateTokens({
    required String? serverUserId,
    required String? accessToken,
  }) async {
    final existing = await getAccount();
    if (existing == null) return;
    await (update(accountTable)..where((t) => t.id.equals(existing.id))).write(
      AccountTableCompanion(
        serverUserId: Value(serverUserId),
        accessToken: Value(accessToken),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
