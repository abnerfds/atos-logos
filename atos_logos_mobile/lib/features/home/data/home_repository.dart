import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/backend_error_message.dart';
import '../../../core/error/exceptions.dart';
import '../domain/models/birthday_member.dart';
import '../domain/models/church.dart';
import '../domain/models/upcoming_event.dart';

@lazySingleton
class HomeRepository {
  final Dio _dio;

  HomeRepository({required Dio dio}) : _dio = dio;

  Future<Church> getMyChurch() async {
    try {
      final response = await _dio.get('/churches/me');
      return Church.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final message = parseBackendErrorMessage(e.response?.data) ??
          'Erro ao carregar dados da igreja';
      throw NetworkException(message, statusCode: e.response?.statusCode);
    }
  }

  Future<BirthdaysResponse> getBirthdays({int? month}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (month != null) queryParams['month'] = month;
      final response = await _dio.get(
        '/member-profiles/birthdays',
        queryParameters: queryParams,
      );
      return BirthdaysResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final message =
          parseBackendErrorMessage(e.response?.data) ?? 'Erro ao carregar aniversariantes';
      throw NetworkException(message, statusCode: e.response?.statusCode);
    }
  }

  /// Fetches the N upcoming events and parses each one into a typed
  /// [UpcomingEvent]. The mobile app never touches the raw JSON shape —
  /// the nested `branch.name` is flattened into [UpcomingEvent.branchName]
  /// at this boundary and the `startsAt` ISO string is parsed into a
  /// real [DateTime].
  Future<List<UpcomingEvent>> getUpcomingEvents({int limit = 5}) async {
    try {
      final response = await _dio.get(
        '/events',
        queryParameters: {'upcoming': true, 'limit': limit},
      );
      final data = (response.data as Map<String, dynamic>)['data'] as List;
      return data
          .map((e) => UpcomingEvent.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final message =
          parseBackendErrorMessage(e.response?.data) ?? 'Erro ao carregar eventos';
      throw NetworkException(message, statusCode: e.response?.statusCode);
    }
  }
}
