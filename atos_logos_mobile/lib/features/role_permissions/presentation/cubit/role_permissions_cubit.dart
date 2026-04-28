import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:atos_logos_mobile/core/enums/role.dart';
import 'package:atos_logos_mobile/features/role_permissions/data/repositories/role_permissions_repository.dart';
import 'package:atos_logos_mobile/features/role_permissions/presentation/cubit/role_permissions_state.dart';

@injectable
class RolePermissionsCubit extends Cubit<RolePermissionsState> {
  final RolePermissionsRepository _repository;

  RolePermissionsCubit({required RolePermissionsRepository repository})
      : _repository = repository,
        super(const RolePermissionsState.initial());

  Future<void> loadRoles() async {
    emit(const RolePermissionsState.loading());
    try {
      final roles = await _repository.fetchAll();
      emit(RolePermissionsState.loaded(roles));
    } catch (e) {
      emit(RolePermissionsState.error(e.toString()));
    }
  }

  Future<void> updatePermissions(
    Role role,
    Map<String, bool> permissions,
  ) async {
    state.whenOrNull(
      loaded: (currentRoles) async {
        emit(const RolePermissionsState.loading());
        try {
          final updated = await _repository.update(role, permissions);
          
          // Update the list with the new configuration
          final updatedList = currentRoles.map((r) {
            return r.role == role ? updated : r;
          }).toList();
          
          emit(RolePermissionsState.loaded(updatedList));
        } catch (e) {
          emit(RolePermissionsState.error(e.toString()));
          // Restore previous state after showing error
          emit(RolePermissionsState.loaded(currentRoles));
        }
      },
    );
  }
}
