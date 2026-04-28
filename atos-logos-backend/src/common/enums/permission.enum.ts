/**
 * Granular permissions enum for the authorization system.
 * Each permission represents a specific action that can be granted or denied
 * to roles (ADMIN, SECRETARY, MEMBER) on a per-church basis.
 */
export enum Permission {
  // ── Secretaria (Members Management) ──────────────────────────────────────
  VIEW_MEMBERS = 'view_members',
  EDIT_MEMBERS = 'edit_members',
  DELETE_MEMBERS = 'delete_members',
  CREATE_MEMBERS = 'create_members',

  // ── Financeiro (Financial) ───────────────────────────────────────────────
  VIEW_CONTRIBUTIONS = 'view_contributions',
  LAUNCH_OFFERINGS = 'launch_offerings',
  EDIT_TRANSACTIONS = 'edit_transactions',
  DELETE_TRANSACTIONS = 'delete_transactions',

  // ── EBD (Sunday School) ──────────────────────────────────────────────────
  MANAGE_CLASSES = 'manage_classes',
  TAKE_ATTENDANCE = 'take_attendance',
  VIEW_EBD_REPORTS = 'view_ebd_reports',

  // ── Eventos (Events) ─────────────────────────────────────────────────────
  VIEW_EVENTS = 'view_events',
  CREATE_EVENTS = 'create_events',
  EDIT_EVENTS = 'edit_events',
  DELETE_EVENTS = 'delete_events',

  // ── Visitantes (Visitors) ────────────────────────────────────────────────
  VIEW_VISITORS = 'view_visitors',
  EDIT_VISITORS = 'edit_visitors',
  DELETE_VISITORS = 'delete_visitors',

  // ── Congregações (Branches) ──────────────────────────────────────────────
  VIEW_BRANCHES = 'view_branches',
  CREATE_BRANCHES = 'create_branches',
  EDIT_BRANCHES = 'edit_branches',
  DELETE_BRANCHES = 'delete_branches',

  // ── Cargos (Positions) ───────────────────────────────────────────────────
  MANAGE_POSITIONS = 'manage_positions',

  // ── Configurações (Settings) ─────────────────────────────────────────────
  MANAGE_ROLES = 'manage_roles',
  VIEW_CHURCH_SETTINGS = 'view_church_settings',
  EDIT_CHURCH_SETTINGS = 'edit_church_settings',
}
