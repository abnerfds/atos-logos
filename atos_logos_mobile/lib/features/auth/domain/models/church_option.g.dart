// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'church_option.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChurchOption _$ChurchOptionFromJson(Map<String, dynamic> json) =>
    _ChurchOption(
      id: json['id'] as String,
      name: json['name'] as String,
      branchName: json['branchName'] as String,
      role: json['role'] as String,
    );

Map<String, dynamic> _$ChurchOptionToJson(_ChurchOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'branchName': instance.branchName,
      'role': instance.role,
    };
