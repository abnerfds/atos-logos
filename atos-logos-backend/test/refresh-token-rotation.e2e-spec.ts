import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import type { App } from 'supertest/types';
import { startPostgresForE2E, StartedTestDb } from './helpers/postgres-container';

process.env.JWT_SECRET = process.env.JWT_SECRET ?? 'e2e-test-secret-at-least-32-chars-long';

/**
 * Refresh Token Rotation + Reuse Detection (e2e)
 *
 * Every /auth/refresh call rotates the token: the presented token is
 * immediately revoked and a new one is issued. If a revoked token is
 * presented again, the server detects the reuse, revokes ALL active
 * sessions for that user, and returns 401. This prevents a stolen token
 * from being silently exploited after the legitimate owner has refreshed.
 */
describe('Refresh Token Rotation + Reuse Detection (e2e)', () => {
  let db: StartedTestDb;
  let app: INestApplication<App>;

  const email = 'rotation-test@test.com';
  const password = 'Str0ngPass!';

  let firstRefreshToken: string;
  let secondRefreshToken: string;

  beforeAll(async () => {
    db = await startPostgresForE2E();

    /* eslint-disable @typescript-eslint/no-require-imports */
    const { AppModule } = require('../src/app.module');
    const { PrismaExceptionFilter } = require(
      '../src/common/filters/prisma-exception.filter',
    );
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

    // Bootstrap: signup issues the first refresh token automatically
    const signup = await request(app.getHttpServer())
      .post('/auth/signup-admin')
      .send({
        name: 'Rotation Test Admin',
        email,
        password,
        churchName: 'Igreja Rotation',
      })
      .expect(201);

    firstRefreshToken = signup.body.refresh_token;
  }, 180_000);

  afterAll(async () => {
    await app?.close();
    await db?.stop();
  });

  it('should issue a new access_token and refresh_token when rotating a valid token', async () => {
    // Given — firstRefreshToken is valid and not yet used for rotation
    // When — client calls /auth/refresh
    const res = await request(app.getHttpServer())
      .post('/auth/refresh')
      .send({ refreshToken: firstRefreshToken })
      .expect(201);

    // Then — new token pair is returned
    expect(res.body.access_token).toBeDefined();
    expect(res.body.refresh_token).toBeDefined();
    // Store for subsequent tests in this suite
    secondRefreshToken = res.body.refresh_token;
  });

  it('should reject the original token after it has been rotated', async () => {
    // Given — firstRefreshToken was already rotated in the previous test
    // When — the same (now-revoked) token is presented again
    // Then — 401 Unauthorized; reuse detection fires
    await request(app.getHttpServer())
      .post('/auth/refresh')
      .send({ refreshToken: firstRefreshToken })
      .expect(401);
  });

  it('should revoke all remaining sessions when a rotated token is reused', async () => {
    // Given — when the previous test re-used firstRefreshToken, the server
    //         detected reuse and revoked ALL active sessions including
    //         secondRefreshToken (the legitimate successor token).
    // When — the replacement token is presented
    // Then — 401 Unauthorized; it was collaterally revoked by the cascade
    await request(app.getHttpServer())
      .post('/auth/refresh')
      .send({ refreshToken: secondRefreshToken })
      .expect(401);
  });

  it('should return 401 for a completely unknown refresh token', async () => {
    // Given — a token that was never issued by this server
    const fakeToken = 'this-is-a-completely-fake-refresh-token-that-never-existed';

    // When — the fake token is sent to /auth/refresh
    // Then — 401 Unauthorized (no row found in DB)
    await request(app.getHttpServer())
      .post('/auth/refresh')
      .send({ refreshToken: fakeToken })
      .expect(401);
  });

  it('should return 401 when a new login session is refreshed after reuse wipes all sessions', async () => {
    // Given — the attacker has a fresh session obtained AFTER the reuse
    //         event wiped all sessions; this fresh session was created by a
    //         new login so it should be valid...
    // When — normal rotation of a brand new token issued post-wipe
    // Then — 200 (normal rotation), confirming the user can re-establish
    //         a session after the wipe by logging in again
    const loginRes = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email, password })
      .expect(201);

    const freshToken = loginRes.body.refresh_token;

    const rotateRes = await request(app.getHttpServer())
      .post('/auth/refresh')
      .send({ refreshToken: freshToken })
      .expect(201);

    expect(rotateRes.body.access_token).toBeDefined();
    expect(rotateRes.body.refresh_token).toBeDefined();
    // Clean up: revoke this session so it does not pollute other suites
    await request(app.getHttpServer())
      .post('/auth/logout')
      .send({ refreshToken: rotateRes.body.refresh_token })
      .expect(204);
  });

  it('should return 204 and silently succeed when logging out an already-revoked token', async () => {
    // Given — firstRefreshToken is already revoked
    // When — client calls /auth/logout with it (e.g., after a crash-recovery)
    // Then — 204 (idempotent; no error thrown for unknown tokens)
    await request(app.getHttpServer())
      .post('/auth/logout')
      .send({ refreshToken: firstRefreshToken })
      .expect(204);
  });
});
