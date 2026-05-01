import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import type { App } from 'supertest/types';
import { startPostgresForE2E, StartedTestDb } from './helpers/postgres-container';

// JWT_SECRET must be set BEFORE AppModule is imported — JwtModule reads it
// at module-load time via getJwtSecret().
process.env.JWT_SECRET = process.env.JWT_SECRET ?? 'e2e-test-secret-at-least-32-chars-long';

/**
 * Tenant Isolation (e2e)
 *
 * Threat model: Church A's ADMIN obtains IDs of resources that belong to
 * Church B and tries to read, modify, or delete them. Under correct
 * multi-tenancy every such attempt must return 404 — the resource is
 * invisible across tenant boundaries, so the attacker cannot even confirm
 * it exists.
 */
describe('Tenant Isolation (e2e)', () => {
  let db: StartedTestDb;
  let app: INestApplication<App>;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let prisma: any;

  let tokenA: string;
  let tokenB: string;

  let churchBId: string;
  let churchBHqBranchId: string;
  let churchBMembershipId: string;
  let churchBFilialId: string;
  let churchBEbdClassId: string;
  let churchBMemberProfileId: string;
  let churchBUserId: string;

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

    // ── Church A (attacker) ───────────────────────────────────────────────
    const signupA = await request(app.getHttpServer())
      .post('/auth/signup-admin')
      .send({
        name: 'Admin Igreja A',
        email: 'admin-a-isolation@test.com',
        password: 'Str0ngPass!',
        churchName: 'Igreja A',
      })
      .expect(201);

    tokenA = signupA.body.access_token;

    // ── Church B (victim) ─────────────────────────────────────────────────
    const signupB = await request(app.getHttpServer())
      .post('/auth/signup-admin')
      .send({
        name: 'Admin Igreja B',
        email: 'admin-b-isolation@test.com',
        password: 'Str0ngPass!',
        churchName: 'Igreja B',
      })
      .expect(201);

    tokenB = signupB.body.access_token;
    churchBId = signupB.body.church.id;

    const branchesB = await request(app.getHttpServer())
      .get('/branches')
      .set('Authorization', `Bearer ${tokenB}`)
      .expect(200);

    churchBHqBranchId = branchesB.body.find(
      (b: { isHeadquarters: boolean }) => b.isHeadquarters,
    ).id;

    // ── Seed a member in Church B ─────────────────────────────────────────
    const memberRes = await request(app.getHttpServer())
      .post('/memberships/with-user')
      .set('Authorization', `Bearer ${tokenB}`)
      .send({
        name: 'Membro Igreja B',
        email: 'membro-b-isolation@test.com',
        password: 'Str0ngPass!',
        branchId: churchBHqBranchId,
        birthDate: '1990-06-15',
        admissionDate: '2023-01-01',
      })
      .expect(201);

    churchBMembershipId = memberRes.body.membership.id;
    churchBUserId = memberRes.body.user.id;
    churchBMemberProfileId = memberRes.body.profile?.id;

    // ── Seed a filial in Church B ─────────────────────────────────────────
    const filialRes = await request(app.getHttpServer())
      .post('/branches')
      .set('Authorization', `Bearer ${tokenB}`)
      .send({ name: 'Filial Igreja B' })
      .expect(201);

    churchBFilialId = filialRes.body.id;

    // ── Seed an EBD quarter + class in Church B via Prisma ────────────────
    // (Creating EBD via API requires 13 lessons — using Prisma is faster
    // here since the test is about isolation, not EBD creation flow.)
    const quarter = await prisma.ebdQuarter.create({
      data: {
        churchId: churchBId,
        name: '1º Trimestre 2025',
        status: 'ACTIVE',
      },
    });

    const ebdClass = await prisma.ebdClass.create({
      data: {
        churchId: churchBId,
        quarterId: quarter.id,
        branchId: churchBHqBranchId,
        name: 'Classe Adultos B',
        targetAudience: 'Adultos',
        status: true,
      },
    });

    churchBEbdClassId = ebdClass.id;

    // ── Resolve Church B's MemberProfile ─────────────────────────────────
    // createWithUser creates the profile automatically (or may return null
    // if birthDate/admissionDate were not provided). Fall back to a direct
    // Prisma lookup to guarantee churchBMemberProfileId is populated.
    if (!churchBMemberProfileId) {
      const existing = await prisma.memberProfile.findFirst({
        where: { userId: churchBUserId, churchId: churchBId },
      });

      if (existing) {
        churchBMemberProfileId = existing.id;
      } else {
        const created = await prisma.memberProfile.create({
          data: {
            userId: churchBUserId,
            churchId: churchBId,
            registrationNumber: '2025-ISOL-001',
            birthDate: new Date('1990-06-15'),
            admissionDate: new Date('2023-01-01'),
          },
        });
        churchBMemberProfileId = created.id;
      }
    }
  }, 180_000);

  afterAll(async () => {
    await app?.close();
    await db?.stop();
  });

  // ── Memberships ────────────────────────────────────────────────────────

  it('should not expose members from another church in GET /memberships', async () => {
    // Given — Church A and Church B each have their own members
    // When — Church A's admin lists its members
    const res = await request(app.getHttpServer())
      .get('/memberships')
      .set('Authorization', `Bearer ${tokenA}`)
      .expect(200);

    // Then — Church B's membership must not appear anywhere in the payload
    expect(JSON.stringify(res.body)).not.toContain(churchBMembershipId);
  });

  it('should return 404 when patching a membership from another church', async () => {
    // Given — churchBMembershipId physically lives in Church B's tenant
    // When — Church A's admin sends a PATCH using that ID
    // Then — 404 Not Found; the tenant filter makes it invisible
    await request(app.getHttpServer())
      .patch(`/memberships/${churchBMembershipId}`)
      .set('Authorization', `Bearer ${tokenA}`)
      .send({ status: 'INACTIVE' })
      .expect(404);
  });

  it('should return 404 when deleting a membership from another church', async () => {
    // Given — churchBMembershipId belongs to Church B
    // When — Church A's admin sends a DELETE using that ID
    // Then — 404 Not Found
    await request(app.getHttpServer())
      .delete(`/memberships/${churchBMembershipId}`)
      .set('Authorization', `Bearer ${tokenA}`)
      .expect(404);
  });

  // ── Branches ───────────────────────────────────────────────────────────

  it('should not expose branches from another church in GET /branches', async () => {
    // Given — Church A and Church B each have distinct branches
    // When — Church A's admin lists its branches
    const res = await request(app.getHttpServer())
      .get('/branches')
      .set('Authorization', `Bearer ${tokenA}`)
      .expect(200);

    // Then — Church B's filial must not be visible
    const ids = res.body.map((b: { id: string }) => b.id);
    expect(ids).not.toContain(churchBFilialId);
  });

  it('should return 404 when patching a branch from another church', async () => {
    // Given — churchBFilialId belongs to Church B
    // When — Church A's admin tries to rename it
    // Then — 404 Not Found
    await request(app.getHttpServer())
      .patch(`/branches/${churchBFilialId}`)
      .set('Authorization', `Bearer ${tokenA}`)
      .send({ name: 'Branch Hijacked' })
      .expect(404);
  });

  it('should return 404 when deleting a branch from another church', async () => {
    // Given — churchBFilialId belongs to Church B
    // When — Church A's admin tries to delete it
    // Then — 404 Not Found
    await request(app.getHttpServer())
      .delete(`/branches/${churchBFilialId}`)
      .set('Authorization', `Bearer ${tokenA}`)
      .expect(404);
  });

  // ── EBD Classes ────────────────────────────────────────────────────────

  it('should return 404 when getting an EBD class from another church', async () => {
    // Given — churchBEbdClassId was created inside Church B's tenant
    // When — Church A's admin fetches it by ID
    // Then — 404 Not Found; EBD service scopes queries by churchId
    await request(app.getHttpServer())
      .get(`/ebd/classes/${churchBEbdClassId}`)
      .set('Authorization', `Bearer ${tokenA}`)
      .expect(404);
  });

  it('should return 404 when deleting an EBD class from another church', async () => {
    // Given — churchBEbdClassId belongs to Church B
    // When — Church A's admin tries to delete it
    // Then — 404 Not Found
    await request(app.getHttpServer())
      .delete(`/ebd/classes/${churchBEbdClassId}`)
      .set('Authorization', `Bearer ${tokenA}`)
      .expect(404);
  });

  // ── MemberProfile IDOR ─────────────────────────────────────────────────
  // MemberProfile is a separate entity from Membership — these three
  // tests close the gap left by the membership IDOR tests above.

  it('should return 404 when getting a MemberProfile from another church', async () => {
    // Given — churchBMemberProfileId lives in Church B's tenant
    // When — Church A's admin fetches it by ID
    // Then — 404 Not Found; PrismaService.forTenant scopes by churchId
    await request(app.getHttpServer())
      .get(`/member-profiles/${churchBMemberProfileId}`)
      .set('Authorization', `Bearer ${tokenA}`)
      .expect(404);
  });

  it('should return 404 when patching a MemberProfile from another church', async () => {
    // Given — churchBMemberProfileId belongs to Church B
    // When — Church A's admin sends a PATCH trying to overwrite it
    // Then — 404 Not Found; the tenant filter prevents the update
    await request(app.getHttpServer())
      .patch(`/member-profiles/${churchBMemberProfileId}`)
      .set('Authorization', `Bearer ${tokenA}`)
      .send({ photoUrl: 'https://evil.com/stolen.jpg' })
      .expect(404);
  });

  it('should return 404 when deleting a MemberProfile from another church', async () => {
    // Given — churchBMemberProfileId belongs to Church B
    // When — Church A's admin tries to delete it
    // Then — 404 Not Found
    await request(app.getHttpServer())
      .delete(`/member-profiles/${churchBMemberProfileId}`)
      .set('Authorization', `Bearer ${tokenA}`)
      .expect(404);
  });

  // ── churchId injection in POST body ───────────────────────────────────
  // Threat model: an attacker uses a valid token for Church A but injects
  // "churchId": "<Church B's UUID>" in the JSON body, hoping the backend
  // creates the resource under Church B instead of Church A.
  //
  // Defence: controllers extract churchId exclusively from the JWT via
  // @CurrentUser(), never from the body. Additionally, none of the create
  // DTOs declare a `churchId` field, so ValidationPipe (forbidNonWhitelisted:
  // true) rejects the body with 400 before any service code runs.

  it('should return 400 when POST /branches body contains an injected churchId', async () => {
    // Given — only "name" is declared in CreateBranchDto; churchId is not
    // When — Church A's admin sends a valid name + injected churchId
    // Then — 400 Bad Request: property churchId should not exist
    await request(app.getHttpServer())
      .post('/branches')
      .set('Authorization', `Bearer ${tokenA}`)
      .send({ name: 'Filial Injetada', churchId: churchBId })
      .expect(400);
  });

  it('should return 400 when POST /memberships/with-user body contains an injected churchId', async () => {
    // Given — CreateMemberWithUserDto has no churchId field
    // When — attacker sends all required fields + injected churchId
    // Then — 400 Bad Request; ValidationPipe blocks the unknown property
    await request(app.getHttpServer())
      .post('/memberships/with-user')
      .set('Authorization', `Bearer ${tokenA}`)
      .send({
        name: 'Injection Attempt',
        email: 'injection-member@test.com',
        password: 'Str0ngPass!',
        branchId: churchBHqBranchId,
        birthDate: '1990-01-01',
        admissionDate: '2023-01-01',
        churchId: churchBId,
      })
      .expect(400);
  });

  it('should return 400 when POST /ebd/classes body contains an injected churchId', async () => {
    // Given — CreateEbdClassDto has no churchId field
    // When — attacker sends required EBD fields + injected churchId
    // Then — 400 Bad Request; ValidationPipe blocks the unknown property
    await request(app.getHttpServer())
      .post('/ebd/classes')
      .set('Authorization', `Bearer ${tokenA}`)
      .send({
        name: 'Turma Injetada',
        targetAudience: 'Adultos',
        branchId: churchBHqBranchId,
        studentIds: [],
        lessons: [],
        churchId: churchBId,
      })
      .expect(400);
  });
});
