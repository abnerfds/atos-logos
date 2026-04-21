import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/backend_error_message.dart';
import '../../../core/error/exceptions.dart';
import '../../members/domain/models/member_profile.dart';

@lazySingleton
class ProfileRepository {
  final Dio _dio;

  ProfileRepository({required Dio dio}) : _dio = dio;

  Future<MemberProfile> getMemberProfile(String profileId) async {
    try {
      final response = await _dio.get('/member-profiles/$profileId');
      return MemberProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao carregar perfil',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<MemberProfile> getMemberProfileByUserId(String userId) async {
    try {
      final response = await _dio.get('/member-profiles/by-user/$userId');
      return MemberProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao carregar perfil',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> updateMyProfile(Map<String, dynamic> data) async {
    try {
      await _dio.patch('/auth/me', data: data);
    } on DioException catch (e) {
      throw NetworkException(
        parseBackendErrorMessage(e.response?.data) ?? 'Erro ao atualizar perfil',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
