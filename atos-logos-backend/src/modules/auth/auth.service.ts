import {
  Injectable,
  UnauthorizedException,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Role } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.service';
import { SignupAdminDto } from './dto/signup-admin.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { JwtPayload, SelectionTokenPayload } from '../../common/interfaces/jwt-payload.interface';
import * as bcrypt from 'bcrypt';
import * as crypto from 'crypto';

/** Opaque refresh token TTL. Balanced: long enough for "stay logged in" UX,
 *  short enough that a leaked token eventually auto-invalidates. */
const REFRESH_TOKEN_TTL_DAYS = 30;

/**
 * Normalizes an email for storage and lookup. Trims whitespace and lowercases
 * the entire address so that "Admin@Church.com" and "admin@church.com" are
 * treated as the same account. Applied both on signup and login.
 */
function normalizeEmail(email: string): string {
  return email.trim().toLowerCase();
}

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  /**
   * Creates a new church (headquarters) with an admin user, then auto-issues
   * a JWT access token + opaque refresh token so the freshly-created admin
   * is logged in immediately. All entities are created in a single
   * transaction; phone is intentionally NOT accepted here — admins set it
   * later via the profile-edit endpoint.
   */
  async signupAdmin(dto: SignupAdminDto) {
    const email = normalizeEmail(dto.email);

    const existingEmail = await this.prisma.user.findUnique({
      where: { email },
    });
    if (existingEmail) {
      throw new BadRequestException('A user with this email already exists');
    }

    const hashedPassword = await bcrypt.hash(dto.password, 10);

    const result = await this.prisma.$transaction(async (tx) => {
      const church = await tx.church.create({
        data: { name: dto.churchName },
      });

      const branch = await tx.branch.create({
        data: {
          churchId: church.id,
          name: dto.churchName,
          isHeadquarters: true,
        },
      });

      const user = await tx.user.create({
        data: {
          name: dto.name,
          email,
          password: hashedPassword,
        },
      });

      const membership = await tx.membership.create({
        data: {
          userId: user.id,
          churchId: church.id,
          branchId: branch.id,
          role: 'ADMIN',
          status: 'ACTIVE',
        },
      });

      return { church, branch, user, membership };
    });

    // Auto-login: issue the same token pair we'd hand out on /auth/login
    // so the mobile app can drop the user straight into /home.
    const tokens = await this.issueTokenPair(
      result.user.id,
      result.user.email!,
      result.church.id,
      result.branch.id,
      'ADMIN',
    );

    // Return user without password.
    const { password: _, ...userWithoutPassword } = result.user;
    return {
      user: userWithoutPassword,
      church: result.church,
      branch: result.branch,
      ...tokens,
    };
  }

  /**
   * Two-phase login flow:
   * - If user has 1 active membership: returns access_token immediately.
   * - If user has N active memberships: returns a selectionToken + church list.
   */
  async login(rawEmail: string, password: string) {
    const email = normalizeEmail(rawEmail);

    const user = await this.prisma.user.findUnique({
      where: { email },
    });
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const memberships = await this.prisma.membership.findMany({
      where: { userId: user.id, status: 'ACTIVE' },
      include: { church: true, branch: true },
    });

    if (memberships.length === 0) {
      // Use the same message as invalid credentials to avoid leaking
      // whether the account exists to unauthenticated callers.
      throw new UnauthorizedException('Invalid credentials');
    }

    // Single membership — issue token pair immediately
    if (memberships.length === 1) {
      const m = memberships[0];
      return this.issueTokenPair(
        user.id,
        user.email!,
        m.churchId,
        m.branchId,
        m.role as Role,
      );
    }

    // Multiple memberships — require church selection
    const selectionPayload: SelectionTokenPayload = {
      sub: user.id,
      email: user.email!,
      type: 'church_selection',
    };

    return {
      requiresChurchSelection: true,
      selectionToken: await this.jwtService.signAsync(selectionPayload, {
        expiresIn: '2m',
      }),
      churches: memberships.map((m) => ({
        id: m.church.id,
        name: m.church.name,
        branchName: m.branch.name,
        role: m.role,
      })),
    };
  }

  /**
   * Second step of multi-church login: validates the selectionToken
   * and issues a full scoped JWT for the selected church.
   */
  async selectChurch(selectionToken: string, churchId: string) {
    let payload: SelectionTokenPayload;
    try {
      payload = await this.jwtService.verifyAsync<SelectionTokenPayload>(selectionToken);
    } catch {
      throw new UnauthorizedException('Invalid or expired selection token');
    }

    if (payload.type !== 'church_selection') {
      throw new UnauthorizedException('Invalid token type');
    }

    const membership = await this.prisma.membership.findFirst({
      where: {
        userId: payload.sub,
        churchId,
        status: 'ACTIVE',
      },
    });

    if (!membership) {
      throw new UnauthorizedException('No active membership for this church');
    }

    return this.issueTokenPair(
      payload.sub,
      payload.email,
      membership.churchId,
      membership.branchId,
      membership.role as Role,
    );
  }

  /**
   * Rotates a refresh token: validates it, revokes the presented row, and
   * issues a brand-new access+refresh pair. Detects token reuse (presenting
   * an already-revoked token) and revokes every active session for the user
   * as a defensive measure.
   */
  async refresh(rawToken: string) {
    const tokenHash = this.hashRefreshToken(rawToken);
    const row = await this.prisma.refreshToken.findUnique({
      where: { tokenHash },
      include: { user: true },
    });

    if (!row) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    // Reuse detection: a revoked token resurfacing is a compromise signal.
    if (row.revokedAt) {
      await this.prisma.refreshToken.updateMany({
        where: { userId: row.userId, revokedAt: null },
        data: { revokedAt: new Date() },
      });
      throw new UnauthorizedException(
        'Refresh token reuse detected. All sessions revoked.',
      );
    }

    if (row.expiresAt.getTime() <= Date.now()) {
      throw new UnauthorizedException('Refresh token expired');
    }

    // Inline the issuance so we can capture the new row's id for the
    // rotation trail without needing an extra lookup.
    const newRefreshToken = crypto.randomBytes(48).toString('base64url');
    const newTokenHash = this.hashRefreshToken(newRefreshToken);
    const newExpiresAt = new Date();
    newExpiresAt.setDate(newExpiresAt.getDate() + REFRESH_TOKEN_TTL_DAYS);

    const newRow = await this.prisma.refreshToken.create({
      data: {
        tokenHash: newTokenHash,
        userId: row.userId,
        churchId: row.churchId,
        branchId: row.branchId,
        role: row.role,
        expiresAt: newExpiresAt,
      },
    });

    const accessToken = await this.issueToken(
      row.userId,
      row.user.email!,
      row.churchId,
      row.branchId,
      row.role,
    );

    // Mark the old row as revoked and link to its successor for auditability.
    await this.prisma.refreshToken.update({
      where: { id: row.id },
      data: {
        revokedAt: new Date(),
        replacedById: newRow.id,
      },
    });

    return { access_token: accessToken, refresh_token: newRefreshToken };
  }

  /**
   * Revokes the presented refresh token (e.g., on explicit logout from a
   * single device). Safe no-op if the token is unknown or already revoked.
   */
  async logoutRefresh(rawToken: string): Promise<void> {
    const tokenHash = this.hashRefreshToken(rawToken);
    await this.prisma.refreshToken.updateMany({
      where: { tokenHash, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  }

  /**
   * Returns the full profile of the authenticated user,
   * including membership, positions, church and branch info.
   */
  async getProfile(userId: string, churchId: string) {
    const membership = await this.prisma.membership.findFirst({
      where: { userId, churchId },
      include: {
        branch: { select: { id: true, name: true } },
        church: { select: { id: true, name: true } },
        user: {
          select: {
            id: true, name: true, email: true, phone: true, cpf: true, rg: true, sex: true, civilStatus: true, fatherName: true, motherName: true, country: true, state: true, city: true, neighborhood: true, street: true, number: true, complement: true,
            memberProfiles: {
              where: { churchId },
              select: {
                photoUrl: true,
                admissionDate: true,
                birthDate: true,
                baptismDate: true,
                consecrationDate: true,
                registrationNumber: true,
              },
              take: 1,
            },
            positions: {
              include: { position: { select: { id: true, name: true } } },
            },
          },
        },
      },
    });

    if (!membership) {
      throw new NotFoundException('Membership not found');
    }

    const profile = membership.user.memberProfiles[0] ?? null;
    const positions = membership.user.positions.map((p) => p.position);

    return {
      user: {
        id: membership.user.id,
        name: membership.user.name,
        email: membership.user.email,
        phone: membership.user.phone,
        cpf: membership.user.cpf,
        rg: membership.user.rg,
        sex: membership.user.sex,
        civilStatus: membership.user.civilStatus,
        fatherName: membership.user.fatherName,
        motherName: membership.user.motherName,
        country: membership.user.country,
        state: membership.user.state,
        city: membership.user.city,
        neighborhood: membership.user.neighborhood,
        street: membership.user.street,
        number: membership.user.number,
        complement: membership.user.complement,
      },
      profile,
      membership: { role: membership.role, status: membership.status },
      positions,
      church: membership.church,
      branch: membership.branch,
    };
  }

  async updateProfile(userId: string, dto: UpdateProfileDto) {
    // Convert empty strings to null so they don't overwrite existing data
    const cleaned = Object.fromEntries(
      Object.entries(dto).map(([k, v]) => [k, v === '' ? null : v]),
    );
    const user = await this.prisma.user.update({
      where: { id: userId },
      data: cleaned,
    });
    const { password: _, ...userWithoutPassword } = user;
    return userWithoutPassword;
  }

  private async issueToken(
    userId: string,
    email: string,
    churchId: string,
    branchId: string,
    role: string,
  ): Promise<string> {
    const payload: JwtPayload = {
      sub: userId,
      email,
      churchId,
      branchId,
      role: role as JwtPayload['role'],
    };
    return this.jwtService.signAsync(payload);
  }

  /**
   * Issues a freshly-signed access token AND a persisted opaque refresh token.
   * The refresh token is stored only as a SHA-256 hash — the plaintext never
   * hits the database.
   */
  private async issueTokenPair(
    userId: string,
    email: string,
    churchId: string,
    branchId: string,
    role: Role,
  ): Promise<{ access_token: string; refresh_token: string }> {
    const accessToken = await this.issueToken(
      userId,
      email,
      churchId,
      branchId,
      role,
    );

    const refreshToken = crypto.randomBytes(48).toString('base64url');
    const tokenHash = this.hashRefreshToken(refreshToken);

    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + REFRESH_TOKEN_TTL_DAYS);

    await this.prisma.refreshToken.create({
      data: {
        tokenHash,
        userId,
        churchId,
        branchId,
        role,
        expiresAt,
      },
    });

    return { access_token: accessToken, refresh_token: refreshToken };
  }

  /** Deterministic SHA-256 hash used for storing / looking up refresh tokens. */
  private hashRefreshToken(rawToken: string): string {
    return crypto.createHash('sha256').update(rawToken).digest('hex');
  }
}
