import { IsString, IsNotEmpty, IsUUID, MaxLength } from 'class-validator';

export class CreateEbdClassDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  name!: string;

  @IsUUID()
  @IsNotEmpty()
  branchId!: string;
}
