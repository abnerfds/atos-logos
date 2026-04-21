import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required UserProfileUser user,
    UserProfileDetail? profile,
    required UserProfileMembership membership,
    required List<UserProfilePosition> positions,
    required UserProfileChurch church,
    required UserProfileBranch branch,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

@freezed
abstract class UserProfileUser with _$UserProfileUser {
  const factory UserProfileUser({
    required String id,
    required String name,
    required String email,
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
  }) = _UserProfileUser;

  factory UserProfileUser.fromJson(Map<String, dynamic> json) =>
      _$UserProfileUserFromJson(json);
}

@freezed
abstract class UserProfileDetail with _$UserProfileDetail {
  const factory UserProfileDetail({
    String? photoUrl,
    String? admissionDate,
    String? birthDate,
    String? baptismDate,
    String? consecrationDate,
    String? registrationNumber,
  }) = _UserProfileDetail;

  factory UserProfileDetail.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDetailFromJson(json);
}

@freezed
abstract class UserProfileMembership with _$UserProfileMembership {
  const factory UserProfileMembership({
    required String role,
    required String status,
  }) = _UserProfileMembership;

  factory UserProfileMembership.fromJson(Map<String, dynamic> json) =>
      _$UserProfileMembershipFromJson(json);
}

@freezed
abstract class UserProfilePosition with _$UserProfilePosition {
  const factory UserProfilePosition({
    required String id,
    required String name,
  }) = _UserProfilePosition;

  factory UserProfilePosition.fromJson(Map<String, dynamic> json) =>
      _$UserProfilePositionFromJson(json);
}

@freezed
abstract class UserProfileChurch with _$UserProfileChurch {
  const factory UserProfileChurch({
    required String id,
    required String name,
  }) = _UserProfileChurch;

  factory UserProfileChurch.fromJson(Map<String, dynamic> json) =>
      _$UserProfileChurchFromJson(json);
}

@freezed
abstract class UserProfileBranch with _$UserProfileBranch {
  const factory UserProfileBranch({
    required String id,
    required String name,
  }) = _UserProfileBranch;

  factory UserProfileBranch.fromJson(Map<String, dynamic> json) =>
      _$UserProfileBranchFromJson(json);
}
