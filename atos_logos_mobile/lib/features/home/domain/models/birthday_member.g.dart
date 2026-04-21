// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'birthday_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BirthdayMember _$BirthdayMemberFromJson(Map<String, dynamic> json) =>
    _BirthdayMember(
      id: json['id'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String?,
      birthDate: json['birthDate'] as String,
    );

Map<String, dynamic> _$BirthdayMemberToJson(_BirthdayMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'photoUrl': instance.photoUrl,
      'birthDate': instance.birthDate,
    };

_BirthdaysResponse _$BirthdaysResponseFromJson(Map<String, dynamic> json) =>
    _BirthdaysResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => BirthdayMember.fromJson(e as Map<String, dynamic>))
          .toList(),
      month: (json['month'] as num).toInt(),
    );

Map<String, dynamic> _$BirthdaysResponseToJson(_BirthdaysResponse instance) =>
    <String, dynamic>{'data': instance.data, 'month': instance.month};
