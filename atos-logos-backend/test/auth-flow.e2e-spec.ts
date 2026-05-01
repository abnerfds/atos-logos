import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import type { App } from 'supertest/types';
import { startPostgresForE2E, StartedTestDb } from './helpers/postgres-container';

process.env.JWT_SECRET = process.env.JWT_SECRET ?? 'e2e-test-secret-at-least-32-chars-long';

/**
 * Auth Flow — 2-Phase Login (e2e)
 *
 * Covers two distinct login paths:
 *   Phase 1 (single membership): POST /auth/login returns access_token directly.
 *   Phase 2 (multi-church):      POST /auth/login returns selectionToken + church
 *                                 list; POST /auth/select-church exchanges it for
 *                                 a full-scoped access_token.
 *
 * Budget: 5 login calls / 60s (ThrottlerModule override).
 * To stay under the limit, the login response is captured ONCE in beforeAll
 * and shared across tests as read-only assertions. Individual tests that
 * require a live login call (invalid-credential tests) are explicitly
 * counted and capped at 2 additional calls.
 */
describe('Auth Flow — 2-Phase Login (e2e)', () => {
  let db: StartedTestDb;
  let app: INestApplication<App>;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let prisma: any;

  const singleEmail = 'single-auth@test.com';
  const singlePassword = 'Str0ngPass!';
  const multiEmail = 'multi-auth@test.com';
  const multiPassword = 'Str0ngPass!';

  // Cached in outer beforeAll (1 login call consumed)
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let singleLoginResponse: any;
  let singleAccessToken: string;

  let multiUserChurchAId: string;
  let multiUserChurchBId: string;

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

    // ── Church A — single-membership user (this admin has exactly 1 church) ─
    const signupA = await request(app.getHttpServer())
      .post('/auth/signup-admin')
      .send({
        name: 'Admin Unico',
        email: singleEmail,
        password: singlePassword,
        churchName: 'Igreja Single',
      })
      .expect(201);

    multiUserChurchAId = signupA.body.church.id;
    const tokenA = signupA.body.access_token;

    const branchesA = await request(app.getHttpServer())
      .get('/branches')
      .set('Authorization', `Bearer ${tokenA}`)
      .expect(200);

    const hqBranchAId = branchesA.body.find(
      (b: { isHeadquarters: boolean }) => b.isHeadquarters,
    ).id;

    // ── Church B — multi-church setup ─────────────────────────────────────
    const signupB = await request(app.getHttpServer())
      .post('/auth/signup-admin')
      .send({
        name: 'Admin Multi B',
        email: 'admin-multib-flow@test.com',
        password: 'Str0ngPass!',
        churchName: 'Igreja Multi B',
      })
      .expect(201);

    multiUserChurchBId = signupB.body.church.id;
    const tokenB = signupB.body.access_token;

    const branchesB = await request(app.getHttpServer())
      .get('/branches')
      .set('Authorization', `Bearer ${tokenB}`)
      .expect(200);

    const hqBranchBId = branchesB.body.find(
      (b: { isHeadquarters: boolean }) => b.isHeadquarters,
    ).id;

    // ── Create multi-church user in Church A ──────────────────────────────
    const multiRes = await request(app.getHttpServer())
      .post('/memberships/with-user')
      .set('Authorization', `Bearer ${tokenA}`)
      .send({
        name: 'Usuario Multi Igreja',
        email: multiEmail,
        password: multiPassword,
        branchId: hqBranchAId,
        birthDate: '1985-05-20',
        admissionDate: '2021-01-01',
      })
      .expect(201);

    const multiUserId = multiRes.body.user.id;

    // Give that same user a second active membership in Church B via Prisma
    // (no extra login slot consumed — Prisma bypasses the throttled endpoint)
    await prisma.membership.create({
      data: {
        userId: multiUserId,
        churchId: multiUserChurchBId,
        branchId: hqBranchBId,
        role: 'MEMBER',
        status: 'ACTIVE',
      },
    });

    // ── Login cache: 1 login call for single-membership verification ──────
    // Tests under "single membership" describe share this cached response.
    singleLoginResponse = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: singleEmail, password: singlePassword }); // counter = 1
    singleAccessToken = singleLoginResponse.body.access_token;
  }, 180_000);

  afterAll(async () => {
    await app?.close();
    await db?.stop();
  });

  // ── Phase 1: single membership ─────────────────────────────────────────

  describe('when the user has a single active membership', () => {
    it('should return access_token and refresh_token directly without requiring church selection', () => {
      // Given — singleEmail has exactly one active membership
      // When — user logs in (response cached in beforeAll, no new API call)
      // Then — full token pair returned; no selectionToken in the response
      expect(singleLoginResponse.status).toBe(201);
      expect(singleLoginResponse.body.access_token).toBeDefined();
      expect(singleLoginResponse.body.refresh_token).toBeDefined();
      expect(singleLoginResponse.body.requiresChurchSelection).toBeUndefined();
      expect(singleLoginResponse.body.selectionToken).toBeUndefined();
    });

    it('should grant access to GET /auth/me when using the returned access_token', async () => {
      // Given — the access_token obtained from the cached single login
      // When — token used on a protected route
      // Then — 200 with profile data
      const meRes = await request(app.getHttpServer())
        .get('/auth/me')
        .set('Authorization', `Bearer ${singleAccessToken}`)
        .expect(200);

      expect(meRes.body.user.email).toBe(singleEmail);
    });
  });

  // ── Phase 2: multi-church selection flow ───────────────────────────────

  describe('when the user has multiple active memberships', () => {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    let multiLoginResponse: any;
    let selectionToken: string;

    beforeAll(async () => {
      // One login call consumed here (counter = 2).
      // This runs AFTER the outer beforeAll so the container is up; the
      // selectionToken is fresh (2-min TTL) and valid for the tests below.
      multiLoginResponse = await request(app.getHttpServer())
        .post('/auth/login')
        .send({ email: multiEmail, password: multiPassword });

      selectionToken = multiLoginResponse.body.selectionToken;
    });

    it('should return requiresChurchSelection flag and a selectionToken', () => {
      // Given — multiEmail has memberships in Church A and Church B
      // When — user logs in (response cached in inner beforeAll)
      // Then — selection flow metadata returned, NOT a full access_token
      expect(multiLoginResponse.status).toBe(201);
      expect(multiLoginResponse.body.requiresChurchSelection).toBe(true);
      expect(multiLoginResponse.body.selectionToken).toBeDefined();
      expect(multiLoginResponse.body.access_token).toBeUndefined();
      expect(multiLoginResponse.body.refresh_token).toBeUndefined();
    });

    it('should include the list of churches the user can select from', () => {
      // Given — multi-church user
      // When — user logs in (cached response from inner beforeAll)
      // Then — both churches appear in the list
      const churchIds = multiLoginResponse.body.churches.map((c: { id: string }) => c.id);
      expect(churchIds).toContain(multiUserChurchAId);
      expect(churchIds).toContain(multiUserChurchBId);
    });

    it('should not grant access to protected routes when using selectionToken as Bearer', async () => {
      // Given — a selectionToken (carries no churchId or role in payload)
      // When — the token is used as Bearer on a resource-scoped endpoint
      // Then — server must NOT return 200 (the JwtStrategy now rejects
      //        tokens whose payload.type === 'church_selection')
      const res = await request(app.getHttpServer())
        .get('/auth/me')
        .set('Authorization', `Bearer ${selectionToken}`);

      expect(res.status).not.toBe(200);
    });

    it('should issue access_token after POST /auth/select-church with a valid selectionToken', async () => {
      // Given — the fresh selectionToken captured in inner beforeAll
      // When — user selects Church A
      const selectRes = await request(app.getHttpServer())
        .post('/auth/select-church')
        .send({ selectionToken, churchId: multiUserChurchAId })
        .expect(201);

      // Then — full token pair returned
      expect(selectRes.body.access_token).toBeDefined();
      expect(selectRes.body.refresh_token).toBeDefined();

      // And the resulting token grants access to protected routes
      const meRes = await request(app.getHttpServer())
        .get('/auth/me')
        .set('Authorization', `Bearer ${selectRes.body.access_token}`)
        .expect(200);

      expect(meRes.body.user.email).toBe(multiEmail);
    });

    it('should return 401 when a regular access_token is sent to POST /auth/select-church', async () => {
      // Given — singleAccessToken is a regular access_token (type field absent)
      // When — it is sent as selectionToken to select-church
      // Then — 401 Unauthorized (the service checks payload.type === 'church_selection')
      await request(app.getHttpServer())
        .post('/auth/select-church')
        .send({ selectionToken: singleAccessToken, churchId: multiUserChurchAId })
        .expect(401);
    });

    it('should return 401 when the selectionToken is tampered', async () => {
      // Given — a forged / corrupted token string
      const tamperedToken = selectionToken.slice(0, -10) + 'TAMPERED!!';

      // When — forged token is used in select-church
      // Then — 401 (JWT signature invalid)
      await request(app.getHttpServer())
        .post('/auth/select-church')
        .send({ selectionToken: tamperedToken, churchId: multiUserChurchAId })
        .expect(401);
    });
  });

  // ── Invalid credentials ────────────────────────────────────────────────
  // These tests consume 2 more login slots (total = 4 < 5 limit).

  describe('when credentials are invalid', () => {
    it('should return 401 for wrong password', async () => {
      // Given — correct email, wrong password (counter = 3)
      // When — login attempt
      // Then — 401 with a generic message (avoids leaking account existence)
      await request(app.getHttpServer())
        .post('/auth/login')
        .send({ email: singleEmail, password: 'WrongPass!' })
        .expect(401);
    });

    it('should return 401 for unknown email', async () => {
      // Given — email that was never registered (counter = 4)
      // When — login attempt
      // Then — 401 with the same generic "Invalid credentials" message
      await request(app.getHttpServer())
        .post('/auth/login')
        .send({ email: 'nobody@test.com', password: 'Str0ngPass!' })
        .expect(401);
    });
  });
});
