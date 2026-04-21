import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateEbdClassDto } from './dto/create-ebd-class.dto';
import { RecordAttendanceDto } from './dto/record-attendance.dto';

@Injectable()
export class EbdService {
  constructor(private prisma: PrismaService) {}

  // ── Classes ───────────────────────────────────────────────────────────

  async findAllClasses(churchId: string) {
    return this.prisma.forTenant(churchId).ebdClass.findMany({
      include: {
        branch: { select: { id: true, name: true } },
        _count: { select: { enrollments: true } },
      },
      orderBy: { name: 'asc' },
    });
  }

  async createClass(churchId: string, dto: CreateEbdClassDto) {
    return this.prisma.ebdClass.create({
      data: { churchId, branchId: dto.branchId, name: dto.name },
      include: { branch: { select: { id: true, name: true } } },
    });
  }

  async deleteClass(churchId: string, classId: string) {
    const cls = await this.prisma.forTenant(churchId).ebdClass.findFirst({
      where: { id: classId },
    });
    if (!cls) throw new NotFoundException('EBD class not found');
    return this.prisma.ebdClass.delete({ where: { id: classId } });
  }

  // ── Enrollments ───────────────────────────────────────────────────────

  async getEnrollments(churchId: string, classId: string) {
    const cls = await this.prisma.forTenant(churchId).ebdClass.findFirst({
      where: { id: classId },
    });
    if (!cls) throw new NotFoundException('EBD class not found');

    return this.prisma.ebdEnrollment.findMany({
      where: { classId },
      include: { user: { select: { id: true, name: true } } },
    });
  }

  async enrollUser(churchId: string, classId: string, userId: string) {
    const cls = await this.prisma.forTenant(churchId).ebdClass.findFirst({
      where: { id: classId },
    });
    if (!cls) throw new NotFoundException('EBD class not found');

    return this.prisma.ebdEnrollment.create({
      data: { classId, userId },
      include: { user: { select: { id: true, name: true } } },
    });
  }

  async unenrollUser(churchId: string, classId: string, userId: string) {
    const cls = await this.prisma.forTenant(churchId).ebdClass.findFirst({
      where: { id: classId },
    });
    if (!cls) throw new NotFoundException('EBD class not found');

    const enrollment = await this.prisma.ebdEnrollment.findFirst({
      where: { classId, userId },
    });
    if (!enrollment) throw new NotFoundException('Enrollment not found');

    return this.prisma.ebdEnrollment.delete({ where: { id: enrollment.id } });
  }

  // ── Attendance ────────────────────────────────────────────────────────

  async recordAttendance(churchId: string, classId: string, dto: RecordAttendanceDto) {
    const cls = await this.prisma.forTenant(churchId).ebdClass.findFirst({
      where: { id: classId },
    });
    if (!cls) throw new NotFoundException('EBD class not found');

    const records = dto.entries.map((entry) =>
      this.prisma.ebdAttendance.upsert({
        where: {
          classId_eventId_userId: {
            classId,
            eventId: dto.eventId,
            userId: entry.userId,
          },
        },
        create: {
          classId,
          eventId: dto.eventId,
          userId: entry.userId,
          isPresent: entry.isPresent,
        },
        update: { isPresent: entry.isPresent },
      }),
    );

    return this.prisma.$transaction(records);
  }

  // ── Frequency & Certificate ───────────────────────────────────────────

  /**
   * Calculates attendance frequency for a user in a class.
   * Returns percentage and whether the certificate can be issued (>= 80%).
   */
  async getFrequency(churchId: string, classId: string, userId: string) {
    const cls = await this.prisma.forTenant(churchId).ebdClass.findFirst({
      where: { id: classId },
    });
    if (!cls) throw new NotFoundException('EBD class not found');

    const totalSessions = await this.prisma.ebdAttendance.groupBy({
      by: ['eventId'],
      where: { classId },
    });

    const presentCount = await this.prisma.ebdAttendance.count({
      where: { classId, userId, isPresent: true },
    });

    const totalCount = totalSessions.length;
    const frequency = totalCount > 0 ? (presentCount / totalCount) * 100 : 0;

    return {
      userId,
      classId,
      totalSessions: totalCount,
      presentCount,
      frequency: Math.round(frequency * 100) / 100,
      certificateEligible: frequency >= 80,
    };
  }
}
