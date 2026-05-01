import { Test, TestingModule } from '@nestjs/testing';
import { MemberProfilesService } from './member-profiles.service';
import { PrismaService } from '../../prisma/prisma.service';

const mockMemberProfile = {
  findMany: jest.fn(),
  findFirst: jest.fn(),
  count: jest.fn(),
  create: jest.fn(),
  update: jest.fn(),
  delete: jest.fn(),
};

const mockPrismaService = {
  forTenant: jest.fn(() => ({
    memberProfile: mockMemberProfile,
    membership: { findFirst: jest.fn() },
    positionUser: { findFirst: jest.fn() },
  })),
  memberProfile: mockMemberProfile,
};

describe('MemberProfilesService', () => {
  let service: MemberProfilesService;
  let prisma: typeof mockPrismaService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        MemberProfilesService,
        { provide: PrismaService, useValue: mockPrismaService },
      ],
    }).compile();

    service = module.get<MemberProfilesService>(MemberProfilesService);
    prisma = module.get(PrismaService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findBirthdays', () => {
    it('should return members with birthday in the specified month', async () => {
      const churchId = 'church-uuid';
      const mockProfiles = [
        { id: 'profile-1', birthDate: new Date('1995-04-12'), photoUrl: 'https://photo1.url', user: { name: 'Ana Paula' } },
        { id: 'profile-2', birthDate: new Date('1988-04-25'), photoUrl: null, user: { name: 'Carlos' } },
      ];
      mockMemberProfile.findMany.mockResolvedValue(mockProfiles);

      const result = await service.findBirthdays(churchId, 4);

      expect(result.data).toHaveLength(2);
      expect(result.month).toBe(4);
      expect(result.data[0].name).toBe('Ana Paula');
      expect(result.data[0].photoUrl).toBe('https://photo1.url');
      expect(result.data[1].name).toBe('Carlos');
      expect(result.data[1].photoUrl).toBeNull();
    });

    it('should default to current month when month not provided', async () => {
      mockMemberProfile.findMany.mockResolvedValue([]);

      const result = await service.findBirthdays('church-uuid');

      expect(result.month).toBe(new Date().getMonth() + 1);
      expect(result.data).toEqual([]);
    });

    it('persists consecrationDate on create', async () => {
      const churchId = 'church-uuid';
      const tenantClient = {
        memberProfile: {
          findFirst: jest.fn().mockResolvedValue(null),
        },
        membership: {
          findFirst: jest.fn().mockResolvedValue({ id: 'm', status: 'ACTIVE' }),
        },
        positionUser: { findFirst: jest.fn().mockResolvedValue(null) },
      };
      mockPrismaService.forTenant.mockReturnValueOnce(tenantClient as any);
      mockMemberProfile.count.mockResolvedValue(0);
      mockMemberProfile.create.mockResolvedValue({ id: 'profile-1' });

      await service.create(churchId, {
        userId: 'user-uuid',
        branchId: 'branch-uuid',
        birthDate: '1990-01-01',
        admissionDate: '2020-05-10',
        consecrationDate: '2022-09-15',
      });

      expect(mockMemberProfile.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            consecrationDate: new Date('2022-09-15'),
          }),
        }),
      );
    });

    it('persists consecrationDate on update', async () => {
      const churchId = 'church-uuid';
      const tenantClient = {
        memberProfile: {
          findFirst: jest.fn().mockResolvedValue({ id: 'profile-uuid' }),
        },
        membership: { findFirst: jest.fn() },
        positionUser: { findFirst: jest.fn().mockResolvedValue(null) },
      };
      mockPrismaService.forTenant.mockReturnValueOnce(tenantClient as any);
      mockMemberProfile.update.mockResolvedValue({ id: 'profile-uuid' });

      await service.update('church-uuid', 'profile-uuid', {
        consecrationDate: '2023-01-01',
      });

      expect(mockMemberProfile.update).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            consecrationDate: new Date('2023-01-01'),
          }),
        }),
      );
    });

    it('should filter out profiles from other months', async () => {
      const churchId = 'church-uuid';
      const mockProfiles = [
        { id: 'profile-1', birthDate: new Date('1995-04-12'), photoUrl: null, user: { name: 'Ana' } },
        { id: 'profile-2', birthDate: new Date('1988-06-25'), photoUrl: null, user: { name: 'Carlos' } },
      ];
      mockMemberProfile.findMany.mockResolvedValue(mockProfiles);

      const result = await service.findBirthdays(churchId, 4);

      expect(result.data).toHaveLength(1);
      expect(result.data[0].name).toBe('Ana');
    });
  });

  describe('findByUserId', () => {
    const churchId = 'church-uuid';
    const userId = 'user-uuid';

    it('should return the profile including identity fields (rg, sex, civilStatus, fatherName, motherName) when a MemberProfile exists', async () => {
      // The regression: userSelect previously omitted rg/sex/civilStatus/
      // fatherName/motherName, so those fields were never sent to the mobile
      // and the edit form pre-fill was always blank for them.
      const fullUser = {
        id: userId,
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
      };
      const tenantClient = {
        memberProfile: {
          findFirst: jest.fn().mockResolvedValue({
            id: 'profile-1',
            userId,
            churchId,
            registrationNumber: '2026-ABCD-001',
            birthDate: new Date('1990-05-12'),
            baptismDate: null,
            admissionDate: new Date('2020-01-15'),
            consecrationDate: new Date('2022-11-30'),
            photoUrl: null,
            user: fullUser,
          }),
        },
        membership: {
          findFirst: jest.fn().mockResolvedValue({
            id: 'membership-1',
            userId,
            churchId,
            branchId: 'branch-1',
            branch: { id: 'branch-1', name: 'Sede' },
          }),
        },
        positionUser: {
          findFirst: jest.fn().mockResolvedValue({
            positionId: 'position-1',
            position: { id: 'position-1', name: 'Pastor' },
          }),
        },
      };
      mockPrismaService.forTenant.mockReturnValue(tenantClient as any);

      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const result = await service.findByUserId(churchId, userId) as any;

      // Identity fields must be present in the returned user object
      expect(result.user).toMatchObject({
        rg: 'SP-99.999.999',
        sex: 'FEMALE',
        civilStatus: 'MARRIED',
        fatherName: 'João Silva',
        motherName: 'Maria Silva',
      });
      // consecrationDate must also be present
      expect(result.consecrationDate).toEqual(new Date('2022-11-30'));
      expect(result).toMatchObject({
        branchId: 'branch-1',
        branch: { id: 'branch-1', name: 'Sede' },
        positionId: 'position-1',
        position: { id: 'position-1', name: 'Pastor' },
      });
    });

    it('should return identity fields from the membership fallback when no MemberProfile exists yet', async () => {
      const fullUser = {
        id: userId,
        name: 'Carlos',
        email: null,
        phone: null,
        cpf: null,
        rg: 'MG-1234567',
        sex: 'MALE',
        civilStatus: 'SINGLE',
        fatherName: 'Pedro',
        motherName: 'Lucia',
        country: null,
        state: null,
        city: null,
        neighborhood: null,
        street: null,
        number: null,
        complement: null,
      };
      const tenantClient = {
        memberProfile: {
          findFirst: jest.fn().mockResolvedValue(null),
        },
        membership: {
          findFirst: jest.fn().mockResolvedValue({
            id: 'membership-1',
            userId,
            churchId,
            branchId: 'branch-1',
            branch: { id: 'branch-1', name: 'Sede' },
            user: fullUser,
          }),
        },
        positionUser: {
          findFirst: jest.fn().mockResolvedValue(null),
        },
      };
      mockPrismaService.forTenant.mockReturnValue(tenantClient as any);

      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const result = await service.findByUserId(churchId, userId) as any;

      expect(result.user).toMatchObject({
        rg: 'MG-1234567',
        sex: 'MALE',
        civilStatus: 'SINGLE',
        fatherName: 'Pedro',
        motherName: 'Lucia',
      });
      // Fallback must include consecrationDate: null so the mobile model
      // doesn't blow up deserializing a missing key.
      expect(result).toHaveProperty('consecrationDate', null);
    });
  });
});
