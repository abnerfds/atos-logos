import 'package:atos_logos_mobile/core/enums/role.dart';
import 'package:atos_logos_mobile/features/role_permissions/domain/models/role_permission.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class RolePermissionsRepository {
  final Dio _dio;

  RolePermissionsRepository({required Dio dio}) : _dio = dio;

  /// Fetches all role permission configurations for the current church
  Future<List<RolePermission>> fetchAll() async {
    final response = await _dio.get('/role-permissions');
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) => RolePermission.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetches permission configuration for a specific role
  Future<RolePermission> fetchOne(Role role) async {
    final response = await _dio.get('/role-permissions/${role.value}');
    return RolePermission.fromJson(response.data as Map<String, dynamic>);
  }

  /// Updates permission configuration for a specific role
  Future<RolePermission> update(
    Role role,
    Map<String, bool> permissions,
  ) async {
    final response = await _dio.patch(
      '/role-permissions/${role.value}',
      data: {'permissions': permissions},
    );
    return RolePermission.fromJson(response.data as Map<String, dynamic>);
  }
}
