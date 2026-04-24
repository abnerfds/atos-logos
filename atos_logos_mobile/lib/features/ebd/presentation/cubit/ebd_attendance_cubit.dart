import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../data/ebd_repository.dart';
import '../../domain/models/ebd_class.dart';

// ── State ─────────────────────────────────────────────────────────────────────

abstract class EbdAttendanceState {}

class EbdAttendanceInitial extends EbdAttendanceState {}

class EbdAttendanceLoading extends EbdAttendanceState {}

class EbdAttendanceLoaded extends EbdAttendanceState {
  EbdAttendanceLoaded({required this.students});
  final List<EbdAttendanceEntry> students;
}

class EbdAttendanceSaving extends EbdAttendanceState {
  EbdAttendanceSaving({required this.students});
  final List<EbdAttendanceEntry> students;
}

class EbdAttendanceSaved extends EbdAttendanceState {}

class EbdAttendanceError extends EbdAttendanceState {
  EbdAttendanceError({required this.message});
  final String message;
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

@injectable
class EbdAttendanceCubit extends Cubit<EbdAttendanceState> {
  EbdAttendanceCubit({required EbdRepository repository})
    : _repository = repository,
      super(EbdAttendanceInitial());

  final EbdRepository _repository;

  Future<void> loadAttendance(String lessonId) async {
    emit(EbdAttendanceLoading());
    try {
      final students = await _repository.getLessonAttendance(lessonId);
      emit(EbdAttendanceLoaded(students: students));
    } catch (e) {
      final message = e is AppException ? e.message : 'Erro inesperado';
      emit(EbdAttendanceError(message: message));
    }
  }

  void togglePresence(String memberId, bool isPresent) {
    final current = state;
    if (current is! EbdAttendanceLoaded) return;
    final updated = current.students.map((s) {
      if (s.memberId == memberId) {
        return EbdAttendanceEntry(
          memberId: s.memberId,
          name: s.name,
          photoUrl: s.photoUrl,
          isPresent: isPresent,
        );
      }
      return s;
    }).toList();
    emit(EbdAttendanceLoaded(students: updated));
  }

  void markAllPresent() {
    final current = state;
    if (current is! EbdAttendanceLoaded) return;
    final updated = current.students.map((s) {
      return EbdAttendanceEntry(
        memberId: s.memberId,
        name: s.name,
        photoUrl: s.photoUrl,
        isPresent: true,
      );
    }).toList();
    emit(EbdAttendanceLoaded(students: updated));
  }

  Future<bool> saveAttendance({
    required String lessonId,
    required double offeringAmount,
    int visitorCount = 0,
  }) async {
    final current = state;
    if (current is! EbdAttendanceLoaded) return false;

    emit(EbdAttendanceSaving(students: current.students));
    try {
      await _repository.saveLessonAttendance(
        lessonId: lessonId,
        attendances: current.students,
        offeringAmount: offeringAmount,
        visitorCount: visitorCount,
      );
      emit(EbdAttendanceSaved());
      return true;
    } catch (e) {
      final message = e is AppException ? e.message : 'Erro inesperado';
      emit(EbdAttendanceError(message: message));
      return false;
    }
  }
}
