import { getJwtSecret, assertRequiredEnv } from './env.config';

describe('env.config', () => {
  const originalEnv = process.env;

  beforeEach(() => {
    process.env = { ...originalEnv };
  });

  afterAll(() => {
    process.env = originalEnv;
  });

  describe('getJwtSecret', () => {
    it('should return the secret when set to a strong value', () => {
      process.env.JWT_SECRET = 'a-long-strong-secret-value-here-1234567890';
      expect(getJwtSecret()).toBe('a-long-strong-secret-value-here-1234567890');
    });

    it('should throw when JWT_SECRET is undefined', () => {
      delete process.env.JWT_SECRET;
      expect(() => getJwtSecret()).toThrow(/JWT_SECRET.*not set/);
    });

    it('should throw when JWT_SECRET is an empty string', () => {
      process.env.JWT_SECRET = '';
      expect(() => getJwtSecret()).toThrow(/JWT_SECRET.*not set/);
    });

    it('should throw when JWT_SECRET is whitespace-only', () => {
      process.env.JWT_SECRET = '    ';
      expect(() => getJwtSecret()).toThrow(/JWT_SECRET.*not set/);
    });

    it('should throw in production when secret is the weak default "secretKey"', () => {
      process.env.JWT_SECRET = 'secretKey';
      process.env.NODE_ENV = 'production';
      expect(() => getJwtSecret()).toThrow(/weak default/);
    });

    it('should throw in production when secret is shorter than 32 characters', () => {
      process.env.JWT_SECRET = 'short-but-not-a-known-default';
      process.env.NODE_ENV = 'production';
      expect(() => getJwtSecret()).toThrow(/at least 32 characters/);
    });

    it('should allow weak secret outside production for developer ergonomics', () => {
      process.env.JWT_SECRET = 'secretKey';
      process.env.NODE_ENV = 'development';
      expect(getJwtSecret()).toBe('secretKey');
    });
  });

  describe('assertRequiredEnv', () => {
    it('should throw when DATABASE_URL is missing', () => {
      process.env.JWT_SECRET = 'a-valid-long-secret-value-123456789';
      delete process.env.DATABASE_URL;
      expect(() => assertRequiredEnv()).toThrow(/DATABASE_URL.*not set/);
    });

    it('should pass when all required vars are set', () => {
      process.env.JWT_SECRET = 'a-valid-long-secret-value-123456789';
      process.env.DATABASE_URL = 'postgresql://localhost/test';
      expect(() => assertRequiredEnv()).not.toThrow();
    });
  });
});
