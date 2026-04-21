// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Branch _$BranchFromJson(Map<String, dynamic> json) => _Branch(
  id: json['id'] as String,
  name: json['name'] as String,
  isHeadquarters: json['isHeadquarters'] as bool,
  country: json['country'] as String?,
  state: json['state'] as String?,
  city: json['city'] as String?,
  neighborhood: json['neighborhood'] as String?,
  street: json['street'] as String?,
  number: json['number'] as String?,
  count: json['_count'] == null
      ? null
      : BranchCount.fromJson(json['_count'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BranchToJson(_Branch instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'isHeadquarters': instance.isHeadquarters,
  'country': instance.country,
  'state': instance.state,
  'city': instance.city,
  'neighborhood': instance.neighborhood,
  'street': instance.street,
  'number': instance.number,
  '_count': instance.count,
};

_BranchCount _$BranchCountFromJson(Map<String, dynamic> json) =>
    _BranchCount(memberships: (json['memberships'] as num?)?.toInt() ?? 0);

Map<String, dynamic> _$BranchCountToJson(_BranchCount instance) =>
    <String, dynamic>{'memberships': instance.memberships};
