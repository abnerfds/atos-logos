import 'package:freezed_annotation/freezed_annotation.dart';

part 'member_profile.freezed.dart';
part 'member_profile.g.dart';

@freezed
abstract class MemberProfileUser with _$MemberProfileUser {
  const factory MemberProfileUser({
    required String id,
    required String name,
    String? email,
    String? phone,
    String? cpf,
    String? rg,
    String? sex,
    String? civilStatus,
    String? fatherName,
    String? motherName,
    String? country,
    String? state,
    String? city,
    String? neighborhood,
    String? street,
    String? number,
    String? complement,
  }) = _MemberProfileUser;

  factory MemberProfileUser.fromJson(Map<String, dynamic> json) =>
      _$MemberProfileUserFromJson(json);
}

@freezed
abstract class MemberProfileBranch with _$MemberProfileBranch {
  const factory MemberProfileBranch({
    required String id,
    required String name,
  }) = _MemberProfileBranch;

  factory MemberProfileBranch.fromJson(Map<String, dynamic> json) =>
      _$MemberProfileBranchFromJson(json);
}

@freezed
abstract class MemberProfilePosition with _$MemberProfilePosition {
  const factory MemberProfilePosition({
    required String id,
    required String name,
  }) = _MemberProfilePosition;

  factory MemberProfilePosition.fromJson(Map<String, dynamic> json) =>
      _$MemberProfilePositionFromJson(json);
}

@freezed
abstract class MemberProfile with _$MemberProfile {
  const factory MemberProfile({
    String? id,
    required String userId,
    required String churchId,
    String? registrationNumber,
    String? birthDate,
    String? baptismDate,
    String? admissionDate,
    String? consecrationDate,
    String? photoUrl,
    String? branchId,
    MemberProfileBranch? branch,
    String? positionId,
    MemberProfilePosition? position,
    MemberProfileUser? user,
  }) = _MemberProfile;

  factory MemberProfile.fromJson(Map<String, dynamic> json) =>
      _$MemberProfileFromJson(json);
}
