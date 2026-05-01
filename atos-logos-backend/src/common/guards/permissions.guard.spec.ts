import { ExecutionContext, ForbiddenException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Role } from '@prisma/client';
import { PermissionsGuard } from './permissions.guard';
import { Permission } from '../enums/permission.enum';
import type { AuthenticatedUser } from '../interfaces/authenticated-user.interface';

// Minimal stub — typed as `any` to avoid TS fighting Prisma's fluent API
// return types (PrismaClientKnownRequestError vs jest.Mock) on findUnique.
function buildPrismaMock() {
  return {
    rolePermission: {
      findUnique: jest.fn(),
    },
  };
}

describe('PermissionsGuard', () => {
  let guard: PermissionsGuard;
  let reflector: jest.Mocked<Reflector>;
  let prisma: ReturnType<typeof buildPrismaMock>;

  beforeEach(() => {
    reflector = {
      getAllAndOverride: jest.fn(),
    } as any;

    prisma = buildPrismaMock();

    guard = new PermissionsGuard(reflector, prisma as any);
  });

  const mockExecutionContext = (user: AuthenticatedUser): ExecutionContext => {
    return {
      switchToHttp: () => ({
        getRequest: () => ({ user }),
      }),
      getHandler: jest.fn(),
      getClass: jest.fn(),
    } as any;
  };

  describe('when no @RequirePermissions decorator is present', () => {
    it('should allow access without checking permissions', async () => {
      // Given — no required permissions
      reflector.getAllAndOverride.mockReturnValue(undefined);

      const user: AuthenticatedUser = {
        userId: 'u1',
        email: 'test@test.com',
        churchId: 'c1',
        branchId: 'b1',
        role: Role.MEMBER,
      };

      const context = mockExecutionContext(user);

      // When
      const result = await guard.canActivate(context);

      // Then
      expect(result).toBe(true);
      expect(prisma.rolePermission.findUnique).not.toHaveBeenCalled();
    });
  });

  describe('when @RequirePermissions decorator is present', () => {
    it('should allow ADMIN unconditionally without checking database', async () => {
      // Given — ADMIN user with required permissions
      reflector.getAllAndOverride.mockReturnValue([Permission.VIEW_MEMBERS]);

      const user: AuthenticatedUser = {
        userId: 'u1',
        email: 'admin@test.com',
        churchId: 'c1',
        branchId: 'b1',
        role: Role.ADMIN,
      };

      const context = mockExecutionContext(user);

      // When
      const result = await guard.canActivate(context);

      // Then
      expect(result).toBe(true);
      expect(prisma.rolePermission.findUnique).not.toHaveBeenCalled();
    });

    it('should allow SECRETARY when they have the required permission', async () => {
      // Given — SECRETARY with VIEW_MEMBERS permission
      reflector.getAllAndOverride.mockReturnValue([Permission.VIEW_MEMBERS]);

      const user: AuthenticatedUser = {
        userId: 'u1',
        email: 'secretary@test.com',
        churchId: 'c1',
        branchId: 'b1',
        role: Role.SECRETARY,
      };

      prisma.rolePermission.findUnique.mockResolvedValue({
        id: 'rp1',
        churchId: 'c1',
        role: Role.SECRETARY,
        permissions: {
          [Permission.VIEW_MEMBERS]: true,
          [Permission.EDIT_MEMBERS]: false,
        },
        createdAt: new Date(),
        updatedAt: new Date(),
      });

      const context = mockExecutionContext(user);

      // When
      const result = await guard.canActivate(context);

      // Then
      expect(result).toBe(true);
      expect(prisma.rolePermission.findUnique).toHaveBeenCalledWith({
        where: {
          churchId_role: {
            churchId: 'c1',
            role: Role.SECRETARY,
          },
        },
      });
    });

    it('should deny SECRETARY when they lack the required permission', async () => {
      // Given — SECRETARY without DELETE_MEMBERS permission
      reflector.getAllAndOverride.mockReturnValue([Permission.DELETE_MEMBERS]);

      const user: AuthenticatedUser = {
        userId: 'u1',
        email: 'secretary@test.com',
        churchId: 'c1',
        branchId: 'b1',
        role: Role.SECRETARY,
      };

      prisma.rolePermission.findUnique.mockResolvedValue({
        id: 'rp1',
        churchId: 'c1',
        role: Role.SECRETARY,
        permissions: {
          [Permission.VIEW_MEMBERS]: true,
          [Permission.DELETE_MEMBERS]: false,
        },
        createdAt: new Date(),
        updatedAt: new Date(),
      });

      const context = mockExecutionContext(user);

      // When / Then
      await expect(guard.canActivate(context)).rejects.toThrow(
        ForbiddenException,
      );
      await expect(guard.canActivate(context)).rejects.toThrow(
        'You do not have the required permissions to perform this action',
      );
    });

    it('should deny MEMBER when they lack the required permission', async () => {
      // Given — MEMBER without EDIT_MEMBERS permission
      reflector.getAllAndOverride.mockReturnValue([Permission.EDIT_MEMBERS]);

      const user: AuthenticatedUser = {
        userId: 'u1',
        email: 'member@test.com',
        churchId: 'c1',
        branchId: 'b1',
        role: Role.MEMBER,
      };

      prisma.rolePermission.findUnique.mockResolvedValue({
        id: 'rp1',
        churchId: 'c1',
        role: Role.MEMBER,
        permissions: {
          [Permission.VIEW_MEMBERS]: false,
          [Permission.EDIT_MEMBERS]: false,
        },
        createdAt: new Date(),
        updatedAt: new Date(),
      });

      const context = mockExecutionContext(user);

      // When / Then
      await expect(guard.canActivate(context)).rejects.toThrow(
        ForbiddenException,
      );
    });

    it('should deny when no permission configuration exists for the role', async () => {
      // Given — SECRETARY with no configuration in database
      reflector.getAllAndOverride.mockReturnValue([Permission.VIEW_MEMBERS]);

      const user: AuthenticatedUser = {
        userId: 'u1',
        email: 'secretary@test.com',
        churchId: 'c1',
        branchId: 'b1',
        role: Role.SECRETARY,
      };

      prisma.rolePermission.findUnique.mockResolvedValue(null);

      const context = mockExecutionContext(user);

      // When / Then
      await expect(guard.canActivate(context)).rejects.toThrow(
        ForbiddenException,
      );
      await expect(guard.canActivate(context)).rejects.toThrow(
        'No permission configuration found for your role',
      );
    });

    it('should require ALL permissions when multiple are specified', async () => {
      // Given — SECRETARY with only one of two required permissions
      reflector.getAllAndOverride.mockReturnValue([
        Permission.VIEW_MEMBERS,
        Permission.EDIT_MEMBERS,
      ]);

      const user: AuthenticatedUser = {
        userId: 'u1',
        email: 'secretary@test.com',
        churchId: 'c1',
        branchId: 'b1',
        role: Role.SECRETARY,
      };

      prisma.rolePermission.findUnique.mockResolvedValue({
        id: 'rp1',
        churchId: 'c1',
        role: Role.SECRETARY,
        permissions: {
          [Permission.VIEW_MEMBERS]: true,
          [Permission.EDIT_MEMBERS]: false, // Missing this one
        },
        createdAt: new Date(),
        updatedAt: new Date(),
      });

      const context = mockExecutionContext(user);

      // When / Then
      await expect(guard.canActivate(context)).rejects.toThrow(
        ForbiddenException,
      );
    });

    it('should allow when user has ALL required permissions', async () => {
      // Given — SECRETARY with both required permissions
      reflector.getAllAndOverride.mockReturnValue([
        Permission.VIEW_MEMBERS,
        Permission.EDIT_MEMBERS,
      ]);

      const user: AuthenticatedUser = {
        userId: 'u1',
        email: 'secretary@test.com',
        churchId: 'c1',
        branchId: 'b1',
        role: Role.SECRETARY,
      };

      prisma.rolePermission.findUnique.mockResolvedValue({
        id: 'rp1',
        churchId: 'c1',
        role: Role.SECRETARY,
        permissions: {
          [Permission.VIEW_MEMBERS]: true,
          [Permission.EDIT_MEMBERS]: true,
        },
        createdAt: new Date(),
        updatedAt: new Date(),
      });

      const context = mockExecutionContext(user);

      // When
      const result = await guard.canActivate(context);

      // Then
      expect(result).toBe(true);
    });
  });
});
