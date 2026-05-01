import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import type { App } from 'supertest/types';
import * as bcrypt from 'bcrypt';
import * as crypto from 'crypto';
import { startPostgresForE2E, StartedTestDb } from './helpers/postgres-container';

process.env.JWT_SECRET = process.env.JWT_SECRET ?? 'e2e-test-secret-at-least-32-chars-long';

/**
 * Rate Limiting (e2e)
 *
 * The ThrottlerModule applies tighter per-endpoint limits on auth routes to
 * slow down brute-force and credential-stuffing attacks.
 *
 * Limit configuration (see AuthController @Throttle overrides):
 *   - POST /auth/login          5 req / 60 s
 *   - POST /auth/signup-admin   5 req / 60 s
 *   - POST /auth/refresh        20 req / 60 s
 *
 * Design note: the account used for the refresh-rate test is created
 * directly via Prisma in beforeAll so that no throttled signup-admin or
 * login slot is consumed during setup — each test sees a clean counter.
 */
describe('Rate Limiting (e2e)', () => {
  let db: StartedTestDb;
  let app: INestApplication<App>;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let prisma: any;

  // Seeded directly in Prisma to avoid consuming throttled-endpoint slots
  let initialRefreshToken: string;

  beforeAll(async () => {
    db = await startPostgresForE2E();

    /* eslint-disable @typescript-eslint/no-require-imports */
    const { AppModule } = require('../src/app.module');
    const { PrismaExceptionFilter } = require(
      '../src/common/filters/prisma-exception.filter',
    );
    const { PrismaService } = require('../src/prisma/prisma.service');
    /* eslint-enable @typescript-eslint/no-require-imports */

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(
      new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform: true }),
    );
    app.useGlobalFilters(new PrismaExceptionFilter());
    await app.init();

    prisma = app.get(PrismaService);

    // ── Seed a user + church + refresh token via Prisma ───────────────────
    // Purpose: the refresh-rate test needs a valid initial token without
    // calling any throttled endpoint during setup.
    const hashedPassword = await bcrypt.hash('Str0ngPass!', 10);

    const user = await prisma.user.create({
      data: {
        name: 'Refresh Rate Admin',
        email: 'refresh-rate@test.com',
        password: hashedPassword,
      },
    });

    const church = await prisma.church.create({
      data: { name: 'Igreja Refresh Rate' },
    });

    const branch = await prisma.branch.create({
      data: { churchId: church.id, name: 'Igreja Refresh Rate', isHeadquarters: true },
    });

    await prisma.membership.create({
      data: {
        userId: user.id,
        churchId: church.id,
        branchId: branch.id,
        role: 'ADMIN',
        status: 'ACTIVE',
      },
    });

    const rawToken = crypto.randomBytes(48).toString('base64url');
    const tokenHash = crypto.createHash('sha256').update(rawToken).digest('hex');
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 30);

    await prisma.refreshToken.create({
      data: {
        tokenHash,
        userId: user.id,
        churchId: church.id,
        branchId: branch.id,
        role: 'ADMIN',
        expiresAt,
      },
    });

    initialRefreshToken = rawToken;
  }, 180_000);

  afterAll(async () => {
    await app?.close();
    await db?.stop();
  });

  // ── Login rate limit ───────────────────────────────────────────────────

  it('should return 429 after 5 rapid login attempts from the same IP', async () => {
    // Given — POST /auth/login allows 5 req/min (ThrottlerModule @Throttle override)
    //         counter starts at 0 because beforeAll made no login calls
    // When — 6 requests are fired in a tight loop using a non-existent email
    //        (the handler returns 401 on invalid credentials; the throttle
    //        guard runs before the handler and counts every attempt)
    const responses: number[] = [];

    for (let i = 1; i <= 6; i++) {
      const res = await request(app.getHttpServer())
        .post('/auth/login')
        // Password ≥ 6 chars so validation pipe passes and throttler counts it
        .send({ email: 'nobody@test.com', password: 'wrongpassword' });

      responses.push(res.status);
    }

    // Then — first 5 pass (handler rejects with 401); 6th is blocked (429)
    expect(responses.slice(0, 5)).toEqual([401, 401, 401, 401, 401]);
    expect(responses[5]).toBe(429);
  });

  // ── Signup-admin rate limit ────────────────────────────────────────────

  it('should return 429 after 5 rapid signup-admin attempts from the same IP', async () => {
    // Given — POST /auth/signup-admin allows 5 req/min; counter starts at 0
    //         (login test above used a DIFFERENT route counter)
    // When — 6 requests are fired; first 5 are valid and create real churches
    const responses: number[] = [];

    for (let i = 1; i <= 6; i++) {
      const res = await request(app.getHttpServer())
        .post('/auth/signup-admin')
        .send({
          name: `Admin Rate ${i}`,
          email: `rate-signup-${i}@test.com`,
          password: 'Str0ngPass!',
          churchName: `Igreja Rate ${i}`,
        });

      responses.push(res.status);
    }

    // Then — first 5 succeed (201 Created); 6th is throttled (429)
    expect(responses.slice(0, 5)).toEqual([201, 201, 201, 201, 201]);
    expect(responses[5]).toBe(429);
  });

  // ── Refresh rate limit ─────────────────────────────────────────────────

  it('should return 429 after 20 rapid refresh attempts from the same IP', async () => {
    // Given — POST /auth/refresh allows 20 req/min; counter starts at 0
    //         initialRefreshToken was seeded via Prisma (no throttled calls)
    // When — 21 refresh calls in a tight loop, always using the latest token
    let currentToken = initialRefreshToken;
    const responses: number[] = [];

    for (let i = 1; i <= 21; i++) {
      const res = await request(app.getHttpServer())
        .post('/auth/refresh')
        .send({ refreshToken: currentToken });

      responses.push(res.status);

      // Keep the rotation chain alive so we don't get 401s before 429
      if (res.status === 201 && res.body.refresh_token) {
        currentToken = res.body.refresh_token;
      }
    }

    // Then — first 20 pass through the throttle (201); 21st is blocked (429)
    const passing = responses.filter((s) => s === 201);
    expect(passing).toHaveLength(20);
    expect(responses[20]).toBe(429);
  });
});
