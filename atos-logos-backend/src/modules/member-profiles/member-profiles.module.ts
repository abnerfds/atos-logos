import { Module } from '@nestjs/common';
import { MemberProfilesController } from './member-profiles.controller';
import { MemberProfilesService } from './member-profiles.service';

@Module({
  controllers: [MemberProfilesController],
  providers: [MemberProfilesService],
})
export class MemberProfilesModule {}
