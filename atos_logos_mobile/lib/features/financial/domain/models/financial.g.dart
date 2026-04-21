// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Campaign _$CampaignFromJson(Map<String, dynamic> json) => _Campaign(
  id: json['id'] as String,
  churchId: json['churchId'] as String,
  title: json['title'] as String,
  goalAmount: json['goalAmount'] as String,
  currentAmount: json['currentAmount'] as String,
  status: json['status'] as String,
);

Map<String, dynamic> _$CampaignToJson(_Campaign instance) => <String, dynamic>{
  'id': instance.id,
  'churchId': instance.churchId,
  'title': instance.title,
  'goalAmount': instance.goalAmount,
  'currentAmount': instance.currentAmount,
  'status': instance.status,
};

_TransactionDonor _$TransactionDonorFromJson(Map<String, dynamic> json) =>
    _TransactionDonor(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$TransactionDonorToJson(_TransactionDonor instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

_FinancialTransaction _$FinancialTransactionFromJson(
  Map<String, dynamic> json,
) => _FinancialTransaction(
  id: json['id'] as String,
  churchId: json['churchId'] as String,
  type: json['type'] as String,
  category: json['category'] as String,
  amount: json['amount'] as String,
  transactionDate: json['transactionDate'] as String,
  donor: json['donor'] == null
      ? null
      : TransactionDonor.fromJson(json['donor'] as Map<String, dynamic>),
);

Map<String, dynamic> _$FinancialTransactionToJson(
  _FinancialTransaction instance,
) => <String, dynamic>{
  'id': instance.id,
  'churchId': instance.churchId,
  'type': instance.type,
  'category': instance.category,
  'amount': instance.amount,
  'transactionDate': instance.transactionDate,
  'donor': instance.donor,
};

_TransactionPage _$TransactionPageFromJson(Map<String, dynamic> json) =>
    _TransactionPage(
      data: (json['data'] as List<dynamic>)
          .map((e) => FinancialTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
    );

Map<String, dynamic> _$TransactionPageToJson(_TransactionPage instance) =>
    <String, dynamic>{
      'data': instance.data,
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
    };

_FinancialSummary _$FinancialSummaryFromJson(Map<String, dynamic> json) =>
    _FinancialSummary(
      totalIncome: (json['totalIncome'] as num).toDouble(),
      totalExpense: (json['totalExpense'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
    );

Map<String, dynamic> _$FinancialSummaryToJson(_FinancialSummary instance) =>
    <String, dynamic>{
      'totalIncome': instance.totalIncome,
      'totalExpense': instance.totalExpense,
      'balance': instance.balance,
    };
