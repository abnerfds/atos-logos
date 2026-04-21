import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../data/positions_repository.dart';
import 'positions_state.dart';

@injectable
class PositionsCubit extends Cubit<PositionsState> {
  final PositionsRepository _repository;

  PositionsCubit({required PositionsRepository repository})
      : _repository = repository,
        super(const PositionsState.initial());

  Future<void> loadPositions() async {
    emit(const PositionsState.loading());
    try {
      final positions = await _repository.getPositions();
      emit(PositionsState.loaded(positions: positions));
    } catch (e) {
      final message = e is AppException ? e.message : 'Erro inesperado';
      emit(PositionsState.error(message: message));
    }
  }

  Future<void> createPosition(String name) async {
    emit(const PositionsState.loading());
    try {
      await _repository.createPosition(name);
      await loadPositions();
    } catch (e) {
      final message = e is AppException ? e.message : 'Erro inesperado';
      emit(PositionsState.error(message: message));
    }
  }

  Future<void> deletePosition(String positionId) async {
    emit(const PositionsState.loading());
    try {
      await _repository.deletePosition(positionId);
      await loadPositions();
    } catch (e) {
      final message = e is AppException ? e.message : 'Erro inesperado';
      emit(PositionsState.error(message: message));
    }
  }

  Future<void> assignUser(String positionId, String userId) async {
    try {
      await _repository.assignUser(positionId, userId);
      await loadPositions();
    } catch (e) {
      final message = e is AppException ? e.message : 'Erro inesperado';
      emit(PositionsState.error(message: message));
    }
  }

  Future<void> unassignUser(String positionId, String userId) async {
    try {
      await _repository.unassignUser(positionId, userId);
      await loadPositions();
    } catch (e) {
      final message = e is AppException ? e.message : 'Erro inesperado';
      emit(PositionsState.error(message: message));
    }
  }
}
