import 'package:freezed_annotation/freezed_annotation.dart';

part 'banner.freezed.dart';
part 'banner.g.dart';

@freezed
abstract class Banner with _$Banner {
  const factory Banner({
    required String id,
    required String imageUrl,
    @Default('') String title,
    @Default(0) int sortOrder,
  }) = _Banner;

  const Banner._();

  factory Banner.fromJson(Map<String, dynamic> json) => _$BannerFromJson(json);
}
