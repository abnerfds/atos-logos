import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/models/birthday_member.dart';
import '../../domain/models/church.dart';
import '../../domain/models/upcoming_event.dart';

part 'home_state.freezed.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState.initial() = _Initial;
  const factory HomeState.loading() = _Loading;
  const factory HomeState.loaded({
    required Church church,
    required List<BirthdayMember> birthdays,
    required List<UpcomingEvent> upcomingEvents,
  }) = _Loaded;
  const factory HomeState.error(String message) = _Error;
}
