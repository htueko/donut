import 'package:drift/drift.dart';

import '../../../catalog/data/local/catalog_database.dart';
import '../../../catalog/data/local/catalog_tables.dart';
import '../../domain/app_user.dart';

part 'auth_dao.g.dart';

@DriftAccessor(tables: [Users])
class AuthDao extends DatabaseAccessor<CatalogDatabase> with _$AuthDaoMixin {
  AuthDao(super.db);

  Future<AppUser?> byPhone(String phoneE164) async {
    final row = await (select(
      users,
    )..where((table) => table.phoneE164.equals(phoneE164))).getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _toEntity(row);
  }

  Future<AppUser?> byId(String id) async {
    final row = await (select(
      users,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _toEntity(row);
  }

  Stream<AppUser?> watchById(String id) {
    final query = select(users)..where((table) => table.id.equals(id));
    return query.watchSingleOrNull().map((row) {
      if (row == null) {
        return null;
      }
      return _toEntity(row);
    });
  }

  Future<void> upsert(AppUser user) {
    return into(users).insert(
      UsersCompanion.insert(
        id: user.id,
        phoneE164: user.phoneE164,
        firstName: user.firstName,
        lastName: Value(user.lastName),
        dateOfBirth: user.dateOfBirth.toIso8601String(),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  AppUser _toEntity(User row) {
    return AppUser(
      id: row.id,
      phoneE164: row.phoneE164,
      firstName: row.firstName,
      lastName: row.lastName,
      dateOfBirth: DateTime.parse(row.dateOfBirth),
    );
  }
}
