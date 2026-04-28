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
import { MemberProfilesService } from './member-profiles.service';
import { CreateMemberProfileDto } from './dto/create-member-profile.dto';
import { UpdateMemberProfileDto } from './dto/update-member-profile.dto';
import { QueryMemberProfileDto } from './dto/query-member-profile.dto';
import { QueryBirthdaysDto } from './dto/query-birthdays.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { PermissionsGuard } from '../../common/guards/permissions.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { RequirePermissions } from '../../common/decorators/require-permissions.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Permission } from '../../common/enums/permission.enum';
import type { AuthenticatedUser } from '../../common/interfaces/authenticated-user.interface';
import { Role } from '@prisma/client';

@Controller('member-profiles')
@UseGuards(JwtAuthGuard, RolesGuard, PermissionsGuard)
export class MemberProfilesController {
  constructor(private readonly memberProfilesService: MemberProfilesService) {}

  @Get()
  @RequirePermissions(Permission.VIEW_MEMBERS)
  async findAll(
    @CurrentUser() user: AuthenticatedUser,
    @Query() query: QueryMemberProfileDto,
  ) {
    return this.memberProfilesService.findAll(user.churchId, query.page, query.limit);
  }

  // IMPORTANT: Named routes must be declared BEFORE @Get(':id') to avoid route conflict
  @Get('by-user/:userId')
  @RequirePermissions(Permission.VIEW_MEMBERS)
  async findByUserId(
    @CurrentUser() user: AuthenticatedUser,
    @Param('userId') userId: string,
  ) {
    return this.memberProfilesService.findByUserId(user.churchId, userId);
  }

  @Get('birthdays')
  @RequirePermissions(Permission.VIEW_MEMBERS)
  async findBirthdays(
    @CurrentUser() user: AuthenticatedUser,
    @Query() query: QueryBirthdaysDto,
  ) {
    return this.memberProfilesService.findBirthdays(user.churchId, query.month);
  }

  @Get(':id')
  @RequirePermissions(Permission.VIEW_MEMBERS)
  async findOne(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
  ) {
    return this.memberProfilesService.findOne(user.churchId, id);
  }

  @Post()
  @Roles(Role.ADMIN, Role.SECRETARY)
  @RequirePermissions(Permission.CREATE_MEMBERS)
  async create(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateMemberProfileDto,
  ) {
    return this.memberProfilesService.create(user.churchId, dto);
  }

  @Patch(':id')
  @Roles(Role.ADMIN, Role.SECRETARY)
  @RequirePermissions(Permission.EDIT_MEMBERS)
  async update(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() dto: UpdateMemberProfileDto,
  ) {
    return this.memberProfilesService.update(user.churchId, id, dto);
  }

  @Delete(':id')
  @HttpCode(204)
  @Roles(Role.ADMIN)
  @RequirePermissions(Permission.DELETE_MEMBERS)
  async remove(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
  ) {
    return this.memberProfilesService.remove(user.churchId, id);
  }
}
