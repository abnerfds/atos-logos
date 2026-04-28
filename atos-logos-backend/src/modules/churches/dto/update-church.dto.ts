import { IsString, IsOptional } from 'class-validator';
import { Transform } from 'class-transformer';

/** Strips every non-digit character — used to sanitise document numbers. */
const digitsOnly = ({ value }: { value: unknown }) =>
  typeof value === 'string' ? value.replace(/\D/g, '') || undefined : value;

export class UpdateChurchDto {
  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @Transform(digitsOnly)
  @IsString()
  documentNumber?: string;
}
