// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_dao.dart';

// ignore_for_file: type=lint
mixin _$CatalogDaoMixin on DatabaseAccessor<CatalogDatabase> {
  $MembersTable get members => attachedDatabase.members;
  $ProductsTable get products => attachedDatabase.products;
  $BannersTable get banners => attachedDatabase.banners;
  $ShopsTable get shops => attachedDatabase.shops;
  $ChallengesTable get challenges => attachedDatabase.challenges;
  $AppMetaTable get appMeta => attachedDatabase.appMeta;
  CatalogDaoManager get managers => CatalogDaoManager(this);
}

class CatalogDaoManager {
  final _$CatalogDaoMixin _db;
  CatalogDaoManager(this._db);
  $$MembersTableTableManager get members =>
      $$MembersTableTableManager(_db.attachedDatabase, _db.members);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db.attachedDatabase, _db.products);
  $$BannersTableTableManager get banners =>
      $$BannersTableTableManager(_db.attachedDatabase, _db.banners);
  $$ShopsTableTableManager get shops =>
      $$ShopsTableTableManager(_db.attachedDatabase, _db.shops);
  $$ChallengesTableTableManager get challenges =>
      $$ChallengesTableTableManager(_db.attachedDatabase, _db.challenges);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db.attachedDatabase, _db.appMeta);
}
