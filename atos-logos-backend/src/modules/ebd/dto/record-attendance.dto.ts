import { Type } from 'class-transformer';
import {
  IsArray,
  IsBoolean,
  IsNotEmpty,
  IsNumber,
  IsUUID,
  Min,
  ValidateNested,
} from 'class-validator';

export class AttendanceEntry {
  @IsUUID()
  @IsNotEmpty()
  memberId!: string;

  @IsBoolean()
  isPresent!: boolean;
}

export class SaveLessonAttendanceDto {
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  visitorCount!: number;

  @Type(() => Number)
  @IsNumber()
  @Min(0)
  offeringAmount!: number;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => AttendanceEntry)
  attendances!: AttendanceEntry[];
}
