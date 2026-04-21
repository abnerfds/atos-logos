import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateVisitorDto } from './dto/create-visitor.dto';
import { UpdateVisitorDto } from './dto/update-visitor.dto';

@Injectable()
export class VisitorsService {
  constructor(private prisma: PrismaService) {}

  async findAll(churchId: string, page = 1, limit = 20) {
    const skip = (page - 1) * limit;
    const [data, total] = await Promise.all([
      this.prisma.forTenant(churchId).visitor.findMany({
        include: { _count: { select: { attendances: true } } },
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
      }),
      this.prisma.forTenant(churchId).visitor.count({}),
    ]);
    return { data, total, page, limit };
  }

  async findOne(churchId: string, visitorId: string) {
    const visitor = await this.prisma.forTenant(churchId).visitor.findFirst({
      where: { id: visitorId },
      include: {
        attendances: {
          include: { event: { select: { id: true, title: true, startsAt: true, type: true } } },
          orderBy: { createdAt: 'desc' },
        },
      },
    });
    if (!visitor) throw new NotFoundException('Visitor not found');
    return visitor;
  }

  async create(churchId: string, dto: CreateVisitorDto) {
    return this.prisma.visitor.create({
      data: { churchId, ...dto },
    });
  }

  async update(churchId: string, visitorId: string, dto: UpdateVisitorDto) {
    const visitor = await this.prisma.forTenant(churchId).visitor.findFirst({
      where: { id: visitorId },
    });
    if (!visitor) throw new NotFoundException('Visitor not found');

    return this.prisma.visitor.update({
      where: { id: visitorId },
      data: dto,
    });
  }

  async checkIn(churchId: string, visitorId: string, eventId: string) {
    // Verify visitor belongs to this church
    const visitor = await this.prisma.forTenant(churchId).visitor.findFirst({
      where: { id: visitorId },
    });
    if (!visitor) throw new NotFoundException('Visitor not found');

    // Verify event belongs to this church
    const event = await this.prisma.forTenant(churchId).event.findFirst({
      where: { id: eventId },
    });
    if (!event) throw new NotFoundException('Event not found');

    return this.prisma.visitorAttendance.create({
      data: { visitorId, eventId },
      include: {
        visitor: { select: { id: true, name: true } },
        event: { select: { id: true, title: true, startsAt: true } },
      },
    });
  }
}
