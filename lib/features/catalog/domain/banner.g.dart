// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Banner _$BannerFromJson(Map<String, dynamic> json) => _Banner(
  id: json['id'] as String,
  imageUrl: json['imageUrl'] as String,
  title: json['title'] as String? ?? '',
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$BannerToJson(_Banner instance) => <String, dynamic>{
  'id': instance.id,
  'imageUrl': instance.imageUrl,
  'title': instance.title,
  'sortOrder': instance.sortOrder,
};
