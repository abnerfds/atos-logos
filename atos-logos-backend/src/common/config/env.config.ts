/**
 * Centralized environment configuration + fail-fast validation.
 *
 * The Nest modules read these values at module load time (via `process.env`),
 * so anything that matters must be asserted here, which `main.ts` calls
 * before `NestFactory.create(AppModule)`.
 */

const WEAK_JWT_SECRETS = new Set([
  'secretKey',
  'secret',
  'changeme',
  'your-secret-key-here',
]);

/**
 * Reads JWT_SECRET from the environment, throwing if it is missing or
 * obviously weak. Exported so modules can share the same validated value.
 */
export function getJwtSecret(): string {
  const secret = process.env.JWT_SECRET;

  if (!secret || secret.trim().length === 0) {
    throw new Error(
      'JWT_SECRET environment variable is not set. ' +
        'Define a strong random value (e.g., `openssl rand -base64 48`) in your .env file.',
    );
  }

  const isProduction = process.env.NODE_ENV === 'production';
  if (isProduction && WEAK_JWT_SECRETS.has(secret)) {
    throw new Error(
      `JWT_SECRET is set to a known weak default (${secret}). ` +
        'Generate a strong random value before deploying to production.',
    );
  }

  if (isProduction && secret.length < 32) {
    throw new Error(
      'JWT_SECRET must be at least 32 characters in production. ' +
        'Generate a strong random value with `openssl rand -base64 48`.',
    );
  }

  return secret;
}

/**
 * Asserts all required environment variables are present and valid.
 * Called once at process bootstrap from `main.ts`.
 */
export function assertRequiredEnv(): void {
  // Touching the getter runs all validations.
  getJwtSecret();

  if (!process.env.DATABASE_URL || process.env.DATABASE_URL.trim().length === 0) {
    throw new Error(
      'DATABASE_URL environment variable is not set. ' +
        'Add it to your .env (see .env.example).',
    );
  }
}
