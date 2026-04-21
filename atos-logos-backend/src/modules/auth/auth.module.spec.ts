import { Module, Global } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { AuthModule } from './auth.module';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { PrismaService } from '../../prisma/prisma.service';

/// A global stub of the PrismaModule so AuthModule finds PrismaService when
/// compiled in isolation (the real PrismaModule is marked @Global in the app).
const mockPrisma = {
  user: { findUnique: jest.fn(), update: jest.fn() },
  membership: { findMany: jest.fn(), findFirst: jest.fn() },
  refreshToken: {
    create: jest.fn(),
    findUnique: jest.fn(),
    update: jest.fn(),
    updateMany: jest.fn(),
  },
  $transaction: jest.fn(),
};

@Global()
@Module({
  providers: [{ provide: PrismaService, useValue: mockPrisma }],
  exports: [PrismaService],
})
class StubPrismaModule {}

describe('AuthModule', () => {
  const originalEnv = process.env;

  beforeEach(() => {
    process.env = { ...originalEnv };
    process.env.JWT_SECRET = 'a-strong-test-secret-that-is-long-enough-1234';
  });

  afterAll(() => {
    process.env = originalEnv;
  });

  it('should compile and wire AuthService + AuthController', async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [StubPrismaModule, AuthModule],
    }).compile();

    expect(moduleRef.get(AuthService)).toBeDefined();
    expect(moduleRef.get(AuthController)).toBeDefined();

    await moduleRef.close();
  });

  it('should fail to compile when JWT_SECRET is missing', async () => {
    delete process.env.JWT_SECRET;

    await expect(
      Test.createTestingModule({
        imports: [StubPrismaModule, AuthModule],
      }).compile(),
    ).rejects.toThrow(/JWT_SECRET.*not set/);
  });
});
