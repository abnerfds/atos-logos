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
import { MembershipsService } from './memberships.service';
import { CreateMembershipDto } from './dto/create-membership.dto';
import { CreateMemberWithUserDto } from './dto/create-member-with-user.dto';
import { UpdateMembershipDto } from './dto/update-membership.dto';
import { UpdateMemberUserDataDto } from './dto/update-member-user-data.dto';
import { QueryMembershipDto } from './dto/query-membership.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import type { AuthenticatedUser } from '../../common/interfaces/authenticated-user.interface';
import { Role } from '@prisma/client';

@Controller('memberships')
@UseGuards(JwtAuthGuard, RolesGuard)
export class MembershipsController {
  constructor(private readonly membershipsService: MembershipsService) {}

  @Get()
  async findAll(
    @CurrentUser() user: AuthenticatedUser,
    @Query() query: QueryMembershipDto,
  ) {
    return this.membershipsService.findAll(
      user.churchId,
      query.page,
      query.limit,
      query.q,
    );
  }

  @Post()
  @Roles(Role.ADMIN, Role.SECRETARY)
  async create(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateMembershipDto,
  ) {
    return this.membershipsService.create(user.churchId, user.role, dto);
  }

  /// Secretariat onboarding: creates a `User`, a `Membership` (and a
  /// `MemberProfile` when birth + admission dates are provided) in a
  /// single transaction. Used by the mobile "Novo Membro" form.
  @Post('with-user')
  @Roles(Role.ADMIN, Role.SECRETARY)
  async createWithUser(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateMemberWithUserDto,
  ) {
    return this.membershipsService.createWithUser(
      user.churchId,
      user.role,
      dto,
    );
  }

  @Patch(':id')
  @Roles(Role.ADMIN)
  async update(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() dto: UpdateMembershipDto,
  ) {
    return this.membershipsService.update(user.churchId, id, dto);
  }

  /// Secretariat edit form: updates the underlying User behind a membership
  /// (keyed by userId — mobile navigates to /edit-member/:userId so this
  /// matches that URL shape). Only touches User columns, never role/status.
  @Patch('by-user/:userId/user-data')
  @Roles(Role.ADMIN, Role.SECRETARY)
  async updateMemberUserData(
    @CurrentUser() user: AuthenticatedUser,
    @Param('userId') userId: string,
    @Body() dto: UpdateMemberUserDataDto,
  ) {
    return this.membershipsService.updateMemberUserData(
      user.churchId,
      userId,
      dto,
    );
  }

  /// Secretariat "Inativar Membro" button — sets the membership to
  /// INACTIVE (guarded by the existing Last-Admin rule). Keyed by userId
  /// to match the edit URL.
  @Patch('by-user/:userId/inactivate')
  @HttpCode(200)
  @Roles(Role.ADMIN, Role.SECRETARY)
  async inactivateByUserId(
    @CurrentUser() user: AuthenticatedUser,
    @Param('userId') userId: string,
  ) {
    return this.membershipsService.inactivateByUserId(user.churchId, userId);
  }

  @Delete(':id')
  @HttpCode(204)
  @Roles(Role.ADMIN)
  async remove(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
  ) {
    return this.membershipsService.remove(user.churchId, id);
  }
}
