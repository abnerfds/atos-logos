import { Test, TestingModule } from '@nestjs/testing';
import {
  ConflictException,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { BranchesService } from './branches.service';
import { PrismaService } from '../../prisma/prisma.service';

const mockBranchModel = {
  findMany: jest.fn(),
  findFirst: jest.fn(),
};

const mockPrisma = {
  forTenant: jest.fn().mockReturnValue({ branch: mockBranchModel }),
  branch: {
    create: jest.fn(),
    update: jest.fn(),
    delete: jest.fn(),
    findFirst: jest.fn(),
    updateMany: jest.fn(),
  },
  membership: { count: jest.fn().mockResolvedValue(0) },
  event: { count: jest.fn().mockResolvedValue(0) },
  ebdClass: { count: jest.fn().mockResolvedValue(0) },
  $transaction: jest.fn(),
};

describe('BranchesService', () => {
  let service: BranchesService;
  let prisma: typeof mockPrisma;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        BranchesService,
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();

    service = module.get<BranchesService>(BranchesService);
    prisma = module.get(PrismaService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findAll', () => {
    it('should return branches with membership count', async () => {
      const branches = [
        {
          id: 'branch-1',
          name: 'Sede',
          isHeadquarters: true,
          _count: { memberships: 10 },
        },
        {
          id: 'branch-2',
          name: 'Filial Centro',
          isHeadquarters: false,
          _count: { memberships: 5 },
        },
      ];

      mockBranchModel.findMany.mockResolvedValue(branches);

      const result = await service.findAll('church-1');

      expect(prisma.forTenant).toHaveBeenCalledWith('church-1');
      expect(mockBranchModel.findMany).toHaveBeenCalledWith({
        where: {},
        include: { _count: { select: { memberships: true } } },
        orderBy: [{ isHeadquarters: 'desc' }, { name: 'asc' }],
      });
      expect(result).toEqual(branches);
      expect(result[0]._count.memberships).toBe(10);
      expect(result[1]._count.memberships).toBe(5);
    });

    it('should filter by case-insensitive name substring when q is provided', async () => {
      mockBranchModel.findMany.mockResolvedValue([]);

      await service.findAll('church-1', 'Filial');

      expect(mockBranchModel.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { name: { contains: 'Filial', mode: 'insensitive' } },
        }),
      );
    });

    it('should trim q before forwarding to Prisma', async () => {
      mockBranchModel.findMany.mockResolvedValue([]);

      await service.findAll('church-1', '  Sede  ');

      expect(mockBranchModel.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { name: { contains: 'Sede', mode: 'insensitive' } },
        }),
      );
    });

    it('should NOT attach a WHERE clause when q is whitespace-only', async () => {
      mockBranchModel.findMany.mockResolvedValue([]);

      await service.findAll('church-1', '   ');

      expect(mockBranchModel.findMany).toHaveBeenCalledWith(
        expect.objectContaining({ where: {} }),
      );
    });
  });

  describe('create', () => {
    it('should create a branch with structured address fields', async () => {
      const dto = {
        name: 'Filial Norte',
        country: 'Brasil',
        state: 'SP',
        city: 'São Paulo',
        neighborhood: 'Santana',
        street: 'Rua Voluntários da Pátria',
        number: '1234',
      };

      const created = {
        id: 'branch-new',
        churchId: 'church-1',
        isHeadquarters: false,
        ...dto,
      };

      mockPrisma.branch.create.mockResolvedValue(created);

      const result = await service.create('church-1', dto);

      expect(mockPrisma.branch.create).toHaveBeenCalledWith({
        data: {
          churchId: 'church-1',
          name: dto.name,
          country: dto.country,
          state: dto.state,
          city: dto.city,
          neighborhood: dto.neighborhood,
          street: dto.street,
          number: dto.number,
          isHeadquarters: false,
        },
      });
      expect(result).toEqual(created);
    });
  });

  describe('update', () => {
    it('should update a branch', async () => {
      const existing = {
        id: 'branch-1',
        name: 'Old Name',
        isHeadquarters: false,
      };
      const dto = { name: 'New Name' };
      const updated = { ...existing, ...dto };

      mockBranchModel.findFirst.mockResolvedValue(existing);
      mockPrisma.branch.update.mockResolvedValue(updated);

      const result = await service.update('church-1', 'branch-1', dto);

      expect(prisma.forTenant).toHaveBeenCalledWith('church-1');
      expect(mockBranchModel.findFirst).toHaveBeenCalledWith({
        where: { id: 'branch-1' },
      });
      expect(mockPrisma.branch.update).toHaveBeenCalledWith({
        where: { id: 'branch-1' },
        data: dto,
      });
      expect(result).toEqual(updated);
    });

    it('should throw NotFoundException when not found', async () => {
      mockBranchModel.findFirst.mockResolvedValue(null);

      await expect(
        service.update('church-1', 'nonexistent', { name: 'X' }),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('remove', () => {
    it('should throw ForbiddenException when deleting headquarters', async () => {
      mockBranchModel.findFirst.mockResolvedValue({
        id: 'branch-1',
        isHeadquarters: true,
      });

      await expect(
        service.remove('church-1', 'branch-1'),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should throw NotFoundException when not found', async () => {
      mockBranchModel.findFirst.mockResolvedValue(null);

      await expect(
        service.remove('church-1', 'nonexistent'),
      ).rejects.toThrow(NotFoundException);
    });

    it('should delete a non-headquarters branch', async () => {
      const branch = { id: 'branch-2', isHeadquarters: false };
      mockBranchModel.findFirst.mockResolvedValue(branch);
      mockPrisma.membership.count.mockResolvedValueOnce(0);
      mockPrisma.event.count.mockResolvedValueOnce(0);
      mockPrisma.ebdClass.count.mockResolvedValueOnce(0);
      mockPrisma.branch.delete.mockResolvedValue(branch);

      const result = await service.remove('church-1', 'branch-2');

      expect(mockPrisma.branch.delete).toHaveBeenCalledWith({
        where: { id: 'branch-2' },
      });
      expect(result).toEqual(branch);
    });

    it('should throw ConflictException when the branch has dependent memberships', async () => {
      // Given — a Filial referenced by 2 memberships (the production bug case)
      mockBranchModel.findFirst.mockResolvedValue({
        id: 'branch-2',
        isHeadquarters: false,
      });
      mockPrisma.membership.count.mockResolvedValueOnce(2);
      mockPrisma.event.count.mockResolvedValueOnce(0);
      mockPrisma.ebdClass.count.mockResolvedValueOnce(0);

      // When — remove is attempted
      const attempt = service.remove('church-1', 'branch-2');

      // Then — a 409 is raised with a user-facing message AND no delete is issued
      await expect(attempt).rejects.toThrow(ConflictException);
      await expect(attempt).rejects.toThrow(/2 registro\(s\) vinculado\(s\)/);
      expect(mockPrisma.branch.delete).not.toHaveBeenCalled();
    });

    it('should throw ConflictException when the branch has dependent events or EBD classes', async () => {
      // Given — a Filial with no memberships but 1 event + 3 ebd classes
      mockBranchModel.findFirst.mockResolvedValue({
        id: 'branch-2',
        isHeadquarters: false,
      });
      mockPrisma.membership.count.mockResolvedValueOnce(0);
      mockPrisma.event.count.mockResolvedValueOnce(1);
      mockPrisma.ebdClass.count.mockResolvedValueOnce(3);

      await expect(
        service.remove('church-1', 'branch-2'),
      ).rejects.toThrow(ConflictException);
      expect(mockPrisma.branch.delete).not.toHaveBeenCalled();
    });
  });

  describe('promoteToHeadquarters', () => {
    /// Stubs a Prisma transaction that proxies to a `tx` client
    /// containing update/updateMany mocks. This lets the test assert
    /// that both the demote and the promote happen inside the same
    /// transaction boundary (so a failure of either rolls both back).
    function stubTx() {
      const tx = {
        branch: {
          updateMany: jest.fn().mockResolvedValue({ count: 1 }),
          update: jest.fn().mockResolvedValue({
            id: 'branch-target',
            isHeadquarters: true,
            churchId: 'church-1',
          }),
        },
      };
      mockPrisma.$transaction.mockImplementation(async (fn: unknown) =>
        (fn as (client: typeof tx) => Promise<unknown>)(tx),
      );
      return tx;
    }

    it('should throw NotFoundException when the branch does not belong to the tenant', async () => {
      mockBranchModel.findFirst.mockResolvedValue(null);

      await expect(
        service.promoteToHeadquarters('church-1', 'foreign-branch'),
      ).rejects.toThrow(NotFoundException);
    });

    it('should throw ConflictException when the branch is already the headquarters (no-op swap)', async () => {
      mockBranchModel.findFirst.mockResolvedValue({
        id: 'branch-1',
        churchId: 'church-1',
        isHeadquarters: true,
      });

      await expect(
        service.promoteToHeadquarters('church-1', 'branch-1'),
      ).rejects.toThrow(ConflictException);
    });

    it('should demote the current HQ AND promote the target inside one transaction (atomic swap)', async () => {
      // Given — target exists in this tenant and is currently a Filial
      mockBranchModel.findFirst.mockResolvedValue({
        id: 'branch-target',
        churchId: 'church-1',
        isHeadquarters: false,
      });
      const tx = stubTx();

      // When
      await service.promoteToHeadquarters('church-1', 'branch-target');

      // Then — the existing HQ was flipped to false via updateMany
      // (no need to look it up separately, since the constraint is
      //  "at most one HQ per church" in practice).
      expect(tx.branch.updateMany).toHaveBeenCalledWith({
        where: { churchId: 'church-1', isHeadquarters: true },
        data: { isHeadquarters: false },
      });
      // And the target was promoted in the same transaction
      expect(tx.branch.update).toHaveBeenCalledWith({
        where: { id: 'branch-target' },
        data: { isHeadquarters: true },
      });
    });

    it('should return the promoted branch row so the caller can display the new HQ', async () => {
      mockBranchModel.findFirst.mockResolvedValue({
        id: 'branch-target',
        churchId: 'church-1',
        isHeadquarters: false,
      });
      stubTx();

      const result = await service.promoteToHeadquarters(
        'church-1',
        'branch-target',
      );

      expect(result).toMatchObject({
        id: 'branch-target',
        isHeadquarters: true,
      });
    });
  });
});
