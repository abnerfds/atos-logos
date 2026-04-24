// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ebd_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EbdClassBranch _$EbdClassBranchFromJson(Map<String, dynamic> json) =>
    _EbdClassBranch(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$EbdClassBranchToJson(_EbdClassBranch instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

_EbdClass _$EbdClassFromJson(Map<String, dynamic> json) => _EbdClass(
  id: json['id'] as String,
  churchId: json['churchId'] as String,
  branchId: json['branchId'] as String,
  name: json['name'] as String,
  branch: json['branch'] == null
      ? null
      : EbdClassBranch.fromJson(json['branch'] as Map<String, dynamic>),
  targetAudience: json['targetAudience'] as String?,
  status: json['status'] as bool?,
  teacherName: json['teacherName'] as String?,
  enrolledCount: (json['enrolledCount'] as num?)?.toInt() ?? 0,
  certificateAvailable: json['certificateAvailable'] as bool? ?? false,
);

Map<String, dynamic> _$EbdClassToJson(_EbdClass instance) => <String, dynamic>{
  'id': instance.id,
  'churchId': instance.churchId,
  'branchId': instance.branchId,
  'name': instance.name,
  'branch': instance.branch,
  'targetAudience': instance.targetAudience,
  'status': instance.status,
  'teacherName': instance.teacherName,
  'enrolledCount': instance.enrolledCount,
  'certificateAvailable': instance.certificateAvailable,
};

_EbdFrequency _$EbdFrequencyFromJson(Map<String, dynamic> json) =>
    _EbdFrequency(
      userId: json['userId'] as String,
      classId: json['classId'] as String,
      totalSessions: (json['totalSessions'] as num).toInt(),
      presentCount: (json['presentCount'] as num).toInt(),
      frequency: (json['frequency'] as num).toDouble(),
      certificateEligible: json['certificateEligible'] as bool,
    );

Map<String, dynamic> _$EbdFrequencyToJson(_EbdFrequency instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'classId': instance.classId,
      'totalSessions': instance.totalSessions,
      'presentCount': instance.presentCount,
      'frequency': instance.frequency,
      'certificateEligible': instance.certificateEligible,
    };
