import 'package:freezed_annotation/freezed_annotation.dart';

part 'membership.freezed.dart';
part 'membership.g.dart';

@freezed
abstract class MembershipUser with _$MembershipUser {
  const factory MembershipUser({
    required String id,
    required String name,
    String? phone,
    String? email,
  }) = _MembershipUser;

  factory MembershipUser.fromJson(Map<String, dynamic> json) =>
      _$MembershipUserFromJson(json);
}

@freezed
abstract class MembershipBranch with _$MembershipBranch {
  const factory MembershipBranch({
    required String id,
    required String name,
  }) = _MembershipBranch;

  factory MembershipBranch.fromJson(Map<String, dynamic> json) =>
      _$MembershipBranchFromJson(json);
}

@freezed
abstract class Membership with _$Membership {
  const factory Membership({
    required String id,
    required String userId,
    required String churchId,
    required String branchId,
    required String role,
    required String status,
    required MembershipUser user,
    required MembershipBranch branch,
  }) = _Membership;

  factory Membership.fromJson(Map<String, dynamic> json) =>
      _$MembershipFromJson(json);
}

@freezed
abstract class MembershipPage with _$MembershipPage {
  const factory MembershipPage({
    required List<Membership> data,
    required int total,
    required int page,
    required int limit,
  }) = _MembershipPage;

  factory MembershipPage.fromJson(Map<String, dynamic> json) =>
      _$MembershipPageFromJson(json);
}
