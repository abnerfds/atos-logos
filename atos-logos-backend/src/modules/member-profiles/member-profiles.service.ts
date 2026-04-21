import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateMemberProfileDto } from './dto/create-member-profile.dto';
import { UpdateMemberProfileDto } from './dto/update-member-profile.dto';

@Injectable()
export class MemberProfilesService {
  constructor(private prisma: PrismaService) {}

  // All user columns that the secretariat edit form needs to pre-fill.
  // Kept in one place so adding a new column only requires one change.
  private readonly userSelect = {
    id: true,
    name: true,
    email: true,
    phone: true,
    cpf: true,
    rg: true,
    sex: true,
    civilStatus: true,
    fatherName: true,
    motherName: true,
    country: true,
    state: true,
    city: true,
    neighborhood: true,
    street: true,
    number: true,
    complement: true,
  } as const;

  async findAll(churchId: string, page = 1, limit = 20) {
    const skip = (page - 1) * limit;
    const [data, total] = await Promise.all([
      this.prisma.forTenant(churchId).memberProfile.findMany({
        include: { user: { select: this.userSelect } },
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
      }),
      this.prisma.forTenant(churchId).memberProfile.count({}),
    ]);
    return { data, total, page, limit };
  }

  async findOne(churchId: string, profileId: string) {
    const profile = await this.prisma.forTenant(churchId).memberProfile.findFirst({
      where: { id: profileId },
      include: { user: { select: this.userSelect } },
    });
    if (!profile) {
      throw new NotFoundException('Member profile not found');
    }
    return profile;
  }

  async findByUserId(churchId: string, userId: string) {
    const userSelect = this.userSelect;

    // Try to find existing member profile
    const profile = await this.prisma.forTenant(churchId).memberProfile.findFirst({
      where: { userId },
      include: { user: { select: userSelect } },
    });

    if (profile) {
      return profile;
    }

    // No profile yet — return user+membership data with null profile fields
    const membership = await this.prisma.forTenant(churchId).membership.findFirst({
      where: { userId, status: 'ACTIVE' },
      include: { user: { select: userSelect } },
    });

    if (!membership) {
      throw new NotFoundException('User not found in this church');
    }

    return {
      id: null,
      userId: membership.userId,
      churchId,
      registrationNumber: null,
      birthDate: null,
      baptismDate: null,
      admissionDate: null,
      consecrationDate: null,
      photoUrl: null,
      user: membership.user,
    };
  }

  async create(churchId: string, dto: CreateMemberProfileDto) {
    // Verify user has a membership in this church
    const membership = await this.prisma.forTenant(churchId).membership.findFirst({
      where: { userId: dto.userId, status: 'ACTIVE' },
    });
    if (!membership) {
      throw new BadRequestException('User does not have an active membership in this church');
    }

    // Check if profile already exists for this user in this church
    const existing = await this.prisma.forTenant(churchId).memberProfile.findFirst({
      where: { userId: dto.userId },
    });
    if (existing) {
      throw new BadRequestException('Member profile already exists for this user');
    }

    // Auto-generate registration number: YYYY-BRANCH_SHORT-SEQ
    const registrationNumber = await this.generateRegistrationNumber(churchId, dto.branchId);

    return this.prisma.memberProfile.create({
      data: {
        userId: dto.userId,
        churchId,
        registrationNumber,
        birthDate: new Date(dto.birthDate),
        baptismDate: dto.baptismDate ? new Date(dto.baptismDate) : null,
        consecrationDate: dto.consecrationDate
          ? new Date(dto.consecrationDate)
          : null,
        admissionDate: new Date(dto.admissionDate),
        photoUrl: dto.photoUrl,
      },
      include: { user: { select: this.userSelect } },
    });
  }

  async update(churchId: string, profileId: string, dto: UpdateMemberProfileDto) {
    const profile = await this.prisma.forTenant(churchId).memberProfile.findFirst({
      where: { id: profileId },
    });
    if (!profile) {
      throw new NotFoundException('Member profile not found');
    }

    return this.prisma.memberProfile.update({
      where: { id: profileId },
      data: {
        ...(dto.birthDate && { birthDate: new Date(dto.birthDate) }),
        ...(dto.baptismDate && { baptismDate: new Date(dto.baptismDate) }),
        ...(dto.consecrationDate && {
          consecrationDate: new Date(dto.consecrationDate),
        }),
        ...(dto.admissionDate && { admissionDate: new Date(dto.admissionDate) }),
        ...(dto.photoUrl !== undefined && { photoUrl: dto.photoUrl }),
      },
    });
  }

  async findBirthdays(churchId: string, month?: number) {
    // TODO: For large churches, push month filtering to database using $queryRaw
    // Currently loads all profiles with birthDates and filters in-app
    const targetMonth = month ?? (new Date().getMonth() + 1);

    const profiles = await this.prisma.forTenant(churchId).memberProfile.findMany({
      where: { birthDate: { not: undefined } },
      include: { user: { select: { name: true } } },
    });

    const filtered = profiles.filter((p) => {
      if (!p.birthDate) return false;
      return p.birthDate.getMonth() + 1 === targetMonth;
    });

    return {
      data: filtered.map((p) => ({
        id: p.id,
        name: p.user.name,
        photoUrl: p.photoUrl,
        birthDate: p.birthDate,
      })),
      month: targetMonth,
    };
  }

  async remove(churchId: string, profileId: string) {
    const profile = await this.prisma.forTenant(churchId).memberProfile.findFirst({
      where: { id: profileId },
    });
    if (!profile) {
      throw new NotFoundException('Member profile not found');
    }
    return this.prisma.memberProfile.delete({ where: { id: profileId } });
  }

  /**
   * Generates a unique registration number in format: YYYY-BRANCHSHORT-SEQUENCE
   * Example: 2026-A1B2-001
   */
  private async generateRegistrationNumber(churchId: string, branchId: string): Promise<string> {
    const year = new Date().getFullYear();
    const branchShort = branchId.substring(0, 4).toUpperCase();

    // Count existing profiles in this church to determine sequence
    const count = await this.prisma.memberProfile.count({
      where: { churchId },
    });
    const seq = String(count + 1).padStart(3, '0');

    return `${year}-${branchShort}-${seq}`;
  }
}
