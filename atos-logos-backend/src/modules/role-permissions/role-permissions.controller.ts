import {
  Controller,
  Get,
  Patch,
  Param,
  Body,
  UseGuards,
  ParseEnumPipe,
} from '@nestjs/common';
import { Role } from '@prisma/client';
import { RolePermissionsService } from './role-permissions.service';
import { UpdateRolePermissionsDto } from './dto/update-role-permissions.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { PermissionsGuard } from '../../common/guards/permissions.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { RequirePermissions } from '../../common/decorators/require-permissions.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Permission } from '../../common/enums/permission.enum';
import type { AuthenticatedUser } from '../../common/interfaces/authenticated-user.interface';

@Controller('role-permissions')
@UseGuards(JwtAuthGuard, RolesGuard, PermissionsGuard)
export class RolePermissionsController {
  constructor(
    private readonly rolePermissionsService: RolePermissionsService,
  ) {}

  /**
   * GET /role-permissions
   * Returns all role permission configurations for the authenticated user's church.
   * Only ADMIN can access this endpoint.
   */
  @Get()
  @Roles(Role.ADMIN)
  @RequirePermissions(Permission.MANAGE_ROLES)
  async findAll(@CurrentUser() user: AuthenticatedUser) {
    return this.rolePermissionsService.findAll(user.churchId);
  }

  /**
   * GET /role-permissions/:role
   * Returns the permission configuration for a specific role.
   * Only ADMIN can access this endpoint.
   */
  @Get(':role')
  @Roles(Role.ADMIN)
  @RequirePermissions(Permission.MANAGE_ROLES)
  async findOne(
    @CurrentUser() user: AuthenticatedUser,
    @Param('role', new ParseEnumPipe(Role)) role: Role,
  ) {
    return this.rolePermissionsService.findOne(user.churchId, role);
  }

  /**
   * PATCH /role-permissions/:role
   * Updates the permission configuration for a specific role.
   * Only ADMIN can access this endpoint.
   * ADMIN role itself cannot be modified (always has full access).
   */
  @Patch(':role')
  @Roles(Role.ADMIN)
  @RequirePermissions(Permission.MANAGE_ROLES)
  async update(
    @CurrentUser() user: AuthenticatedUser,
    @Param('role', new ParseEnumPipe(Role)) role: Role,
    @Body() dto: UpdateRolePermissionsDto,
  ) {
    return this.rolePermissionsService.update(user.churchId, role, dto);
  }
}
