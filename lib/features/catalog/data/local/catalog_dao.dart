import 'dart:async';

import 'package:async/async.dart';
import 'package:drift/drift.dart';

import '../../domain/banner.dart' as banner;
import '../../domain/catalog_data.dart';
import '../../domain/catalog_enums.dart';
import '../../domain/challenge.dart' as challenge;
import '../../domain/member.dart' as member;
import '../../domain/product.dart' as product;
import '../../domain/shop.dart' as shop;
import 'catalog_database.dart';
import 'catalog_tables.dart';

part 'catalog_dao.g.dart';

@DriftAccessor(tables: [Members, Products, Banners, Shops, Challenges, AppMeta])
class CatalogDao extends DatabaseAccessor<CatalogDatabase>
    with _$CatalogDaoMixin {
  CatalogDao(super.db);

  Future<member.Member?> memberRow() async {
    final row = await (select(members)..limit(1)).getSingleOrNull();
    if (row == null) {
      return null;
    }
    return member.Member(
      id: row.id,
      name: row.name,
      photoUrl: row.photoUrl,
      tier: Tier.fromName(row.tier),
      points: row.points,
      notificationsCount: row.notificationsCount,
    );
  }

  Future<List<product.Product>> productRows() async {
    final rows = await select(products).get();
    return rows.map(_productFromRow).toList(growable: false);
  }

  Future<product.Product?> productById(String id) async {
    final row = await (select(
      products,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _productFromRow(row);
  }

  Future<CatalogData> loadCatalog() async {
    final memberEntry = await memberRow();
    final productList = await productRows();
    final bannerRows = await select(banners).get();
    final shopRows = await select(shops).get();
    final challengeRows = await select(challenges).get();
    return CatalogData(
      products: productList,
      banners: bannerRows.map(_bannerFromRow).toList(growable: false),
      shops: shopRows.map(_shopFromRow).toList(growable: false),
      challenges: challengeRows.map(_challengeFromRow).toList(growable: false),
      member: memberEntry,
    );
  }

  Stream<CatalogData> watchCatalog() {
    final changes = StreamGroup.merge<dynamic>([
      select(members).watch(),
      select(products).watch(),
      select(banners).watch(),
      select(shops).watch(),
      select(challenges).watch(),
    ]);
    return changes.asyncMap((_) => loadCatalog());
  }

  Future<void> replaceCatalog(CatalogData seed) {
    return transaction(() async {
      await delete(products).go();
      await delete(banners).go();
      await delete(shops).go();
      await delete(challenges).go();
      await delete(members).go();
      await batch((batch) {
        batch.insertAll(products, seed.products.map(_productToRow));
        batch.insertAll(banners, seed.banners.map(_bannerToRow));
        batch.insertAll(shops, seed.shops.map(_shopToRow));
        batch.insertAll(challenges, seed.challenges.map(_challengeToRow));
        if (seed.member != null) {
          batch.insert(
            members,
            _memberToRow(seed.member!),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    });
  }

  Future<String?> readMeta(String key) async {
    final row = await (select(
      appMeta,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> writeMeta(String key, String value) {
    return into(appMeta).insert(
      AppMetaCompanion.insert(key: key, value: value),
      mode: InsertMode.insertOrReplace,
    );
  }

  product.Product _productFromRow(Product row) {
    return product.Product(
      id: row.id,
      code: row.code,
      name: row.name,
      priceMmk: row.priceMmk,
      isNew: row.isNew,
      discountPercent: row.discountPercent,
      imageUrl: row.imageUrl,
      description: row.description,
      section: CatalogSection.fromName(row.section),
    );
  }

  ProductsCompanion _productToRow(product.Product entity) {
    return ProductsCompanion.insert(
      id: entity.id,
      code: entity.code,
      name: entity.name,
      priceMmk: entity.priceMmk,
      isNew: Value(entity.isNew),
      discountPercent: Value(entity.discountPercent),
      imageUrl: Value(entity.imageUrl),
      description: Value(entity.description),
      section: Value(entity.sectionName),
    );
  }

  banner.Banner _bannerFromRow(Banner row) {
    return banner.Banner(
      id: row.id,
      imageUrl: row.imageUrl,
      title: row.title,
      sortOrder: row.sortOrder,
    );
  }

  BannersCompanion _bannerToRow(banner.Banner entity) {
    return BannersCompanion.insert(
      id: entity.id,
      imageUrl: entity.imageUrl,
      title: Value(entity.title),
      sortOrder: Value(entity.sortOrder),
    );
  }

  shop.Shop _shopFromRow(Shop row) {
    return shop.Shop(
      id: row.id,
      name: row.name,
      address: row.address,
      distanceLabel: row.distanceLabel,
      imageUrl: row.imageUrl,
      isOpen: row.isOpen,
    );
  }

  ShopsCompanion _shopToRow(shop.Shop entity) {
    return ShopsCompanion.insert(
      id: entity.id,
      name: entity.name,
      address: Value(entity.address),
      distanceLabel: Value(entity.distanceLabel),
      imageUrl: Value(entity.imageUrl),
      isOpen: Value(entity.isOpen),
    );
  }

  challenge.Challenge _challengeFromRow(Challenge row) {
    return challenge.Challenge(
      id: row.id,
      title: row.title,
      kind: ChallengeKind.fromName(row.kind),
      current: row.current,
      target: row.target,
    );
  }

  ChallengesCompanion _challengeToRow(challenge.Challenge entity) {
    return ChallengesCompanion.insert(
      id: entity.id,
      title: entity.title,
      kind: Value(entity.kind.name),
      current: Value(entity.current),
      target: Value(entity.target),
    );
  }

  MembersCompanion _memberToRow(member.Member entity) {
    return MembersCompanion.insert(
      id: entity.id,
      name: entity.name,
      photoUrl: Value(entity.photoUrl),
      tier: Value(entity.tier.name),
      points: Value(entity.points),
      notificationsCount: Value(entity.notificationsCount),
    );
  }
}
