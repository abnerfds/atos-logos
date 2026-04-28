import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsDateString,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  ValidateNested,
} from 'class-validator';

export class UpdateEbdLessonDto {
  @IsUUID()
  @IsOptional()
  id?: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  theme!: string;

  @IsDateString()
  scheduledDate!: string;
}

export class UpdateEbdClassDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  @IsOptional()
  name?: string;

  @IsString()
  @IsOptional()
  @MaxLength(120)
  targetAudience?: string;

  @IsString()
  @IsOptional()
  @MaxLength(100)
  quarterName?: string;

  @IsArray()
  @IsUUID('4', { each: true })
  @IsOptional()
  teacherIds?: string[];

  @IsArray()
  @IsUUID('4', { each: true })
  @IsOptional()
  studentIds?: string[];

  @IsArray()
  @ArrayMinSize(13)
  @ArrayMaxSize(13)
  @ValidateNested({ each: true })
  @Type(() => UpdateEbdLessonDto)
  @IsOptional()
  lessons?: UpdateEbdLessonDto[];
}
