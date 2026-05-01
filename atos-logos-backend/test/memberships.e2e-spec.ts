import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import type { App } from 'supertest/types';
import { startPostgresForE2E, StartedTestDb } from './helpers/postgres-container';

// JWT_SECRET must be in env BEFORE AppModule is imported — JwtModule
// reads it at module-load time.
process.env.JWT_SECRET = process.env.JWT_SECRET ?? 'e2e-test-secret-at-least-32-chars-long';

/**
 * Memberships + auth identity-fields e2e — pinpoints the contract for
 * the new identity columns (rg, sex, civilStatus, fatherName, motherName)
 * on User and consecrationDate on MemberProfile. Runs against a real
 * Postgres via testcontainers so enum/date validation behaves like prod.
 */
describe('Memberships + Auth identity fields (e2e)', () => {
  let db: StartedTestDb;
  let app: INestApplication<App>;
  let accessToken: string;
  let adminUserId: string;
  let hqBranchId: string;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let prisma: any;

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

    const signup = await request(app.getHttpServer())
      .post('/auth/signup-admin')
      .send({
        name: 'Admin Identity E2E',
        email: 'admin-identity-e2e@test.com',
        password: 'Str0ngPass!',
        churchName: 'Igreja Identity E2E',
      })
      .expect(201);

    accessToken = signup.body.access_token;

    const branches = await request(app.getHttpServer())
      .get('/branches')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200);
    hqBranchId = branches.body.find(
      (b: { isHeadquarters: boolean; id: string }) => b.isHeadquarters,
    ).id;

    const adminUser = await prisma.user.findUnique({
      where: { email: 'admin-identity-e2e@test.com' },
    });
    adminUserId = adminUser.id;
  }, 180_000);

  afterAll(async () => {
    await app?.close();
    await db?.stop();
  });

  // ------------------------------------------------------------------
  // POST /memberships/with-user
  // ------------------------------------------------------------------

  it('should persist all identity fields and consecrationDate when creating a member with full payload', async () => {
    // Given — a payload that exercises all 5 identity fields plus the
    // three @db.Date columns that gate MemberProfile creation.
    const payload = {
      name: 'Joao da Silva',
      password: 'Str0ngPass!',
      email: 'joao-full@test.com',
      branchId: hqBranchId,
      rg: 'MG-12.345.678',
      sex: 'MALE',
      civilStatus: 'MARRIED',
      fatherName: 'Pedro da Silva',
      motherName: 'Maria da Silva',
      birthDate: '1990-05-12',
      admissionDate: '2020-01-15',
      consecrationDate: '2022-08-20',
    };

    // When — the secretariat endpoint is called by an ADMIN
    const res = await request(app.getHttpServer())
      .post('/memberships/with-user')
      .set('Authorization', `Bearer ${accessToken}`)
      .send(payload)
      .expect(201);

    // Then — the response echoes the persisted identity fields and
    // the MemberProfile row carries consecrationDate as supplied.
    expect(res.body.user).toMatchObject({
      rg: 'MG-12.345.678',
      sex: 'MALE',
      civilStatus: 'MARRIED',
      fatherName: 'Pedro da Silva',
      motherName: 'Maria da Silva',
    });
    expect(res.body.user.password).toBeUndefined();
    expect(res.body.profile).not.toBeNull();
    expect(new Date(res.body.profile.consecrationDate).toISOString()).toBe(
      new Date('2022-08-20').toISOString(),
    );

    // And — Prisma confirms the User row matches what the API returned.
    const dbUser = await prisma.user.findUnique({
      where: { email: 'joao-full@test.com' },
    });
    expect(dbUser).toMatchObject({
      rg: 'MG-12.345.678',
      sex: 'MALE',
      civilStatus: 'MARRIED',
      fatherName: 'Pedro da Silva',
      motherName: 'Maria da Silva',
    });
  });

  it('should reject creation when sex is not a valid Sex enum value', async () => {
    // Given — a payload with an invalid Sex enum
    const payload = {
      name: 'Bad Sex',
      password: 'Str0ngPass!',
      email: 'bad-sex@test.com',
      branchId: hqBranchId,
      sex: 'INVALID',
    };

    // When/Then — class-validator returns 400 before touching the DB
    await request(app.getHttpServer())
      .post('/memberships/with-user')
      .set('Authorization', `Bearer ${accessToken}`)
      .send(payload)
      .expect(400);
  });

  it('should reject creation when civilStatus is not a valid CivilStatus enum value', async () => {
    // Given — civilStatus has a bogus value
    const payload = {
      name: 'Bad Civil',
      password: 'Str0ngPass!',
      email: 'bad-civil@test.com',
      branchId: hqBranchId,
      civilStatus: 'NOT_A_THING',
    };

    // When/Then — 400 from validation pipe
    await request(app.getHttpServer())
      .post('/memberships/with-user')
      .set('Authorization', `Bearer ${accessToken}`)
      .send(payload)
      .expect(400);
  });

  it('should reject creation when consecrationDate is not a valid ISO date string', async () => {
    // Given — consecrationDate is a free-form string, not ISO
    const payload = {
      name: 'Bad Date',
      password: 'Str0ngPass!',
      email: 'bad-date@test.com',
      branchId: hqBranchId,
      consecrationDate: 'not-a-date',
    };

    // When/Then — 400 from @IsDateString()
    await request(app.getHttpServer())
      .post('/memberships/with-user')
      .set('Authorization', `Bearer ${accessToken}`)
      .send(payload)
      .expect(400);
  });

  // ------------------------------------------------------------------
  // PATCH /memberships/by-user/:userId/user-data
  // ------------------------------------------------------------------

  it('should update only the supplied identity fields and leave other columns untouched', async () => {
    // Given — a member created with cpf + phone + name; the patch will
    // only carry the 5 identity fields. Other columns must survive.
    const created = await request(app.getHttpServer())
      .post('/memberships/with-user')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        name: 'Original Name',
        password: 'Str0ngPass!',
        email: 'patch-target@test.com',
        phone: '+5531999990000',
        cpf: '12345678901',
        branchId: hqBranchId,
      })
      .expect(201);
    const targetUserId = created.body.user.id as string;

    // When — secretariat patches just the identity columns
    await request(app.getHttpServer())
      .patch(`/memberships/by-user/${targetUserId}/user-data`)
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        rg: 'SP-99.000.111',
        sex: 'FEMALE',
        civilStatus: 'SINGLE',
        fatherName: 'Patched Father',
        motherName: 'Patched Mother',
      })
      .expect(200);

    // Then — Prisma confirms the 5 identity fields changed AND the
    // pre-existing name/email/phone/cpf columns are untouched.
    const after = await prisma.user.findUnique({ where: { id: targetUserId } });
    expect(after).toMatchObject({
      rg: 'SP-99.000.111',
      sex: 'FEMALE',
      civilStatus: 'SINGLE',
      fatherName: 'Patched Father',
      motherName: 'Patched Mother',
      name: 'Original Name',
      email: 'patch-target@test.com',
      // DTOs strip non-digit chars from phone (@Transform digitsOnly), so
      // '+5531999990000' is stored as '5531999990000'.
      phone: '5531999990000',
      cpf: '12345678901',
    });
  });

  // ------------------------------------------------------------------
  // GET /auth/me — shape includes the new fields (null for fresh admin)
  // ------------------------------------------------------------------

  it('should expose the new identity fields and consecrationDate on GET /auth/me even when null', async () => {
    // Given — the bootstrap admin who has not set any identity fields
    // When — they call /auth/me
    const res = await request(app.getHttpServer())
      .get('/auth/me')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200);

    // Then — the response shape carries the 5 identity keys (null) and
    // a profile slot (null is fine — admin signup does not create one).
    expect(res.body).toHaveProperty('user');
    expect(res.body.user).toHaveProperty('rg');
    expect(res.body.user).toHaveProperty('sex');
    expect(res.body.user).toHaveProperty('civilStatus');
    expect(res.body.user).toHaveProperty('fatherName');
    expect(res.body.user).toHaveProperty('motherName');
    expect(res.body.user.id).toBe(adminUserId);
    expect(res.body).toHaveProperty('profile');
    if (res.body.profile) {
      expect(res.body.profile).toHaveProperty('consecrationDate');
    }
  });

  // ------------------------------------------------------------------
  // PATCH /auth/me round-trip
  // ------------------------------------------------------------------

  it('should persist identity fields via PATCH /auth/me and surface them on the next GET /auth/me', async () => {
    // Given — the admin patches their own identity fields
    await request(app.getHttpServer())
      .patch('/auth/me')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        rg: 'RJ-77.111.222',
        sex: 'MALE',
        civilStatus: 'STABLE_UNION',
        fatherName: 'Admin Father',
        motherName: 'Admin Mother',
      })
      .expect(200);

    // When — they read /auth/me again
    const me = await request(app.getHttpServer())
      .get('/auth/me')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200);

    // Then — all 5 identity fields are present and equal to what we sent
    expect(me.body.user).toMatchObject({
      rg: 'RJ-77.111.222',
      sex: 'MALE',
      civilStatus: 'STABLE_UNION',
      fatherName: 'Admin Father',
      motherName: 'Admin Mother',
    });
  });

  // ------------------------------------------------------------------
  // PATCH /member-profiles/:profileId — edit-member date fields
  // (regression: dates were silently dropped from the mobile edit form)
  // ------------------------------------------------------------------

  it('should persist every date field when PATCH /member-profiles/:id is called with the full ecclesiastical payload', async () => {
    // Given — a member with an existing MemberProfile (full onboarding).
    const created = await request(app.getHttpServer())
      .post('/memberships/with-user')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        name: 'Date Edit Target',
        password: 'Str0ngPass!',
        email: 'date-edit@test.com',
        branchId: hqBranchId,
        birthDate: '1990-05-12',
        admissionDate: '2020-01-15',
        baptismDate: '2010-03-20',
        consecrationDate: '2022-08-20',
      })
      .expect(201);
    const profileId = created.body.profile.id as string;

    // When — the secretary edits every date field
    await request(app.getHttpServer())
      .patch(`/member-profiles/${profileId}`)
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        birthDate: '1991-06-13',
        baptismDate: '2011-04-21',
        admissionDate: '2021-02-16',
        consecrationDate: '2023-09-21',
      })
      .expect(200);

    // Then — Prisma shows every date updated to the new value.
    const after = await prisma.memberProfile.findUnique({
      where: { id: profileId },
    });
    expect(new Date(after.birthDate).toISOString()).toBe(
      new Date('1991-06-13').toISOString(),
    );
    expect(new Date(after.baptismDate).toISOString()).toBe(
      new Date('2011-04-21').toISOString(),
    );
    expect(new Date(after.admissionDate).toISOString()).toBe(
      new Date('2021-02-16').toISOString(),
    );
    expect(new Date(after.consecrationDate).toISOString()).toBe(
      new Date('2023-09-21').toISOString(),
    );
  });

  it('should leave unchanged date columns intact when PATCH /member-profiles/:id carries a partial payload (edit-only-one-date round-trip)', async () => {
    // Given — a member whose profile has birth + admission + baptism set.
    const created = await request(app.getHttpServer())
      .post('/memberships/with-user')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        name: 'Partial Edit Target',
        password: 'Str0ngPass!',
        email: 'partial-edit@test.com',
        branchId: hqBranchId,
        birthDate: '1985-02-02',
        admissionDate: '2015-11-30',
        baptismDate: '1995-07-07',
      })
      .expect(201);
    const profileId = created.body.profile.id as string;

    // When — only baptismDate is patched
    await request(app.getHttpServer())
      .patch(`/member-profiles/${profileId}`)
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ baptismDate: '2000-01-01' })
      .expect(200);

    // Then — the other date columns survive untouched
    const after = await prisma.memberProfile.findUnique({
      where: { id: profileId },
    });
    expect(new Date(after.baptismDate).toISOString()).toBe(
      new Date('2000-01-01').toISOString(),
    );
    expect(new Date(after.birthDate).toISOString()).toBe(
      new Date('1985-02-02').toISOString(),
    );
    expect(new Date(after.admissionDate).toISOString()).toBe(
      new Date('2015-11-30').toISOString(),
    );
  });

  it('should reject PATCH /member-profiles/:id when a date is not a valid ISO string', async () => {
    // Given — any existing profile
    const created = await request(app.getHttpServer())
      .post('/memberships/with-user')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        name: 'Bad Date Target',
        password: 'Str0ngPass!',
        email: 'bad-date-patch@test.com',
        branchId: hqBranchId,
        birthDate: '1990-01-01',
        admissionDate: '2020-01-01',
      })
      .expect(201);
    const profileId = created.body.profile.id as string;

    // When/Then — the validation pipe rejects garbage dates
    await request(app.getHttpServer())
      .patch(`/member-profiles/${profileId}`)
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ birthDate: 'not-a-date' })
      .expect(400);
  });
});
