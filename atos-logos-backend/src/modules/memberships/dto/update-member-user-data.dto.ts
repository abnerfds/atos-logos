import {
  IsEmail,
  IsEnum,
  IsOptional,
  IsString,
  IsUUID,
  MinLength,
} from 'class-validator';
import { CivilStatus, Sex } from '@prisma/client';

/**
 * Payload for the secretariat edit form. Updates the User row behind a
 * membership — not the membership itself (role/status/branch live under
 * the membership DTOs).
 *
 * Every field is optional: the secretariat form may only change one or
 * two fields, and the service should only persist what's supplied so it
 * doesn't accidentally blank other columns.
 */
export class UpdateMemberUserDataDto {
  @IsOptional()
  @IsString()
  @MinLength(1)
  name?: string;

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

  @IsOptional()
  @IsString()
  country?: string;

  @IsOptional()
  @IsString()
  state?: string;

  @IsOptional()
  @IsString()
  city?: string;

  @IsOptional()
  @IsString()
  neighborhood?: string;

  @IsOptional()
  @IsString()
  street?: string;

  @IsOptional()
  @IsString()
  number?: string;

  @IsOptional()
  @IsString()
  complement?: string;

  // -- Membership-level fields --
  // The "user-data" endpoint doubles as the secretariat's atomic edit
  // endpoint: when the form changes the branch or the position, those
  // writes go through in the SAME transaction so the record never ends
  // up half-migrated (e.g., User saved but branch change lost).

  @IsOptional()
  @IsUUID()
  branchId?: string;

  @IsOptional()
  @IsUUID()
  positionId?: string;
}
