// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'select_church_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SelectChurchRequest _$SelectChurchRequestFromJson(Map<String, dynamic> json) =>
    _SelectChurchRequest(
      selectionToken: json['selectionToken'] as String,
      churchId: json['churchId'] as String,
    );

Map<String, dynamic> _$SelectChurchRequestToJson(
  _SelectChurchRequest instance,
) => <String, dynamic>{
  'selectionToken': instance.selectionToken,
  'churchId': instance.churchId,
};
