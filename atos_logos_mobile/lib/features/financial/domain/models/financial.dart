import 'package:freezed_annotation/freezed_annotation.dart';

part 'financial.freezed.dart';
part 'financial.g.dart';

@freezed
abstract class Campaign with _$Campaign {
  const factory Campaign({
    required String id,
    required String churchId,
    required String title,
    required String goalAmount,
    required String currentAmount,
    required String status,
  }) = _Campaign;
  factory Campaign.fromJson(Map<String, dynamic> json) => _$CampaignFromJson(json);
}

@freezed
abstract class TransactionDonor with _$TransactionDonor {
  const factory TransactionDonor({required String id, required String name}) = _TransactionDonor;
  factory TransactionDonor.fromJson(Map<String, dynamic> json) => _$TransactionDonorFromJson(json);
}

@freezed
abstract class FinancialTransaction with _$FinancialTransaction {
  const factory FinancialTransaction({
    required String id,
    required String churchId,
    required String type,
    required String category,
    required String amount,
    required String transactionDate,
    TransactionDonor? donor,
  }) = _FinancialTransaction;
  factory FinancialTransaction.fromJson(Map<String, dynamic> json) => _$FinancialTransactionFromJson(json);
}

@freezed
abstract class TransactionPage with _$TransactionPage {
  const factory TransactionPage({
    required List<FinancialTransaction> data,
    required int total,
    required int page,
    required int limit,
  }) = _TransactionPage;
  factory TransactionPage.fromJson(Map<String, dynamic> json) => _$TransactionPageFromJson(json);
}

@freezed
abstract class FinancialSummary with _$FinancialSummary {
  const factory FinancialSummary({
    required double totalIncome,
    required double totalExpense,
    required double balance,
  }) = _FinancialSummary;
  factory FinancialSummary.fromJson(Map<String, dynamic> json) => _$FinancialSummaryFromJson(json);
}
