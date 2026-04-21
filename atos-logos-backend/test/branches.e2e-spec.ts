import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import type { App } from 'supertest/types';
import { startPostgresForE2E, StartedTestDb } from './helpers/postgres-container';

// Ensure JWT_SECRET is set BEFORE AppModule is imported — JwtModule
// reads it at module-load time via getJwtSecret().
process.env.JWT_SECRET = process.env.JWT_SECRET ?? 'e2e-test-secret-at-least-32-chars-long';

/**
 * DELETE /branches/:id — e2e with a real Postgres via testcontainers.
 *
 * The production bug that motivated this spec: deleting a Filial that
 * had memberships pointing to it returned a generic 500 because the
 * Prisma FK violation (P2003) was not handled. These tests pin the
 * contract: 204 on clean delete, 409 on conflict, 403 on HQ, 404 on
 * missing.
 */
describe('DELETE /branches/:id (e2e)', () => {
  let db: StartedTestDb;
  let app: INestApplication<App>;
  let accessToken: string;
  let hqBranchId: string;

  beforeAll(async () => {
    db = await startPostgresForE2E();

    // Require AFTER DATABASE_URL is set so PrismaService picks up the
    // container URL in its constructor. (ts-jest runs CJS, so require
    // is the right tool here — ESM dynamic import needs vm-modules.)
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

    // Bootstrap tenant: signup admin creates Church + HQ Branch +
    // ADMIN User + Membership, then returns a JWT access token.
    const signup = await request(app.getHttpServer())
      .post('/auth/signup-admin')
      .send({
        name: 'Admin E2E',
        email: 'admin-e2e@test.com',
        password: 'Str0ngPass!',
        churchName: 'Igreja E2E',
      })
      .expect(201);

    accessToken = signup.body.access_token;

    const branches = await request(app.getHttpServer())
      .get('/branches')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200);
    hqBranchId = branches.body.find((b: { isHeadquarters: boolean; id: string }) => b.isHeadquarters).id;
  }, 180_000);

  afterAll(async () => {
    await app?.close();
    await db?.stop();
  });

  async function createFilial(name: string): Promise<string> {
    const res = await request(app.getHttpServer())
      .post('/branches')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ name })
      .expect(201);
    return res.body.id as string;
  }

  it('should return 204 when deleting a filial with no dependents', async () => {
    // Given — a freshly created Filial with no memberships/events
    const filialId = await createFilial('Filial Clean');

    // When — admin deletes it
    // Then — server responds 204 and the branch is gone
    await request(app.getHttpServer())
      .delete(`/branches/${filialId}`)
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(204);

    const list = await request(app.getHttpServer())
      .get('/branches')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200);
    expect(list.body.find((b: { id: string }) => b.id === filialId)).toBeUndefined();
  });

  it('should return 409 with a clear message when deleting a filial that has active memberships', async () => {
    // Given — a Filial whose id is referenced by at least one
    // Membership row (the exact scenario that was producing 500).
    const filialId = await createFilial('Filial Com Vinculos');
    // Seed a Membership via the app's PrismaService so we share the
    // same pg adapter config the app was built with (avoids having
    // to re-wire the adapter here).
    /* eslint-disable @typescript-eslint/no-require-imports */
    const { PrismaService } = require('../src/prisma/prisma.service');
    /* eslint-enable @typescript-eslint/no-require-imports */
    const prisma = app.get(PrismaService);
    const user = await prisma.user.create({
      data: { name: 'Fulano', email: 'fulano@test.com', password: 'x' },
    });
    const anyMembership = await prisma.membership.findFirst();
    await prisma.membership.create({
      data: {
        userId: user.id,
        churchId: anyMembership!.churchId,
        branchId: filialId,
        role: 'MEMBER',
      },
    });

    // When — admin tries to delete the Filial
    // Then — server responds 409 with a user-friendly message, NOT 500
    const res = await request(app.getHttpServer())
      .delete(`/branches/${filialId}`)
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(409);

    expect(res.body.message).toMatch(/vinculad|vínculo|membros|não é possível/i);
  });

  it('should return 403 when trying to delete the headquarters branch', async () => {
    // Given — the Sede (created at signup) cannot be deleted by rule
    // When — admin attempts to delete it
    // Then — server responds 403 Forbidden
    await request(app.getHttpServer())
      .delete(`/branches/${hqBranchId}`)
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(403);
  });

  it('should return 404 when the branch id does not exist in this church', async () => {
    // Given — a random UUID that is not a branch of this tenant
    const ghostId = '00000000-0000-0000-0000-000000000000';

    // When — admin tries to delete it
    // Then — server responds 404 Not Found
    await request(app.getHttpServer())
      .delete(`/branches/${ghostId}`)
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(404);
  });
});
