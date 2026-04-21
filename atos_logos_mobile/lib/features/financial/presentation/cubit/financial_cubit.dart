import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../data/financial_repository.dart';
import 'financial_state.dart';

@injectable
class FinancialCubit extends Cubit<FinancialState> {
  final FinancialRepository _repository;

  FinancialCubit({required FinancialRepository repository})
      : _repository = repository,
        super(const FinancialState.initial());

  Future<void> loadFinancial() async {
    emit(const FinancialState.loading());
    try {
      final results = await Future.wait([
        _repository.getSummary(),
        _repository.getCampaigns(),
        _repository.getTransactions(),
      ]);
      emit(FinancialState.loaded(
        summary: results[0] as dynamic,
        campaigns: results[1] as dynamic,
        transactions: (results[2] as dynamic).data as dynamic,
      ));
    } catch (e) {
      final message = e is AppException ? e.message : 'Erro inesperado';
      emit(FinancialState.error(message: message));
    }
  }
}
