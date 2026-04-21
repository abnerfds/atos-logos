import { IsString, IsOptional, IsDateString, IsEnum, MaxLength } from 'class-validator';
import { EventType } from '@prisma/client';

export class UpdateEventDto {
  @IsOptional()
  @IsString()
  @MaxLength(255)
  title?: string;

  @IsOptional()
  @IsDateString()
  startsAt?: string;

  @IsOptional()
  @IsEnum(EventType)
  type?: EventType;
}
