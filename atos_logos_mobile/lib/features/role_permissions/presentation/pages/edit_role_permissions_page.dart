import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:atos_logos_mobile/core/enums/permission.dart';
import 'package:atos_logos_mobile/core/enums/role.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:atos_logos_mobile/features/role_permissions/domain/models/role_permission.dart';
import 'package:atos_logos_mobile/features/role_permissions/presentation/cubit/role_permissions_cubit.dart';
import 'package:atos_logos_mobile/features/role_permissions/presentation/cubit/role_permissions_state.dart';

/// Edição de Permissões - Permite configurar permissões granulares por função
class EditRolePermissionsPage extends StatefulWidget {
  final String roleValue;

  const EditRolePermissionsPage({
    super.key,
    required this.roleValue,
  });

  @override
  State<EditRolePermissionsPage> createState() =>
      _EditRolePermissionsPageState();
}

class _EditRolePermissionsPageState extends State<EditRolePermissionsPage> {
  late Role role;
  late Map<String, bool> permissions;
  bool isModified = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    role = Role.fromValue(widget.roleValue);
    permissions = {};
  }

  void _togglePermission(String key, bool value) {
    if (role == Role.admin) return; // ADMIN cannot be modified

    setState(() {
      permissions[key] = value;
      isModified = true;
    });
  }

  Future<void> _saveChanges() async {
    if (!isModified || isSaving) return;

    setState(() => isSaving = true);

    try {
      await context.read<RolePermissionsCubit>().updatePermissions(
            role,
            permissions,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Permissões atualizadas com sucesso',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao salvar: $e',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            backgroundColor: const Color(0xFFE53935),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        // Check if user is ADMIN
        final isAdmin = authState.maybeWhen(
          authenticated: (profile) => profile?.membership.role == 'ADMIN',
          orElse: () => false,
        );

        // If not ADMIN, show access denied
        if (!isAdmin) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: Color(0xFF9CA4AB),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Acesso Restrito',
                    style: GoogleFonts.manrope(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2C3338),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Apenas administradores podem editar permissões.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF596065),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.home),
                    label: const Text('Voltar ao Início'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF37628A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Stack(
          children: [
            BlocBuilder<RolePermissionsCubit, RolePermissionsState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const SizedBox.shrink(),
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Color(0xFF37628A)),
                  ),
                  loaded: (roles) {
                    final roleConfig = roles.firstWhere((r) => r.role == role);
                    if (permissions.isEmpty) {
                      permissions = Map.from(roleConfig.permissions);
                    }
                    return _buildContent(context, roleConfig);
                  },
                  error: (message) => Center(
                    child: Text(
                      'Erro: $message',
                      style: GoogleFonts.inter(color: Colors.red),
                    ),
                  ),
                );
              },
            ),
            if (isModified && !isSaving)
              Positioned(
                left: 0,
                right: 0,
                bottom: 80,
                child: Center(
                  child: FloatingActionButton.extended(
                    onPressed: _saveChanges,
                    backgroundColor: const Color(0xFF37628A),
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: Text(
                      'Salvar Alterações',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, RolePermission roleConfig) {
    final isAdmin = role == Role.admin;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Permissões: ${role.label}',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2C3338),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isAdmin
                ? 'O Administrador possui acesso total incondicional ao sistema'
                : 'Habilite as ações permitidas para esta função',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isAdmin ? const Color(0xFFE65100) : const Color(0xFF596065),
            ),
          ),
          const SizedBox(height: 24),
          ...PermissionCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildCategoryCard(category, isAdmin),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(PermissionCategory category, bool isAdmin) {
    final categoryPermissions = category.permissions;

    // Color mapping for each category
    final categoryColors = {
      PermissionCategory.secretaria: const Color(0xFF37628A),
      PermissionCategory.financeiro: const Color(0xFF4CAF50),
      PermissionCategory.ebd: const Color(0xFF9B7EBD),
      PermissionCategory.eventos: const Color(0xFFFF9800),
      PermissionCategory.visitantes: const Color(0xFF00BCD4),
      PermissionCategory.congregacoes: const Color(0xFF795548),
      PermissionCategory.cargos: const Color(0xFFE91E63),
      PermissionCategory.configuracoes: const Color(0xFF607D8B),
    };

    final color = categoryColors[category] ?? const Color(0xFF37628A);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  category.label,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE8EBED)),
          ...categoryPermissions.map((permission) {
            final permissionIcon = _getPermissionIcon(permission);
            final isEnabled = permissions[permission.value] ?? false;

            return _buildPermissionTile(
              icon: permissionIcon,
              label: permission.label,
              value: isEnabled,
              onChanged: isAdmin
                  ? null
                  : (value) => _togglePermission(permission.value, value),
              color: color,
            );
          }),
        ],
      ),
    );
  }

  IconData _getPermissionIcon(Permission permission) {
    switch (permission) {
      case Permission.viewMembers:
        return Icons.visibility;
      case Permission.editMembers:
        return Icons.edit;
      case Permission.deleteMembers:
        return Icons.delete;
      case Permission.createMembers:
        return Icons.person_add;
      case Permission.viewContributions:
        return Icons.payments;
      case Permission.launchOfferings:
        return Icons.add_card;
      case Permission.editTransactions:
        return Icons.edit_note;
      case Permission.deleteTransactions:
        return Icons.delete_outline;
      case Permission.manageClasses:
        return Icons.class_;
      case Permission.takeAttendance:
        return Icons.fact_check;
      case Permission.viewEbdReports:
        return Icons.assessment;
      case Permission.viewEvents:
        return Icons.event;
      case Permission.createEvents:
        return Icons.add_circle_outline;
      case Permission.editEvents:
        return Icons.edit_calendar;
      case Permission.deleteEvents:
        return Icons.event_busy;
      case Permission.viewVisitors:
        return Icons.people;
      case Permission.editVisitors:
        return Icons.person_add_alt;
      case Permission.deleteVisitors:
        return Icons.person_remove;
      case Permission.viewBranches:
        return Icons.church;
      case Permission.createBranches:
        return Icons.add_business;
      case Permission.editBranches:
        return Icons.edit_location;
      case Permission.deleteBranches:
        return Icons.delete_forever;
      case Permission.managePositions:
        return Icons.badge;
      case Permission.manageRoles:
        return Icons.admin_panel_settings;
      case Permission.viewChurchSettings:
        return Icons.settings;
      case Permission.editChurchSettings:
        return Icons.tune;
    }
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool>? onChanged,
    required Color color,
  }) {
    final isDisabled = onChanged == null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (value ? color : const Color(0xFF9CA4AB))
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: value ? color : const Color(0xFF9CA4AB),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2C3338),
                  ),
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeTrackColor: color,
                inactiveThumbColor: const Color(0xFFE8EBED),
                inactiveTrackColor: const Color(0xFFF5F7FA),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
