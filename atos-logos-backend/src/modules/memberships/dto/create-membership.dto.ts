import { IsString, IsNotEmpty, IsUUID, IsOptional, IsEnum } from 'class-validator';
import { Role } from '@prisma/client';

export class CreateMembershipDto {
  @IsUUID()
  @IsNotEmpty()
  userId!: string;

  @IsUUID()
  @IsNotEmpty()
  branchId!: string;

  @IsOptional()
  @IsEnum(Role)
  role?: Role;
}
