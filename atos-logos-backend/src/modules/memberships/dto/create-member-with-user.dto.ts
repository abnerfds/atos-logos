import {
  IsDateString,
  IsEmail,
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUUID,
  MinLength,
} from 'class-validator';
import { CivilStatus, Role, Sex } from '@prisma/client';

/**
 * Secretariat payload that creates a User + Membership (and, when
 * birthDate + admissionDate are present, a MemberProfile) atomically.
 *
 * The temporary password is provided by the secretary and should be
 * shared with the new member out-of-band. There is no password-reset
 * endpoint yet, so users change their password via `PATCH /auth/me`
 * after first login.
 */
export class CreateMemberWithUserDto {
  // -- User fields --

  @IsString()
  @IsNotEmpty()
  name!: string;

  @IsString()
  @MinLength(6)
  password!: string;

  @IsOptional()
  @IsEmail()
  email?: string;

  @IsOptional()
  @IsString()
  phone?: string;

  @IsOptional()
  @IsString()
  cpf?: string;

  @IsOptional()
  @IsString()
  rg?: string;

  @IsOptional()
  @IsEnum(Sex)
  sex?: Sex;

  @IsOptional()
  @IsEnum(CivilStatus)
  civilStatus?: CivilStatus;

  @IsOptional()
  @IsString()
  fatherName?: string;

  @IsOptional()
  @IsString()
  motherName?: string;

  // -- Membership fields --

  @IsUUID()
  branchId!: string;

  @IsOptional()
  @IsEnum(Role)
  role?: Role;

  /// Optional MemberPosition to attach on creation (e.g. "Pastor",
  /// "Diácono"). This is the ecclesiastical title — different from
  /// `role`, which is the access-control level. When provided, a
  /// PositionUser row is created inside the same transaction.
  @IsOptional()
  @IsUUID()
  positionId?: string;

  // -- Optional MemberProfile fields --
  // The profile row is created only when BOTH birthDate and admissionDate
  // are present (they are @db.Date NOT NULL in the Prisma schema).
  // baptismDate is accepted when provided regardless.

  @IsOptional()
  @IsDateString()
  birthDate?: string;

  @IsOptional()
  @IsDateString()
  baptismDate?: string;

  @IsOptional()
  @IsDateString()
  admissionDate?: string;

  @IsOptional()
  @IsDateString()
  consecrationDate?: string;
}
