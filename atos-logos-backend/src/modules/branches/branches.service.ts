import {
  ConflictException,
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateBranchDto } from './dto/create-branch.dto';
import { UpdateBranchDto } from './dto/update-branch.dto';

@Injectable()
export class BranchesService {
  constructor(private prisma: PrismaService) {}

  async findAll(churchId: string, q?: string) {
    // Only attach the name filter when q is a non-empty string so the
    // default listing stays a clean SELECT — matches the Members
    // pattern so the two listings behave the same way.
    const where = q && q.trim().length > 0
      ? { name: { contains: q.trim(), mode: 'insensitive' as const } }
      : {};
    return this.prisma.forTenant(churchId).branch.findMany({
      where,
      include: { _count: { select: { memberships: true } } },
      orderBy: [{ isHeadquarters: 'desc' }, { name: 'asc' }],
    });
  }

  async create(churchId: string, dto: CreateBranchDto) {
    return this.prisma.branch.create({
      data: {
        churchId,
        name: dto.name,
        country: dto.country,
        state: dto.state,
        city: dto.city,
        neighborhood: dto.neighborhood,
        street: dto.street,
        number: dto.number,
        isHeadquarters: false, // Only signup creates HQ
      },
    });
  }

  async update(churchId: string, branchId: string, dto: UpdateBranchDto) {
    const branch = await this.prisma.forTenant(churchId).branch.findFirst({
      where: { id: branchId },
    });
    if (!branch) {
      throw new NotFoundException('Branch not found');
    }
    return this.prisma.branch.update({
      where: { id: branchId },
      data: dto,
    });
  }

  /**
   * Promotes a Filial to Sede. Because the business rule is "exactly
   * one HQ per church", this is an atomic swap: the current HQ (if any)
   * is demoted inside the SAME transaction so the church is never left
   * in a state with zero or two HQs — even if the second write fails.
   *
   * Throws:
   *  - NotFoundException if the branch doesn't belong to this tenant.
   *  - ConflictException if the branch is already the HQ (would be a
   *    no-op that silently passes; better to surface it).
   */
  async promoteToHeadquarters(churchId: string, branchId: string) {
    const branch = await this.prisma.forTenant(churchId).branch.findFirst({
      where: { id: branchId },
    });
    if (!branch) {
      throw new NotFoundException('Branch not found in this church');
    }
    if (branch.isHeadquarters) {
      throw new ConflictException('Branch is already the headquarters');
    }

    // Atomic swap: demote whoever is currently HQ, then promote the
    // target. updateMany is cheap when no row matches — if the church
    // happens to have zero HQs (shouldn't be possible today but is
    // defensive) the promote still runs.
    return this.prisma.$transaction(async (tx) => {
      await tx.branch.updateMany({
        where: { churchId, isHeadquarters: true },
        data: { isHeadquarters: false },
      });
      return tx.branch.update({
        where: { id: branchId },
        data: { isHeadquarters: true },
      });
    });
  }

  async remove(churchId: string, branchId: string) {
    const branch = await this.prisma.forTenant(churchId).branch.findFirst({
      where: { id: branchId },
    });
    if (!branch) {
      throw new NotFoundException('Branch not found');
    }
    if (branch.isHeadquarters) {
      throw new ForbiddenException('Cannot delete the headquarters branch');
    }

    // Pre-check dependents so we can surface a friendly 409 instead of
    // letting Postgres raise a raw FK violation that the filter would
    // map to a generic 500. Covers the three relations pointing at
    // Branch without onDelete: Cascade (schema.prisma).
    const [memberships, events, ebdClasses] = await Promise.all([
      this.prisma.membership.count({ where: { branchId } }),
      this.prisma.event.count({ where: { branchId } }),
      this.prisma.ebdClass.count({ where: { branchId } }),
    ]);
    const total = memberships + events + ebdClasses;
    if (total > 0) {
      throw new ConflictException(
        `Não é possível excluir esta filial: existem ${total} registro(s) vinculado(s) ` +
          `(${memberships} membro(s), ${events} evento(s), ${ebdClasses} turma(s) de EBD). ` +
          `Transfira ou remova esses vínculos primeiro.`,
      );
    }

    return this.prisma.branch.delete({ where: { id: branchId } });
  }
}
