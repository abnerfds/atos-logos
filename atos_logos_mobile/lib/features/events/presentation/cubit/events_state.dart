import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/event.dart';

part 'events_state.freezed.dart';

@freezed
class EventsState with _$EventsState {
  const factory EventsState.initial() = _Initial;
  const factory EventsState.loading() = _Loading;
  const factory EventsState.loaded({
    required List<Event> events,
    required int total,
    required int page,
  }) = _Loaded;
  const factory EventsState.error({required String message}) = _Error;
}
