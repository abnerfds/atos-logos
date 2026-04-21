import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/backend_error_message.dart';
import '../../../core/error/exceptions.dart';
import '../domain/models/branch.dart';

@lazySingleton
class BranchesRepository {
  final Dio _dio;

  BranchesRepository({required Dio dio}) : _dio = dio;

  Future<List<Branch>> getBranches({String? q}) async {
    try {
      final queryParams = <String, dynamic>{};
      // Only attach q when non-empty so the default list request stays
      // a clean GET — backend treats missing q as no filter.
      if (q != null && q.trim().isNotEmpty) {
        queryParams['q'] = q.trim();
      }
      final response = await _dio.get(
        '/branches',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      final list = response.data as List;
      return list
          .map((e) => Branch.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao carregar congregações',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Partial update — only the supplied fields are PATCHed so the
  /// secretary doesn't accidentally blank address columns they didn't
  /// touch. Backend `UpdateBranchDto` has all fields optional.
  Future<Branch> updateBranch({
    required String id,
    String? name,
    String? country,
    String? state,
    String? city,
    String? neighborhood,
    String? street,
    String? number,
  }) async {
    try {
      final payload = <String, dynamic>{
        if (name != null && name.isNotEmpty) 'name': name,
        if (country != null) 'country': country,
        if (state != null) 'state': state,
        if (city != null) 'city': city,
        if (neighborhood != null) 'neighborhood': neighborhood,
        if (street != null) 'street': street,
        if (number != null) 'number': number,
      };
      final response = await _dio.patch(
        '/branches/$id',
        data: payload,
      );
      return Branch.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao atualizar congregação',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Promotes a Filial to Sede. Backend atomically demotes the current
  /// HQ and promotes the target in a single transaction, so this
  /// call never leaves the church with zero or two HQs. The 409
  /// "already headquarters" guard surfaces with the server's message.
  Future<Branch> promoteToHeadquarters(String id) async {
    try {
      final response = await _dio.patch(
        '/branches/$id/promote-to-headquarters',
      );
      return Branch.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao promover congregação',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Deletes a non-headquarters branch. The backend enforces the
  /// "cannot delete HQ" guard and returns 403 in that case — the
  /// caller should surface the server's message verbatim so the
  /// secretary understands why the action was refused.
  Future<void> deleteBranch(String id) async {
    try {
      await _dio.delete('/branches/$id');
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao remover congregação',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Branch> createBranch({
    required String name,
    String? country,
    String? state,
    String? city,
    String? neighborhood,
    String? street,
    String? number,
  }) async {
    try {
      final response = await _dio.post('/branches', data: {
        'name': name,
        if (country != null) 'country': country,
        if (state != null) 'state': state,
        if (city != null) 'city': city,
        if (neighborhood != null) 'neighborhood': neighborhood,
        if (street != null) 'street': street,
        if (number != null) 'number': number,
      });
      return Branch.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao criar congregação',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
