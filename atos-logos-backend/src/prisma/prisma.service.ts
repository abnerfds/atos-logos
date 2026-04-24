import 'dotenv/config';
import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';

@Injectable()
export class PrismaService
  extends PrismaClient
  implements OnModuleInit, OnModuleDestroy
{
  constructor() {
    const url = process.env.DATABASE_URL ?? '';
    if (url.startsWith('prisma+postgres://')) {
      super({ accelerateUrl: url });
    } else {
      const adapter = new PrismaPg(url);
      super({ adapter });
    }
  }

  async onModuleInit() {
    await this.$connect();
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }

  /**
   * Returns a Prisma client extension that automatically scopes all queries
   * on tenant-aware models to the given churchId.
   * Usage in services: this.prisma.forTenant(user.churchId).branch.findMany()
   */
  forTenant(churchId: string) {
    return this.$extends({
      query: {
        branch: {
          // eslint-disable-next-line @typescript-eslint/no-explicit-any -- Prisma $extends API requires untyped args
          async $allOperations({ args, query }: { args: Record<string, any>; query: (args: any) => any }) {
            if ('where' in args) {
              args.where = { ...args.where, churchId };
            }
            return query(args);
          },
        },
        membership: {
          // eslint-disable-next-line @typescript-eslint/no-explicit-any -- Prisma $extends API requires untyped args
          async $allOperations({ args, query }: { args: Record<string, any>; query: (args: any) => any }) {
            if ('where' in args) {
              args.where = { ...args.where, churchId };
            }
            return query(args);
          },
        },
        memberProfile: {
          // eslint-disable-next-line @typescript-eslint/no-explicit-any -- Prisma $extends API requires untyped args
          async $allOperations({ args, query }: { args: Record<string, any>; query: (args: any) => any }) {
            if ('where' in args) {
              args.where = { ...args.where, churchId };
            }
            return query(args);
          },
        },
        memberPosition: {
          // eslint-disable-next-line @typescript-eslint/no-explicit-any -- Prisma $extends API requires untyped args
          async $allOperations({ args, query }: { args: Record<string, any>; query: (args: any) => any }) {
            if ('where' in args) {
              args.where = { ...args.where, churchId };
            }
            return query(args);
          },
        },
        event: {
          // eslint-disable-next-line @typescript-eslint/no-explicit-any -- Prisma $extends API requires untyped args
          async $allOperations({ args, query }: { args: Record<string, any>; query: (args: any) => any }) {
            if ('where' in args) {
              args.where = { ...args.where, churchId };
            }
            return query(args);
          },
        },
        visitor: {
          // eslint-disable-next-line @typescript-eslint/no-explicit-any -- Prisma $extends API requires untyped args
          async $allOperations({ args, query }: { args: Record<string, any>; query: (args: any) => any }) {
            if ('where' in args) {
              args.where = { ...args.where, churchId };
            }
            return query(args);
          },
        },
        ebdQuarter: {
          // eslint-disable-next-line @typescript-eslint/no-explicit-any -- Prisma $extends API requires untyped args
          async $allOperations({ args, query }: { args: Record<string, any>; query: (args: any) => any }) {
            if ('where' in args) {
              args.where = { ...args.where, churchId };
            }
            return query(args);
          },
        },
        ebdClass: {
          // eslint-disable-next-line @typescript-eslint/no-explicit-any -- Prisma $extends API requires untyped args
          async $allOperations({ args, query }: { args: Record<string, any>; query: (args: any) => any }) {
            if ('where' in args) {
              args.where = { ...args.where, churchId };
            }
            return query(args);
          },
        },
        campaign: {
          // eslint-disable-next-line @typescript-eslint/no-explicit-any -- Prisma $extends API requires untyped args
          async $allOperations({ args, query }: { args: Record<string, any>; query: (args: any) => any }) {
            if ('where' in args) {
              args.where = { ...args.where, churchId };
            }
            return query(args);
          },
        },
        financialTransaction: {
          // eslint-disable-next-line @typescript-eslint/no-explicit-any -- Prisma $extends API requires untyped args
          async $allOperations({ args, query }: { args: Record<string, any>; query: (args: any) => any }) {
            if ('where' in args) {
              args.where = { ...args.where, churchId };
            }
            return query(args);
          },
        },
      },
    });
  }
}
