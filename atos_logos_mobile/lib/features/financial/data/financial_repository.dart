import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/backend_error_message.dart';
import '../../../core/error/exceptions.dart';
import '../domain/models/financial.dart';

@lazySingleton
class FinancialRepository {
  final Dio _dio;

  FinancialRepository({required Dio dio}) : _dio = dio;

  Future<List<Campaign>> getCampaigns() async {
    try {
      final response = await _dio.get('/financial/campaigns');
      return (response.data as List)
          .map((e) => Campaign.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao carregar campanhas',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<TransactionPage> getTransactions({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get('/financial/transactions', queryParameters: {'page': page, 'limit': limit});
      return TransactionPage.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao carregar transacoes',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<FinancialSummary> getSummary() async {
    try {
      final response = await _dio.get('/financial/summary');
      return FinancialSummary.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao carregar resumo',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
