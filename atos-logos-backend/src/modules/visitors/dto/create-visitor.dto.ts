import { IsString, IsNotEmpty, IsOptional, MaxLength } from 'class-validator';

export class CreateVisitorDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  name!: string;

  @IsOptional()
  @IsString()
  phone?: string;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  observations?: string;
}
