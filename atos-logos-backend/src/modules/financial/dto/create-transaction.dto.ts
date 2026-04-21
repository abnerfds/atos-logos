import { IsString, IsNotEmpty, IsOptional, IsUUID, IsNumber, Min, IsEnum, IsDateString, MaxLength } from 'class-validator';
import { TransactionType } from '@prisma/client';

export class CreateTransactionDto {
  @IsEnum(TransactionType)
  @IsNotEmpty()
  type!: TransactionType;

  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  category!: string;

  @IsNumber()
  @Min(0.01)
  amount!: number;

  @IsDateString()
  @IsNotEmpty()
  transactionDate!: string;

  @IsOptional()
  @IsUUID()
  branchId?: string;

  @IsOptional()
  @IsUUID()
  donorUserId?: string;
}
