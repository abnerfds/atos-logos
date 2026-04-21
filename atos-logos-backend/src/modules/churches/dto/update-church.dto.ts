import { IsString, IsOptional } from 'class-validator';

export class UpdateChurchDto {
  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsString()
  documentNumber?: string;
}
