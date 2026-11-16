import 'package:freezed_annotation/freezed_annotation.dart';

import 'catalog_enums.dart';

part 'challenge.freezed.dart';
part 'challenge.g.dart';

@freezed
abstract class Challenge with _$Challenge {
  const factory Challenge({
    required String id,
    required String title,
    @Default(ChallengeKind.donut) ChallengeKind kind,
    @Default(0) int current,
    @Default(1) int target,
  }) = _Challenge;

  const Challenge._();

  factory Challenge.fromJson(Map<String, dynamic> json) =>
      _$ChallengeFromJson(json);

  bool get isComplete => current >= target;

  double get progress => target <= 0 ? 0 : (current / target).clamp(0.0, 1.0);
}
