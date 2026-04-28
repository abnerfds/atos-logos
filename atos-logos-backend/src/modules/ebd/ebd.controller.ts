import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { EbdService } from './ebd.service';
import { CreateEbdClassDto } from './dto/create-ebd-class.dto';
import { UpdateEbdClassDto } from './dto/update-ebd-class.dto';
import { SaveLessonAttendanceDto } from './dto/record-attendance.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { PermissionsGuard } from '../../common/guards/permissions.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { RequirePermissions } from '../../common/decorators/require-permissions.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Permission } from '../../common/enums/permission.enum';
import type { AuthenticatedUser } from '../../common/interfaces/authenticated-user.interface';
import { Role } from '@prisma/client';

@Controller('ebd')
@UseGuards(JwtAuthGuard, RolesGuard, PermissionsGuard)
export class EbdController {
  constructor(private readonly ebdService: EbdService) {}

  // ── Classes ───────────────────────────────────────────────────────────

  @Get('setup-options')
  @RequirePermissions(Permission.MANAGE_CLASSES)
  async getSetupOptions(@CurrentUser() user: AuthenticatedUser) {
    return this.ebdService.getSetupOptions(user.churchId);
  }

  @Get('quarter-summary')
  @RequirePermissions(Permission.VIEW_EBD_REPORTS)
  async getQuarterSummary(@CurrentUser() user: AuthenticatedUser) {
    return this.ebdService.getQuarterSummary(user.churchId);
  }

  @Get('classes')
  @RequirePermissions(Permission.MANAGE_CLASSES)
  async findAllClasses(
    @CurrentUser() user: AuthenticatedUser,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    return this.ebdService.findAllClasses(
      user.churchId,
      Number(page ?? 1),
      Number(limit ?? 20),
      user.userId,
    );
  }

  @Post('classes')
  @Roles(Role.ADMIN, Role.SECRETARY)
  @RequirePermissions(Permission.MANAGE_CLASSES)
  async createClass(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateEbdClassDto,
  ) {
    return this.ebdService.createClass(user.churchId, dto);
  }

  @Get('classes/:id')
  @RequirePermissions(Permission.MANAGE_CLASSES)
  async findOneClass(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
  ) {
    return this.ebdService.findOneClass(user.churchId, id);
  }

  @Delete('classes/:id')
  @HttpCode(204)
  @Roles(Role.ADMIN)
  @RequirePermissions(Permission.MANAGE_CLASSES)
  async deleteClass(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
  ) {
    return this.ebdService.deleteClass(user.churchId, id);
  }

  @Patch('classes/:id')
  @Roles(Role.ADMIN, Role.SECRETARY)
  @RequirePermissions(Permission.MANAGE_CLASSES)
  async updateClass(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() dto: UpdateEbdClassDto,
  ) {
    return this.ebdService.updateClass(user.churchId, id, dto);
  }

  @Post('classes/:id/enrollments/copy-from-previous')
  @Roles(Role.ADMIN, Role.SECRETARY)
  @RequirePermissions(Permission.MANAGE_CLASSES)
  async copyEnrollmentsFromPreviousClass(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') classId: string,
  ) {
    return this.ebdService.copyEnrollmentsFromPreviousClass(
      user.churchId,
      classId,
    );
  }

  @Get('classes/:id/lessons')
  @RequirePermissions(Permission.MANAGE_CLASSES)
  async findLessons(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') classId: string,
  ) {
    return this.ebdService.findLessons(user.churchId, classId);
  }

  // ── Enrollments ───────────────────────────────────────────────────────

  @Get('classes/:id/enrollments')
  @RequirePermissions(Permission.MANAGE_CLASSES)
  async getEnrollments(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') classId: string,
  ) {
    return this.ebdService.getEnrollments(user.churchId, classId);
  }

  @Post('classes/:id/enrollments/:userId')
  @Roles(Role.ADMIN, Role.SECRETARY)
  @RequirePermissions(Permission.MANAGE_CLASSES)
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
  @RequirePermissions(Permission.MANAGE_CLASSES)
  async unenrollUser(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') classId: string,
    @Param('userId') userId: string,
  ) {
    return this.ebdService.unenrollUser(user.churchId, classId, userId);
  }

  // ── Attendance ────────────────────────────────────────────────────────

  @Get('lessons/:id/attendance')
  @RequirePermissions(Permission.TAKE_ATTENDANCE)
  async getLessonAttendance(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') lessonId: string,
  ) {
    return this.ebdService.getLessonAttendance(user.churchId, lessonId);
  }

  @Post('lessons/:id/attendance')
  @Roles(Role.ADMIN, Role.SECRETARY)
  @RequirePermissions(Permission.TAKE_ATTENDANCE)
  async saveLessonAttendance(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') lessonId: string,
    @Body() dto: SaveLessonAttendanceDto,
  ) {
    return this.ebdService.saveLessonAttendance(user.churchId, lessonId, dto);
  }

  // ── Frequency / Certificate ───────────────────────────────────────────

  @Get('classes/:id/frequency/:userId')
  @RequirePermissions(Permission.VIEW_EBD_REPORTS)
  async getFrequency(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') classId: string,
    @Param('userId') userId: string,
  ) {
    return this.ebdService.getFrequency(user.churchId, classId, userId);
  }

  @Get('members/:memberId/progress')
  @RequirePermissions(Permission.VIEW_EBD_REPORTS)
  async getMemberProgress(
    @CurrentUser() user: AuthenticatedUser,
    @Param('memberId') memberId: string,
  ) {
    return this.ebdService.getMemberProgress(user.churchId, memberId);
  }

  @Post('members/:memberId/certificates')
  @RequirePermissions(Permission.VIEW_EBD_REPORTS)
  async createMemberCertificate(
    @CurrentUser() user: AuthenticatedUser,
    @Param('memberId') memberId: string,
  ) {
    return this.ebdService.createMemberCertificate(user.churchId, memberId);
  }
}
