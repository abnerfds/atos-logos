// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'church.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Church _$ChurchFromJson(Map<String, dynamic> json) => _Church(
  id: json['id'] as String,
  name: json['name'] as String,
  documentNumber: json['documentNumber'] as String?,
  activePlan: json['activePlan'] as String,
);

Map<String, dynamic> _$ChurchToJson(_Church instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'documentNumber': instance.documentNumber,
  'activePlan': instance.activePlan,
};
