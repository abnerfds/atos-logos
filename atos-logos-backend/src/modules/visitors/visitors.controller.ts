import {
  Controller, Get, Post, Patch,
  Body, Param, Query, UseGuards,
} from '@nestjs/common';
import { VisitorsService } from './visitors.service';
import { CreateVisitorDto } from './dto/create-visitor.dto';
import { UpdateVisitorDto } from './dto/update-visitor.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import type { AuthenticatedUser } from '../../common/interfaces/authenticated-user.interface';
import { Role } from '@prisma/client';
import { QueryEventDto } from '../events/dto/query-event.dto';

@Controller('visitors')
@UseGuards(JwtAuthGuard, RolesGuard)
export class VisitorsController {
  constructor(private readonly visitorsService: VisitorsService) {}

  @Get()
  async findAll(
    @CurrentUser() user: AuthenticatedUser,
    @Query() query: QueryEventDto,
  ) {
    return this.visitorsService.findAll(user.churchId, query.page, query.limit);
  }

  @Get(':id')
  async findOne(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
  ) {
    return this.visitorsService.findOne(user.churchId, id);
  }

  @Post()
  @Roles(Role.ADMIN, Role.SECRETARY)
  async create(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateVisitorDto,
  ) {
    return this.visitorsService.create(user.churchId, dto);
  }

  @Patch(':id')
  @Roles(Role.ADMIN, Role.SECRETARY)
  async update(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() dto: UpdateVisitorDto,
  ) {
    return this.visitorsService.update(user.churchId, id, dto);
  }

  @Post(':id/check-in/:eventId')
  @Roles(Role.ADMIN, Role.SECRETARY)
  async checkIn(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') visitorId: string,
    @Param('eventId') eventId: string,
  ) {
    return this.visitorsService.checkIn(user.churchId, visitorId, eventId);
  }
}
