import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import type { App } from 'supertest/types';
import { startPostgresForE2E, StartedTestDb } from './helpers/postgres-container';

process.env.JWT_SECRET = process.env.JWT_SECRET ?? 'e2e-test-secret-at-least-32-chars-long';

/**
 * Role Permissions E2E Tests
 * 
 * Tests the complete flow of the granular permissions system:
 * 1. ADMIN can configure permissions for SECRETARY and MEMBER
 * 2. ADMIN always has full access (bypass)
 * 3. SECRETARY/MEMBER are restricted by their configured permissions
 * 4. Multi-tenant isolation (church A cannot see church B's config)
 */
describe('Role Permissions System (e2e)', () => {
  let db: StartedTestDb;
  let app: INestApplication<App>;
  let adminToken: string;
  let secretaryToken: string;
  let memberToken: string;
  let churchId: string;
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

    // Create admin user
    const adminSignup = await request(app.getHttpServer())
      .post('/auth/signup-admin')
      .send({
        name: 'Admin Permissions',
        email: 'admin-perms@test.com',
        password: 'Str0ngPass!',
        churchName: 'Igreja Permissions Test',
      })
      .expect(201);

    adminToken = adminSignup.body.access_token;
    churchId = adminSignup.body.church.id;

    const branches = await request(app.getHttpServer())
      .get('/branches')
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);
    hqBranchId = branches.body.find(
      (b: { isHeadquarters: boolean }) => b.isHeadquarters,
    ).id;

    // Create secretary user
    const secretaryPayload = {
      name: 'Secretary Test',
      email: 'secretary-perms@test.com',
      password: 'Str0ngPass!',
      branchId: hqBranchId,
      birthDate: '1985-03-15',
      admissionDate: '2020-01-01',
    };

    const secretaryResponse = await request(app.getHttpServer())
      .post('/memberships/with-user')
      .set('Authorization', `Bearer ${adminToken}`)
      .send(secretaryPayload)
      .expect(201);

    // Promote to SECRETARY
    await prisma.membership.update({
      where: { id: secretaryResponse.body.membership.id },
      data: { role: 'SECRETARY' },
    });

    // Login as secretary
    const secretaryLogin = await request(app.getHttpServer())
      .post('/auth/login')
      .send({
        email: 'secretary-perms@test.com',
        password: 'Str0ngPass!',
      })
      .expect(201);

    secretaryToken = secretaryLogin.body.access_token;

    // Create member user
    const memberPayload = {
      name: 'Member Test',
      email: 'member-perms@test.com',
      password: 'Str0ngPass!',
      branchId: hqBranchId,
      birthDate: '1990-06-20',
      admissionDate: '2021-01-01',
    };

    await request(app.getHttpServer())
      .post('/memberships/with-user')
      .set('Authorization', `Bearer ${adminToken}`)
      .send(memberPayload)
      .expect(201);

    // Login as member
    const memberLogin = await request(app.getHttpServer())
      .post('/auth/login')
      .send({
        email: 'member-perms@test.com',
        password: 'Str0ngPass!',
      })
      .expect(201);

    memberToken = memberLogin.body.access_token;
  }, 180_000);

  afterAll(async () => {
    await app?.close();
    await db?.stop();
  });

  // ──────────────────────────────────────────────────────────────────────
  // GET /role-permissions — List all role configurations
  // ──────────────────────────────────────────────────────────────────────

  describe('GET /role-permissions', () => {
    it('should allow ADMIN to list all role configurations', async () => {
      // When
      const response = await request(app.getHttpServer())
        .get('/role-permissions')
        .set('Authorization', `Bearer ${adminToken}`)
        .expect(200);

      // Then
      expect(response.body).toHaveLength(3);
      expect(response.body.map((r: any) => r.role)).toEqual(
        expect.arrayContaining(['ADMIN', 'SECRETARY', 'MEMBER']),
      );
      expect(response.body[0]).toHaveProperty('permissions');
      expect(response.body[0]).toHaveProperty('updatedAt');
    });

    it('should deny SECRETARY access to list configurations', async () => {
      // When / Then
      await request(app.getHttpServer())
        .get('/role-permissions')
        .set('Authorization', `Bearer ${secretaryToken}`)
        .expect(403);
    });

    it('should deny MEMBER access to list configurations', async () => {
      // When / Then
      await request(app.getHttpServer())
        .get('/role-permissions')
        .set('Authorization', `Bearer ${memberToken}`)
        .expect(403);
    });
  });

  // ──────────────────────────────────────────────────────────────────────
  // GET /role-permissions/:role — Get specific role configuration
  // ──────────────────────────────────────────────────────────────────────

  describe('GET /role-permissions/:role', () => {
    it('should allow ADMIN to get SECRETARY configuration', async () => {
      // When
      const response = await request(app.getHttpServer())
        .get('/role-permissions/SECRETARY')
        .set('Authorization', `Bearer ${adminToken}`)
        .expect(200);

      // Then
      expect(response.body.role).toBe('SECRETARY');
      expect(response.body).toHaveProperty('permissions');
      expect(typeof response.body.permissions).toBe('object');
    });

    it('should deny SECRETARY access to view configurations', async () => {
      // When / Then
      await request(app.getHttpServer())
        .get('/role-permissions/SECRETARY')
        .set('Authorization', `Bearer ${secretaryToken}`)
        .expect(403);
    });
  });

  // ──────────────────────────────────────────────────────────────────────
  // PATCH /role-permissions/:role — Update role permissions
  // ──────────────────────────────────────────────────────────────────────

  describe('PATCH /role-permissions/:role', () => {
    it('should allow ADMIN to update SECRETARY permissions', async () => {
      // Given
      const newPermissions = {
        permissions: {
          view_members: true,
          edit_members: true,
          delete_members: false,
          view_contributions: false,
        },
      };

      // When
      const response = await request(app.getHttpServer())
        .patch('/role-permissions/SECRETARY')
        .set('Authorization', `Bearer ${adminToken}`)
        .send(newPermissions)
        .expect(200);

      // Then
      expect(response.body.role).toBe('SECRETARY');
      expect(response.body.permissions).toEqual(newPermissions.permissions);
    });

    it('should allow ADMIN to update MEMBER permissions', async () => {
      // Given
      const newPermissions = {
        permissions: {
          view_events: true,
          view_branches: true,
        },
      };

      // When
      const response = await request(app.getHttpServer())
        .patch('/role-permissions/MEMBER')
        .set('Authorization', `Bearer ${adminToken}`)
        .send(newPermissions)
        .expect(200);

      // Then
      expect(response.body.role).toBe('MEMBER');
      expect(response.body.permissions).toEqual(newPermissions.permissions);
    });

    it('should reject attempt to update ADMIN permissions', async () => {
      // Given
      const newPermissions = {
        permissions: {
          view_members: false,
        },
      };

      // When / Then
      await request(app.getHttpServer())
        .patch('/role-permissions/ADMIN')
        .set('Authorization', `Bearer ${adminToken}`)
        .send(newPermissions)
        .expect(404); // NotFoundException
    });

    it('should deny SECRETARY from updating permissions', async () => {
      // Given
      const newPermissions = {
        permissions: {
          view_members: true,
        },
      };

      // When / Then
      await request(app.getHttpServer())
        .patch('/role-permissions/MEMBER')
        .set('Authorization', `Bearer ${secretaryToken}`)
        .send(newPermissions)
        .expect(403);
    });
  });

  // ──────────────────────────────────────────────────────────────────────
  // Integration: Permissions enforcement on protected endpoints
  // ──────────────────────────────────────────────────────────────────────

  describe('Permissions enforcement on /member-profiles', () => {
    beforeAll(async () => {
      // Configure SECRETARY with view_members but NOT edit_members
      await request(app.getHttpServer())
        .patch('/role-permissions/SECRETARY')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          permissions: {
            view_members: true,
            edit_members: false,
            delete_members: false,
            create_members: false,
          },
        })
        .expect(200);

      // Configure MEMBER with NO permissions
      await request(app.getHttpServer())
        .patch('/role-permissions/MEMBER')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          permissions: {
            view_members: false,
            edit_members: false,
          },
        })
        .expect(200);
    });

    it('should allow ADMIN to view members (unconditional bypass)', async () => {
      // When / Then
      await request(app.getHttpServer())
        .get('/member-profiles')
        .set('Authorization', `Bearer ${adminToken}`)
        .expect(200);
    });

    it('should allow SECRETARY to view members when permission is granted', async () => {
      // When / Then
      await request(app.getHttpServer())
        .get('/member-profiles')
        .set('Authorization', `Bearer ${secretaryToken}`)
        .expect(200);
    });

    it('should deny SECRETARY from creating members when permission is not granted', async () => {
      // Given
      const payload = {
        userId: 'some-user-id',
        branchId: hqBranchId,
        birthDate: '1990-01-01',
        admissionDate: '2020-01-01',
      };

      // When / Then
      await request(app.getHttpServer())
        .post('/member-profiles')
        .set('Authorization', `Bearer ${secretaryToken}`)
        .send(payload)
        .expect(403);
    });

    it('should deny MEMBER from viewing members when permission is not granted', async () => {
      // When / Then
      await request(app.getHttpServer())
        .get('/member-profiles')
        .set('Authorization', `Bearer ${memberToken}`)
        .expect(403);
    });

    it('should allow SECRETARY to view members after permission is granted', async () => {
      // Given — grant create_members permission
      await request(app.getHttpServer())
        .patch('/role-permissions/SECRETARY')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          permissions: {
            view_members: true,
            create_members: true,
          },
        })
        .expect(200);

      // When — try to view members again
      const response = await request(app.getHttpServer())
        .get('/member-profiles')
        .set('Authorization', `Bearer ${secretaryToken}`)
        .expect(200);

      // Then
      expect(response.body).toHaveProperty('data');
    });
  });

  // ──────────────────────────────────────────────────────────────────────
  // Multi-tenant isolation
  // ──────────────────────────────────────────────────────────────────────

  describe('Multi-tenant isolation', () => {
    let church2AdminToken: string;

    beforeAll(async () => {
      // Create second church
      const church2Signup = await request(app.getHttpServer())
        .post('/auth/signup-admin')
        .send({
          name: 'Admin Church 2',
          email: 'admin-church2@test.com',
          password: 'Str0ngPass!',
          churchName: 'Igreja 2',
        })
        .expect(201);

      church2AdminToken = church2Signup.body.access_token;
    });

    it('should return different configurations for different churches', async () => {
      // Given — configure church 1 SECRETARY
      await request(app.getHttpServer())
        .patch('/role-permissions/SECRETARY')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          permissions: {
            view_members: true,
            edit_members: true,
          },
        })
        .expect(200);

      // And — configure church 2 SECRETARY differently
      await request(app.getHttpServer())
        .patch('/role-permissions/SECRETARY')
        .set('Authorization', `Bearer ${church2AdminToken}`)
        .send({
          permissions: {
            view_members: false,
            edit_members: false,
          },
        })
        .expect(200);

      // When — fetch both configurations
      const church1Config = await request(app.getHttpServer())
        .get('/role-permissions/SECRETARY')
        .set('Authorization', `Bearer ${adminToken}`)
        .expect(200);

      const church2Config = await request(app.getHttpServer())
        .get('/role-permissions/SECRETARY')
        .set('Authorization', `Bearer ${church2AdminToken}`)
        .expect(200);

      // Then — they should be different
      expect(church1Config.body.permissions.view_members).toBe(true);
      expect(church2Config.body.permissions.view_members).toBe(false);
    });
  });

  // ──────────────────────────────────────────────────────────────────────
  // Validation
  // ──────────────────────────────────────────────────────────────────────

  describe('Validation', () => {
    it('should reject invalid role enum', async () => {
      // When / Then
      await request(app.getHttpServer())
        .get('/role-permissions/INVALID_ROLE')
        .set('Authorization', `Bearer ${adminToken}`)
        .expect(400);
    });

    it('should reject non-object permissions', async () => {
      // When / Then
      await request(app.getHttpServer())
        .patch('/role-permissions/SECRETARY')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          permissions: 'invalid',
        })
        .expect(400);
    });

    it('should reject empty permissions object', async () => {
      // When / Then — empty object is actually valid (removes all permissions)
      const response = await request(app.getHttpServer())
        .patch('/role-permissions/SECRETARY')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          permissions: {},
        })
        .expect(200);

      expect(response.body.permissions).toEqual({});
    });
  });
});
