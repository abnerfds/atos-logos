import { ExtractJwt, Strategy } from 'passport-jwt';
import { PassportStrategy } from '@nestjs/passport';
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtPayload, SelectionTokenPayload } from '../../common/interfaces/jwt-payload.interface';
import { AuthenticatedUser } from '../../common/interfaces/authenticated-user.interface';
import { getJwtSecret } from '../../common/config/env.config';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor() {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: getJwtSecret(),
    });
  }

  /** Maps JWT payload to the AuthenticatedUser shape injected into req.user. */
  async validate(payload: JwtPayload | SelectionTokenPayload): Promise<AuthenticatedUser> {
    // Selection tokens are single-use exchange tokens for the multi-church
    // login flow. They must never be accepted as Bearer tokens on resource
    // endpoints — only POST /auth/select-church consumes them explicitly.
    if ((payload as SelectionTokenPayload).type === 'church_selection') {
      throw new UnauthorizedException('Selection tokens cannot be used as access tokens');
    }

    const p = payload as JwtPayload;
    return {
      userId: p.sub,
      email: p.email,
      churchId: p.churchId,
      branchId: p.branchId,
      role: p.role,
    };
  }
}
