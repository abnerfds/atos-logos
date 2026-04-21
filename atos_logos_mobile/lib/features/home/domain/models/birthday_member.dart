import 'package:freezed_annotation/freezed_annotation.dart';

part 'birthday_member.freezed.dart';
part 'birthday_member.g.dart';

@freezed
abstract class BirthdayMember with _$BirthdayMember {
  const factory BirthdayMember({
    required String id,
    required String name,
    String? photoUrl,
    required String birthDate,
  }) = _BirthdayMember;

  factory BirthdayMember.fromJson(Map<String, dynamic> json) =>
      _$BirthdayMemberFromJson(json);
}

@freezed
abstract class BirthdaysResponse with _$BirthdaysResponse {
  const factory BirthdaysResponse({
    required List<BirthdayMember> data,
    required int month,
  }) = _BirthdaysResponse;

  factory BirthdaysResponse.fromJson(Map<String, dynamic> json) =>
      _$BirthdaysResponseFromJson(json);
}
