import {
  Controller, Get, Post, Delete,
  Body, Param, UseGuards, HttpCode,
} from '@nestjs/common';
import { EbdService } from './ebd.service';
import { CreateEbdClassDto } from './dto/create-ebd-class.dto';
import { RecordAttendanceDto } from './dto/record-attendance.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import type { AuthenticatedUser } from '../../common/interfaces/authenticated-user.interface';
import { Role } from '@prisma/client';

@Controller('ebd')
@UseGuards(JwtAuthGuard, RolesGuard)
export class EbdController {
  constructor(private readonly ebdService: EbdService) {}

  // ── Classes ───────────────────────────────────────────────────────────

  @Get('classes')
  async findAllClasses(@CurrentUser() user: AuthenticatedUser) {
    return this.ebdService.findAllClasses(user.churchId);
  }

  @Post('classes')
  @Roles(Role.ADMIN, Role.SECRETARY)
  async createClass(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateEbdClassDto,
  ) {
    return this.ebdService.createClass(user.churchId, dto);
  }

  @Delete('classes/:id')
  @HttpCode(204)
  @Roles(Role.ADMIN)
  async deleteClass(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
  ) {
    return this.ebdService.deleteClass(user.churchId, id);
  }

  // ── Enrollments ───────────────────────────────────────────────────────

  @Get('classes/:id/enrollments')
  async getEnrollments(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') classId: string,
  ) {
    return this.ebdService.getEnrollments(user.churchId, classId);
  }

  @Post('classes/:id/enrollments/:userId')
  @Roles(Role.ADMIN, Role.SECRETARY)
  async enrollUser(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') classId: string,
    @Param('userId') userId: string,
  ) {
    return this.ebdService.enrollUser(user.churchId, classId, userId);
  }

  @Delete('classes/:id/enrollments/:userId')
  @HttpCode(204)
  @Roles(Role.ADMIN, Role.SECRETARY)
  async unenrollUser(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') classId: string,
    @Param('userId') userId: string,
  ) {
    return this.ebdService.unenrollUser(user.churchId, classId, userId);
  }

  // ── Attendance ────────────────────────────────────────────────────────

  @Post('classes/:id/attendance')
  @Roles(Role.ADMIN, Role.SECRETARY)
  async recordAttendance(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') classId: string,
    @Body() dto: RecordAttendanceDto,
  ) {
    return this.ebdService.recordAttendance(user.churchId, classId, dto);
  }

  // ── Frequency / Certificate ───────────────────────────────────────────

  @Get('classes/:id/frequency/:userId')
  async getFrequency(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') classId: string,
    @Param('userId') userId: string,
  ) {
    return this.ebdService.getFrequency(user.churchId, classId, userId);
  }
}
