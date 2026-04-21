import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/financial.dart';

part 'financial_state.freezed.dart';

@freezed
class FinancialState with _$FinancialState {
  const factory FinancialState.initial() = _Initial;
  const factory FinancialState.loading() = _Loading;
  const factory FinancialState.loaded({
    required FinancialSummary summary,
    required List<Campaign> campaigns,
    required List<FinancialTransaction> transactions,
  }) = _Loaded;
  const factory FinancialState.error({required String message}) = _Error;
}
