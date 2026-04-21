// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visitor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Visitor _$VisitorFromJson(Map<String, dynamic> json) => _Visitor(
  id: json['id'] as String,
  churchId: json['churchId'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String?,
  observations: json['observations'] as String?,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$VisitorToJson(_Visitor instance) => <String, dynamic>{
  'id': instance.id,
  'churchId': instance.churchId,
  'name': instance.name,
  'phone': instance.phone,
  'observations': instance.observations,
  'createdAt': instance.createdAt,
};

_VisitorPage _$VisitorPageFromJson(Map<String, dynamic> json) => _VisitorPage(
  data: (json['data'] as List<dynamic>)
      .map((e) => Visitor.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
);

Map<String, dynamic> _$VisitorPageToJson(_VisitorPage instance) =>
    <String, dynamic>{
      'data': instance.data,
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
    };
