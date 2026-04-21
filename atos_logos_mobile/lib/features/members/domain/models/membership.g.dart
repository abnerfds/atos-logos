// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MembershipUser _$MembershipUserFromJson(Map<String, dynamic> json) =>
    _MembershipUser(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$MembershipUserToJson(_MembershipUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'email': instance.email,
    };

_MembershipBranch _$MembershipBranchFromJson(Map<String, dynamic> json) =>
    _MembershipBranch(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$MembershipBranchToJson(_MembershipBranch instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

_Membership _$MembershipFromJson(Map<String, dynamic> json) => _Membership(
  id: json['id'] as String,
  userId: json['userId'] as String,
  churchId: json['churchId'] as String,
  branchId: json['branchId'] as String,
  role: json['role'] as String,
  status: json['status'] as String,
  user: MembershipUser.fromJson(json['user'] as Map<String, dynamic>),
  branch: MembershipBranch.fromJson(json['branch'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MembershipToJson(_Membership instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'churchId': instance.churchId,
      'branchId': instance.branchId,
      'role': instance.role,
      'status': instance.status,
      'user': instance.user,
      'branch': instance.branch,
    };

_MembershipPage _$MembershipPageFromJson(Map<String, dynamic> json) =>
    _MembershipPage(
      data: (json['data'] as List<dynamic>)
          .map((e) => Membership.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
    );

Map<String, dynamic> _$MembershipPageToJson(_MembershipPage instance) =>
    <String, dynamic>{
      'data': instance.data,
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
    };
