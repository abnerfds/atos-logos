import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateEbdClassDto } from './dto/create-ebd-class.dto';
import { SaveLessonAttendanceDto } from './dto/record-attendance.dto';

type PrismaAny = PrismaService & Record<string, any>;

@Injectable()
export class EbdService {
  constructor(private prisma: PrismaService) {}

  // ── Classes ───────────────────────────────────────────────────────────

  async getSetupOptions(churchId: string) {
    const db = this.prisma as PrismaAny;
    const [activeQuarter, memberships] = await Promise.all([
      db.ebdQuarter.findFirst({
        where: { churchId, status: 'ACTIVE' },
        orderBy: { createdAt: 'desc' },
      }),
      db.membership.findMany({
        where: { churchId, status: 'ACTIVE' },
        include: {
          user: {
            select: {
              id: true,
              name: true,
              memberProfiles: {
                where: { churchId },
                select: { photoUrl: true },
                take: 1,
              },
            },
          },
        },
        orderBy: { user: { name: 'asc' } },
        take: 200,
      }),
    ]);

    const people = memberships.map((membership: any) => ({
      memberId: membership.user.id,
      name: membership.user.name,
      role: membership.role,
      photoUrl: membership.user.memberProfiles[0]?.photoUrl ?? null,
    }));

    return {
      activeQuarter,
      teachers: people,
      students: people,
    };
  }

  async findAllClasses(
    churchId: string,
    page = 1,
    limit = 20,
    memberId?: string,
  ) {
    const safePage = Math.max(page, 1);
    const safeLimit = Math.min(Math.max(limit, 1), 100);
    const skip = (safePage - 1) * safeLimit;
    const db = this.prisma as PrismaAny;

    const [items, total] = await db.$transaction([
      db.ebdClass.findMany({
        where: { churchId, status: true },
        include: {
          branch: { select: { id: true, name: true } },
          teachers: { include: { user: { select: { id: true, name: true } } } },
          _count: { select: { enrollments: true } },
          lessons: {
            where: { isCompleted: true },
            select: {
              id: true,
              attendances: memberId
                ? {
                    where: { userId: memberId, isPresent: true },
                    select: { id: true },
                  }
                : false,
            },
          },
        },
        orderBy: { createdAt: 'desc' },
        skip,
        take: safeLimit,
      }),
      db.ebdClass.count({ where: { churchId, status: true } }),
    ]);

    return {
      data: items.map((item: any) => {
        const completedLessons = item.lessons.length;
        const presentCount = memberId
          ? item.lessons.filter((lesson: any) => lesson.attendances.length > 0)
              .length
          : 0;
        const frequency =
          completedLessons > 0
            ? Math.round((presentCount / completedLessons) * 100)
            : 0;

        return {
          id: item.id,
          churchId: item.churchId,
          branchId: item.branchId,
          branch: item.branch,
          name: item.name,
          targetAudience: item.targetAudience,
          status: item.status,
          teacherName: item.teachers[0]?.user.name ?? null,
          teachers: item.teachers.map((teacher: any) => ({
            id: teacher.user.id,
            name: teacher.user.name,
          })),
          enrolledCount: item._count.enrollments,
          certificateAvailable: memberId ? frequency >= 80 : false,
        };
      }),
      meta: {
        page: safePage,
        limit: safeLimit,
        total,
        totalPages: Math.ceil(total / safeLimit),
      },
    };
  }

  async createClass(churchId: string, dto: CreateEbdClassDto) {
    const teacherIds = this.normalizeTeacherIds(dto);
    if (teacherIds.length === 0) {
      throw new BadRequestException('At least one teacher is required');
    }

    return (this.prisma as PrismaAny).$transaction(async (tx: PrismaAny) => {
      const quarter = await this.resolveQuarter(tx, churchId, dto);

      return tx.ebdClass.create({
        data: {
          churchId,
          branchId: dto.branchId,
          quarterId: quarter.id,
          name: dto.name,
          targetAudience: dto.targetAudience,
          status: true,
          teachers: {
            createMany: {
              data: teacherIds.map((userId) => ({ userId })),
              skipDuplicates: true,
            },
          },
          enrollments: {
            createMany: {
              data: dto.studentIds.map((userId) => ({ userId })),
              skipDuplicates: true,
            },
          },
          lessons: {
            createMany: {
              data: dto.lessons.map((lesson, index) => ({
                number: index + 1,
                theme: lesson.theme,
                scheduledDate: new Date(lesson.scheduledDate),
              })),
            },
          },
        },
        include: {
          teachers: { include: { user: { select: { id: true, name: true } } } },
          lessons: { orderBy: { number: 'asc' } },
          _count: { select: { enrollments: true } },
        },
      });
    });
  }

  async findOneClass(churchId: string, classId: string) {
    const db = this.prisma as PrismaAny;
    const item = await db.ebdClass.findFirst({
      where: { id: classId, churchId },
      include: {
        branch: { select: { id: true, name: true } },
        quarter: { select: { id: true, name: true } },
        teachers: { include: { user: { select: { id: true, name: true } } } },
        _count: { select: { enrollments: true } },
      },
    });
    if (!item) throw new NotFoundException('EBD class not found');

    return {
      id: item.id,
      churchId: item.churchId,
      branchId: item.branchId,
      branch: item.branch,
      name: item.name,
      targetAudience: item.targetAudience,
      status: item.status,
      teacherName: item.teachers[0]?.user.name ?? null,
      teachers: item.teachers.map((t: any) => ({
        id: t.user.id,
        name: t.user.name,
      })),
      quarterName: item.quarter?.name ?? null,
      enrolledCount: item._count.enrollments,
    };
  }

  async deleteClass(churchId: string, classId: string) {
    await this.findClassOrThrow(churchId, classId);
    return (this.prisma as PrismaAny).ebdClass.delete({
      where: { id: classId },
    });
  }

  async copyEnrollmentsFromPreviousClass(churchId: string, classId: string) {
    const targetClass = await this.findClassOrThrow(churchId, classId);
    const sourceClass = await (this.prisma as PrismaAny).ebdClass.findFirst({
      where: {
        churchId,
        branchId: targetClass.branchId,
        id: { not: classId },
        createdAt: { lt: targetClass.createdAt },
      },
      include: { enrollments: { select: { userId: true } } },
      orderBy: { createdAt: 'desc' },
    });

    if (!sourceClass)
      throw new NotFoundException('Previous EBD class not found');

    await (this.prisma as PrismaAny).ebdEnrollment.createMany({
      data: sourceClass.enrollments.map((enrollment: { userId: string }) => ({
        classId,
        userId: enrollment.userId,
      })),
      skipDuplicates: true,
    });

    return this.getEnrollments(churchId, classId);
  }

  // ── Quarter Summary ───────────────────────────────────────────────────

  async getQuarterSummary(churchId: string) {
    const db = this.prisma as PrismaAny;

    const activeClasses = await db.ebdClass.findMany({
      where: { churchId, status: true },
      include: {
        teachers: { select: { userId: true } },
        _count: { select: { enrollments: true } },
        lessons: {
          where: { isCompleted: true },
          include: {
            attendances: {
              where: { isPresent: true },
              select: { id: true },
            },
          },
        },
      },
    });

    const totalStudents = activeClasses.reduce(
      (sum: number, cls: any) => sum + cls._count.enrollments,
      0,
    );

    const teacherIds = new Set<string>();
    for (const cls of activeClasses) {
      for (const t of cls.teachers) {
        teacherIds.add(t.userId);
      }
    }

    let totalPresences = 0;
    let totalSessions = 0;
    for (const cls of activeClasses) {
      for (const lesson of cls.lessons) {
        totalSessions++;
        totalPresences += lesson.attendances.length;
      }
    }

    const averageFrequency =
      totalSessions > 0 && totalStudents > 0
        ? Math.round((totalPresences / (totalSessions * totalStudents)) * 100)
        : 0;

    return {
      totalStudents,
      activeClasses: activeClasses.length,
      averageFrequency,
      totalTeachers: teacherIds.size,
    };
  }

  // ── Lessons ───────────────────────────────────────────────────────────

  async findLessons(churchId: string, classId: string) {
    await this.findClassOrThrow(churchId, classId);

    const lessons = await (this.prisma as PrismaAny).ebdLesson.findMany({
      where: { classId },
      include: { journal: { select: { id: true } } },
      orderBy: { scheduledDate: 'asc' },
    });

    return lessons.map((lesson: any) => ({
      id: lesson.id,
      classId: lesson.classId,
      number: lesson.number,
      theme: lesson.theme,
      scheduledDate: lesson.scheduledDate,
      isCompleted: lesson.isCompleted,
      hasJournal: Boolean(lesson.journal),
    }));
  }

  // ── Enrollments ───────────────────────────────────────────────────────

  async getEnrollments(churchId: string, classId: string) {
    await this.findClassOrThrow(churchId, classId);

    return (this.prisma as PrismaAny).ebdEnrollment.findMany({
      where: { classId },
      include: { user: { select: { id: true, name: true } } },
      orderBy: { createdAt: 'asc' },
    });
  }

  async enrollUser(churchId: string, classId: string, userId: string) {
    await this.findClassOrThrow(churchId, classId);

    return (this.prisma as PrismaAny).ebdEnrollment.create({
      data: { classId, userId },
      include: { user: { select: { id: true, name: true } } },
    });
  }

  async unenrollUser(churchId: string, classId: string, userId: string) {
    await this.findClassOrThrow(churchId, classId);

    const enrollment = await (this.prisma as PrismaAny).ebdEnrollment.findFirst(
      {
        where: { classId, userId },
      },
    );
    if (!enrollment) throw new NotFoundException('Enrollment not found');

    return (this.prisma as PrismaAny).ebdEnrollment.delete({
      where: { id: enrollment.id },
    });
  }

  // ── Attendance ────────────────────────────────────────────────────────

  async getLessonAttendance(churchId: string, lessonId: string) {
    const lesson = await this.findLessonOrThrow(churchId, lessonId);
    const attendanceRows = await (
      this.prisma as PrismaAny
    ).ebdAttendance.findMany({
      where: { lessonId },
      select: { userId: true, isPresent: true },
    });
    const attendanceByUserId = new Map(
      attendanceRows.map((attendance: any) => [
        attendance.userId,
        attendance.isPresent,
      ]),
    );

    const enrollments = await (this.prisma as PrismaAny).ebdEnrollment.findMany(
      {
        where: { classId: lesson.classId },
        include: {
          user: {
            select: {
              id: true,
              name: true,
              memberProfiles: {
                where: { churchId },
                select: { photoUrl: true },
                take: 1,
              },
            },
          },
        },
        orderBy: { user: { name: 'asc' } },
      },
    );

    return enrollments.map((enrollment: any) => ({
      memberId: enrollment.user.id,
      name: enrollment.user.name,
      photoUrl: enrollment.user.memberProfiles[0]?.photoUrl ?? null,
      isPresent: attendanceByUserId.get(enrollment.user.id) ?? false,
    }));
  }

  async saveLessonAttendance(
    churchId: string,
    lessonId: string,
    dto: SaveLessonAttendanceDto,
  ) {
    return (this.prisma as PrismaAny).$transaction(async (tx: PrismaAny) => {
      const lesson = await tx.ebdLesson.findFirst({
        where: { id: lessonId, class_: { churchId } },
      });
      if (!lesson) throw new NotFoundException('EBD lesson not found');

      await Promise.all(
        dto.attendances.map((attendance) =>
          tx.ebdAttendance.upsert({
            where: {
              lessonId_userId: {
                lessonId,
                userId: attendance.memberId,
              },
            },
            create: {
              lessonId,
              userId: attendance.memberId,
              isPresent: attendance.isPresent,
            },
            update: { isPresent: attendance.isPresent },
          }),
        ),
      );

      const journal = await tx.ebdJournal.upsert({
        where: { lessonId },
        create: {
          lessonId,
          visitorCount: dto.visitorCount,
          offeringAmount: dto.offeringAmount,
        },
        update: {
          visitorCount: dto.visitorCount,
          offeringAmount: dto.offeringAmount,
        },
      });

      const updatedLesson = await tx.ebdLesson.update({
        where: { id: lessonId },
        data: { isCompleted: true },
      });

      return { lesson: updatedLesson, journal };
    });
  }

  // ── Frequency & Certificate ───────────────────────────────────────────

  async getMemberProgress(churchId: string, memberId: string) {
    const enrollment = await this.findActiveEnrollment(churchId, memberId);
    if (!enrollment)
      throw new NotFoundException('Active EBD enrollment not found');

    const today = new Date();
    const lessons = await (this.prisma as PrismaAny).ebdLesson.findMany({
      where: {
        classId: enrollment.classId,
        scheduledDate: { lte: today },
      },
      select: { id: true },
    });

    const lessonIds = lessons.map((lesson: { id: string }) => lesson.id);
    const presentCount =
      lessonIds.length === 0
        ? 0
        : await (this.prisma as PrismaAny).ebdAttendance.count({
            where: {
              lessonId: { in: lessonIds },
              userId: memberId,
              isPresent: true,
            },
          });

    return this.buildProgressPayload(
      enrollment.class_,
      memberId,
      lessons.length,
      presentCount,
    );
  }

  async createMemberCertificate(churchId: string, memberId: string) {
    const enrollment = await this.findActiveEnrollment(churchId, memberId);
    if (!enrollment)
      throw new NotFoundException('Active EBD enrollment not found');

    const completedLessons = await (
      this.prisma as PrismaAny
    ).ebdLesson.findMany({
      where: { classId: enrollment.classId, isCompleted: true },
      select: { id: true },
    });
    const completedLessonIds = completedLessons.map(
      (lesson: { id: string }) => lesson.id,
    );
    const presentCount =
      completedLessonIds.length === 0
        ? 0
        : await (this.prisma as PrismaAny).ebdAttendance.count({
            where: {
              lessonId: { in: completedLessonIds },
              userId: memberId,
              isPresent: true,
            },
          });

    const frequency = this.calculateFrequency(
      presentCount,
      completedLessonIds.length,
    );
    if (frequency < 80) {
      throw new BadRequestException(
        'Member is not eligible for EBD certificate',
      );
    }

    const certificate = await this.generateCertificate(
      memberId,
      enrollment.class_.name,
    );
    return {
      success: true,
      memberId,
      classId: enrollment.classId,
      className: enrollment.class_.name,
      frequencyPercentage: frequency,
      certificate,
    };
  }

  async getFrequency(churchId: string, classId: string, userId: string) {
    await this.findClassOrThrow(churchId, classId);

    const completedLessons = await (
      this.prisma as PrismaAny
    ).ebdLesson.findMany({
      where: { classId, isCompleted: true },
      select: { id: true },
    });
    const lessonIds = completedLessons.map(
      (lesson: { id: string }) => lesson.id,
    );
    const presentCount =
      lessonIds.length === 0
        ? 0
        : await (this.prisma as PrismaAny).ebdAttendance.count({
            where: { lessonId: { in: lessonIds }, userId, isPresent: true },
          });

    return {
      userId,
      classId,
      totalSessions: lessonIds.length,
      presentCount,
      frequency: this.calculateFrequency(presentCount, lessonIds.length),
      certificateEligible:
        this.calculateFrequency(presentCount, lessonIds.length) >= 80,
    };
  }

  private async findClassOrThrow(churchId: string, classId: string) {
    const cls = await (this.prisma as PrismaAny).ebdClass.findFirst({
      where: { id: classId, churchId },
    });
    if (!cls) throw new NotFoundException('EBD class not found');
    return cls;
  }

  private async findLessonOrThrow(churchId: string, lessonId: string) {
    const lesson = await (this.prisma as PrismaAny).ebdLesson.findFirst({
      where: { id: lessonId, class_: { churchId } },
    });
    if (!lesson) throw new NotFoundException('EBD lesson not found');
    return lesson;
  }

  private async findActiveEnrollment(churchId: string, memberId: string) {
    return (this.prisma as PrismaAny).ebdEnrollment.findFirst({
      where: {
        userId: memberId,
        class_: {
          churchId,
          status: true,
          quarter: { status: 'ACTIVE' },
        },
      },
      include: { class_: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  private normalizeTeacherIds(dto: CreateEbdClassDto) {
    return Array.from(
      new Set([...(dto.teacherIds ?? []), dto.teacherId].filter(Boolean)),
    ) as string[];
  }

  private async resolveQuarter(
    tx: PrismaAny,
    churchId: string,
    dto: CreateEbdClassDto,
  ) {
    if (dto.quarterId) {
      const quarter = await tx.ebdQuarter.findFirst({
        where: { id: dto.quarterId, churchId },
      });
      if (!quarter) throw new NotFoundException('EBD quarter not found');
      return quarter;
    }

    const quarterName = dto.quarterName?.trim();
    if (!quarterName) {
      throw new BadRequestException('quarterId or quarterName is required');
    }

    const existingQuarter = await tx.ebdQuarter.findFirst({
      where: { churchId, name: quarterName, status: 'ACTIVE' },
    });
    if (existingQuarter) return existingQuarter;

    return tx.ebdQuarter.create({
      data: {
        churchId,
        name: quarterName,
        status: 'ACTIVE',
      },
    });
  }

  private calculateFrequency(presentCount: number, totalCount: number) {
    if (totalCount === 0) return 0;
    return Math.round((presentCount / totalCount) * 100);
  }

  private buildProgressPayload(
    cls: { id: string; name: string },
    memberId: string,
    totalLessons: number,
    totalPresences: number,
  ) {
    return {
      memberId,
      classId: cls.id,
      className: cls.name,
      totalLessons,
      totalPresences,
      frequencyPercentage: this.calculateFrequency(
        totalPresences,
        totalLessons,
      ),
    };
  }

  private async generateCertificate(memberId: string, className: string) {
    return {
      memberId,
      className,
      generatedAt: new Date().toISOString(),
    };
  }
}
