import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/backend_error_message.dart';
import '../../../core/error/exceptions.dart';
import '../domain/models/ebd_class.dart';

@lazySingleton
class EbdRepository {
  final Dio _dio;

  EbdRepository({required Dio dio}) : _dio = dio;

  Future<List<EbdClass>> getClasses() async {
    try {
      final response = await _dio.get('/ebd/classes');
      return (response.data as List)
          .map((e) => EbdClass.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao carregar turmas',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<EbdClass> createClass({required String name, required String branchId}) async {
    try {
      final response = await _dio.post('/ebd/classes', data: {'name': name, 'branchId': branchId});
      return EbdClass.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao criar turma',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<EbdFrequency> getFrequency(String classId, String userId) async {
    try {
      final response = await _dio.get('/ebd/classes/$classId/frequency/$userId');
      return EbdFrequency.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao carregar frequencia',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
