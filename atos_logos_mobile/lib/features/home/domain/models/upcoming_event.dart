import 'package:freezed_annotation/freezed_annotation.dart';

part 'upcoming_event.freezed.dart';

/// Strongly-typed representation of an event rendered on the dashboard's
/// "Próximos Eventos" list.
///
/// The backend `GET /events` endpoint returns objects that include a
/// nested `branch: { id, name }` and a `startsAt` string in ISO-8601.
/// We flatten those into [branchName] and parse the date into a real
/// [DateTime] at the repository boundary so the UI never deals with
/// untyped maps or raw date strings.
@freezed
abstract class UpcomingEvent with _$UpcomingEvent {
  const factory UpcomingEvent({
    required String id,
    required String title,
    required DateTime startsAt,
    String? branchName,
    String? type,
  }) = _UpcomingEvent;

  /// Manual JSON parser (not generated via json_serializable) because
  /// we need to flatten the nested `branch.name` field and convert the
  /// ISO date into a [DateTime]. Prefer calling this from the repository,
  /// not from the UI.
  factory UpcomingEvent.fromJson(Map<String, dynamic> json) {
    final branch = json['branch'];
    return UpcomingEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      startsAt: DateTime.parse(json['startsAt'] as String),
      branchName:
          branch is Map<String, dynamic> ? branch['name'] as String? : null,
      type: json['type'] as String?,
    );
  }
}
