import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/backend_error_message.dart';
import '../../../core/error/exceptions.dart';
import '../domain/models/visitor.dart';

@lazySingleton
class VisitorsRepository {
  final Dio _dio;

  VisitorsRepository({required Dio dio}) : _dio = dio;

  Future<VisitorPage> getVisitors({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get('/visitors', queryParameters: {'page': page, 'limit': limit});
      return VisitorPage.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao carregar visitantes',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Visitor> createVisitor({required String name, String? phone, String? observations}) async {
    try {
      final response = await _dio.post('/visitors', data: {
        'name': name,
        if (phone != null) 'phone': phone,
        if (observations != null) 'observations': observations,
      });
      return Visitor.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao cadastrar visitante',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> checkIn(String visitorId, String eventId) async {
    try {
      await _dio.post('/visitors/$visitorId/check-in/$eventId');
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao fazer check-in',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
