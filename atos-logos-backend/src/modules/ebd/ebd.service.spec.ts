import { BadRequestException, NotFoundException } from '@nestjs/common';
import { EbdService } from './ebd.service';

const churchId = 'church-1';
const branchId = 'branch-1';
const classId = 'class-1';
const lessonId = 'lesson-1';
const memberId = 'member-1';

function buildPrismaMock() {
  return {
    $transaction: jest.fn(),
    ebdQuarter: { findFirst: jest.fn(), create: jest.fn() },
    ebdClass: {
      findMany: jest.fn(),
      count: jest.fn(),
      create: jest.fn(),
      findFirst: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    },
    ebdClassTeacher: {
      deleteMany: jest.fn(),
      createMany: jest.fn(),
    },
    ebdLesson: {
      findMany: jest.fn(),
      findFirst: jest.fn(),
      update: jest.fn(),
    },
    ebdEnrollment: {
      findMany: jest.fn(),
      findFirst: jest.fn(),
      create: jest.fn(),
      createMany: jest.fn(),
      delete: jest.fn(),
      deleteMany: jest.fn(),
    },
    ebdAttendance: {
      findMany: jest.fn(),
      count: jest.fn(),
      upsert: jest.fn(),
    },
    ebdJournal: {
      upsert: jest.fn(),
    },
  };
}

describe('EbdService', () => {
  let service: EbdService;
  let prisma: ReturnType<typeof buildPrismaMock>;

  beforeEach(() => {
    prisma = buildPrismaMock();
    prisma.$transaction.mockImplementation(async (arg: unknown) => {
      if (Array.isArray(arg)) return Promise.all(arg);
      return (arg as (tx: typeof prisma) => Promise<unknown>)(prisma);
    });
    service = new EbdService(prisma as any);
  });

  it('should create an EBD class with teachers, enrolled students, and 13 lessons', async () => {
    // Given
    prisma.ebdQuarter.findFirst.mockResolvedValue({
      id: 'quarter-1',
      churchId,
    });
    prisma.ebdClass.create.mockResolvedValue({ id: classId });
    const lessons = Array.from({ length: 13 }, (_, index) => ({
      theme: `Lesson ${index + 1}`,
      scheduledDate: `2026-05-${String(index + 1).padStart(2, '0')}`,
    }));

    // When
    await service.createClass(churchId, {
      name: 'Parables of Jesus',
      targetAudience: 'Adults',
      quarterId: 'quarter-1',
      branchId,
      teacherIds: ['teacher-1', 'teacher-2'],
      studentIds: ['student-1', 'student-2'],
      lessons,
    });

    // Then
    expect(prisma.ebdClass.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          name: 'Parables of Jesus',
          targetAudience: 'Adults',
          teachers: {
            createMany: {
              data: [{ userId: 'teacher-1' }, { userId: 'teacher-2' }],
              skipDuplicates: true,
            },
          },
          enrollments: {
            createMany: {
              data: [{ userId: 'student-1' }, { userId: 'student-2' }],
              skipDuplicates: true,
            },
          },
          lessons: {
            createMany: {
              data: expect.arrayContaining([
                expect.objectContaining({ number: 1, theme: 'Lesson 1' }),
                expect.objectContaining({ number: 13, theme: 'Lesson 13' }),
              ]),
            },
          },
        }),
      }),
    );
  });

  it('should create the quarter from quarterName when quarterId is not provided', async () => {
    // Given
    prisma.ebdQuarter.findFirst.mockResolvedValue(null);
    prisma.ebdQuarter.create.mockResolvedValue({ id: 'quarter-new', churchId });
    prisma.ebdClass.create.mockResolvedValue({ id: classId });

    // When
    await service.createClass(churchId, {
      name: 'Parables of Jesus',
      targetAudience: 'Adults',
      quarterName: '2026.2',
      branchId,
      teacherId: 'teacher-1',
      studentIds: ['student-1'],
      lessons: Array.from({ length: 13 }, (_, index) => ({
        theme: `Lesson ${index + 1}`,
        scheduledDate: `2026-05-${String(index + 1).padStart(2, '0')}`,
      })),
    });

    // Then
    expect(prisma.ebdQuarter.create).toHaveBeenCalledWith({
      data: { churchId, name: '2026.2', status: 'ACTIVE' },
    });
    expect(prisma.ebdClass.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({ quarterId: 'quarter-new' }),
      }),
    );
  });

  it('should return active classes with teacher names, enrollment count, and certificate availability', async () => {
    // Given
    prisma.ebdClass.findMany.mockResolvedValue([
      {
        id: classId,
        name: 'Parables of Jesus',
        targetAudience: 'Adults',
        status: true,
        teachers: [{ user: { id: 'teacher-1', name: 'Prof. Ricardo' } }],
        _count: { enrollments: 42 },
        lessons: [
          { id: 'lesson-1', attendances: [{ id: 'attendance-1' }] },
          { id: 'lesson-2', attendances: [{ id: 'attendance-2' }] },
        ],
      },
    ]);
    prisma.ebdClass.count.mockResolvedValue(1);

    // When
    const result = await service.findAllClasses(churchId, 1, 20, memberId);

    // Then
    expect(result.data[0]).toMatchObject({
      id: classId,
      teacherName: 'Prof. Ricardo',
      enrolledCount: 42,
      certificateAvailable: true,
    });
    expect(result.meta).toMatchObject({ page: 1, limit: 20, total: 1 });
  });

  it('should return lessons with a hasJournal flag', async () => {
    // Given
    prisma.ebdClass.findFirst.mockResolvedValue({ id: classId, churchId });
    prisma.ebdLesson.findMany.mockResolvedValue([
      {
        id: lessonId,
        classId,
        number: 1,
        theme: 'The Sower',
        scheduledDate: new Date('2026-04-26'),
        isCompleted: true,
        journal: { id: 'journal-1' },
      },
    ]);

    // When
    const lessons = await service.findLessons(churchId, classId);

    // Then
    expect(prisma.ebdLesson.findMany).toHaveBeenCalledWith(
      expect.objectContaining({ orderBy: { scheduledDate: 'asc' } }),
    );
    expect(lessons[0]).toMatchObject({ id: lessonId, hasJournal: true });
  });

  it('should default attendance to false when no attendance row exists', async () => {
    // Given
    prisma.ebdLesson.findFirst.mockResolvedValue({ id: lessonId, classId });
    prisma.ebdAttendance.findMany.mockResolvedValue([
      { userId: 'member-2', isPresent: true },
    ]);
    prisma.ebdEnrollment.findMany.mockResolvedValue([
      {
        user: {
          id: memberId,
          name: 'Adriano Silva',
          memberProfiles: [{ photoUrl: 'https://example.test/photo.png' }],
        },
      },
    ]);

    // When
    const attendances = await service.getLessonAttendance(churchId, lessonId);

    // Then
    expect(attendances).toEqual([
      {
        memberId,
        name: 'Adriano Silva',
        photoUrl: 'https://example.test/photo.png',
        isPresent: false,
      },
    ]);
  });

  it('should bulk save attendance, upsert the journal, and mark lesson completed in one transaction', async () => {
    // Given
    prisma.ebdLesson.findFirst.mockResolvedValue({ id: lessonId, classId });
    prisma.ebdAttendance.upsert.mockResolvedValue({});
    prisma.ebdJournal.upsert.mockResolvedValue({ id: 'journal-1' });
    prisma.ebdLesson.update.mockResolvedValue({
      id: lessonId,
      isCompleted: true,
    });

    // When
    const result = await service.saveLessonAttendance(churchId, lessonId, {
      visitorCount: 0,
      offeringAmount: 25,
      attendances: [
        { memberId: 'member-1', isPresent: true },
        { memberId: 'member-2', isPresent: false },
      ],
    });

    // Then
    expect(prisma.$transaction).toHaveBeenCalledTimes(1);
    expect(prisma.ebdAttendance.upsert).toHaveBeenCalledTimes(2);
    expect(prisma.ebdJournal.upsert).toHaveBeenCalledWith(
      expect.objectContaining({
        create: expect.objectContaining({
          visitorCount: 0,
          offeringAmount: 25,
        }),
        update: expect.objectContaining({
          visitorCount: 0,
          offeringAmount: 25,
        }),
      }),
    );
    expect(prisma.ebdLesson.update).toHaveBeenCalledWith({
      where: { id: lessonId },
      data: { isCompleted: true },
    });
    expect(result.lesson.isCompleted).toBe(true);
  });

  it('should calculate active member progress using lessons up to today', async () => {
    // Given
    prisma.ebdEnrollment.findFirst.mockResolvedValue({
      classId,
      class_: { id: classId, name: 'Parables of Jesus' },
    });
    prisma.ebdLesson.findMany.mockResolvedValue([
      { id: 'lesson-1' },
      { id: 'lesson-2' },
    ]);
    prisma.ebdAttendance.count.mockResolvedValue(1);

    // When
    const progress = await service.getMemberProgress(churchId, memberId);

    // Then
    expect(progress).toMatchObject({
      memberId,
      classId,
      totalLessons: 2,
      totalPresences: 1,
      frequencyPercentage: 50,
    });
  });

  it('should reject certificate generation when member frequency is below 80 percent', async () => {
    // Given
    prisma.ebdEnrollment.findFirst.mockResolvedValue({
      classId,
      class_: { id: classId, name: 'Parables of Jesus' },
    });
    prisma.ebdLesson.findMany.mockResolvedValue([
      { id: 'lesson-1' },
      { id: 'lesson-2' },
      { id: 'lesson-3' },
      { id: 'lesson-4' },
      { id: 'lesson-5' },
    ]);
    prisma.ebdAttendance.count.mockResolvedValue(3);

    // When
    const attempt = service.createMemberCertificate(churchId, memberId);

    // Then
    await expect(attempt).rejects.toThrow(BadRequestException);
  });

  it('should reject class creation when the quarter does not belong to the church', async () => {
    // Given
    prisma.ebdQuarter.findFirst.mockResolvedValue(null);

    // When
    const attempt = service.createClass(churchId, {
      name: 'Parables of Jesus',
      targetAudience: 'Adults',
      quarterId: 'quarter-1',
      branchId,
      teacherId: 'teacher-1',
      studentIds: [],
      lessons: Array.from({ length: 13 }, (_, index) => ({
        theme: `Lesson ${index + 1}`,
        scheduledDate: `2026-05-${String(index + 1).padStart(2, '0')}`,
      })),
    });

    // Then
    await expect(attempt).rejects.toThrow(NotFoundException);
  });

  // ── updateClass ───────────────────────────────────────────────────────────

  describe('updateClass', () => {
    it('should update name and targetAudience when only scalar fields are provided', async () => {
      // Given
      prisma.ebdClass.findFirst.mockResolvedValue({ id: classId, churchId });
      prisma.ebdClass.update.mockResolvedValue({
        id: classId,
        name: 'Updated Name',
        targetAudience: 'Youth',
      });

      // When
      await service.updateClass(churchId, classId, {
        name: 'Updated Name',
        targetAudience: 'Youth',
      });

      // Then
      expect(prisma.ebdClass.update).toHaveBeenCalledWith({
        where: { id: classId },
        data: { name: 'Updated Name', targetAudience: 'Youth' },
      });
      expect(prisma.ebdClassTeacher.deleteMany).not.toHaveBeenCalled();
      expect(prisma.ebdEnrollment.deleteMany).not.toHaveBeenCalled();
    });

    it('should link an existing quarter when quarterName matches one already in the church', async () => {
      // Given
      prisma.ebdClass.findFirst.mockResolvedValue({ id: classId, churchId });
      prisma.ebdClass.update.mockResolvedValue({ id: classId });
      prisma.ebdQuarter.findFirst.mockResolvedValue({
        id: 'quarter-existing',
        churchId,
        name: '2026.2',
      });

      // When
      await service.updateClass(churchId, classId, { quarterName: '2026.2' });

      // Then
      expect(prisma.ebdQuarter.create).not.toHaveBeenCalled();
      expect(prisma.ebdClass.update).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({ quarterId: 'quarter-existing' }),
        }),
      );
    });

    it('should create a new quarter when quarterName does not exist yet', async () => {
      // Given
      prisma.ebdClass.findFirst.mockResolvedValue({ id: classId, churchId });
      prisma.ebdClass.update.mockResolvedValue({ id: classId });
      prisma.ebdQuarter.findFirst.mockResolvedValue(null);
      prisma.ebdQuarter.create.mockResolvedValue({
        id: 'quarter-new',
        churchId,
        name: '2026.3',
      });

      // When
      await service.updateClass(churchId, classId, { quarterName: '2026.3' });

      // Then
      expect(prisma.ebdQuarter.create).toHaveBeenCalledWith({
        data: { churchId, name: '2026.3', status: 'ACTIVE' },
      });
      expect(prisma.ebdClass.update).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({ quarterId: 'quarter-new' }),
        }),
      );
    });

    it('should replace teachers when teacherIds is provided', async () => {
      // Given
      prisma.ebdClass.findFirst.mockResolvedValue({ id: classId, churchId });
      prisma.ebdClass.update.mockResolvedValue({ id: classId });
      prisma.ebdClassTeacher.deleteMany.mockResolvedValue({ count: 1 });
      prisma.ebdClassTeacher.createMany.mockResolvedValue({ count: 2 });

      // When
      await service.updateClass(churchId, classId, {
        teacherIds: ['teacher-2', 'teacher-3'],
      });

      // Then
      expect(prisma.ebdClassTeacher.deleteMany).toHaveBeenCalledWith({
        where: { classId },
      });
      expect(prisma.ebdClassTeacher.createMany).toHaveBeenCalledWith({
        data: [
          { classId, userId: 'teacher-2' },
          { classId, userId: 'teacher-3' },
        ],
        skipDuplicates: true,
      });
    });

    it('should replace enrollments when studentIds is provided', async () => {
      // Given
      prisma.ebdClass.findFirst.mockResolvedValue({ id: classId, churchId });
      prisma.ebdClass.update.mockResolvedValue({ id: classId });
      prisma.ebdEnrollment.deleteMany.mockResolvedValue({ count: 2 });
      prisma.ebdEnrollment.createMany.mockResolvedValue({ count: 3 });

      // When
      await service.updateClass(churchId, classId, {
        studentIds: ['student-1', 'student-2', 'student-3'],
      });

      // Then
      expect(prisma.ebdEnrollment.deleteMany).toHaveBeenCalledWith({
        where: { classId },
      });
      expect(prisma.ebdEnrollment.createMany).toHaveBeenCalledWith({
        data: [
          { classId, userId: 'student-1' },
          { classId, userId: 'student-2' },
          { classId, userId: 'student-3' },
        ],
        skipDuplicates: true,
      });
    });

    it('should update lesson themes and dates matched by position', async () => {
      // Given
      const existingLessons = Array.from({ length: 13 }, (_, i) => ({
        id: `lesson-${i + 1}`,
        number: i + 1,
      }));
      prisma.ebdClass.findFirst.mockResolvedValue({ id: classId, churchId });
      prisma.ebdClass.update.mockResolvedValue({ id: classId });
      prisma.ebdLesson.findMany.mockResolvedValue(existingLessons);
      prisma.ebdLesson.update.mockResolvedValue({});

      const updatedLessons = Array.from({ length: 13 }, (_, i) => ({
        theme: `Updated Theme ${i + 1}`,
        scheduledDate: `2026-06-${String(i + 1).padStart(2, '0')}`,
      }));

      // When
      await service.updateClass(churchId, classId, {
        lessons: updatedLessons,
      });

      // Then
      expect(prisma.ebdLesson.findMany).toHaveBeenCalledWith(
        expect.objectContaining({ orderBy: { number: 'asc' } }),
      );
      expect(prisma.ebdLesson.update).toHaveBeenCalledTimes(13);
      expect(prisma.ebdLesson.update).toHaveBeenCalledWith({
        where: { id: 'lesson-1' },
        data: {
          theme: 'Updated Theme 1',
          scheduledDate: new Date('2026-06-01'),
        },
      });
    });

    it('should throw NotFoundException when class does not belong to the church', async () => {
      // Given
      prisma.ebdClass.findFirst.mockResolvedValue(null);

      // When
      const attempt = service.updateClass(churchId, classId, {
        name: 'Should Fail',
      });

      // Then
      await expect(attempt).rejects.toThrow(NotFoundException);
    });

    it('should run all updates inside a single transaction', async () => {
      // Given
      prisma.ebdClass.findFirst.mockResolvedValue({ id: classId, churchId });
      prisma.ebdClass.update.mockResolvedValue({ id: classId });
      prisma.ebdClassTeacher.deleteMany.mockResolvedValue({ count: 1 });
      prisma.ebdClassTeacher.createMany.mockResolvedValue({ count: 1 });
      prisma.ebdEnrollment.deleteMany.mockResolvedValue({ count: 1 });
      prisma.ebdEnrollment.createMany.mockResolvedValue({ count: 1 });

      // When
      await service.updateClass(churchId, classId, {
        name: 'Full Update',
        teacherIds: ['teacher-1'],
        studentIds: ['student-1'],
      });

      // Then
      expect(prisma.$transaction).toHaveBeenCalledTimes(1);
    });
  });
});
