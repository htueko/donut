import 'package:freezed_annotation/freezed_annotation.dart';

import 'banner.dart';
import 'catalog_enums.dart';
import 'challenge.dart';
import 'member.dart';
import 'product.dart';
import 'shop.dart';

part 'catalog_data.freezed.dart';

@freezed
abstract class CatalogData with _$CatalogData {
  const factory CatalogData({
    @Default(<Product>[]) List<Product> products,
    @Default(<Banner>[]) List<Banner> banners,
    @Default(<Shop>[]) List<Shop> shops,
    @Default(<Challenge>[]) List<Challenge> challenges,
    Member? member,
  }) = _CatalogData;

  const CatalogData._();

  List<Product> productsInSection(CatalogSection section) {
    return products
        .where((product) => product.section == section)
        .toList(growable: false);
  }

  Product? productById(String id) {
    for (final product in products) {
      if (product.id == id) {
        return product;
      }
    }
    return null;
  }
}
