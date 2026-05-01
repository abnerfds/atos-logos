import { NotFoundException } from '@nestjs/common';
import { Role } from '@prisma/client';
import { RolePermissionsService } from './role-permissions.service';
import { Permission } from '../../common/enums/permission.enum';

function buildPrismaMock() {
  return {
    rolePermission: {
      findUnique: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
    },
  };
}

describe('RolePermissionsService', () => {
  let service: RolePermissionsService;
  let prisma: ReturnType<typeof buildPrismaMock>;

  const churchId = 'church-123';

  beforeEach(() => {
    prisma = buildPrismaMock();
    service = new RolePermissionsService(prisma as any);
  });

  describe('findAll', () => {
    it('should return all role configurations when they exist', async () => {
      // Given — all roles have configurations
      prisma.rolePermission.findUnique
        .mockResolvedValueOnce({
          id: 'rp1',
          churchId,
          role: Role.ADMIN,
          permissions: {},
          createdAt: new Date(),
          updatedAt: new Date(),
        })
        .mockResolvedValueOnce({
          id: 'rp2',
          churchId,
          role: Role.SECRETARY,
          permissions: { [Permission.VIEW_MEMBERS]: true },
          createdAt: new Date(),
          updatedAt: new Date(),
        })
        .mockResolvedValueOnce({
          id: 'rp3',
          churchId,
          role: Role.MEMBER,
          permissions: { [Permission.VIEW_EVENTS]: true },
          createdAt: new Date(),
          updatedAt: new Date(),
        });

      // When
      const result = await service.findAll(churchId);

      // Then
      expect(result).toHaveLength(3);
      expect(result[0].role).toBe(Role.ADMIN);
      expect(result[1].role).toBe(Role.SECRETARY);
      expect(result[2].role).toBe(Role.MEMBER);
    });

    it('should create default configurations when they do not exist', async () => {
      // Given — no configurations exist
      prisma.rolePermission.findUnique.mockResolvedValue(null);
      prisma.rolePermission.create.mockImplementation((args: any) => {
        return Promise.resolve({
          id: 'new-rp',
          churchId,
          role: args.data.role,
          permissions: args.data.permissions,
          createdAt: new Date(),
          updatedAt: new Date(),
        });
      });

      // When
      const result = await service.findAll(churchId);

      // Then
      expect(result).toHaveLength(3);
      expect(prisma.rolePermission.create).toHaveBeenCalledTimes(3);
      expect(prisma.rolePermission.create).toHaveBeenCalledWith({
        data: {
          churchId,
          role: Role.ADMIN,
          permissions: expect.any(Object),
        },
      });
    });
  });

  describe('findOne', () => {
    it('should return the configuration when it exists', async () => {
      // Given — configuration exists
      const mockConfig = {
        id: 'rp1',
        churchId,
        role: Role.SECRETARY,
        permissions: { [Permission.VIEW_MEMBERS]: true },
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      prisma.rolePermission.findUnique.mockResolvedValue(mockConfig);

      // When
      const result = await service.findOne(churchId, Role.SECRETARY);

      // Then
      expect(result.role).toBe(Role.SECRETARY);
      expect(result.permissions).toEqual({ [Permission.VIEW_MEMBERS]: true });
    });

    it('should create default configuration when it does not exist', async () => {
      // Given — no configuration exists
      prisma.rolePermission.findUnique.mockResolvedValue(null);
      prisma.rolePermission.create.mockResolvedValue({
        id: 'new-rp',
        churchId,
        role: Role.MEMBER,
        permissions: { [Permission.VIEW_EVENTS]: true },
        createdAt: new Date(),
        updatedAt: new Date(),
      });

      // When
      const result = await service.findOne(churchId, Role.MEMBER);

      // Then
      expect(result.role).toBe(Role.MEMBER);
      expect(prisma.rolePermission.create).toHaveBeenCalledWith({
        data: {
          churchId,
          role: Role.MEMBER,
          permissions: expect.any(Object),
        },
      });
    });
  });

  describe('update', () => {
    it('should update permissions for SECRETARY role', async () => {
      // Given — existing configuration
      prisma.rolePermission.findUnique.mockResolvedValue({
        id: 'rp1',
        churchId,
        role: Role.SECRETARY,
        permissions: { [Permission.VIEW_MEMBERS]: true },
        createdAt: new Date(),
        updatedAt: new Date(),
      });

      const newPermissions = {
        [Permission.VIEW_MEMBERS]: true,
        [Permission.EDIT_MEMBERS]: true,
      };

      prisma.rolePermission.update.mockResolvedValue({
        id: 'rp1',
        churchId,
        role: Role.SECRETARY,
        permissions: newPermissions,
        createdAt: new Date(),
        updatedAt: new Date(),
      });

      // When
      const result = await service.update(churchId, Role.SECRETARY, {
        permissions: newPermissions,
      });

      // Then
      expect(result.permissions).toEqual(newPermissions);
      expect(prisma.rolePermission.update).toHaveBeenCalledWith({
        where: { churchId_role: { churchId, role: Role.SECRETARY } },
        data: { permissions: newPermissions },
      });
    });

    it('should update permissions for MEMBER role', async () => {
      // Given — existing configuration
      prisma.rolePermission.findUnique.mockResolvedValue({
        id: 'rp1',
        churchId,
        role: Role.MEMBER,
        permissions: {},
        createdAt: new Date(),
        updatedAt: new Date(),
      });

      const newPermissions = {
        [Permission.VIEW_EVENTS]: true,
      };

      prisma.rolePermission.update.mockResolvedValue({
        id: 'rp1',
        churchId,
        role: Role.MEMBER,
        permissions: newPermissions,
        createdAt: new Date(),
        updatedAt: new Date(),
      });

      // When
      const result = await service.update(churchId, Role.MEMBER, {
        permissions: newPermissions,
      });

      // Then
      expect(result.permissions).toEqual(newPermissions);
    });

    it('should reject updates to ADMIN role', async () => {
      // Given — attempt to update ADMIN
      const newPermissions = {
        [Permission.VIEW_MEMBERS]: false,
      };

      // When / Then
      await expect(
        service.update(churchId, Role.ADMIN, { permissions: newPermissions }),
      ).rejects.toThrow(NotFoundException);

      await expect(
        service.update(churchId, Role.ADMIN, { permissions: newPermissions }),
      ).rejects.toThrow(
        'ADMIN permissions cannot be modified - they have unconditional full access',
      );

      expect(prisma.rolePermission.update).not.toHaveBeenCalled();
    });

    it('should create configuration if it does not exist before updating', async () => {
      // Given — no configuration exists
      prisma.rolePermission.findUnique.mockResolvedValue(null);
      prisma.rolePermission.create.mockResolvedValue({
        id: 'new-rp',
        churchId,
        role: Role.SECRETARY,
        permissions: {},
        createdAt: new Date(),
        updatedAt: new Date(),
      });

      const newPermissions = {
        [Permission.VIEW_MEMBERS]: true,
      };

      prisma.rolePermission.update.mockResolvedValue({
        id: 'new-rp',
        churchId,
        role: Role.SECRETARY,
        permissions: newPermissions,
        createdAt: new Date(),
        updatedAt: new Date(),
      });

      // When
      await service.update(churchId, Role.SECRETARY, {
        permissions: newPermissions,
      });

      // Then
      expect(prisma.rolePermission.create).toHaveBeenCalled();
      expect(prisma.rolePermission.update).toHaveBeenCalled();
    });
  });
});
