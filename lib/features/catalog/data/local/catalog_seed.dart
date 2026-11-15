import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/banner.dart';
import '../../domain/catalog_data.dart';
import '../../domain/challenge.dart';
import '../../domain/member.dart';
import '../../domain/product.dart';
import '../../domain/shop.dart';
import 'catalog_database.dart' hide Banner, Challenge, Member, Product, Shop;

class CatalogSeed {
  const CatalogSeed._();

  static const String seedVersionKey = 'catalog_seed_version';
  static const int currentVersion = 1;
  static const String assetPath = 'assets/seed/catalog.json';
}

class SeedRunner {
  SeedRunner(this._db);

  final CatalogDatabase _db;

  Future<void> seedIfNeeded() async {
    final stored = await _db.catalogDao.readMeta(CatalogSeed.seedVersionKey);
    if (stored == '${CatalogSeed.currentVersion}') {
      return;
    }
    final catalog = await _loadSeed();
    await _db.catalogDao.replaceCatalog(catalog);
    await _db.catalogDao.writeMeta(
      CatalogSeed.seedVersionKey,
      '${CatalogSeed.currentVersion}',
    );
  }

  Future<CatalogData> _loadSeed() async {
    final raw = await rootBundle.loadString(CatalogSeed.assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return CatalogData(
      products: _parseList<Product>(json['products'], Product.fromJson),
      banners: _parseList<Banner>(json['banners'], Banner.fromJson),
      shops: _parseList<Shop>(json['shops'], Shop.fromJson),
      challenges: _parseList<Challenge>(json['challenges'], Challenge.fromJson),
      member: json['member'] == null
          ? null
          : Member.fromJson(json['member'] as Map<String, dynamic>),
    );
  }

  List<T> _parseList<T>(
    Object? raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (raw is! List) {
      return const [];
    }
    return raw
        .map((item) => fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }
}

Future<void> runSeed(CatalogDatabase db) {
  return SeedRunner(db).seedIfNeeded();
}
