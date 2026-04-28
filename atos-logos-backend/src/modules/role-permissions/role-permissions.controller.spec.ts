import { Role } from '@prisma/client';
import { RolePermissionsController } from './role-permissions.controller';
import { RolePermissionsService } from './role-permissions.service';
import { Permission } from '../../common/enums/permission.enum';
import type { AuthenticatedUser } from '../../common/interfaces/authenticated-user.interface';

describe('RolePermissionsController', () => {
  let controller: RolePermissionsController;
  let service: jest.Mocked<RolePermissionsService>;

  const mockUser: AuthenticatedUser = {
    userId: 'u1',
    email: 'admin@test.com',
    churchId: 'c1',
    branchId: 'b1',
    role: Role.ADMIN,
  };

  beforeEach(() => {
    service = {
      findAll: jest.fn(),
      findOne: jest.fn(),
      update: jest.fn(),
    } as any;

    controller = new RolePermissionsController(service);
  });

  describe('findAll', () => {
    it('should return all role configurations for the church', async () => {
      // Given
      const mockConfigs = [
        {
          role: Role.ADMIN,
          permissions: {},
          updatedAt: new Date(),
        },
        {
          role: Role.SECRETARY,
          permissions: { [Permission.VIEW_MEMBERS]: true },
          updatedAt: new Date(),
        },
        {
          role: Role.MEMBER,
          permissions: { [Permission.VIEW_EVENTS]: true },
          updatedAt: new Date(),
        },
      ];

      service.findAll.mockResolvedValue(mockConfigs);

      // When
      const result = await controller.findAll(mockUser);

      // Then
      expect(result).toEqual(mockConfigs);
      expect(service.findAll).toHaveBeenCalledWith('c1');
    });
  });

  describe('findOne', () => {
    it('should return configuration for a specific role', async () => {
      // Given
      const mockConfig = {
        role: Role.SECRETARY,
        permissions: { [Permission.VIEW_MEMBERS]: true },
        updatedAt: new Date(),
      };

      service.findOne.mockResolvedValue(mockConfig);

      // When
      const result = await controller.findOne(mockUser, Role.SECRETARY);

      // Then
      expect(result).toEqual(mockConfig);
      expect(service.findOne).toHaveBeenCalledWith('c1', Role.SECRETARY);
    });
  });

  describe('update', () => {
    it('should update permissions for a role', async () => {
      // Given
      const dto = {
        permissions: {
          [Permission.VIEW_MEMBERS]: true,
          [Permission.EDIT_MEMBERS]: true,
        },
      };

      const mockUpdated = {
        role: Role.SECRETARY,
        permissions: dto.permissions,
        updatedAt: new Date(),
      };

      service.update.mockResolvedValue(mockUpdated);

      // When
      const result = await controller.update(mockUser, Role.SECRETARY, dto);

      // Then
      expect(result).toEqual(mockUpdated);
      expect(service.update).toHaveBeenCalledWith('c1', Role.SECRETARY, dto);
    });
  });
});
