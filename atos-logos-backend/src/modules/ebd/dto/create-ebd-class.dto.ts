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

export class CreateEbdLessonDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  theme!: string;

  @IsDateString()
  scheduledDate!: string;
}

export class CreateEbdClassDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  name!: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(120)
  targetAudience!: string;

  @IsUUID()
  @IsOptional()
  quarterId?: string;

  @IsString()
  @IsOptional()
  @MaxLength(120)
  quarterName?: string;

  @IsUUID()
  @IsNotEmpty()
  branchId!: string;

  @IsUUID()
  @IsOptional()
  teacherId?: string;

  @IsArray()
  @IsUUID('4', { each: true })
  @IsOptional()
  teacherIds?: string[];

  @IsArray()
  @IsUUID('4', { each: true })
  studentIds!: string[];

  @IsArray()
  @ArrayMinSize(13)
  @ArrayMaxSize(13)
  @ValidateNested({ each: true })
  @Type(() => CreateEbdLessonDto)
  lessons!: CreateEbdLessonDto[];
}
