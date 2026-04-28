/// Granular permissions enum matching the backend Permission enum.
/// Each permission represents a specific action that can be granted or denied.
enum Permission {
  // Secretaria (Members Management)
  viewMembers('view_members', 'Ver Membros'),
  editMembers('edit_members', 'Editar Membros'),
  deleteMembers('delete_members', 'Excluir Membros'),
  createMembers('create_members', 'Criar Membros'),

  // Financeiro (Financial)
  viewContributions('view_contributions', 'Ver Contribuições'),
  launchOfferings('launch_offerings', 'Lançar Ofertas'),
  editTransactions('edit_transactions', 'Editar Transações'),
  deleteTransactions('delete_transactions', 'Excluir Transações'),

  // EBD (Sunday School)
  manageClasses('manage_classes', 'Gerenciar Classes'),
  takeAttendance('take_attendance', 'Realizar Chamada'),
  viewEbdReports('view_ebd_reports', 'Ver Relatórios EBD'),

  // Eventos (Events)
  viewEvents('view_events', 'Ver Eventos'),
  createEvents('create_events', 'Criar Eventos'),
  editEvents('edit_events', 'Editar Eventos'),
  deleteEvents('delete_events', 'Excluir Eventos'),

  // Visitantes (Visitors)
  viewVisitors('view_visitors', 'Ver Visitantes'),
  editVisitors('edit_visitors', 'Editar Visitantes'),
  deleteVisitors('delete_visitors', 'Excluir Visitantes'),

  // Congregações (Branches)
  viewBranches('view_branches', 'Ver Congregações'),
  createBranches('create_branches', 'Criar Congregações'),
  editBranches('edit_branches', 'Editar Congregações'),
  deleteBranches('delete_branches', 'Excluir Congregações'),

  // Cargos (Positions)
  managePositions('manage_positions', 'Gerenciar Cargos'),

  // Configurações (Settings)
  manageRoles('manage_roles', 'Gerenciar Funções'),
  viewChurchSettings('view_church_settings', 'Ver Configurações'),
  editChurchSettings('edit_church_settings', 'Editar Configurações');

  const Permission(this.value, this.label);

  final String value;
  final String label;

  static Permission? fromValue(String value) {
    try {
      return Permission.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }
}

/// Permission categories for UI grouping
enum PermissionCategory {
  secretaria('Secretaria'),
  financeiro('Financeiro'),
  ebd('EBD'),
  eventos('Eventos'),
  visitantes('Visitantes'),
  congregacoes('Congregações'),
  cargos('Cargos'),
  configuracoes('Configurações');

  const PermissionCategory(this.label);

  final String label;

  List<Permission> get permissions {
    switch (this) {
      case PermissionCategory.secretaria:
        return [
          Permission.viewMembers,
          Permission.editMembers,
          Permission.deleteMembers,
          Permission.createMembers,
        ];
      case PermissionCategory.financeiro:
        return [
          Permission.viewContributions,
          Permission.launchOfferings,
          Permission.editTransactions,
          Permission.deleteTransactions,
        ];
      case PermissionCategory.ebd:
        return [
          Permission.manageClasses,
          Permission.takeAttendance,
          Permission.viewEbdReports,
        ];
      case PermissionCategory.eventos:
        return [
          Permission.viewEvents,
          Permission.createEvents,
          Permission.editEvents,
          Permission.deleteEvents,
        ];
      case PermissionCategory.visitantes:
        return [
          Permission.viewVisitors,
          Permission.editVisitors,
          Permission.deleteVisitors,
        ];
      case PermissionCategory.congregacoes:
        return [
          Permission.viewBranches,
          Permission.createBranches,
          Permission.editBranches,
          Permission.deleteBranches,
        ];
      case PermissionCategory.cargos:
        return [Permission.managePositions];
      case PermissionCategory.configuracoes:
        return [
          Permission.manageRoles,
          Permission.viewChurchSettings,
          Permission.editChurchSettings,
        ];
    }
  }
}
