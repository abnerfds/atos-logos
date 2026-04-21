// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MemberProfileUser _$MemberProfileUserFromJson(Map<String, dynamic> json) =>
    _MemberProfileUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
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

Map<String, dynamic> _$MemberProfileUserToJson(_MemberProfileUser instance) =>
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

_MemberProfile _$MemberProfileFromJson(Map<String, dynamic> json) =>
    _MemberProfile(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      churchId: json['churchId'] as String,
      registrationNumber: json['registrationNumber'] as String?,
      birthDate: json['birthDate'] as String?,
      baptismDate: json['baptismDate'] as String?,
      admissionDate: json['admissionDate'] as String?,
      consecrationDate: json['consecrationDate'] as String?,
      photoUrl: json['photoUrl'] as String?,
      user: json['user'] == null
          ? null
          : MemberProfileUser.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MemberProfileToJson(_MemberProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'churchId': instance.churchId,
      'registrationNumber': instance.registrationNumber,
      'birthDate': instance.birthDate,
      'baptismDate': instance.baptismDate,
      'admissionDate': instance.admissionDate,
      'consecrationDate': instance.consecrationDate,
      'photoUrl': instance.photoUrl,
      'user': instance.user,
    };
