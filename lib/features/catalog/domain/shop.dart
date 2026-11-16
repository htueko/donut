import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop.freezed.dart';
part 'shop.g.dart';

@freezed
abstract class Shop with _$Shop {
  const factory Shop({
    required String id,
    required String name,
    @Default('') String address,
    @Default('') String distanceLabel,
    @Default('') String imageUrl,
    @Default(true) bool isOpen,
  }) = _Shop;

  const Shop._();

  factory Shop.fromJson(Map<String, dynamic> json) => _$ShopFromJson(json);
}
