import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreatePositionDto } from './dto/create-position.dto';
import { UpdatePositionDto } from './dto/update-position.dto';

@Injectable()
export class MemberPositionsService {
  constructor(private prisma: PrismaService) {}

  async findAll(churchId: string) {
    return this.prisma.forTenant(churchId).memberPosition.findMany({
      include: {
        users: {
          include: { user: { select: { id: true, name: true } } },
        },
      },
      orderBy: { name: 'asc' },
    });
  }

  async create(churchId: string, dto: CreatePositionDto) {
    return this.prisma.memberPosition.create({
      data: { churchId, name: dto.name },
    });
  }

  async update(churchId: string, positionId: string, dto: UpdatePositionDto) {
    const position = await this.prisma.forTenant(churchId).memberPosition.findFirst({
      where: { id: positionId },
    });
    if (!position) {
      throw new NotFoundException('Position not found');
    }
    return this.prisma.memberPosition.update({
      where: { id: positionId },
      data: dto,
    });
  }

  async remove(churchId: string, positionId: string) {
    const position = await this.prisma.forTenant(churchId).memberPosition.findFirst({
      where: { id: positionId },
    });
    if (!position) {
      throw new NotFoundException('Position not found');
    }
    return this.prisma.memberPosition.delete({ where: { id: positionId } });
  }

  // ── Position ↔ User assignment ────────────────────────────────────────

  async assignUser(churchId: string, positionId: string, userId: string) {
    // Verify position belongs to this church
    const position = await this.prisma.forTenant(churchId).memberPosition.findFirst({
      where: { id: positionId },
    });
    if (!position) {
      throw new NotFoundException('Position not found');
    }

    // Verify user has a membership in this church
    const membership = await this.prisma.forTenant(churchId).membership.findFirst({
      where: { userId, status: 'ACTIVE' },
    });
    if (!membership) {
      throw new BadRequestException('User does not have an active membership in this church');
    }

    return this.prisma.positionUser.create({
      data: { userId, positionId },
      include: { user: { select: { id: true, name: true } }, position: true },
    });
  }

  async unassignUser(churchId: string, positionId: string, userId: string) {
    const position = await this.prisma.forTenant(churchId).memberPosition.findFirst({
      where: { id: positionId },
    });
    if (!position) {
      throw new NotFoundException('Position not found');
    }

    const assignment = await this.prisma.positionUser.findFirst({
      where: { positionId, userId },
    });
    if (!assignment) {
      throw new NotFoundException('User is not assigned to this position');
    }

    return this.prisma.positionUser.delete({ where: { id: assignment.id } });
  }
}
