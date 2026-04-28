import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  HttpCode,
} from '@nestjs/common';
import { BranchesService } from './branches.service';
import { CreateBranchDto } from './dto/create-branch.dto';
import { UpdateBranchDto } from './dto/update-branch.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { PermissionsGuard } from '../../common/guards/permissions.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { RequirePermissions } from '../../common/decorators/require-permissions.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Permission } from '../../common/enums/permission.enum';
import type { AuthenticatedUser } from '../../common/interfaces/authenticated-user.interface';
import { Role } from '@prisma/client';

@Controller('branches')
@UseGuards(JwtAuthGuard, RolesGuard, PermissionsGuard)
export class BranchesController {
  constructor(private readonly branchesService: BranchesService) {}

  @Get()
  @RequirePermissions(Permission.VIEW_BRANCHES)
  async findAll(
    @CurrentUser() user: AuthenticatedUser,
    @Query('q') q?: string,
  ) {
    return this.branchesService.findAll(user.churchId, q);
  }

  @Post()
  @Roles(Role.ADMIN)
  @RequirePermissions(Permission.CREATE_BRANCHES)
  async create(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateBranchDto,
  ) {
    return this.branchesService.create(user.churchId, dto);
  }

  @Patch(':id')
  @Roles(Role.ADMIN)
  @RequirePermissions(Permission.EDIT_BRANCHES)
  async update(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() dto: UpdateBranchDto,
  ) {
    return this.branchesService.update(user.churchId, id, dto);
  }

  /// Atomic "make this the Sede" — demotes the current HQ and promotes
  /// the target in one transaction. Guards: branch must belong to this
  /// church and must not already be HQ.
  @Patch(':id/promote-to-headquarters')
  @Roles(Role.ADMIN)
  @RequirePermissions(Permission.EDIT_BRANCHES)
  async promoteToHeadquarters(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
  ) {
    return this.branchesService.promoteToHeadquarters(user.churchId, id);
  }

  @Delete(':id')
  @HttpCode(204)
  @Roles(Role.ADMIN)
  @RequirePermissions(Permission.DELETE_BRANCHES)
  async remove(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
  ) {
    return this.branchesService.remove(user.churchId, id);
  }
}
