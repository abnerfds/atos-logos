import { IsString, IsNotEmpty, IsUUID, MaxLength } from 'class-validator';

export class CreateScheduleDto {
  @IsUUID()
  @IsNotEmpty()
  userId!: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  functionName!: string;
}
