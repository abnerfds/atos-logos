import { Module } from '@nestjs/common';
import { EbdController } from './ebd.controller';
import { EbdService } from './ebd.service';

@Module({
  controllers: [EbdController],
  providers: [EbdService],
})
export class EbdModule {}
