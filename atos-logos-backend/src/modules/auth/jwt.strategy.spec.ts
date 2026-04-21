import { JwtStrategy } from './jwt.strategy';
import { JwtPayload } from '../../common/interfaces/jwt-payload.interface';

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
  });
});
