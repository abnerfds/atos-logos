import {
  CanActivate,
  ExecutionContext,
  Injectable,
  ForbiddenException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Role } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.service';
import { PERMISSIONS_KEY } from '../decorators/require-permissions.decorator';
import { Permission } from '../enums/permission.enum';
import type { AuthenticatedUser } from '../interfaces/authenticated-user.interface';

/**
 * Guard that enforces granular permission checks based on the @RequirePermissions decorator.
 * 
 * Authorization Logic:
 * 1. If no @RequirePermissions decorator is present, access is granted (falls back to @Roles if any)
 * 2. If user role is ADMIN, access is ALWAYS granted (unconditional full access)
 * 3. For SECRETARY and MEMBER roles:
 *    - Fetches the RolePermission configuration for the user's church and role
 *    - Checks if ALL required permissions are set to true in the JSON
 *    - Denies access (403) if any required permission is missing or false
 */
@Injectable()
export class PermissionsGuard implements CanActivate {
  constructor(
    private reflector: Reflector,
    private prisma: PrismaService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const requiredPermissions = this.reflector.getAllAndOverride<Permission[]>(
      PERMISSIONS_KEY,
      [context.getHandler(), context.getClass()],
    );

    // No @RequirePermissions decorator = no permission restriction
    if (!requiredPermissions || requiredPermissions.length === 0) {
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const user: AuthenticatedUser = request.user;

    if (!user) {
      throw new ForbiddenException('User not authenticated');
    }

    // ADMIN has unconditional full access to everything
    if (user.role === Role.ADMIN) {
      return true;
    }

    // For SECRETARY and MEMBER, check granular permissions
    const rolePermission = await this.prisma.rolePermission.findUnique({
      where: {
        churchId_role: {
          churchId: user.churchId,
          role: user.role,
        },
      },
    });

    // If no configuration exists, deny access by default (fail-safe)
    if (!rolePermission) {
      throw new ForbiddenException(
        'No permission configuration found for your role',
      );
    }

    const permissions = rolePermission.permissions as Record<string, boolean>;

    // Check if ALL required permissions are granted
    const hasAllPermissions = requiredPermissions.every(
      (permission) => permissions[permission] === true,
    );

    if (!hasAllPermissions) {
      throw new ForbiddenException(
        'You do not have the required permissions to perform this action',
      );
    }

    return true;
  }
}
