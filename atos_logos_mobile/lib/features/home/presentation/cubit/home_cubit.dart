import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../data/home_repository.dart';
import '../../domain/models/birthday_member.dart';
import '../../domain/models/church.dart';
import '../../domain/models/upcoming_event.dart';
import 'home_state.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _repository;

  HomeCubit({required HomeRepository repository})
      : _repository = repository,
        super(const HomeState.initial());

  /// Loads the 3 pieces of dashboard data concurrently. The church fetch
  /// is treated as mandatory (failure → [HomeState.error]) while the
  /// birthdays and upcoming-events fetches are resilient: a failure in
  /// either one logs a debug message and falls back to an empty list
  /// so the rest of the dashboard still renders. This is a deliberate
  /// UX decision to avoid blanking the screen because a single auxiliary
  /// endpoint is slow or transiently broken.
  Future<void> loadDashboard() async {
    emit(const HomeState.loading());
    try {
      final results = await Future.wait<dynamic>([
        _repository.getMyChurch(),
        (() async {
          try {
            return await _repository.getBirthdays();
          } catch (e) {
            debugPrint('HomeCubit: failed to load birthdays → $e');
            return BirthdaysResponse(
              data: const [],
              month: DateTime.now().month,
            );
          }
        })(),
        (() async {
          try {
            return await _repository.getUpcomingEvents();
          } catch (e) {
            debugPrint('HomeCubit: failed to load upcoming events → $e');
            return const <UpcomingEvent>[];
          }
        })(),
      ]);

      final church = results[0] as Church;
      final birthdaysResponse = results[1] as BirthdaysResponse;
      final events = results[2] as List<UpcomingEvent>;

      emit(HomeState.loaded(
        church: church,
        birthdays: birthdaysResponse.data,
        upcomingEvents: events,
      ));
    } on AppException catch (e) {
      emit(HomeState.error(e.message));
    } catch (e) {
      // Defensive: if the mandatory church fetch throws something other
      // than AppException (e.g. FormatException from malformed JSON), we
      // still need to leave the loading state so the UI can recover.
      debugPrint('HomeCubit: unexpected error in loadDashboard → $e');
      emit(const HomeState.error('Erro inesperado ao carregar dashboard'));
    }
  }
}
