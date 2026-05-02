import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './modules/auth/auth.module';
import { ChurchesModule } from './modules/churches/churches.module';
import { BranchesModule } from './modules/branches/branches.module';
import { MembershipsModule } from './modules/memberships/memberships.module';
import { MemberProfilesModule } from './modules/member-profiles/member-profiles.module';
import { MemberPositionsModule } from './modules/member-positions/member-positions.module';
import { EventsModule } from './modules/events/events.module';
import { VisitorsModule } from './modules/visitors/visitors.module';
import { EbdModule } from './modules/ebd/ebd.module';
import { FinancialModule } from './modules/financial/financial.module';
import { RolePermissionsModule } from './modules/role-permissions/role-permissions.module';
import { HealthModule } from './modules/health/health.module';

@Module({
  imports: [
    ThrottlerModule.forRoot([{ ttl: 60000, limit: 60 }]),
    PrismaModule,
    HealthModule,
    AuthModule,
    ChurchesModule,
    BranchesModule,
    MembershipsModule,
    MemberProfilesModule,
    MemberPositionsModule,
    EventsModule,
    VisitorsModule,
    EbdModule,
    FinancialModule,
    RolePermissionsModule,
  ],
  providers: [
    { provide: APP_GUARD, useClass: ThrottlerGuard },
  ],
})
export class AppModule {}
