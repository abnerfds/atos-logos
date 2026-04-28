import { Injectable, NotFoundException } from '@nestjs/common';
import { Role } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.service';
import { Permission } from '../../common/enums/permission.enum';
import { UpdateRolePermissionsDto } from './dto/update-role-permissions.dto';

/**
 * Default permissions for each role when no configuration exists.
 * ADMIN is not included here because it always has full access unconditionally.
 */
const DEFAULT_PERMISSIONS: Record<Role, Record<string, boolean>> = {
  [Role.ADMIN]: {}, // Not used - ADMIN bypasses all checks
  [Role.SECRETARY]: {
    // Secretaria
    [Permission.VIEW_MEMBERS]: true,
    [Permission.EDIT_MEMBERS]: true,
    [Permission.DELETE_MEMBERS]: false,
    [Permission.CREATE_MEMBERS]: true,
    // Financeiro
    [Permission.VIEW_CONTRIBUTIONS]: false,
    [Permission.LAUNCH_OFFERINGS]: false,
    [Permission.EDIT_TRANSACTIONS]: false,
    [Permission.DELETE_TRANSACTIONS]: false,
    // EBD
    [Permission.MANAGE_CLASSES]: true,
    [Permission.TAKE_ATTENDANCE]: true,
    [Permission.VIEW_EBD_REPORTS]: true,
    // Eventos
    [Permission.VIEW_EVENTS]: true,
    [Permission.CREATE_EVENTS]: false,
    [Permission.EDIT_EVENTS]: false,
    [Permission.DELETE_EVENTS]: false,
    // Visitantes
    [Permission.VIEW_VISITORS]: true,
    [Permission.EDIT_VISITORS]: true,
    [Permission.DELETE_VISITORS]: false,
    // Congregações
    [Permission.VIEW_BRANCHES]: true,
    [Permission.CREATE_BRANCHES]: false,
    [Permission.EDIT_BRANCHES]: false,
    [Permission.DELETE_BRANCHES]: false,
    // Cargos
    [Permission.MANAGE_POSITIONS]: false,
    // Configurações
    [Permission.MANAGE_ROLES]: false,
    [Permission.VIEW_CHURCH_SETTINGS]: false,
    [Permission.EDIT_CHURCH_SETTINGS]: false,
  },
  [Role.MEMBER]: {
    // Secretaria
    [Permission.VIEW_MEMBERS]: false,
    [Permission.EDIT_MEMBERS]: false,
    [Permission.DELETE_MEMBERS]: false,
    [Permission.CREATE_MEMBERS]: false,
    // Financeiro
    [Permission.VIEW_CONTRIBUTIONS]: false,
    [Permission.LAUNCH_OFFERINGS]: false,
    [Permission.EDIT_TRANSACTIONS]: false,
    [Permission.DELETE_TRANSACTIONS]: false,
    // EBD
    [Permission.MANAGE_CLASSES]: false,
    [Permission.TAKE_ATTENDANCE]: false,
    [Permission.VIEW_EBD_REPORTS]: false,
    // Eventos
    [Permission.VIEW_EVENTS]: true,
    [Permission.CREATE_EVENTS]: false,
    [Permission.EDIT_EVENTS]: false,
    [Permission.DELETE_EVENTS]: false,
    // Visitantes
    [Permission.VIEW_VISITORS]: false,
    [Permission.EDIT_VISITORS]: false,
    [Permission.DELETE_VISITORS]: false,
    // Congregações
    [Permission.VIEW_BRANCHES]: true,
    [Permission.CREATE_BRANCHES]: false,
    [Permission.EDIT_BRANCHES]: false,
    [Permission.DELETE_BRANCHES]: false,
    // Cargos
    [Permission.MANAGE_POSITIONS]: false,
    // Configurações
    [Permission.MANAGE_ROLES]: false,
    [Permission.VIEW_CHURCH_SETTINGS]: false,
    [Permission.EDIT_CHURCH_SETTINGS]: false,
  },
};

@Injectable()
export class RolePermissionsService {
  constructor(private prisma: PrismaService) {}

  /**
   * Returns all role permission configurations for the church.
   * Creates default configurations if they don't exist.
   */
  async findAll(churchId: string) {
    const roles = [Role.ADMIN, Role.SECRETARY, Role.MEMBER];
    const configurations = await Promise.all(
      roles.map(async (role) => {
        let config = await this.prisma.rolePermission.findUnique({
          where: { churchId_role: { churchId, role } },
        });

        // Create default configuration if it doesn't exist
        if (!config) {
          config = await this.prisma.rolePermission.create({
            data: {
              churchId,
              role,
              permissions: DEFAULT_PERMISSIONS[role],
            },
          });
        }

        return {
          role,
          permissions: config.permissions as Record<string, boolean>,
          updatedAt: config.updatedAt,
        };
      }),
    );

    return configurations;
  }

  /**
   * Returns the permission configuration for a specific role.
   * Creates default configuration if it doesn't exist.
   */
  async findOne(churchId: string, role: Role) {
    let config = await this.prisma.rolePermission.findUnique({
      where: { churchId_role: { churchId, role } },
    });

    if (!config) {
      config = await this.prisma.rolePermission.create({
        data: {
          churchId,
          role,
          permissions: DEFAULT_PERMISSIONS[role],
        },
      });
    }

    return {
      role,
      permissions: config.permissions as Record<string, boolean>,
      updatedAt: config.updatedAt,
    };
  }

  /**
   * Updates the permission configuration for a specific role.
   * ADMIN role cannot be updated (always has full access).
   */
  async update(churchId: string, role: Role, dto: UpdateRolePermissionsDto) {
    // Prevent updating ADMIN permissions (they're always full access)
    if (role === Role.ADMIN) {
      throw new NotFoundException(
        'ADMIN permissions cannot be modified - they have unconditional full access',
      );
    }

    // Ensure the configuration exists first
    await this.findOne(churchId, role);

    const updated = await this.prisma.rolePermission.update({
      where: { churchId_role: { churchId, role } },
      data: { permissions: dto.permissions },
    });

    return {
      role,
      permissions: updated.permissions as Record<string, boolean>,
      updatedAt: updated.updatedAt,
    };
  }
}
