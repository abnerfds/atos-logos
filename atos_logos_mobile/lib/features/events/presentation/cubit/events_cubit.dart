import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../data/events_repository.dart';
import 'events_state.dart';

@injectable
class EventsCubit extends Cubit<EventsState> {
  final EventsRepository _repository;

  EventsCubit({required EventsRepository repository})
      : _repository = repository,
        super(const EventsState.initial());

  Future<void> loadEvents({int page = 1, String? type}) async {
    emit(const EventsState.loading());
    try {
      final result = await _repository.getEvents(page: page, type: type);
      emit(EventsState.loaded(events: result.data, total: result.total, page: result.page));
    } catch (e) {
      final message = e is AppException ? e.message : 'Erro inesperado';
      emit(EventsState.error(message: message));
    }
  }

  Future<void> createEvent({
    required String title,
    required String startsAt,
    required String type,
    String? branchId,
  }) async {
    emit(const EventsState.loading());
    try {
      await _repository.createEvent(title: title, startsAt: startsAt, type: type, branchId: branchId);
      await loadEvents();
    } catch (e) {
      final message = e is AppException ? e.message : 'Erro inesperado';
      emit(EventsState.error(message: message));
    }
  }

  Future<void> deleteEvent(String eventId) async {
    emit(const EventsState.loading());
    try {
      await _repository.deleteEvent(eventId);
      await loadEvents();
    } catch (e) {
      final message = e is AppException ? e.message : 'Erro inesperado';
      emit(EventsState.error(message: message));
    }
  }
}
