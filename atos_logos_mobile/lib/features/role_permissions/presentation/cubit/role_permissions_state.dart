import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:atos_logos_mobile/features/role_permissions/domain/models/role_permission.dart';

part 'role_permissions_state.freezed.dart';

@freezed
class RolePermissionsState with _$RolePermissionsState {
  const factory RolePermissionsState.initial() = _Initial;
  const factory RolePermissionsState.loading() = _Loading;
  const factory RolePermissionsState.loaded(List<RolePermission> roles) =
      _Loaded;
  const factory RolePermissionsState.error(String message) = _Error;
}
