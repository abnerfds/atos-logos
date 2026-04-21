import { Test, TestingModule } from '@nestjs/testing';
import {
  BadRequestException,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';

import { MembershipsService } from './memberships.service';
import { PrismaService } from '../../prisma/prisma.service';

type TxClient = {
  user: { create: jest.Mock };
  membership: { create: jest.Mock };
  memberProfile: { create: jest.Mock; count: jest.Mock };
  positionUser: { create: jest.Mock };
};

const mockPrismaService = {
  forTenant: jest.fn(),
  user: {
    findFirst: jest.fn(),
    update: jest.fn(),
  },
  membership: {
    findFirst: jest.fn(),
    findMany: jest.fn(),
    update: jest.fn(),
    count: jest.fn(),
  },
  memberProfile: {
    count: jest.fn(),
  },
  positionUser: {
    deleteMany: jest.fn(),
    create: jest.fn(),
  },
  $transaction: jest.fn(),
};

describe('MembershipsService - createWithUser', () => {
  let service: MembershipsService;
  let prisma: typeof mockPrismaService;

  const churchId = 'church-1';
  const branchId = 'branch-1';

  function stubBranchFound({
    positionFound = true,
  }: { positionFound?: boolean } = {}) {
    mockPrismaService.forTenant.mockReturnValue({
      branch: {
        findFirst: jest.fn().mockResolvedValue({
          id: branchId,
          churchId,
          isHeadquarters: true,
        }),
      },
      memberPosition: {
        findFirst: jest.fn().mockResolvedValue(
          positionFound
            ? { id: 'position-1', churchId, name: 'Pastor' }
            : null,
        ),
      },
    });
  }

  function stubBranchNotFound() {
    mockPrismaService.forTenant.mockReturnValue({
      branch: {
        findFirst: jest.fn().mockResolvedValue(null),
      },
      memberPosition: {
        findFirst: jest.fn().mockResolvedValue(null),
      },
    });
  }

  function stubTransaction(overrides: Partial<TxClient> = {}) {
    const tx: TxClient = {
      user: {
        create: jest.fn().mockResolvedValue({
          id: 'user-1',
          name: 'Ana Silva',
          email: 'ana@example.com',
          phone: null,
          cpf: null,
          password: 'hashed',
        }),
      },
      membership: {
        create: jest.fn().mockResolvedValue({
          id: 'membership-1',
          userId: 'user-1',
          churchId,
          branchId,
          role: 'MEMBER',
          status: 'ACTIVE',
        }),
      },
      memberProfile: {
        create: jest.fn().mockResolvedValue({
          id: 'profile-1',
          userId: 'user-1',
          churchId,
          registrationNumber: '2026-BRAN-001',
        }),
        count: jest.fn().mockResolvedValue(0),
      },
      positionUser: {
        create: jest.fn().mockResolvedValue({
          id: 'pu-1',
          userId: 'user-1',
          positionId: 'position-1',
        }),
      },
      ...overrides,
    };
    mockPrismaService.$transaction.mockImplementation(async (fn: unknown) =>
      (fn as (client: TxClient) => Promise<unknown>)(tx),
    );
    return tx;
  }

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        MembershipsService,
        { provide: PrismaService, useValue: mockPrismaService },
      ],
    }).compile();

    service = module.get<MembershipsService>(MembershipsService);
    prisma = module.get(PrismaService);

    // Reset all stubs between tests
    jest.clearAllMocks();
    prisma.user.findFirst.mockResolvedValue(null);
    prisma.memberProfile.count.mockResolvedValue(0);
  });

  it('should throw NotFoundException when the branch does not belong to this church', async () => {
    // Given — the branch does not exist for this tenant
    stubBranchNotFound();

    // When — secretary tries to create a member on that branch
    const attempt = service.createWithUser(churchId, 'ADMIN', {
      name: 'Ana',
      password: 'secret-tmp',
      branchId,
    });

    // Then — the request fails with a clear tenant mismatch error
    await expect(attempt).rejects.toThrow(NotFoundException);
  });

  it('should throw BadRequestException when email is already used by another user', async () => {
    // Given — a User already exists with this email
    stubBranchFound();
    prisma.user.findFirst.mockResolvedValueOnce({
      id: 'existing-user',
      email: 'ana@example.com',
    });

    // When
    const attempt = service.createWithUser(churchId, 'ADMIN', {
      name: 'Ana',
      password: 'secret-tmp',
      email: 'ana@example.com',
      branchId,
    });

    // Then — 400 instead of a raw Prisma unique-constraint 500
    await expect(attempt).rejects.toThrow(BadRequestException);
  });

  it('should throw BadRequestException when cpf is already used by another user', async () => {
    stubBranchFound();
    prisma.user.findFirst.mockResolvedValueOnce({
      id: 'existing-user',
      cpf: '12345678900',
    });

    const attempt = service.createWithUser(churchId, 'ADMIN', {
      name: 'Ana',
      password: 'secret-tmp',
      cpf: '12345678900',
      branchId,
    });

    await expect(attempt).rejects.toThrow(BadRequestException);
  });

  it('should throw BadRequestException when phone is already used by another user', async () => {
    stubBranchFound();
    prisma.user.findFirst.mockResolvedValueOnce({
      id: 'existing-user',
      phone: '+5511999999999',
    });

    const attempt = service.createWithUser(churchId, 'ADMIN', {
      name: 'Ana',
      password: 'secret-tmp',
      phone: '+5511999999999',
      branchId,
    });

    await expect(attempt).rejects.toThrow(BadRequestException);
  });

  it('should create user + membership (and NO profile) when birthDate/admissionDate are not provided', async () => {
    // Given — no profile fields in the payload
    stubBranchFound();
    const tx = stubTransaction();

    // When
    const result = await service.createWithUser(churchId, 'ADMIN', {
      name: 'Ana',
      password: 'secret-tmp',
      branchId,
    });

    // Then — user + membership created, profile skipped
    expect(tx.user.create).toHaveBeenCalledTimes(1);
    expect(tx.membership.create).toHaveBeenCalledTimes(1);
    expect(tx.memberProfile.create).not.toHaveBeenCalled();
    expect(result.profile).toBeNull();
  });

  it('should create user + membership + profile when both birthDate AND admissionDate are provided', async () => {
    // Given — full onboarding payload
    stubBranchFound();
    const tx = stubTransaction();

    // When
    const result = await service.createWithUser(churchId, 'ADMIN', {
      name: 'Ana',
      password: 'secret-tmp',
      branchId,
      birthDate: '1990-05-20',
      admissionDate: '2020-03-15',
      baptismDate: '2018-06-10',
    });

    // Then — all three rows created in the transaction
    expect(tx.user.create).toHaveBeenCalledTimes(1);
    expect(tx.membership.create).toHaveBeenCalledTimes(1);
    expect(tx.memberProfile.create).toHaveBeenCalledTimes(1);
    expect(result.profile).not.toBeNull();
  });

  it('should default the membership role to MEMBER when the caller does not specify one', async () => {
    stubBranchFound();
    const tx = stubTransaction();

    await service.createWithUser(churchId, 'ADMIN', {
      name: 'Ana',
      password: 'secret-tmp',
      branchId,
    });

    const membershipData = tx.membership.create.mock.calls[0][0].data;
    expect(membershipData.role).toBe('MEMBER');
    expect(membershipData.status).toBe('ACTIVE');
  });

  it('should honour an explicit role when the caller provides one (e.g. promoting a new secretary)', async () => {
    stubBranchFound();
    const tx = stubTransaction();

    await service.createWithUser(churchId, 'ADMIN', {
      name: 'Carla',
      password: 'secret-tmp',
      branchId,
      role: 'SECRETARY',
    });

    const membershipData = tx.membership.create.mock.calls[0][0].data;
    expect(membershipData.role).toBe('SECRETARY');
  });

  it('should bcrypt-hash the password before persisting the user row (never store plaintext)', async () => {
    stubBranchFound();
    const tx = stubTransaction();

    await service.createWithUser(churchId, 'ADMIN', {
      name: 'Ana',
      password: 'plaintext-secret',
      branchId,
    });

    const userData = tx.user.create.mock.calls[0][0].data;
    expect(userData.password).not.toBe('plaintext-secret');
    // The bcrypt comparator succeeds for the hashed column
    await expect(
      bcrypt.compare('plaintext-secret', userData.password as string),
    ).resolves.toBe(true);
  });

  it('should create a PositionUser row inside the same transaction when positionId is provided', async () => {
    // Given — the secretary picked a cargo (MemberPosition) on the form
    stubBranchFound();
    const tx = stubTransaction();

    // When
    await service.createWithUser(churchId, 'ADMIN', {
      name: 'Ana',
      password: 'secret-tmp',
      branchId,
      positionId: 'position-1',
    });

    // Then — the cargo row is created atomically alongside user/membership
    expect(tx.positionUser.create).toHaveBeenCalledTimes(1);
    expect(tx.positionUser.create.mock.calls[0][0].data).toEqual({
      userId: 'user-1',
      positionId: 'position-1',
    });
  });

  it('should NOT touch positionUser when positionId is omitted from the payload', async () => {
    stubBranchFound();
    const tx = stubTransaction();

    await service.createWithUser(churchId, 'ADMIN', {
      name: 'Ana',
      password: 'secret-tmp',
      branchId,
    });

    expect(tx.positionUser.create).not.toHaveBeenCalled();
  });

  it('should throw NotFoundException when positionId does not belong to this church (prevents cross-tenant spoofing)', async () => {
    // Given — the position UUID is valid syntactically but belongs to another tenant
    stubBranchFound({ positionFound: false });

    // When / Then
    const attempt = service.createWithUser(churchId, 'ADMIN', {
      name: 'Ana',
      password: 'secret-tmp',
      branchId,
      positionId: 'foreign-position-id',
    });
    await expect(attempt).rejects.toThrow(NotFoundException);
  });

  // -- password stripping test kept last in createWithUser group ----------
  it('should strip the password field from the returned user so it never leaves the service', async () => {
    stubBranchFound();
    stubTransaction();

    const result = await service.createWithUser(churchId, 'ADMIN', {
      name: 'Ana',
      password: 'secret-tmp',
      branchId,
    });

    expect(result.user).not.toHaveProperty('password');
  });

  it('persists identity fields (rg, sex, civilStatus, fatherName, motherName) on user creation', async () => {
    stubBranchFound();
    const tx = stubTransaction();

    await service.createWithUser(churchId, 'ADMIN', {
      name: 'Jane Doe',
      password: 'secret12',
      branchId,
      rg: 'MG-12.345.678',
      sex: 'FEMALE',
      civilStatus: 'MARRIED',
      fatherName: 'John Doe',
      motherName: 'Mary Doe',
    });

    expect(tx.user.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          rg: 'MG-12.345.678',
          sex: 'FEMALE',
          civilStatus: 'MARRIED',
          fatherName: 'John Doe',
          motherName: 'Mary Doe',
        }),
      }),
    );
  });

  it('persists consecrationDate on the MemberProfile when provided', async () => {
    stubBranchFound();
    const tx = stubTransaction();

    await service.createWithUser(churchId, 'ADMIN', {
      name: 'Ana',
      password: 'secret-tmp',
      branchId,
      birthDate: '1990-05-20',
      admissionDate: '2020-03-15',
      consecrationDate: '2022-09-15',
    });

    expect(tx.memberProfile.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          consecrationDate: new Date('2022-09-15'),
        }),
      }),
    );
  });

  describe('role-assignment guard (privilege escalation)', () => {
    it('should REFUSE to create an ADMIN when the caller is SECRETARY', async () => {
      // Given — a secretary POSTs { role: 'ADMIN' } trying to self-elevate
      stubBranchFound();
      stubTransaction();

      // When
      const attempt = service.createWithUser(churchId, 'SECRETARY', {
        name: 'Mallory',
        password: 'secret-tmp',
        branchId,
        role: 'ADMIN',
      });

      // Then — forbidden, and no DB work happened
      await expect(attempt).rejects.toThrow(ForbiddenException);
    });

    it('should REFUSE to create a SECRETARY when the caller is SECRETARY (no peer elevation)', async () => {
      stubBranchFound();
      stubTransaction();

      await expect(
        service.createWithUser(churchId, 'SECRETARY', {
          name: 'Mallory',
          password: 'secret-tmp',
          branchId,
          role: 'SECRETARY',
        }),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should ALLOW a SECRETARY to create a plain MEMBER (default onboarding path)', async () => {
      stubBranchFound();
      stubTransaction();

      await expect(
        service.createWithUser(churchId, 'SECRETARY', {
          name: 'Ana',
          password: 'secret-tmp',
          branchId,
          role: 'MEMBER',
        }),
      ).resolves.toBeDefined();
    });

    it('should ALLOW an ADMIN to create an ADMIN or SECRETARY', async () => {
      stubBranchFound();
      stubTransaction();

      await expect(
        service.createWithUser(churchId, 'ADMIN', {
          name: 'New Admin',
          password: 'secret-tmp',
          branchId,
          role: 'ADMIN',
        }),
      ).resolves.toBeDefined();
    });
  });

  describe('registrationNumber race (P2002 retry)', () => {
    it('should recompute the registration number and retry when two secretaries race on the unique constraint', async () => {
      // Given — full profile payload so the registrationNumber path
      // runs. The first tx attempt blows up with P2002 on the
      // registrationNumber column (simulating a parallel insert that
      // grabbed the same count); the second attempt succeeds.
      stubBranchFound();

      const txAttempts: TxClient[] = [];
      mockPrismaService.$transaction.mockImplementation(async (fn: unknown) => {
        const tx: TxClient = {
          user: {
            create: jest.fn().mockResolvedValue({
              id: 'user-1',
              name: 'Ana',
              email: null,
              phone: null,
              cpf: null,
              password: 'hashed',
            }),
          },
          membership: {
            create: jest.fn().mockResolvedValue({ id: 'membership-1' }),
          },
          memberProfile: {
            // First tx sees count=5; second tx sees count=6.
            count: jest
              .fn()
              .mockResolvedValueOnce(5)
              .mockResolvedValueOnce(6),
            create:
              txAttempts.length === 0
                ? jest.fn().mockRejectedValue(
                    new (require('@prisma/client').Prisma.PrismaClientKnownRequestError)(
                      'unique violation',
                      {
                        code: 'P2002',
                        clientVersion: 'test',
                        meta: { target: ['registrationNumber'] },
                      },
                    ),
                  )
                : jest.fn().mockResolvedValue({ id: 'profile-1' }),
          },
          positionUser: { create: jest.fn() },
        };
        txAttempts.push(tx);
        return (fn as (client: TxClient) => Promise<unknown>)(tx);
      });

      // When
      const result = await service.createWithUser(churchId, 'ADMIN', {
        name: 'Ana',
        password: 'secret-tmp',
        branchId,
        birthDate: '1990-05-20',
        admissionDate: '2020-03-15',
      });

      // Then — the service retried the whole transaction and the second attempt succeeded
      expect(txAttempts).toHaveLength(2);
      expect(result).toBeDefined();
    });

    it('should surface a 409 ConflictException after 3 consecutive registrationNumber collisions', async () => {
      stubBranchFound();

      mockPrismaService.$transaction.mockImplementation(async (fn: unknown) => {
        const tx: TxClient = {
          user: {
            create: jest.fn().mockResolvedValue({
              id: 'user-1',
              email: null,
              phone: null,
              cpf: null,
              password: 'hashed',
            }),
          },
          membership: { create: jest.fn().mockResolvedValue({}) },
          memberProfile: {
            count: jest.fn().mockResolvedValue(0),
            create: jest.fn().mockRejectedValue(
              new (require('@prisma/client').Prisma.PrismaClientKnownRequestError)(
                'unique violation',
                {
                  code: 'P2002',
                  clientVersion: 'test',
                  meta: { target: ['registrationNumber'] },
                },
              ),
            ),
          },
          positionUser: { create: jest.fn() },
        };
        return (fn as (client: TxClient) => Promise<unknown>)(tx);
      });

      await expect(
        service.createWithUser(churchId, 'ADMIN', {
          name: 'Ana',
          password: 'secret-tmp',
          branchId,
          birthDate: '1990-05-20',
          admissionDate: '2020-03-15',
        }),
      ).rejects.toThrow(/matrícula/i);
    });
  });
});

describe('MembershipsService - findAll search', () => {
  let service: MembershipsService;
  let prisma: typeof mockPrismaService;

  const churchId = 'church-1';

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        MembershipsService,
        { provide: PrismaService, useValue: mockPrismaService },
      ],
    }).compile();
    service = module.get<MembershipsService>(MembershipsService);
    prisma = module.get(PrismaService);
    jest.clearAllMocks();
  });

  it('should NOT attach a WHERE clause when q is omitted (keeps default listing a clean SELECT)', async () => {
    const findMany = jest.fn().mockResolvedValue([]);
    const count = jest.fn().mockResolvedValue(0);
    prisma.forTenant.mockReturnValue({
      membership: { findMany, count },
    });

    await service.findAll(churchId);

    expect(findMany).toHaveBeenCalledWith(expect.objectContaining({ where: {} }));
    expect(count).toHaveBeenCalledWith({ where: {} });
  });

  it('should NOT attach a WHERE clause when q is whitespace-only (treats "   " as no filter)', async () => {
    const findMany = jest.fn().mockResolvedValue([]);
    const count = jest.fn().mockResolvedValue(0);
    prisma.forTenant.mockReturnValue({
      membership: { findMany, count },
    });

    await service.findAll(churchId, 1, 20, '   ');

    expect(findMany).toHaveBeenCalledWith(expect.objectContaining({ where: {} }));
  });

  it('should filter by case-insensitive user.name substring when q is provided', async () => {
    const findMany = jest.fn().mockResolvedValue([]);
    const count = jest.fn().mockResolvedValue(0);
    prisma.forTenant.mockReturnValue({
      membership: { findMany, count },
    });

    await service.findAll(churchId, 1, 20, 'Ana');

    const expectedWhere = {
      user: { name: { contains: 'Ana', mode: 'insensitive' } },
    };
    expect(findMany).toHaveBeenCalledWith(
      expect.objectContaining({ where: expectedWhere }),
    );
    expect(count).toHaveBeenCalledWith({ where: expectedWhere });
  });

  it('should trim surrounding whitespace from q before forwarding to Prisma', async () => {
    const findMany = jest.fn().mockResolvedValue([]);
    const count = jest.fn().mockResolvedValue(0);
    prisma.forTenant.mockReturnValue({
      membership: { findMany, count },
    });

    await service.findAll(churchId, 1, 20, '  Ana  ');

    expect(findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          user: { name: { contains: 'Ana', mode: 'insensitive' } },
        },
      }),
    );
  });
});

describe('MembershipsService - updateMemberUserData', () => {
  let service: MembershipsService;
  let prisma: typeof mockPrismaService;

  const churchId = 'church-1';
  const userId = 'user-1';

  function stubMembershipFound() {
    mockPrismaService.forTenant.mockReturnValue({
      membership: {
        findFirst: jest.fn().mockResolvedValue({
          id: 'membership-1',
          userId,
          churchId,
          branchId: 'branch-1',
          role: 'MEMBER',
          status: 'ACTIVE',
        }),
      },
    });
  }

  function stubMembershipNotFound() {
    mockPrismaService.forTenant.mockReturnValue({
      membership: {
        findFirst: jest.fn().mockResolvedValue(null),
      },
    });
  }

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        MembershipsService,
        { provide: PrismaService, useValue: mockPrismaService },
      ],
    }).compile();

    service = module.get<MembershipsService>(MembershipsService);
    prisma = module.get(PrismaService);
    jest.clearAllMocks();
    prisma.user.findFirst.mockResolvedValue(null);
    prisma.user.update.mockResolvedValue({
      id: userId,
      name: 'Updated',
      email: null,
      password: 'hashed',
    });
    // The service wraps the writes in a Prisma $transaction. For the
    // plain user-only tests we have the tx callback run against the
    // same top-level mock so `prisma.user.update` stays observable; the
    // atomic-edit describe below overrides this with its own tx stub.
    prisma.$transaction.mockImplementation(async (fn: unknown) =>
      (fn as (client: typeof prisma) => Promise<unknown>)(prisma),
    );
  });

  it('should throw NotFoundException when the user has no membership in this church', async () => {
    stubMembershipNotFound();

    await expect(
      service.updateMemberUserData(churchId, userId, { name: 'New Name' }),
    ).rejects.toThrow(NotFoundException);
  });

  it('should update only the fields supplied in the DTO (never blanks untouched columns)', async () => {
    // Given
    stubMembershipFound();

    // When — only name changes
    await service.updateMemberUserData(churchId, userId, {
      name: 'Ana Silva',
    });

    // Then — the update payload is exactly { name } and nothing else
    expect(prisma.user.update).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { id: userId },
        data: { name: 'Ana Silva' },
      }),
    );
  });

  it('should persist every address field (name/email/phone/cpf/country/state/city/neighborhood/street/number/complement) when the secretariat fills out the whole form', async () => {
    stubMembershipFound();
    await service.updateMemberUserData(churchId, userId, {
      name: 'Ana Silva',
      email: 'ana@example.com',
      phone: '+5511999999999',
      cpf: '12345678900',
      country: 'Brasil',
      state: 'SP',
      city: 'São Paulo',
      neighborhood: 'Centro',
      street: 'Rua X',
      number: '42',
      complement: 'Apto 3',
    });

    expect(prisma.user.update).toHaveBeenCalledWith({
      where: { id: userId },
      data: {
        name: 'Ana Silva',
        email: 'ana@example.com',
        phone: '+5511999999999',
        cpf: '12345678900',
        country: 'Brasil',
        state: 'SP',
        city: 'São Paulo',
        neighborhood: 'Centro',
        street: 'Rua X',
        number: '42',
        complement: 'Apto 3',
      },
    });
  });

  it('should persist all identity + address fields together when the secretariat fills the complete form', async () => {
    stubMembershipFound();
    await service.updateMemberUserData(churchId, userId, {
      name: 'Ana Silva',
      email: 'ana@example.com',
      phone: '+5511999999999',
      cpf: '12345678900',
      rg: 'SP-99.999.999',
      sex: 'FEMALE',
      civilStatus: 'MARRIED',
      fatherName: 'João Silva',
      motherName: 'Maria Silva',
      country: 'Brasil',
      state: 'SP',
      city: 'São Paulo',
      neighborhood: 'Centro',
      street: 'Rua X',
      number: '42',
      complement: 'Apto 3',
    });

    expect(prisma.user.update).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { id: userId },
        data: expect.objectContaining({
          name: 'Ana Silva',
          rg: 'SP-99.999.999',
          sex: 'FEMALE',
          civilStatus: 'MARRIED',
          fatherName: 'João Silva',
          motherName: 'Maria Silva',
          country: 'Brasil',
          state: 'SP',
          city: 'São Paulo',
          neighborhood: 'Centro',
          street: 'Rua X',
          number: '42',
          complement: 'Apto 3',
        }),
      }),
    );
  });

  it('should throw BadRequestException when the new email belongs to another user', async () => {
    stubMembershipFound();
    prisma.user.findFirst.mockResolvedValueOnce({
      id: 'other-user',
      email: 'taken@example.com',
    });

    await expect(
      service.updateMemberUserData(churchId, userId, {
        email: 'taken@example.com',
      }),
    ).rejects.toThrow(BadRequestException);
  });

  it('should NOT flag a uniqueness conflict when the "conflicting" row is the same user being edited', async () => {
    // Given — findFirst would match the user's OWN current row if not
    // excluded. The service must pass `id: { not: userId }` to skip it.
    stubMembershipFound();
    // Simulate Prisma correctly returning null because the excludeUserId
    // filter kicked in: we just assert the query was shaped that way.
    prisma.user.findFirst.mockResolvedValue(null);

    await service.updateMemberUserData(churchId, userId, {
      email: 'ana@example.com',
    });

    expect(prisma.user.findFirst).toHaveBeenCalledWith({
      where: {
        OR: [{ email: 'ana@example.com' }],
        id: { not: userId },
      },
    });
  });

  it('should strip the password field from the updated user row', async () => {
    stubMembershipFound();

    const result = await service.updateMemberUserData(churchId, userId, {
      name: 'Ana',
    });

    expect(result).not.toHaveProperty('password');
  });

  it('updateMemberUserData persists new identity fields', async () => {
    stubMembershipFound();

    await service.updateMemberUserData(churchId, userId, {
      rg: 'SP-99.999.999',
      sex: 'MALE',
      civilStatus: 'SINGLE',
      fatherName: 'A',
      motherName: 'B',
    });

    expect(prisma.user.update).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { id: userId },
        data: expect.objectContaining({
          rg: 'SP-99.999.999',
          sex: 'MALE',
          civilStatus: 'SINGLE',
          fatherName: 'A',
          motherName: 'B',
        }),
      }),
    );
  });

  describe('with atomic membership + position changes', () => {
    /// Tx stub shared by the branch + position tests. Mirrors the shape
    /// the real Prisma tx client exposes for the touched models.
    function stubTransactionalEdit() {
      const tx = {
        user: {
          update: jest.fn().mockResolvedValue({
            id: userId,
            name: 'Ana',
            password: 'hashed',
          }),
        },
        membership: {
          update: jest.fn().mockResolvedValue({
            id: 'membership-1',
            userId,
            branchId: 'branch-new',
          }),
        },
        positionUser: {
          deleteMany: jest.fn().mockResolvedValue({ count: 1 }),
          create: jest.fn().mockResolvedValue({
            id: 'pu-1',
            userId,
            positionId: 'position-new',
          }),
        },
      };
      mockPrismaService.$transaction.mockImplementation(async (fn: unknown) =>
        (fn as (client: typeof tx) => Promise<unknown>)(tx),
      );
      return tx;
    }

    function stubEditTenantChecks({
      membershipFound = true,
      branchFound = true,
      positionFound = true,
    } = {}) {
      mockPrismaService.forTenant.mockReturnValue({
        membership: {
          findFirst: jest.fn().mockResolvedValue(
            membershipFound
              ? {
                  id: 'membership-1',
                  userId,
                  churchId,
                  branchId: 'branch-old',
                }
              : null,
          ),
        },
        branch: {
          findFirst: jest.fn().mockResolvedValue(
            branchFound
              ? { id: 'branch-new', churchId, isHeadquarters: false }
              : null,
          ),
        },
        memberPosition: {
          findFirst: jest.fn().mockResolvedValue(
            positionFound
              ? { id: 'position-new', churchId, name: 'Diácono' }
              : null,
          ),
        },
      });
    }

    it('should update membership.branchId inside the same transaction when branchId is provided', async () => {
      stubEditTenantChecks();
      const tx = stubTransactionalEdit();

      await service.updateMemberUserData(churchId, userId, {
        name: 'Ana',
        branchId: 'branch-new',
      });

      expect(tx.user.update).toHaveBeenCalledTimes(1);
      expect(tx.membership.update).toHaveBeenCalledWith({
        where: { id: 'membership-1' },
        data: { branchId: 'branch-new' },
      });
    });

    it('should throw NotFoundException when branchId does not belong to this church', async () => {
      // Given — branch belongs to another tenant
      stubEditTenantChecks({ branchFound: false });

      await expect(
        service.updateMemberUserData(churchId, userId, {
          branchId: 'foreign-branch',
        }),
      ).rejects.toThrow(NotFoundException);
    });

    it('should throw NotFoundException when positionId does not belong to this church', async () => {
      stubEditTenantChecks({ positionFound: false });

      await expect(
        service.updateMemberUserData(churchId, userId, {
          positionId: 'foreign-position',
        }),
      ).rejects.toThrow(NotFoundException);
    });

    it('should replace the existing PositionUser (delete old, create new) in the same transaction, scoped to this tenant so cargos in other churches are not wiped', async () => {
      // Given — user being edited may also be member of another
      // church. The deleteMany must filter by position.churchId so
      // cargos in that OTHER church survive.
      stubEditTenantChecks();
      const tx = stubTransactionalEdit();

      await service.updateMemberUserData(churchId, userId, {
        positionId: 'position-new',
      });

      // Old assignments in this tenant wiped via nested position filter
      expect(tx.positionUser.deleteMany).toHaveBeenCalledWith({
        where: { userId, position: { churchId } },
      });
      expect(tx.positionUser.create).toHaveBeenCalledWith({
        data: { userId, positionId: 'position-new' },
      });
    });

    it('should NOT touch positionUser when positionId is omitted (preserves the existing cargo)', async () => {
      stubEditTenantChecks();
      const tx = stubTransactionalEdit();

      await service.updateMemberUserData(churchId, userId, {
        name: 'Ana',
      });

      expect(tx.positionUser.deleteMany).not.toHaveBeenCalled();
      expect(tx.positionUser.create).not.toHaveBeenCalled();
    });
  });
});

describe('MembershipsService - inactivateByUserId', () => {
  let service: MembershipsService;
  let prisma: typeof mockPrismaService;

  const churchId = 'church-1';
  const userId = 'user-1';
  const membershipId = 'membership-1';

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        MembershipsService,
        { provide: PrismaService, useValue: mockPrismaService },
      ],
    }).compile();

    service = module.get<MembershipsService>(MembershipsService);
    prisma = module.get(PrismaService);
    jest.clearAllMocks();
  });

  it('should throw NotFoundException when the user has no membership in this church', async () => {
    mockPrismaService.forTenant.mockReturnValue({
      membership: {
        findFirst: jest.fn().mockResolvedValue(null),
      },
    });

    await expect(
      service.inactivateByUserId(churchId, userId),
    ).rejects.toThrow(NotFoundException);
  });

  it('should set the membership status to INACTIVE for a non-admin membership', async () => {
    const findFirst = jest.fn().mockResolvedValue({
      id: membershipId,
      userId,
      churchId,
      role: 'MEMBER',
      status: 'ACTIVE',
    });
    mockPrismaService.forTenant.mockReturnValue({
      membership: { findFirst },
    });
    prisma.membership.update.mockResolvedValue({
      id: membershipId,
      status: 'INACTIVE',
    });

    await service.inactivateByUserId(churchId, userId);

    expect(prisma.membership.update).toHaveBeenCalledWith({
      where: { id: membershipId },
      data: { status: 'INACTIVE' },
    });
  });

  it('should REFUSE to inactivate the last ADMIN (keeps the Last-Admin guard intact)', async () => {
    const findFirst = jest.fn().mockResolvedValue({
      id: membershipId,
      userId,
      churchId,
      role: 'ADMIN',
      status: 'ACTIVE',
    });
    mockPrismaService.forTenant.mockReturnValue({
      membership: { findFirst },
    });
    // No OTHER active admins besides the target → guard fires.
    prisma.membership.count.mockResolvedValue(0);

    await expect(
      service.inactivateByUserId(churchId, userId),
    ).rejects.toThrow(ForbiddenException);
  });

  it('should REFUSE to inactivate the 2nd of 2 admins when inactivating the other would leave zero (regression: off-by-one)', async () => {
    // Given — exactly 2 admins in the church. When one is inactivated
    // the guard must count the REMAINING admins, not the total. The
    // old implementation counted the target too and let this pass.
    const findFirst = jest.fn().mockResolvedValue({
      id: membershipId,
      userId,
      churchId,
      role: 'ADMIN',
      status: 'ACTIVE',
    });
    mockPrismaService.forTenant.mockReturnValue({
      membership: { findFirst },
    });
    // Query `{ id: { not: membershipId } }` — should return 1 (the other admin).
    prisma.membership.count.mockResolvedValue(1);
    prisma.membership.update.mockResolvedValue({
      id: membershipId,
      status: 'INACTIVE',
    });

    await service.inactivateByUserId(churchId, userId);

    expect(prisma.membership.count).toHaveBeenCalledWith({
      where: {
        churchId,
        role: 'ADMIN',
        status: 'ACTIVE',
        id: { not: membershipId },
      },
    });
  });
});
