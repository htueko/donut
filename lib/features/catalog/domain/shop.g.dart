// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Shop _$ShopFromJson(Map<String, dynamic> json) => _Shop(
  id: json['id'] as String,
  name: json['name'] as String,
  address: json['address'] as String? ?? '',
  distanceLabel: json['distanceLabel'] as String? ?? '',
  imageUrl: json['imageUrl'] as String? ?? '',
  isOpen: json['isOpen'] as bool? ?? true,
);

Map<String, dynamic> _$ShopToJson(_Shop instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'address': instance.address,
  'distanceLabel': instance.distanceLabel,
  'imageUrl': instance.imageUrl,
  'isOpen': instance.isOpen,
};
