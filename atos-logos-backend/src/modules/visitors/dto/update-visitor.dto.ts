import { IsString, IsOptional, MaxLength } from 'class-validator';

export class UpdateVisitorDto {
  @IsOptional()
  @IsString()
  @MaxLength(255)
  name?: string;

  @IsOptional()
  @IsString()
  phone?: string;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  observations?: string;
}
