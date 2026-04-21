import { IsString, IsNotEmpty, IsUUID, IsOptional, IsDateString } from 'class-validator';

export class CreateMemberProfileDto {
  @IsUUID()
  @IsNotEmpty()
  userId!: string;

  @IsUUID()
  @IsNotEmpty()
  branchId!: string;

  @IsDateString()
  @IsNotEmpty()
  birthDate!: string;

  @IsOptional()
  @IsDateString()
  baptismDate?: string;

  @IsOptional()
  @IsDateString()
  consecrationDate?: string;

  @IsDateString()
  @IsNotEmpty()
  admissionDate!: string;

  @IsOptional()
  @IsString()
  photoUrl?: string;
}
