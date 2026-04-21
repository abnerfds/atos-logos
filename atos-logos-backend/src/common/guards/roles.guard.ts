import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Role } from '@prisma/client';
import { ROLES_KEY } from '../decorators/roles.decorator';

/**
 * Guard that checks if the authenticated user has one of the required roles.
 * If no @Roles() decorator is present, access is granted (public within auth).
 */
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<Role[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    // No @Roles decorator = no role restriction (still requires JWT auth)
    if (!requiredRoles || requiredRoles.length === 0) {
      return true;
    }

    const { role } = context.switchToHttp().getRequest().user;
    return requiredRoles.includes(role);
  }
}
