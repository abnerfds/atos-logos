// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  user: UserProfileUser.fromJson(json['user'] as Map<String, dynamic>),
  profile: json['profile'] == null
      ? null
      : UserProfileDetail.fromJson(json['profile'] as Map<String, dynamic>),
  membership: UserProfileMembership.fromJson(
    json['membership'] as Map<String, dynamic>,
  ),
  positions: (json['positions'] as List<dynamic>)
      .map((e) => UserProfilePosition.fromJson(e as Map<String, dynamic>))
      .toList(),
  church: UserProfileChurch.fromJson(json['church'] as Map<String, dynamic>),
  branch: UserProfileBranch.fromJson(json['branch'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'user': instance.user,
      'profile': instance.profile,
      'membership': instance.membership,
      'positions': instance.positions,
      'church': instance.church,
      'branch': instance.branch,
    };

_UserProfileUser _$UserProfileUserFromJson(Map<String, dynamic> json) =>
    _UserProfileUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      cpf: json['cpf'] as String?,
      rg: json['rg'] as String?,
      sex: json['sex'] as String?,
      civilStatus: json['civilStatus'] as String?,
      fatherName: json['fatherName'] as String?,
      motherName: json['motherName'] as String?,
      country: json['country'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      neighborhood: json['neighborhood'] as String?,
      street: json['street'] as String?,
      number: json['number'] as String?,
      complement: json['complement'] as String?,
    );

Map<String, dynamic> _$UserProfileUserToJson(_UserProfileUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'cpf': instance.cpf,
      'rg': instance.rg,
      'sex': instance.sex,
      'civilStatus': instance.civilStatus,
      'fatherName': instance.fatherName,
      'motherName': instance.motherName,
      'country': instance.country,
      'state': instance.state,
      'city': instance.city,
      'neighborhood': instance.neighborhood,
      'street': instance.street,
      'number': instance.number,
      'complement': instance.complement,
    };

_UserProfileDetail _$UserProfileDetailFromJson(Map<String, dynamic> json) =>
    _UserProfileDetail(
      photoUrl: json['photoUrl'] as String?,
      admissionDate: json['admissionDate'] as String?,
      birthDate: json['birthDate'] as String?,
      baptismDate: json['baptismDate'] as String?,
      consecrationDate: json['consecrationDate'] as String?,
      registrationNumber: json['registrationNumber'] as String?,
    );

Map<String, dynamic> _$UserProfileDetailToJson(_UserProfileDetail instance) =>
    <String, dynamic>{
      'photoUrl': instance.photoUrl,
      'admissionDate': instance.admissionDate,
      'birthDate': instance.birthDate,
      'baptismDate': instance.baptismDate,
      'consecrationDate': instance.consecrationDate,
      'registrationNumber': instance.registrationNumber,
    };

_UserProfileMembership _$UserProfileMembershipFromJson(
  Map<String, dynamic> json,
) => _UserProfileMembership(
  role: json['role'] as String,
  status: json['status'] as String,
);

Map<String, dynamic> _$UserProfileMembershipToJson(
  _UserProfileMembership instance,
) => <String, dynamic>{'role': instance.role, 'status': instance.status};

_UserProfilePosition _$UserProfilePositionFromJson(Map<String, dynamic> json) =>
    _UserProfilePosition(
      id: json['id'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$UserProfilePositionToJson(
  _UserProfilePosition instance,
) => <String, dynamic>{'id': instance.id, 'name': instance.name};

_UserProfileChurch _$UserProfileChurchFromJson(Map<String, dynamic> json) =>
    _UserProfileChurch(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$UserProfileChurchToJson(_UserProfileChurch instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

_UserProfileBranch _$UserProfileBranchFromJson(Map<String, dynamic> json) =>
    _UserProfileBranch(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$UserProfileBranchToJson(_UserProfileBranch instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};
