// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Challenge _$ChallengeFromJson(Map<String, dynamic> json) => _Challenge(
  id: json['id'] as String,
  title: json['title'] as String,
  kind:
      $enumDecodeNullable(_$ChallengeKindEnumMap, json['kind']) ??
      ChallengeKind.donut,
  current: (json['current'] as num?)?.toInt() ?? 0,
  target: (json['target'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$ChallengeToJson(_Challenge instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'kind': _$ChallengeKindEnumMap[instance.kind]!,
      'current': instance.current,
      'target': instance.target,
    };

const _$ChallengeKindEnumMap = {
  ChallengeKind.donut: 'donut',
  ChallengeKind.coffee: 'coffee',
};
