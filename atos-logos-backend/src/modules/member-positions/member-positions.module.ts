import { Module } from '@nestjs/common';
import { MemberPositionsController } from './member-positions.controller';
import { MemberPositionsService } from './member-positions.service';

@Module({
  controllers: [MemberPositionsController],
  providers: [MemberPositionsService],
})
export class MemberPositionsModule {}
