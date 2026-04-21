import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  UseGuards,
  HttpCode,
} from '@nestjs/common';
import { MemberPositionsService } from './member-positions.service';
import { CreatePositionDto } from './dto/create-position.dto';
import { UpdatePositionDto } from './dto/update-position.dto';
import { AssignPositionDto } from './dto/assign-position.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import type { AuthenticatedUser } from '../../common/interfaces/authenticated-user.interface';
import { Role } from '@prisma/client';

@Controller('member-positions')
@UseGuards(JwtAuthGuard, RolesGuard)
export class MemberPositionsController {
  constructor(private readonly positionsService: MemberPositionsService) {}

  @Get()
  async findAll(@CurrentUser() user: AuthenticatedUser) {
    return this.positionsService.findAll(user.churchId);
  }

  @Post()
  @Roles(Role.ADMIN)
  async create(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreatePositionDto,
  ) {
    return this.positionsService.create(user.churchId, dto);
  }

  @Patch(':id')
  @Roles(Role.ADMIN)
  async update(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() dto: UpdatePositionDto,
  ) {
    return this.positionsService.update(user.churchId, id, dto);
  }

  @Delete(':id')
  @HttpCode(204)
  @Roles(Role.ADMIN)
  async remove(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
  ) {
    return this.positionsService.remove(user.churchId, id);
  }

  // ── Assignment endpoints ──────────────────────────────────────────────

  @Post(':id/users')
  @Roles(Role.ADMIN)
  async assignUser(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') positionId: string,
    @Body() dto: AssignPositionDto,
  ) {
    return this.positionsService.assignUser(user.churchId, positionId, dto.userId);
  }

  @Delete(':id/users/:userId')
  @HttpCode(204)
  @Roles(Role.ADMIN)
  async unassignUser(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') positionId: string,
    @Param('userId') userId: string,
  ) {
    return this.positionsService.unassignUser(user.churchId, positionId, userId);
  }
}
