import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateEventDto } from './dto/create-event.dto';
import { UpdateEventDto } from './dto/update-event.dto';
import { CreateScheduleDto } from './dto/create-schedule.dto';
import { EventType } from '@prisma/client';

@Injectable()
export class EventsService {
  constructor(private prisma: PrismaService) {}

  async findAll(churchId: string, page = 1, limit = 20, type?: EventType, upcoming?: boolean) {
    const skip = (page - 1) * limit;
    const where: any = {};
    if (type) where.type = type;
    if (upcoming) where.startsAt = { gte: new Date() };

    const orderBy = upcoming ? { startsAt: 'asc' as const } : { startsAt: 'desc' as const };

    const [data, total] = await Promise.all([
      this.prisma.forTenant(churchId).event.findMany({
        where,
        include: {
          branch: { select: { id: true, name: true } },
          schedules: {
            include: { user: { select: { id: true, name: true } } },
          },
          _count: { select: { visitorAttendances: true } },
        },
        orderBy,
        skip,
        take: limit,
      }),
      this.prisma.forTenant(churchId).event.count({ where }),
    ]);
    return { data, total, page, limit };
  }

  async findOne(churchId: string, eventId: string) {
    const event = await this.prisma.forTenant(churchId).event.findFirst({
      where: { id: eventId },
      include: {
        branch: { select: { id: true, name: true } },
        schedules: {
          include: { user: { select: { id: true, name: true } } },
        },
        visitorAttendances: {
          include: { visitor: { select: { id: true, name: true } } },
        },
      },
    });
    if (!event) throw new NotFoundException('Event not found');
    return event;
  }

  async create(churchId: string, dto: CreateEventDto) {
    return this.prisma.event.create({
      data: {
        churchId,
        title: dto.title,
        startsAt: new Date(dto.startsAt),
        type: dto.type,
        branchId: dto.branchId || null,
      },
      include: { branch: { select: { id: true, name: true } } },
    });
  }

  async update(churchId: string, eventId: string, dto: UpdateEventDto) {
    const event = await this.prisma.forTenant(churchId).event.findFirst({
      where: { id: eventId },
    });
    if (!event) throw new NotFoundException('Event not found');

    return this.prisma.event.update({
      where: { id: eventId },
      data: {
        ...(dto.title && { title: dto.title }),
        ...(dto.startsAt && { startsAt: new Date(dto.startsAt) }),
        ...(dto.type && { type: dto.type }),
      },
    });
  }

  async remove(churchId: string, eventId: string) {
    const event = await this.prisma.forTenant(churchId).event.findFirst({
      where: { id: eventId },
    });
    if (!event) throw new NotFoundException('Event not found');
    return this.prisma.event.delete({ where: { id: eventId } });
  }

  // ── Schedule management ───────────────────────────────────────────────

  async addSchedule(churchId: string, eventId: string, dto: CreateScheduleDto) {
    const event = await this.prisma.forTenant(churchId).event.findFirst({
      where: { id: eventId },
    });
    if (!event) throw new NotFoundException('Event not found');

    return this.prisma.eventSchedule.create({
      data: {
        eventId,
        userId: dto.userId,
        functionName: dto.functionName,
      },
      include: { user: { select: { id: true, name: true } } },
    });
  }

  async removeSchedule(churchId: string, eventId: string, scheduleId: string) {
    const event = await this.prisma.forTenant(churchId).event.findFirst({
      where: { id: eventId },
    });
    if (!event) throw new NotFoundException('Event not found');

    const schedule = await this.prisma.eventSchedule.findFirst({
      where: { id: scheduleId, eventId },
    });
    if (!schedule) throw new NotFoundException('Schedule entry not found');

    return this.prisma.eventSchedule.delete({ where: { id: scheduleId } });
  }
}
