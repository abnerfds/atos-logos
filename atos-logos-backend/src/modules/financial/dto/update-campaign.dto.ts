import { IsString, IsOptional, IsNumber, Min, MaxLength } from 'class-validator';

export class UpdateCampaignDto {
  @IsOptional()
  @IsString()
  @MaxLength(255)
  title?: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  goalAmount?: number;

  @IsOptional()
  @IsString()
  status?: string; // active, completed, cancelled
}
