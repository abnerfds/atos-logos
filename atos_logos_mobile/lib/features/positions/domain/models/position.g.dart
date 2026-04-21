// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'position.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PositionUserInfo _$PositionUserInfoFromJson(Map<String, dynamic> json) =>
    _PositionUserInfo(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$PositionUserInfoToJson(_PositionUserInfo instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

_PositionUserPivot _$PositionUserPivotFromJson(Map<String, dynamic> json) =>
    _PositionUserPivot(
      id: json['id'] as String,
      userId: json['userId'] as String,
      positionId: json['positionId'] as String,
      user: PositionUserInfo.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PositionUserPivotToJson(_PositionUserPivot instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'positionId': instance.positionId,
      'user': instance.user,
    };

_Position _$PositionFromJson(Map<String, dynamic> json) => _Position(
  id: json['id'] as String,
  churchId: json['churchId'] as String,
  name: json['name'] as String,
  users:
      (json['users'] as List<dynamic>?)
          ?.map((e) => PositionUserPivot.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$PositionToJson(_Position instance) => <String, dynamic>{
  'id': instance.id,
  'churchId': instance.churchId,
  'name': instance.name,
  'users': instance.users,
};
