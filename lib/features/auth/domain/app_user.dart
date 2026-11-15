import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String phoneE164,
    required String firstName,
    String? lastName,
    required DateTime dateOfBirth,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);

  const AppUser._();

  String get fullName {
    final last = lastName;
    if (last == null || last.trim().isEmpty) {
      return firstName;
    }
    return '$firstName $last';
  }
}
