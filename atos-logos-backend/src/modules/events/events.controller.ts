import {
  Controller, Get, Post, Patch, Delete,
  Body, Param, Query, UseGuards, HttpCode,
} from '@nestjs/common';
import { EventsService } from './events.service';
import { CreateEventDto } from './dto/create-event.dto';
import { UpdateEventDto } from './dto/update-event.dto';
import { QueryEventDto } from './dto/query-event.dto';
import { CreateScheduleDto } from './dto/create-schedule.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { PermissionsGuard } from '../../common/guards/permissions.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { RequirePermissions } from '../../common/decorators/require-permissions.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Permission } from '../../common/enums/permission.enum';
import type { AuthenticatedUser } from '../../common/interfaces/authenticated-user.interface';
import { Role } from '@prisma/client';

@Controller('events')
@UseGuards(JwtAuthGuard, RolesGuard, PermissionsGuard)
export class EventsController {
  constructor(private readonly eventsService: EventsService) {}

  @Get()
  @RequirePermissions(Permission.VIEW_EVENTS)
  async findAll(
    @CurrentUser() user: AuthenticatedUser,
    @Query() query: QueryEventDto,
  ) {
    return this.eventsService.findAll(user.churchId, query.page, query.limit, query.type, query.upcoming);
  }

  @Get(':id')
  @RequirePermissions(Permission.VIEW_EVENTS)
  async findOne(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
  ) {
    return this.eventsService.findOne(user.churchId, id);
  }

  @Post()
  @Roles(Role.ADMIN, Role.SECRETARY)
  @RequirePermissions(Permission.CREATE_EVENTS)
  async create(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateEventDto,
  ) {
    return this.eventsService.create(user.churchId, dto);
  }

  @Patch(':id')
  @Roles(Role.ADMIN, Role.SECRETARY)
  @RequirePermissions(Permission.EDIT_EVENTS)
  async update(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() dto: UpdateEventDto,
  ) {
    return this.eventsService.update(user.churchId, id, dto);
  }

  @Delete(':id')
  @HttpCode(204)
  @Roles(Role.ADMIN)
  @RequirePermissions(Permission.DELETE_EVENTS)
  async remove(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
  ) {
    return this.eventsService.remove(user.churchId, id);
  }

  // ── Schedules ─────────────────────────────────────────────────────────

  @Post(':id/schedules')
  @Roles(Role.ADMIN, Role.SECRETARY)
  @RequirePermissions(Permission.EDIT_EVENTS)
  async addSchedule(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') eventId: string,
    @Body() dto: CreateScheduleDto,
  ) {
    return this.eventsService.addSchedule(user.churchId, eventId, dto);
  }

  @Delete(':id/schedules/:scheduleId')
  @HttpCode(204)
  @Roles(Role.ADMIN, Role.SECRETARY)
  @RequirePermissions(Permission.EDIT_EVENTS)
  async removeSchedule(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') eventId: string,
    @Param('scheduleId') scheduleId: string,
  ) {
    return this.eventsService.removeSchedule(user.churchId, eventId, scheduleId);
  }
}
