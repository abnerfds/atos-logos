// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventBranch _$EventBranchFromJson(Map<String, dynamic> json) =>
    _EventBranch(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$EventBranchToJson(_EventBranch instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

_ScheduleUser _$ScheduleUserFromJson(Map<String, dynamic> json) =>
    _ScheduleUser(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$ScheduleUserToJson(_ScheduleUser instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

_EventSchedule _$EventScheduleFromJson(Map<String, dynamic> json) =>
    _EventSchedule(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      userId: json['userId'] as String,
      functionName: json['functionName'] as String,
      user: ScheduleUser.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EventScheduleToJson(_EventSchedule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventId': instance.eventId,
      'userId': instance.userId,
      'functionName': instance.functionName,
      'user': instance.user,
    };

_Event _$EventFromJson(Map<String, dynamic> json) => _Event(
  id: json['id'] as String,
  churchId: json['churchId'] as String,
  branchId: json['branchId'] as String?,
  title: json['title'] as String,
  startsAt: json['startsAt'] as String,
  type: json['type'] as String,
  branch: json['branch'] == null
      ? null
      : EventBranch.fromJson(json['branch'] as Map<String, dynamic>),
  schedules:
      (json['schedules'] as List<dynamic>?)
          ?.map((e) => EventSchedule.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$EventToJson(_Event instance) => <String, dynamic>{
  'id': instance.id,
  'churchId': instance.churchId,
  'branchId': instance.branchId,
  'title': instance.title,
  'startsAt': instance.startsAt,
  'type': instance.type,
  'branch': instance.branch,
  'schedules': instance.schedules,
};

_EventPage _$EventPageFromJson(Map<String, dynamic> json) => _EventPage(
  data: (json['data'] as List<dynamic>)
      .map((e) => Event.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
);

Map<String, dynamic> _$EventPageToJson(_EventPage instance) =>
    <String, dynamic>{
      'data': instance.data,
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
    };
