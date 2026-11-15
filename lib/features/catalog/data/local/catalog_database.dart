import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'catalog_dao.dart';
import 'catalog_tables.dart';

part 'catalog_database.g.dart';

@DriftDatabase(
  tables: [Members, Products, Banners, Shops, Challenges, AppMeta, Users],
  daos: [CatalogDao],
)
class CatalogDatabase extends _$CatalogDatabase {
  CatalogDatabase(super.e);

  CatalogDatabase.inMemory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  static Future<CatalogDatabase> open() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'donut.sqlite'));
    return CatalogDatabase(NativeDatabase(file));
  }
}
