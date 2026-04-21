import { SetMetadata } from '@nestjs/common';
import { Role } from '@prisma/client';

export const ROLES_KEY = 'roles';

/**
 * Decorator that specifies which roles are allowed to access an endpoint.
 * Usage: @Roles(Role.ADMIN, Role.SECRETARY)
 */
export const Roles = (...roles: Role[]) => SetMetadata(ROLES_KEY, roles);
