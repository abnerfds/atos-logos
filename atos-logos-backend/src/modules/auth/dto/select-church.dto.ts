import { IsString, IsNotEmpty, IsUUID } from 'class-validator';

export class SelectChurchDto {
  @IsString()
  @IsNotEmpty()
  selectionToken!: string;

  @IsUUID()
  @IsNotEmpty()
  churchId!: string;
}
