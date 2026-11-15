import 'package:freezed_annotation/freezed_annotation.dart';

import 'catalog_enums.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,
    required String code,
    required String name,
    required int priceMmk,
    @Default(false) bool isNew,
    int? discountPercent,
    @Default('') String imageUrl,
    @Default('') String description,
    @Default(CatalogSection.popular) CatalogSection section,
  }) = _Product;

  const Product._();

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  String get sectionName => switch (section) {
    CatalogSection.seasonal => 'seasonal',
    CatalogSection.popular => 'popular',
    CatalogSection.orderAgain => 'order_again',
  };
}
