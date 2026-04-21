import { IsOptional, IsInt, IsString, Min, Max } from 'class-validator';
import { Type } from 'class-transformer';

export class QueryMembershipDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 20;

  /// Free-text search over the member's name. Matches are case-insensitive
  /// substrings on `user.name`. Performed at the database level so the
  /// result set stays consistent with pagination.
  @IsOptional()
  @IsString()
  q?: string;
}
