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

  Future<void> createClass({required String name, required String branchId}) async {
    emit(const EbdState.loading());
    try {
      await _repository.createClass(name: name, branchId: branchId);
      await loadClasses();
    } catch (e) {
      final message = e is AppException ? e.message : 'Erro inesperado';
      emit(EbdState.error(message: message));
    }
  }
}
