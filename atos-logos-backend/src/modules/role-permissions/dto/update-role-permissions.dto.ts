import { IsObject, IsNotEmpty } from 'class-validator';

export class UpdateRolePermissionsDto {
  @IsObject()
  @IsNotEmpty()
  permissions!: Record<string, boolean>;
}
