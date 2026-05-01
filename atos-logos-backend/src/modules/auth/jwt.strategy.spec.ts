import { UnauthorizedException } from '@nestjs/common';
import { JwtStrategy } from './jwt.strategy';
import { JwtPayload, SelectionTokenPayload } from '../../common/interfaces/jwt-payload.interface';

describe('JwtStrategy', () => {
  const originalEnv = process.env;

  beforeEach(() => {
    process.env = { ...originalEnv };
    // A valid secret so the `getJwtSecret()` gate in the constructor passes.
    process.env.JWT_SECRET = 'a-strong-test-secret-that-is-long-enough-1234';
  });

  afterAll(() => {
    process.env = originalEnv;
  });

  describe('constructor', () => {
    it('should construct successfully when JWT_SECRET is set to a valid value', () => {
      // Given — JWT_SECRET is a strong value (see beforeEach)
      // When / Then — the constructor must not throw
      expect(() => new JwtStrategy()).not.toThrow();
    });

    it('should throw during construction when JWT_SECRET is missing from the environment', () => {
      // Given — JWT_SECRET is absent
      delete process.env.JWT_SECRET;

      // When / Then — constructing the strategy fails fast
      expect(() => new JwtStrategy()).toThrow(/JWT_SECRET.*not set/);
    });
  });

  describe('validate', () => {
    it('should map a JWT payload to the AuthenticatedUser shape when the strategy validates a token', async () => {
      // Given — a strategy and a valid JWT payload
      const strategy = new JwtStrategy();
      const payload: JwtPayload = {
        sub: 'user-uuid',
        email: 'admin@church.com',
        churchId: 'church-uuid',
        branchId: 'branch-uuid',
        role: 'ADMIN',
      };

      // When — validate is called by the passport pipeline
      const result = await strategy.validate(payload);

      // Then — the returned shape is the AuthenticatedUser injected into req.user
      expect(result).toEqual({
        userId: 'user-uuid',
        email: 'admin@church.com',
        churchId: 'church-uuid',
        branchId: 'branch-uuid',
        role: 'ADMIN',
      });
    });

    it('should throw UnauthorizedException when the payload belongs to a selection token', async () => {
      // Given — a selectionToken payload (type: 'church_selection')
      //         This token is issued by POST /auth/login for multi-church users
      //         and must ONLY be consumed by POST /auth/select-church.
      const strategy = new JwtStrategy();
      const selectionPayload: SelectionTokenPayload = {
        sub: 'user-uuid',
        email: 'multi@church.com',
        type: 'church_selection',
      };

      // When — the passport pipeline calls validate() with this payload
      // Then — UnauthorizedException is thrown, blocking access to any endpoint
      await expect(strategy.validate(selectionPayload)).rejects.toThrow(
        UnauthorizedException,
      );
    });
  });
});
