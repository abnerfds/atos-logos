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
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import type { AuthenticatedUser } from '../../common/interfaces/authenticated-user.interface';
import { Role } from '@prisma/client';

@Controller('member-profiles')
@UseGuards(JwtAuthGuard, RolesGuard)
export class MemberProfilesController {
  constructor(private readonly memberProfilesService: MemberProfilesService) {}

  @Get()
  async findAll(
    @CurrentUser() user: AuthenticatedUser,
    @Query() query: QueryMemberProfileDto,
  ) {
    return this.memberProfilesService.findAll(user.churchId, query.page, query.limit);
  }

  // IMPORTANT: Named routes must be declared BEFORE @Get(':id') to avoid route conflict
  @Get('by-user/:userId')
  async findByUserId(
    @CurrentUser() user: AuthenticatedUser,
    @Param('userId') userId: string,
  ) {
    return this.memberProfilesService.findByUserId(user.churchId, userId);
  }

  @Get('birthdays')
  async findBirthdays(
    @CurrentUser() user: AuthenticatedUser,
    @Query() query: QueryBirthdaysDto,
  ) {
    return this.memberProfilesService.findBirthdays(user.churchId, query.month);
  }

  @Get(':id')
  async findOne(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
  ) {
    return this.memberProfilesService.findOne(user.churchId, id);
  }

  @Post()
  @Roles(Role.ADMIN, Role.SECRETARY)
  async create(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateMemberProfileDto,
  ) {
    return this.memberProfilesService.create(user.churchId, dto);
  }

  @Patch(':id')
  @Roles(Role.ADMIN, Role.SECRETARY)
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
  async remove(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
  ) {
    return this.memberProfilesService.remove(user.churchId, id);
  }
}
