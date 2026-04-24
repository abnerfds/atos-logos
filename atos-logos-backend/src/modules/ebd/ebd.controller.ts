import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  Param,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { EbdService } from './ebd.service';
import { CreateEbdClassDto } from './dto/create-ebd-class.dto';
import { SaveLessonAttendanceDto } from './dto/record-attendance.dto';
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

  @Get('setup-options')
  async getSetupOptions(@CurrentUser() user: AuthenticatedUser) {
    return this.ebdService.getSetupOptions(user.churchId);
  }

  @Get('classes')
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

  @Post('classes/:id/enrollments/copy-from-previous')
  @Roles(Role.ADMIN, Role.SECRETARY)
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
  async findLessons(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') classId: string,
  ) {
    return this.ebdService.findLessons(user.churchId, classId);
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

  @Get('lessons/:id/attendance')
  async getLessonAttendance(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') lessonId: string,
  ) {
    return this.ebdService.getLessonAttendance(user.churchId, lessonId);
  }

  @Post('lessons/:id/attendance')
  @Roles(Role.ADMIN, Role.SECRETARY)
  async saveLessonAttendance(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') lessonId: string,
    @Body() dto: SaveLessonAttendanceDto,
  ) {
    return this.ebdService.saveLessonAttendance(user.churchId, lessonId, dto);
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

  @Get('members/:memberId/progress')
  async getMemberProgress(
    @CurrentUser() user: AuthenticatedUser,
    @Param('memberId') memberId: string,
  ) {
    return this.ebdService.getMemberProgress(user.churchId, memberId);
  }

  @Post('members/:memberId/certificates')
  async createMemberCertificate(
    @CurrentUser() user: AuthenticatedUser,
    @Param('memberId') memberId: string,
  ) {
    return this.ebdService.createMemberCertificate(user.churchId, memberId);
  }
}
