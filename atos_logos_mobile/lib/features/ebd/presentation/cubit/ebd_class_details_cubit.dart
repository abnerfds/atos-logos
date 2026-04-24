import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../data/ebd_repository.dart';
import '../../domain/models/ebd_class.dart';

// ── State ─────────────────────────────────────────────────────────────────────

abstract class EbdClassDetailsState {}

class EbdClassDetailsInitial extends EbdClassDetailsState {}

class EbdClassDetailsLoading extends EbdClassDetailsState {}

class EbdClassDetailsLoaded extends EbdClassDetailsState {
  EbdClassDetailsLoaded({required this.classDetail, required this.lessons});
  final EbdClassDetail classDetail;
  final List<EbdLesson> lessons;
}

class EbdClassDetailsError extends EbdClassDetailsState {
  EbdClassDetailsError({required this.message});
  final String message;
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

@injectable
class EbdClassDetailsCubit extends Cubit<EbdClassDetailsState> {
  EbdClassDetailsCubit({required EbdRepository repository})
    : _repository = repository,
      super(EbdClassDetailsInitial());

  final EbdRepository _repository;

  Future<void> loadDetails(String classId) async {
    emit(EbdClassDetailsLoading());
    try {
      final results = await Future.wait([
        _repository.getClassDetail(classId),
        _repository.getLessons(classId),
      ]);
      emit(
        EbdClassDetailsLoaded(
          classDetail: results[0] as EbdClassDetail,
          lessons: results[1] as List<EbdLesson>,
        ),
      );
    } catch (e) {
      final message = e is AppException ? e.message : 'Erro inesperado';
      emit(EbdClassDetailsError(message: message));
    }
  }
}
