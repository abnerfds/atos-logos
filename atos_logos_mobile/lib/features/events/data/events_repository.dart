import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/backend_error_message.dart';
import '../../../core/error/exceptions.dart';
import '../domain/models/event.dart';

@lazySingleton
class EventsRepository {
  final Dio _dio;

  EventsRepository({required Dio dio}) : _dio = dio;

  Future<EventPage> getEvents({int page = 1, int limit = 20, String? type}) async {
    try {
      final response = await _dio.get('/events', queryParameters: {
        'page': page,
        'limit': limit,
        if (type != null) 'type': type,
      });
      return EventPage.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao carregar eventos',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Event> createEvent({
    required String title,
    required String startsAt,
    required String type,
    String? branchId,
  }) async {
    try {
      final response = await _dio.post('/events', data: {
        'title': title,
        'startsAt': startsAt,
        'type': type,
        if (branchId != null) 'branchId': branchId,
      });
      return Event.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao criar evento',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _dio.delete('/events/$eventId');
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao remover evento',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<EventSchedule> addSchedule(String eventId, {required String userId, required String functionName}) async {
    try {
      final response = await _dio.post('/events/$eventId/schedules', data: {
        'userId': userId,
        'functionName': functionName,
      });
      return EventSchedule.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao adicionar escala',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
