import 'package:freezed_annotation/freezed_annotation.dart';

import 'catalog_enums.dart';

part 'member.freezed.dart';
part 'member.g.dart';

@freezed
abstract class Member with _$Member {
  const factory Member({
    required String id,
    required String name,
    @Default('') String photoUrl,
    @Default(Tier.bronze) Tier tier,
    @Default(0) int points,
    @Default(0) int pointsToNextTier,
    @Default(0) int notificationsCount,
  }) = _Member;

  const Member._();

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);
}
