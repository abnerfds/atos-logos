import { IsUUID, IsNotEmpty, IsBoolean, IsArray, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

export class AttendanceEntry {
  @IsUUID()
  @IsNotEmpty()
  userId!: string;

  @IsBoolean()
  isPresent!: boolean;
}

export class RecordAttendanceDto {
  @IsUUID()
  @IsNotEmpty()
  eventId!: string;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => AttendanceEntry)
  entries!: AttendanceEntry[];
}
