import { ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Role } from '@prisma/client';
import { RolesGuard } from './roles.guard';
import { ROLES_KEY } from '../decorators/roles.decorator';
import type { AuthenticatedUser } from '../interfaces/authenticated-user.interface';

describe('RolesGuard', () => {
  let guard: RolesGuard;
  let reflector: jest.Mocked<Reflector>;

  beforeEach(() => {
    reflector = { getAllAndOverride: jest.fn() } as any;
    guard = new RolesGuard(reflector);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  const mockContext = (role: Role): ExecutionContext =>
    ({
      switchToHttp: () => ({
        getRequest: () => ({ user: { role } as AuthenticatedUser }),
      }),
      getHandler: jest.fn(),
      getClass: jest.fn(),
    }) as any;

  // ── No decorator ──────────────────────────────────────────────────────

  it('should grant access when no @Roles decorator is present on the handler', () => {
    // Given — reflector finds no ROLES_KEY metadata (open endpoint within auth)
    reflector.getAllAndOverride.mockReturnValue(undefined);
    const ctx = mockContext(Role.MEMBER);

    // When
    const result = guard.canActivate(ctx);

    // Then — guard returns true; auth is enforced by JwtAuthGuard upstream
    expect(result).toBe(true);
    expect(reflector.getAllAndOverride).toHaveBeenCalledWith(ROLES_KEY, [
      ctx.getHandler(),
      ctx.getClass(),
    ]);
  });

  it('should grant access when @Roles is present but the list is empty', () => {
    // Given — decorator exists but no roles listed (degenerate case)
    reflector.getAllAndOverride.mockReturnValue([]);
    const ctx = mockContext(Role.MEMBER);

    // When / Then
    expect(guard.canActivate(ctx)).toBe(true);
  });

  // ── Role match ────────────────────────────────────────────────────────

  it('should grant access when the user role exactly matches the single required role', () => {
    // Given — only ADMINs allowed
    reflector.getAllAndOverride.mockReturnValue([Role.ADMIN]);
    const ctx = mockContext(Role.ADMIN);

    // When / Then
    expect(guard.canActivate(ctx)).toBe(true);
  });

  it('should grant access when the user role is one of multiple required roles', () => {
    // Given — ADMIN or SECRETARY allowed; user is SECRETARY
    reflector.getAllAndOverride.mockReturnValue([Role.ADMIN, Role.SECRETARY]);
    const ctx = mockContext(Role.SECRETARY);

    // When / Then
    expect(guard.canActivate(ctx)).toBe(true);
  });

  // ── Role mismatch ─────────────────────────────────────────────────────

  it('should deny access when the user role does not match the single required role', () => {
    // Given — only ADMIN allowed; user is MEMBER
    reflector.getAllAndOverride.mockReturnValue([Role.ADMIN]);
    const ctx = mockContext(Role.MEMBER);

    // When / Then — RolesGuard returns false; NestJS translates to 403
    expect(guard.canActivate(ctx)).toBe(false);
  });

  it('should deny access when user is MEMBER but only ADMIN and SECRETARY are allowed', () => {
    // Given — secretariat-only endpoint; user is a regular MEMBER
    reflector.getAllAndOverride.mockReturnValue([Role.ADMIN, Role.SECRETARY]);
    const ctx = mockContext(Role.MEMBER);

    // When / Then
    expect(guard.canActivate(ctx)).toBe(false);
  });

  it('should deny access when user is SECRETARY but only ADMIN is allowed', () => {
    // Given — admin-only operation (e.g., promote-to-headquarters)
    reflector.getAllAndOverride.mockReturnValue([Role.ADMIN]);
    const ctx = mockContext(Role.SECRETARY);

    // When / Then
    expect(guard.canActivate(ctx)).toBe(false);
  });
});
