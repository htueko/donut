// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Member _$MemberFromJson(Map<String, dynamic> json) => _Member(
  id: json['id'] as String,
  name: json['name'] as String,
  photoUrl: json['photoUrl'] as String? ?? '',
  tier: $enumDecodeNullable(_$TierEnumMap, json['tier']) ?? Tier.bronze,
  points: (json['points'] as num?)?.toInt() ?? 0,
  pointsToNextTier: (json['pointsToNextTier'] as num?)?.toInt() ?? 0,
  notificationsCount: (json['notificationsCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$MemberToJson(_Member instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'photoUrl': instance.photoUrl,
  'tier': _$TierEnumMap[instance.tier]!,
  'points': instance.points,
  'pointsToNextTier': instance.pointsToNextTier,
  'notificationsCount': instance.notificationsCount,
};

const _$TierEnumMap = {
  Tier.bronze: 'bronze',
  Tier.silver: 'silver',
  Tier.gold: 'gold',
  Tier.platinum: 'platinum',
};
