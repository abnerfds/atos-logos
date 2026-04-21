import 'package:freezed_annotation/freezed_annotation.dart';

part 'event.freezed.dart';
part 'event.g.dart';

@freezed
abstract class EventBranch with _$EventBranch {
  const factory EventBranch({required String id, required String name}) = _EventBranch;
  factory EventBranch.fromJson(Map<String, dynamic> json) => _$EventBranchFromJson(json);
}

@freezed
abstract class ScheduleUser with _$ScheduleUser {
  const factory ScheduleUser({required String id, required String name}) = _ScheduleUser;
  factory ScheduleUser.fromJson(Map<String, dynamic> json) => _$ScheduleUserFromJson(json);
}

@freezed
abstract class EventSchedule with _$EventSchedule {
  const factory EventSchedule({
    required String id,
    required String eventId,
    required String userId,
    required String functionName,
    required ScheduleUser user,
  }) = _EventSchedule;
  factory EventSchedule.fromJson(Map<String, dynamic> json) => _$EventScheduleFromJson(json);
}

@freezed
abstract class Event with _$Event {
  const factory Event({
    required String id,
    required String churchId,
    String? branchId,
    required String title,
    required String startsAt,
    required String type,
    EventBranch? branch,
    @Default([]) List<EventSchedule> schedules,
  }) = _Event;
  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}

@freezed
abstract class EventPage with _$EventPage {
  const factory EventPage({
    required List<Event> data,
    required int total,
    required int page,
    required int limit,
  }) = _EventPage;
  factory EventPage.fromJson(Map<String, dynamic> json) => _$EventPageFromJson(json);
}
