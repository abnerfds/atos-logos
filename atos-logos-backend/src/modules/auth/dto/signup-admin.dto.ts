import { IsString, IsNotEmpty, MinLength, IsEmail } from 'class-validator';
import { Transform } from 'class-transformer';

/// Payload accepted by `POST /auth/signup-admin`.
///
/// `phone` is intentionally NOT part of this DTO. The unique `User.phone`
/// column still exists, but it is set later via the profile-edit endpoint
/// so signup stays minimal and never collides on a missing-phone collision.
export class SignupAdminDto {
  @IsString()
  @IsNotEmpty()
  name!: string;

  @IsEmail()
  @IsNotEmpty()
  @Transform(({ value }) =>
    typeof value === 'string' ? value.trim().toLowerCase() : value,
  )
  email!: string;

  @IsString()
  @IsNotEmpty()
  @MinLength(6)
  password!: string;

  @IsString()
  @IsNotEmpty()
  churchName!: string;
}
