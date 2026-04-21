import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { CivilStatus, Prisma, Role, Sex } from '@prisma/client';

import { PrismaService } from '../../prisma/prisma.service';
import { CreateMembershipDto } from './dto/create-membership.dto';
import { CreateMemberWithUserDto } from './dto/create-member-with-user.dto';
import { UpdateMembershipDto } from './dto/update-membership.dto';
import { UpdateMemberUserDataDto } from './dto/update-member-user-data.dto';

@Injectable()
export class MembershipsService {
  constructor(private prisma: PrismaService) {}

  async findAll(churchId: string, page = 1, limit = 20, q?: string) {
    const skip = (page - 1) * limit;
    // Only attach the name filter when q is a non-empty string so the
    // default listing stays a clean SELECT without a WHERE clause.
    const where = q && q.trim().length > 0
      ? { user: { name: { contains: q.trim(), mode: 'insensitive' as const } } }
      : {};
    const [data, total] = await Promise.all([
      this.prisma.forTenant(churchId).membership.findMany({
        where,
        include: { user: { select: { id: true, name: true, phone: true, email: true } }, branch: true },
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
      }),
      this.prisma.forTenant(churchId).membership.count({ where }),
    ]);
    return { data, total, page, limit };
  }

  async create(churchId: string, callerRole: Role, dto: CreateMembershipDto) {
    // Only ADMIN may assign ADMIN/SECRETARY; SECRETARY can onboard MEMBERs only.
    this.assertCanAssignRole(callerRole, dto.role);

    // Verify branch belongs to this church
    const branch = await this.prisma.forTenant(churchId).branch.findFirst({
      where: { id: dto.branchId },
    });
    if (!branch) {
      throw new NotFoundException('Branch not found in this church');
    }

    return this.prisma.membership.create({
      data: {
        userId: dto.userId,
        churchId,
        branchId: dto.branchId,
        role: dto.role || 'MEMBER',
        status: 'ACTIVE',
      },
      include: { user: { select: { id: true, name: true, phone: true, email: true } } },
    });
  }

  /**
   * Secretariat entry-point: creates a `User`, a `Membership` and (when
   * both `birthDate` and `admissionDate` are provided) a `MemberProfile`
   * in a single transaction, so a new member is onboarded atomically
   * without half-committed rows.
   *
   * The password is a temporary string supplied by the secretary. It is
   * bcrypt-hashed before persistence; the returned object never includes
   * the password field.
   */
  async createWithUser(
    churchId: string,
    callerRole: Role,
    dto: CreateMemberWithUserDto,
  ) {
    // 0. Role-assignment guard: SECRETARY cannot self-elevate by
    //    creating an ADMIN (or SECRETARY) member. Enforced here, before
    //    any DB work, so the rejection is loud and testable at service
    //    level rather than hidden behind a controller guard.
    this.assertCanAssignRole(callerRole, dto.role);

    // 1. Tenant validation: the branch must belong to this church.
    const branch = await this.prisma.forTenant(churchId).branch.findFirst({
      where: { id: dto.branchId },
    });
    if (!branch) {
      throw new NotFoundException('Branch not found in this church');
    }

    // 1b. If a position was picked on the form, verify it belongs to
    //     this church too — otherwise a secretary could spoof a position
    //     from another tenant via its UUID.
    if (dto.positionId) {
      const position = await this.prisma.forTenant(churchId).memberPosition.findFirst({
        where: { id: dto.positionId },
      });
      if (!position) {
        throw new NotFoundException('Position not found in this church');
      }
    }

    // 2. Uniqueness pre-check: surface a 400 with a readable message
    //    instead of letting Prisma throw a raw 500 on unique conflicts.
    await this.ensureNoConflictingUser({
      email: dto.email,
      cpf: dto.cpf,
      phone: dto.phone,
    });

    // 3. Hash the temp password before it touches the DB.
    const hashedPassword = await bcrypt.hash(dto.password, 10);

    // 4. Determine whether we have enough data for a MemberProfile.
    //    Schema requires birthDate AND admissionDate (both NOT NULL).
    const hasProfileData = Boolean(dto.birthDate && dto.admissionDate);

    // 5. Whole onboarding goes inside a single transaction. We also
    //    retry the transaction if the unique constraint on
    //    `MemberProfile.registrationNumber` fires — two secretaries
    //    creating members at the same moment can both compute the same
    //    YYYY-BRANCH-SEQ because Postgres READ COMMITTED lets them see
    //    the same count. On collision we re-run and recompute.
    const txResult = await this.runWithRegistrationNumberRetry(async () => {
      return this.prisma.$transaction(async (tx) => {
        const user = await tx.user.create({
          data: {
            name: dto.name,
            email: dto.email,
            phone: dto.phone,
            cpf: dto.cpf,
            rg: dto.rg,
            sex: dto.sex,
            civilStatus: dto.civilStatus,
            fatherName: dto.fatherName,
            motherName: dto.motherName,
            password: hashedPassword,
          },
        });

        const membership = await tx.membership.create({
          data: {
            userId: user.id,
            churchId,
            branchId: dto.branchId,
            role: dto.role ?? 'MEMBER',
            status: 'ACTIVE',
          },
        });

        let profile: unknown = null;
        if (hasProfileData) {
          // Count INSIDE the tx so it reflects the latest committed
          // state under the tx's snapshot; the outer retry handles the
          // residual race where two txs see the same count.
          const count = await tx.memberProfile.count({ where: { churchId } });
          const registrationNumber = this.buildRegistrationNumber(
            dto.branchId,
            count,
          );
          profile = await tx.memberProfile.create({
            data: {
              userId: user.id,
              churchId,
              registrationNumber,
              birthDate: new Date(dto.birthDate!),
              admissionDate: new Date(dto.admissionDate!),
              baptismDate: dto.baptismDate ? new Date(dto.baptismDate) : null,
              consecrationDate: dto.consecrationDate
                ? new Date(dto.consecrationDate)
                : null,
            },
          });
        }

        if (dto.positionId) {
          await tx.positionUser.create({
            data: {
              userId: user.id,
              positionId: dto.positionId,
            },
          });
        }

        return { user, membership, profile };
      });
    });

    // Strip the password from the returned user so it never leaves the
    // service boundary, even in logs.
    const { password: _, ...userWithoutPassword } = txResult.user as {
      password: string;
      [k: string]: unknown;
    };
    return {
      user: userWithoutPassword,
      membership: txResult.membership,
      profile: txResult.profile,
    };
  }

  /**
   * Secretariat edit form: updates only the underlying User's editable
   * columns (name/email/phone/cpf + address). Keeps role/status/branch
   * out of scope — those belong to `update()`.
   *
   * Guards against:
   *  - editing a user from another tenant (no membership in churchId)
   *  - uniqueness conflicts on email/cpf/phone (excluding the user's own row)
   *
   * Never touches the password column.
   */
  async updateMemberUserData(
    churchId: string,
    userId: string,
    dto: UpdateMemberUserDataDto,
  ) {
    // 1. Tenant check — without this, any admin could PATCH any user
    //    across churches by guessing the userId.
    const membership = await this.prisma.forTenant(churchId).membership.findFirst({
      where: { userId },
    });
    if (!membership) {
      throw new NotFoundException('Membership not found');
    }

    // 2. Validate that any membership-level target (branch, position)
    //    belongs to this tenant too — otherwise the DTO's UUID check
    //    alone would let a secretary move a member into another church's
    //    branch by guessing its UUID.
    if (dto.branchId) {
      const branch = await this.prisma.forTenant(churchId).branch.findFirst({
        where: { id: dto.branchId },
      });
      if (!branch) {
        throw new NotFoundException('Branch not found in this church');
      }
    }
    if (dto.positionId) {
      const position = await this.prisma
        .forTenant(churchId)
        .memberPosition.findFirst({
          where: { id: dto.positionId },
        });
      if (!position) {
        throw new NotFoundException('Position not found in this church');
      }
    }

    // 3. Prevent "A user with this email already exists" false-positives
    //    by excluding the user's own row from the uniqueness lookup.
    await this.ensureNoConflictingUser(
      { email: dto.email, cpf: dto.cpf, phone: dto.phone },
      { excludeUserId: userId },
    );

    // 4. Build the user payload from only the supplied fields so we
    //    never blank out a column the form didn't touch.
    const userData: Record<string, string | Sex | CivilStatus> = {};
    const userFields: Array<keyof UpdateMemberUserDataDto> = [
      'name',
      'email',
      'phone',
      'cpf',
      'rg',
      'sex',
      'civilStatus',
      'fatherName',
      'motherName',
      'country',
      'state',
      'city',
      'neighborhood',
      'street',
      'number',
      'complement',
    ];
    for (const field of userFields) {
      const value = dto[field];
      if (value !== undefined) {
        userData[field] = value as string | Sex | CivilStatus;
      }
    }

    // 5. Atomic write: user row + membership branch + position assignment
    //    all go through together so the edit form never leaves the record
    //    half-migrated.
    const txResult = await this.prisma.$transaction(async (tx) => {
      const updatedUser = await tx.user.update({
        where: { id: userId },
        data: userData,
      });

      if (dto.branchId) {
        await tx.membership.update({
          where: { id: membership.id },
          data: { branchId: dto.branchId },
        });
      }

      if (dto.positionId) {
        // Replace: a user can only hold one cargo on this form today,
        // so we wipe the previous assignments and insert the new one.
        // Scope the wipe to positions in THIS church so a user who is
        // also a member of another congregation doesn't lose their
        // cargos there when the secretary edits them here.
        await tx.positionUser.deleteMany({
          where: { userId, position: { churchId } },
        });
        await tx.positionUser.create({
          data: { userId, positionId: dto.positionId },
        });
      }

      return updatedUser;
    });

    // Strip password so it never leaks, even into logs.
    const { password: _, ...userWithoutPassword } = txResult as {
      password: string;
      [k: string]: unknown;
    };
    return userWithoutPassword;
  }

  /**
   * Convenience wrapper for the secretariat's "Inativar Membro" button.
   * Resolves the membership row by userId + current tenant and delegates
   * to the existing `update()` flow so the Last-Admin guard still fires.
   */
  async inactivateByUserId(churchId: string, userId: string) {
    const membership = await this.prisma.forTenant(churchId).membership.findFirst({
      where: { userId },
    });
    if (!membership) {
      throw new NotFoundException('Membership not found');
    }
    return this.update(churchId, membership.id, { status: 'INACTIVE' });
  }

  async update(churchId: string, membershipId: string, dto: UpdateMembershipDto) {
    const membership = await this.prisma.forTenant(churchId).membership.findFirst({
      where: { id: membershipId },
    });
    if (!membership) {
      throw new NotFoundException('Membership not found');
    }

    // If downgrading from ADMIN or deactivating, check Last Admin rule
    const isDemotingAdmin =
      membership.role === 'ADMIN' && dto.role && dto.role !== 'ADMIN';
    const isDeactivatingAdmin =
      membership.role === 'ADMIN' &&
      dto.status &&
      dto.status !== 'ACTIVE';

    if (isDemotingAdmin || isDeactivatingAdmin) {
      await this.ensureNotLastAdmin(churchId, membershipId);
    }

    return this.prisma.membership.update({
      where: { id: membershipId },
      data: dto,
    });
  }

  async remove(churchId: string, membershipId: string) {
    const membership = await this.prisma.forTenant(churchId).membership.findFirst({
      where: { id: membershipId },
    });
    if (!membership) {
      throw new NotFoundException('Membership not found');
    }

    if (membership.role === 'ADMIN') {
      await this.ensureNotLastAdmin(churchId, membershipId);
    }

    return this.prisma.membership.delete({ where: { id: membershipId } });
  }

  /**
   * Checks that none of the provided contact fields collide with another
   * user. Each field is only checked when present — the DTO treats all
   * three as optional.
   */
  private async ensureNoConflictingUser(
    candidate: {
      email?: string;
      cpf?: string;
      phone?: string;
    },
    opts: { excludeUserId?: string } = {},
  ) {
    const orFilters: Array<Record<string, string>> = [];
    if (candidate.email) orFilters.push({ email: candidate.email });
    if (candidate.cpf) orFilters.push({ cpf: candidate.cpf });
    if (candidate.phone) orFilters.push({ phone: candidate.phone });
    if (orFilters.length === 0) return;

    // When editing an existing user, skip their own row — otherwise the
    // uniqueness check fires a false-positive on the unchanged email.
    const where: Record<string, unknown> = { OR: orFilters };
    if (opts.excludeUserId) {
      where.id = { not: opts.excludeUserId };
    }

    const existing = await this.prisma.user.findFirst({ where });
    if (existing) {
      throw new BadRequestException(
        'A user with this email, phone or cpf already exists',
      );
    }
  }

  /**
   * Registration number format: YYYY-BRANCHSHORT-SEQ (e.g. 2026-A1B2-001).
   * Kept pure (no I/O) so the caller can compute it from a count read
   * inside a transaction for consistency.
   */
  private buildRegistrationNumber(branchId: string, existingCount: number): string {
    const year = new Date().getFullYear();
    const branchShort = branchId.substring(0, 4).toUpperCase();
    const seq = String(existingCount + 1).padStart(3, '0');
    return `${year}-${branchShort}-${seq}`;
  }

  /**
   * Runs the onboarding transaction; if it fails because two parallel
   * secretaries computed the same `registrationNumber` (P2002 on that
   * column), retries a few times before giving up with a 409. Bounded
   * retry so a genuinely broken unique constraint still surfaces.
   */
  private async runWithRegistrationNumberRetry<T>(
    fn: () => Promise<T>,
    maxAttempts = 3,
  ): Promise<T> {
    for (let attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await fn();
      } catch (err) {
        if (this.isRegistrationNumberConflict(err) && attempt < maxAttempts) {
          continue;
        }
        if (this.isRegistrationNumberConflict(err)) {
          throw new ConflictException(
            'Não foi possível gerar o número de matrícula — tente novamente.',
          );
        }
        throw err;
      }
    }
    // Unreachable: the loop either returns or throws.
    /* istanbul ignore next */
    throw new ConflictException('Registration number retry exhausted');
  }

  private isRegistrationNumberConflict(err: unknown): boolean {
    if (!(err instanceof Prisma.PrismaClientKnownRequestError)) return false;
    if (err.code !== 'P2002') return false;
    const target = err.meta?.target;
    if (Array.isArray(target)) return target.includes('registrationNumber');
    return typeof target === 'string' && target.includes('registrationNumber');
  }

  /**
   * Rule: only ADMIN callers may assign ADMIN or SECRETARY. Leaving
   * role unset (= MEMBER) is always allowed, so secretaries can onboard
   * ordinary members without elevation.
   */
  private assertCanAssignRole(callerRole: Role, requestedRole: Role | undefined) {
    if (!requestedRole || requestedRole === 'MEMBER') return;
    if (callerRole === 'ADMIN') return;
    throw new ForbiddenException(
      'Only an admin can assign the ADMIN or SECRETARY role',
    );
  }

  /**
   * Prevents deletion/demotion/deactivation of the last ACTIVE admin in
   * a church. Excludes the target membership from the count so that
   * inactivating one of exactly two admins correctly triggers the guard
   * (the previous implementation counted the target and missed this
   * edge case).
   */
  private async ensureNotLastAdmin(churchId: string, membershipId: string) {
    const otherActiveAdmins = await this.prisma.membership.count({
      where: {
        churchId,
        role: 'ADMIN',
        status: 'ACTIVE',
        id: { not: membershipId },
      },
    });
    if (otherActiveAdmins === 0) {
      throw new ForbiddenException(
        'Cannot remove or demote the last admin of this church',
      );
    }
  }
}
