import { execSync } from 'child_process';
import { PostgreSqlContainer, StartedPostgreSqlContainer } from '@testcontainers/postgresql';

export interface StartedTestDb {
  url: string;
  stop: () => Promise<void>;
}

/**
 * Spins up an ephemeral Postgres for e2e, applies all Prisma migrations
 * against it, and sets process.env.DATABASE_URL so Nest modules picked
 * up at import time see the test database. Callers MUST invoke this
 * BEFORE importing AppModule (otherwise PrismaService captures the
 * wrong URL at construction time).
 */
export async function startPostgresForE2E(): Promise<StartedTestDb> {
  const container: StartedPostgreSqlContainer = await new PostgreSqlContainer('postgres:15')
    .withDatabase('atos_logos_test')
    .withUsername('postgres')
    .withPassword('password')
    .start();

  const url = container.getConnectionUri();
  process.env.DATABASE_URL = url;

  // Apply real migrations so FK constraints (the whole reason this
  // harness exists) are present. migrate deploy is idempotent/safe
  // against a fresh DB and does not try to generate new migrations.
  execSync('npx prisma migrate deploy', {
    env: { ...process.env, DATABASE_URL: url },
    stdio: 'inherit',
  });

  return {
    url,
    stop: async () => {
      await container.stop();
    },
  };
}
