import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../../prisma/prisma.service';
import * as bcrypt from 'bcrypt';

const mockPrismaService = {
  user: {
    findUnique: jest.fn(),
    update: jest.fn(),
  },
  membership: {
    findMany: jest.fn(),
    findFirst: jest.fn(),
  },
  refreshToken: {
    create: jest.fn(),
    findUnique: jest.fn(),
    update: jest.fn(),
    updateMany: jest.fn(),
  },
  $transaction: jest.fn(),
};

const mockJwtService = {
  signAsync: jest.fn(() => 'test-jwt-token'),
  verifyAsync: jest.fn(),
};

describe('AuthService', () => {
  let service: AuthService;
  let prisma: typeof mockPrismaService;
  let jwt: typeof mockJwtService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: PrismaService, useValue: mockPrismaService },
        { provide: JwtService, useValue: mockJwtService },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
    prisma = module.get(PrismaService);
    jwt = module.get(JwtService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('signupAdmin', () => {
    function mockSignupTransaction(opts: {
      churchId?: string;
      branchId?: string;
      userId?: string;
      userEmail?: string;
    } = {}) {
      const txResult = {
        church: { id: opts.churchId ?? 'church-1', name: 'Grace Church' },
        branch: {
          id: opts.branchId ?? 'branch-1',
          churchId: opts.churchId ?? 'church-1',
          isHeadquarters: true,
        },
        user: {
          id: opts.userId ?? 'user-1',
          name: 'Pastor John',
          email: opts.userEmail ?? 'admin@church.com',
          password: 'hashed',
        },
        membership: { id: 'mem-1', role: 'ADMIN', status: 'ACTIVE' },
      };
      const userCreate = jest.fn().mockResolvedValue(txResult.user);
      prisma.$transaction.mockImplementation(async (fn: any) => fn({
        church: { create: jest.fn().mockResolvedValue(txResult.church) },
        branch: { create: jest.fn().mockResolvedValue(txResult.branch) },
        user: { create: userCreate },
        membership: {
          create: jest.fn().mockResolvedValue(txResult.membership),
        },
      }));
      return { txResult, userCreate };
    }

    it('should create church, branch, user and membership and auto-issue a token pair so the new admin is logged in immediately', async () => {
      // Given — no existing user, the transaction succeeds
      prisma.user.findUnique.mockResolvedValue(null);
      mockSignupTransaction();
      prisma.refreshToken.create.mockResolvedValue({ id: 'rt-1' });

      // When — a new admin signs up
      const result = await service.signupAdmin({
        name: 'Pastor John',
        email: 'admin@church.com',
        password: 'password123',
        churchName: 'Grace Church',
      });

      // Then — the response contains the created entities AND a fresh
      // access/refresh token pair so the mobile app can skip the login.
      expect(result).toHaveProperty('user');
      expect(result).toHaveProperty('church');
      expect(result).toHaveProperty('branch');
      expect(result.user).not.toHaveProperty('password');
      expect(result).toHaveProperty('access_token', 'test-jwt-token');
      expect(result).toHaveProperty('refresh_token');
      expect(typeof (result as any).refresh_token).toBe('string');
      expect((result as any).refresh_token.length).toBeGreaterThan(32);

      // And the persisted refresh token is a SHA-256 hash, never the raw value.
      const createCall = prisma.refreshToken.create.mock.calls[0][0];
      expect(createCall.data.tokenHash).not.toBe(
        (result as any).refresh_token,
      );
      expect(createCall.data.tokenHash).toMatch(/^[a-f0-9]{64}$/);
      expect(createCall.data.role).toBe('ADMIN');
    });

    it('should throw "A user with this email already exists" when the email is already taken', async () => {
      // Given — the email lookup hits an existing row
      prisma.user.findUnique.mockResolvedValue({ id: 'exists' });

      // When / Then — signupAdmin rejects with the conflict error
      await expect(
        service.signupAdmin({
          name: 'John',
          email: 'admin@church.com',
          password: 'pwd123',
          churchName: 'Church',
        }),
      ).rejects.toThrow('A user with this email already exists');
    });

    it('should normalize email by trimming whitespace and lowercasing before checking existence and creating the user', async () => {
      // Given — no existing user; transaction stub captures the create call
      prisma.user.findUnique.mockResolvedValue(null);
      const { userCreate } = mockSignupTransaction({
        userEmail: 'admin@church.com',
      });
      prisma.refreshToken.create.mockResolvedValue({ id: 'rt-1' });

      // When — the caller passes a messy email
      await service.signupAdmin({
        name: 'Pastor',
        email: '  Admin@Church.COM  ',
        password: 'password123',
        churchName: 'Grace',
      });

      // Then — both the lookup and the insert receive the canonical form
      expect(prisma.user.findUnique).toHaveBeenCalledWith({
        where: { email: 'admin@church.com' },
      });
      expect(userCreate).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({ email: 'admin@church.com' }),
        }),
      );
    });

    it('should NOT accept a phone field on the signup payload (admins set phone later via profile edit)', async () => {
      // Given — no existing user
      prisma.user.findUnique.mockResolvedValue(null);
      const { userCreate } = mockSignupTransaction();
      prisma.refreshToken.create.mockResolvedValue({ id: 'rt-1' });

      // When — signup is called with the legitimate field set only
      // (the DTO no longer types `phone`, so even if a stray client sent
      // it the global ValidationPipe `forbidNonWhitelisted: true` would
      // strip/reject it before reaching the service)
      await service.signupAdmin({
        name: 'Pastor John',
        email: 'admin@church.com',
        password: 'password123',
        churchName: 'Grace Church',
      });

      // Then — the inserted user row has NO phone column set, and only
      // the email is checked for uniqueness (no phone lookup happens).
      expect(prisma.user.findUnique).toHaveBeenCalledTimes(1);
      const createArgs = userCreate.mock.calls[0][0];
      expect(createArgs.data).not.toHaveProperty('phone');
    });
  });

  describe('login', () => {
    it('should return access_token and refresh_token for single membership', async () => {
      const hashedPassword = await bcrypt.hash('password123', 1);
      const user = { id: 'user-1', email: 'admin@church.com', password: hashedPassword };

      prisma.user.findUnique.mockResolvedValue(user);
      prisma.membership.findMany.mockResolvedValue([
        {
          churchId: 'church-1',
          branchId: 'branch-1',
          role: 'ADMIN',
          church: { id: 'church-1', name: 'Grace' },
          branch: { id: 'branch-1', name: 'HQ' },
        },
      ]);
      prisma.refreshToken.create.mockResolvedValue({ id: 'rt-1' });

      const result = await service.login('admin@church.com', 'password123');

      expect(result).toHaveProperty('access_token', 'test-jwt-token');
      expect(result).toHaveProperty('refresh_token');
      expect(typeof (result as any).refresh_token).toBe('string');
      expect((result as any).refresh_token.length).toBeGreaterThan(32);
      expect(result).not.toHaveProperty('requiresChurchSelection');

      // The refresh token persisted must NOT be the plaintext — only a hash.
      const createCall = prisma.refreshToken.create.mock.calls[0][0];
      expect(createCall.data.tokenHash).not.toBe((result as any).refresh_token);
      expect(createCall.data.tokenHash).toMatch(/^[a-f0-9]{64}$/); // sha256 hex
      expect(createCall.data.userId).toBe('user-1');
      expect(createCall.data.churchId).toBe('church-1');
      expect(createCall.data.branchId).toBe('branch-1');
      expect(createCall.data.role).toBe('ADMIN');
      expect(createCall.data.expiresAt).toBeInstanceOf(Date);
    });

    it('should return church selection for multiple memberships', async () => {
      const hashedPassword = await bcrypt.hash('password123', 1);
      const user = { id: 'user-1', email: 'admin@church.com', password: hashedPassword };

      prisma.user.findUnique.mockResolvedValue(user);
      prisma.membership.findMany.mockResolvedValue([
        {
          churchId: 'church-1', branchId: 'branch-1', role: 'ADMIN',
          church: { id: 'church-1', name: 'Grace' },
          branch: { id: 'branch-1', name: 'HQ' },
        },
        {
          churchId: 'church-2', branchId: 'branch-2', role: 'MEMBER',
          church: { id: 'church-2', name: 'Hope' },
          branch: { id: 'branch-2', name: 'Downtown' },
        },
      ]);

      const result = await service.login('admin@church.com', 'password123');

      expect(result).toHaveProperty('requiresChurchSelection', true);
      expect(result).toHaveProperty('selectionToken');
      expect(result).toHaveProperty('churches');
      expect((result as any).churches).toHaveLength(2);
    });

    it('should throw for invalid credentials (wrong email)', async () => {
      prisma.user.findUnique.mockResolvedValue(null);

      await expect(service.login('wrong@email.com', 'pwd')).rejects.toThrow('Invalid credentials');
    });

    it('should throw for invalid credentials (wrong password)', async () => {
      const hashedPassword = await bcrypt.hash('realpass', 1);
      prisma.user.findUnique.mockResolvedValue({
        id: 'user-1', email: 'admin@church.com', password: hashedPassword,
      });

      await expect(service.login('admin@church.com', 'wrongpass')).rejects.toThrow('Invalid credentials');
    });

    it('should throw Invalid credentials when user has no active memberships (prevents user enumeration)', async () => {
      const hashedPassword = await bcrypt.hash('password123', 1);
      prisma.user.findUnique.mockResolvedValue({
        id: 'user-1', email: 'admin@church.com', password: hashedPassword,
      });
      prisma.membership.findMany.mockResolvedValue([]);

      await expect(service.login('admin@church.com', 'password123')).rejects.toThrow('Invalid credentials');
    });

    it('should normalize email by trimming whitespace and lowercasing before lookup', async () => {
      const hashedPassword = await bcrypt.hash('password123', 1);
      prisma.user.findUnique.mockResolvedValue({
        id: 'user-1', email: 'admin@church.com', password: hashedPassword,
      });
      prisma.membership.findMany.mockResolvedValue([
        {
          churchId: 'church-1', branchId: 'branch-1', role: 'ADMIN',
          church: { id: 'church-1', name: 'Grace' },
          branch: { id: 'branch-1', name: 'HQ' },
        },
      ]);

      await service.login('  Admin@Church.COM  ', 'password123');

      expect(prisma.user.findUnique).toHaveBeenCalledWith({
        where: { email: 'admin@church.com' },
      });
    });
  });

  describe('selectChurch', () => {
    it('should issue access_token and refresh_token for a valid selection', async () => {
      jwt.verifyAsync.mockResolvedValue({
        sub: 'user-1', email: 'admin@church.com', type: 'church_selection',
      });
      prisma.membership.findFirst.mockResolvedValue({
        churchId: 'church-1', branchId: 'branch-1', role: 'ADMIN',
      });
      prisma.refreshToken.create.mockResolvedValue({ id: 'rt-1' });

      const result = await service.selectChurch('valid-token', 'church-1');

      expect(result).toHaveProperty('access_token', 'test-jwt-token');
      expect(result).toHaveProperty('refresh_token');
      expect((result as any).refresh_token.length).toBeGreaterThan(32);
    });

    it('should throw for invalid selection token', async () => {
      jwt.verifyAsync.mockRejectedValue(new Error('invalid'));

      await expect(service.selectChurch('bad-token', 'church-1')).rejects.toThrow(
        'Invalid or expired selection token',
      );
    });

    it('should throw when the verified token has the wrong type', async () => {
      // Someone forged (or reused) a standard JWT instead of a church_selection one.
      jwt.verifyAsync.mockResolvedValue({
        sub: 'user-1',
        email: 'admin@church.com',
        type: 'access',
      });

      await expect(service.selectChurch('wrong-type-token', 'church-1')).rejects.toThrow(
        'Invalid token type',
      );
    });

    it('should throw when the user has no active membership for the selected church', async () => {
      jwt.verifyAsync.mockResolvedValue({
        sub: 'user-1',
        email: 'admin@church.com',
        type: 'church_selection',
      });
      prisma.membership.findFirst.mockResolvedValue(null);

      await expect(service.selectChurch('valid-token', 'church-unknown')).rejects.toThrow(
        'No active membership for this church',
      );
    });
  });

  describe('refresh', () => {
    it('should issue new token pair and revoke the old row on successful rotation', async () => {
      const now = new Date();
      const futureExpiry = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000);
      const userRow = {
        id: 'rt-old',
        tokenHash: 'stored-hash',
        userId: 'user-1',
        churchId: 'church-1',
        branchId: 'branch-1',
        role: 'ADMIN',
        expiresAt: futureExpiry,
        revokedAt: null,
        user: { id: 'user-1', email: 'admin@church.com' },
      };
      prisma.refreshToken.findUnique.mockResolvedValue(userRow);
      prisma.refreshToken.create.mockResolvedValue({ id: 'rt-new' });
      prisma.refreshToken.update.mockResolvedValue({});

      const result = await service.refresh('some-refresh-token');

      expect(result).toHaveProperty('access_token', 'test-jwt-token');
      expect(result).toHaveProperty('refresh_token');
      expect((result as any).refresh_token).not.toBe('some-refresh-token');

      // Old row must be marked revoked with replacedBy pointing at the new row.
      expect(prisma.refreshToken.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: 'rt-old' },
          data: expect.objectContaining({
            revokedAt: expect.any(Date),
            replacedById: 'rt-new',
          }),
        }),
      );
    });

    it('should throw Invalid refresh token when the hash is unknown', async () => {
      prisma.refreshToken.findUnique.mockResolvedValue(null);

      await expect(service.refresh('ghost-token')).rejects.toThrow(
        'Invalid refresh token',
      );
    });

    it('should detect reuse and revoke ALL user tokens when a revoked token is presented', async () => {
      const revokedRow = {
        id: 'rt-old',
        tokenHash: 'hash',
        userId: 'user-1',
        churchId: 'church-1',
        branchId: 'branch-1',
        role: 'ADMIN',
        expiresAt: new Date(Date.now() + 60_000),
        revokedAt: new Date(Date.now() - 1000),
        user: { id: 'user-1', email: 'admin@church.com' },
      };
      prisma.refreshToken.findUnique.mockResolvedValue(revokedRow);
      prisma.refreshToken.updateMany.mockResolvedValue({ count: 3 });

      await expect(service.refresh('reused-token')).rejects.toThrow(
        /reuse/i,
      );

      expect(prisma.refreshToken.updateMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({ userId: 'user-1', revokedAt: null }),
          data: expect.objectContaining({ revokedAt: expect.any(Date) }),
        }),
      );
    });

    it('should throw when refresh token is expired', async () => {
      const expiredRow = {
        id: 'rt-exp',
        tokenHash: 'hash',
        userId: 'user-1',
        churchId: 'church-1',
        branchId: 'branch-1',
        role: 'ADMIN',
        expiresAt: new Date(Date.now() - 1000),
        revokedAt: null,
        user: { id: 'user-1', email: 'admin@church.com' },
      };
      prisma.refreshToken.findUnique.mockResolvedValue(expiredRow);

      await expect(service.refresh('expired-token')).rejects.toThrow(/expired/i);
    });
  });

  describe('logoutRefresh', () => {
    it('should revoke the presented refresh token', async () => {
      prisma.refreshToken.updateMany.mockResolvedValue({ count: 1 });

      await service.logoutRefresh('some-token');

      expect(prisma.refreshToken.updateMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({
            tokenHash: expect.any(String),
            revokedAt: null,
          }),
          data: expect.objectContaining({ revokedAt: expect.any(Date) }),
        }),
      );
    });
  });

  describe('getProfile', () => {
    it('should return full user profile with membership, positions, church and branch', async () => {
      const userId = 'user-uuid';
      const churchId = 'church-uuid';

      const mockMembership = {
        id: 'membership-uuid',
        role: 'ADMIN',
        status: 'ACTIVE',
        branch: { id: 'branch-uuid', name: 'Sede Principal' },
        user: {
          id: userId,
          name: 'Ricardo Oliveira',
          email: 'ricardo@email.com',
          phone: '11999999999',
          memberProfiles: [{
            photoUrl: 'https://photo.url',
            admissionDate: new Date('2020-03-15'),
            birthDate: new Date('1990-05-20'),
            baptismDate: new Date('2018-06-10'),
            registrationNumber: '2020-ABCD-001',
          }],
          positions: [{ position: { id: 'pos-uuid', name: 'Pastor' } }],
        },
        church: { id: churchId, name: 'Igreja Batista Central' },
      };

      prisma.membership.findFirst = jest.fn().mockResolvedValue(mockMembership);

      const result = await service.getProfile(userId, churchId);

      expect(result).toEqual({
        user: { id: userId, name: 'Ricardo Oliveira', email: 'ricardo@email.com', phone: '11999999999' },
        profile: {
          photoUrl: 'https://photo.url',
          admissionDate: new Date('2020-03-15'),
          birthDate: new Date('1990-05-20'),
          baptismDate: new Date('2018-06-10'),
          registrationNumber: '2020-ABCD-001',
        },
        membership: { role: 'ADMIN', status: 'ACTIVE' },
        positions: [{ id: 'pos-uuid', name: 'Pastor' }],
        church: { id: churchId, name: 'Igreja Batista Central' },
        branch: { id: 'branch-uuid', name: 'Sede Principal' },
      });
    });

    it('should throw NotFoundException when membership not found', async () => {
      prisma.membership.findFirst = jest.fn().mockResolvedValue(null);
      await expect(service.getProfile('user-uuid', 'church-uuid')).rejects.toThrow();
    });

    it('should return the new identity fields (rg, sex, civilStatus, fatherName, motherName) and consecrationDate when present on the Prisma row', async () => {
      // Given — Prisma returns a fully-populated user row with the new
      // identity columns AND a memberProfile that carries consecrationDate
      const userId = 'user-uuid';
      const churchId = 'church-uuid';
      const consecration = new Date('2024-06-15');
      const mockMembership = {
        id: 'membership-uuid',
        role: 'ADMIN',
        status: 'ACTIVE',
        branch: { id: 'branch-uuid', name: 'Sede' },
        user: {
          id: userId,
          name: 'Ricardo',
          email: 'r@e.com',
          phone: '11999',
          cpf: '123',
          rg: '12.345.678-9',
          sex: 'MALE',
          civilStatus: 'MARRIED',
          fatherName: 'Carlos Oliveira',
          motherName: 'Ana Oliveira',
          country: null,
          state: null,
          city: null,
          neighborhood: null,
          street: null,
          number: null,
          complement: null,
          memberProfiles: [
            {
              photoUrl: null,
              admissionDate: new Date('2020-03-15'),
              birthDate: new Date('1990-05-20'),
              baptismDate: null,
              consecrationDate: consecration,
              registrationNumber: null,
            },
          ],
          positions: [],
        },
        church: { id: churchId, name: 'Igreja' },
      };
      prisma.membership.findFirst = jest.fn().mockResolvedValue(mockMembership);

      // When — getProfile is called
      const result = await service.getProfile(userId, churchId);

      // Then — the returned user surfaces all five new identity fields
      expect(result.user).toEqual(
        expect.objectContaining({
          rg: '12.345.678-9',
          sex: 'MALE',
          civilStatus: 'MARRIED',
          fatherName: 'Carlos Oliveira',
          motherName: 'Ana Oliveira',
        }),
      );
      // And the nested profile carries consecrationDate verbatim
      expect(result.profile).toEqual(
        expect.objectContaining({ consecrationDate: consecration }),
      );
    });

    it('should return null for the new identity fields and consecrationDate when the Prisma row has them null', async () => {
      // Given — every new column comes back null from Prisma
      const userId = 'user-uuid';
      const churchId = 'church-uuid';
      const mockMembership = {
        id: 'membership-uuid',
        role: 'MEMBER',
        status: 'ACTIVE',
        branch: { id: 'branch-uuid', name: 'Sede' },
        user: {
          id: userId,
          name: 'João',
          email: 'j@e.com',
          phone: null,
          cpf: null,
          rg: null,
          sex: null,
          civilStatus: null,
          fatherName: null,
          motherName: null,
          country: null,
          state: null,
          city: null,
          neighborhood: null,
          street: null,
          number: null,
          complement: null,
          memberProfiles: [
            {
              photoUrl: null,
              admissionDate: new Date('2020-01-01'),
              birthDate: new Date('1990-01-01'),
              baptismDate: null,
              consecrationDate: null,
              registrationNumber: null,
            },
          ],
          positions: [],
        },
        church: { id: churchId, name: 'Igreja' },
      };
      prisma.membership.findFirst = jest.fn().mockResolvedValue(mockMembership);

      // When — getProfile is called
      const result = await service.getProfile(userId, churchId);

      // Then — the new fields are surfaced as null (not undefined / missing)
      expect(result.user.rg).toBeNull();
      expect(result.user.sex).toBeNull();
      expect(result.user.civilStatus).toBeNull();
      expect(result.user.fatherName).toBeNull();
      expect(result.user.motherName).toBeNull();
      expect(result.profile?.consecrationDate).toBeNull();
    });

    it('should return null profile when no member profile exists', async () => {
      const mockMembership = {
        id: 'membership-uuid', role: 'MEMBER', status: 'ACTIVE',
        branch: { id: 'branch-uuid', name: 'Sede' },
        user: { id: 'user-uuid', name: 'João', email: 'joao@email.com', phone: null, memberProfiles: [], positions: [] },
        church: { id: 'church-uuid', name: 'Igreja' },
      };
      prisma.membership.findFirst = jest.fn().mockResolvedValue(mockMembership);
      const result = await service.getProfile('user-uuid', 'church-uuid');
      expect(result.profile).toBeNull();
      expect(result.positions).toEqual([]);
    });
  });

  describe('updateProfile', () => {
    it('should update user fields and return user without password', async () => {
      const updatedUser = {
        id: 'user-1',
        name: 'Ana Updated',
        email: 'ana@test.com',
        phone: '11999999999',
        cpf: '12345678900',
        country: 'Brasil',
        state: 'SP',
        city: 'São Paulo',
        neighborhood: 'Jardins',
        street: 'Rua das Flores',
        number: '123',
        complement: 'Apto 4',
        password: 'hashed',
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      mockPrismaService.user.update.mockResolvedValue(updatedUser);

      const result = await service.updateProfile('user-1', {
        name: 'Ana Updated',
        cpf: '12345678900',
      });

      expect(mockPrismaService.user.update).toHaveBeenCalledWith({
        where: { id: 'user-1' },
        data: { name: 'Ana Updated', cpf: '12345678900' },
      });
      expect(result).not.toHaveProperty('password');
      expect(result.name).toBe('Ana Updated');
    });

    it('should forward the new identity fields (rg, sex, civilStatus, fatherName, motherName) verbatim to prisma.user.update', async () => {
      // Given — a payload that exercises every new identity field
      const updatedUser = {
        id: 'user-1',
        name: 'Ana',
        email: 'ana@test.com',
        phone: null,
        cpf: null,
        rg: '12.345.678-9',
        sex: 'FEMALE',
        civilStatus: 'MARRIED',
        fatherName: 'Carlos',
        motherName: 'Maria',
        country: null,
        state: null,
        city: null,
        neighborhood: null,
        street: null,
        number: null,
        complement: null,
        password: 'hashed',
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      mockPrismaService.user.update.mockResolvedValue(updatedUser);

      // When — updateProfile is called with the new fields set
      const result = await service.updateProfile('user-1', {
        rg: '12.345.678-9',
        sex: 'FEMALE' as any,
        civilStatus: 'MARRIED' as any,
        fatherName: 'Carlos',
        motherName: 'Maria',
      });

      // Then — the call reaches Prisma with all five identity fields intact
      expect(mockPrismaService.user.update).toHaveBeenCalledWith({
        where: { id: 'user-1' },
        data: {
          rg: '12.345.678-9',
          sex: 'FEMALE',
          civilStatus: 'MARRIED',
          fatherName: 'Carlos',
          motherName: 'Maria',
        },
      });
      // And the returned user still has the password stripped
      expect(result).not.toHaveProperty('password');
      expect(result).toEqual(
        expect.objectContaining({
          rg: '12.345.678-9',
          sex: 'FEMALE',
          civilStatus: 'MARRIED',
          fatherName: 'Carlos',
          motherName: 'Maria',
        }),
      );
    });
  });
});
