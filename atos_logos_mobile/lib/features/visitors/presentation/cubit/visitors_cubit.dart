import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../data/visitors_repository.dart';
import 'visitors_state.dart';

@injectable
class VisitorsCubit extends Cubit<VisitorsState> {
  final VisitorsRepository _repository;

  VisitorsCubit({required VisitorsRepository repository})
      : _repository = repository,
        super(const VisitorsState.initial());

  Future<void> loadVisitors({int page = 1}) async {
    emit(const VisitorsState.loading());
    try {
      final result = await _repository.getVisitors(page: page);
      emit(VisitorsState.loaded(visitors: result.data, total: result.total, page: result.page));
    } catch (e) {
      final message = e is AppException ? e.message : 'Erro inesperado';
      emit(VisitorsState.error(message: message));
    }
  }

  Future<void> createVisitor({required String name, String? phone, String? observations}) async {
    emit(const VisitorsState.loading());
    try {
      await _repository.createVisitor(name: name, phone: phone, observations: observations);
      await loadVisitors();
    } catch (e) {
      final message = e is AppException ? e.message : 'Erro inesperado';
      emit(VisitorsState.error(message: message));
    }
  }

  Future<void> checkIn(String visitorId, String eventId) async {
    try {
      await _repository.checkIn(visitorId, eventId);
      await loadVisitors();
    } catch (e) {
      final message = e is AppException ? e.message : 'Erro inesperado';
      emit(VisitorsState.error(message: message));
    }
  }
}
