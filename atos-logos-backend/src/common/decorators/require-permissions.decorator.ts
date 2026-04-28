import { SetMetadata } from '@nestjs/common';
import { Permission } from '../enums/permission.enum';

export const PERMISSIONS_KEY = 'permissions';

/**
 * Decorator that specifies which permissions are required to access an endpoint.
 * Works in conjunction with PermissionsGuard to enforce granular authorization.
 * 
 * ADMIN role always bypasses permission checks (full access).
 * SECRETARY and MEMBER roles are checked against the RolePermission configuration.
 * 
 * Usage: @RequirePermissions(Permission.VIEW_MEMBERS, Permission.EDIT_MEMBERS)
 */
export const RequirePermissions = (...permissions: Permission[]) =>
  SetMetadata(PERMISSIONS_KEY, permissions);
