import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/backend_error_message.dart';
import '../../../core/error/exceptions.dart';
import '../domain/models/position.dart';

@lazySingleton
class PositionsRepository {
  final Dio _dio;

  PositionsRepository({required Dio dio}) : _dio = dio;

  Future<List<Position>> getPositions() async {
    try {
      final response = await _dio.get('/member-positions');
      return (response.data as List)
          .map((e) => Position.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao carregar cargos',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Position> createPosition(String name) async {
    try {
      final response = await _dio.post('/member-positions', data: {'name': name});
      return Position.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao criar cargo',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> deletePosition(String positionId) async {
    try {
      await _dio.delete('/member-positions/$positionId');
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao remover cargo',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> assignUser(String positionId, String userId) async {
    try {
      await _dio.post('/member-positions/$positionId/users', data: {'userId': userId});
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao atribuir cargo',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> unassignUser(String positionId, String userId) async {
    try {
      await _dio.delete('/member-positions/$positionId/users/$userId');
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao remover atribuicao',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
