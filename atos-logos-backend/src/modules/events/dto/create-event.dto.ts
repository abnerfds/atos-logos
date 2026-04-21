import { IsString, IsNotEmpty, IsOptional, IsUUID, IsDateString, IsEnum, MaxLength } from 'class-validator';
import { EventType } from '@prisma/client';

export class CreateEventDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  title!: string;

  @IsDateString()
  @IsNotEmpty()
  startsAt!: string;

  @IsEnum(EventType)
  @IsNotEmpty()
  type!: EventType;

  @IsOptional()
  @IsUUID()
  branchId?: string;
}
