import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../data/ebd_repository.dart';
import 'ebd_state.dart';

@injectable
class EbdCubit extends Cubit<EbdState> {
  final EbdRepository _repository;

  EbdCubit({required EbdRepository repository})
    : _repository = repository,
      super(const EbdState.initial());

  Future<void> loadClasses() async {
    emit(const EbdState.loading());
    try {
      final classes = await _repository.getClasses();
      emit(EbdState.loaded(classes: classes));
    } catch (e) {
      final message = e is AppException ? e.message : 'Erro inesperado';
      emit(EbdState.error(message: message));
    }
  }

  Future<bool> createClass({
    required String name,
    required String branchId,
    String targetAudience = 'Geral',
    String? quarterId,
    String? quarterName,
    List<String> teacherIds = const [],
    List<String> studentIds = const [],
    List<EbdLessonInput> lessons = const [],
  }) async {
    emit(const EbdState.loading());
    try {
      await _repository.createClass(
        name: name,
        branchId: branchId,
        targetAudience: targetAudience,
        quarterId: quarterId,
        quarterName: quarterName,
        teacherIds: teacherIds,
        studentIds: studentIds,
        lessons: lessons,
      );
      await loadClasses();
      return true;
    } catch (e) {
      final message = e is AppException ? e.message : 'Erro inesperado';
      emit(EbdState.error(message: message));
      return false;
    }
  }

  Future<bool> updateClass({
    required String classId,
    String? name,
    String? targetAudience,
    String? quarterName,
    List<String>? teacherIds,
    List<String>? studentIds,
    List<EbdLessonInput>? lessons,
  }) async {
    emit(const EbdState.loading());
    try {
      await _repository.updateClass(
        classId: classId,
        name: name,
        targetAudience: targetAudience,
        quarterName: quarterName,
        teacherIds: teacherIds,
        studentIds: studentIds,
        lessons: lessons,
      );
      await loadClasses();
      return true;
    } catch (e) {
      final message = e is AppException ? e.message : 'Erro inesperado';
      emit(EbdState.error(message: message));
      return false;
    }
  }
}
