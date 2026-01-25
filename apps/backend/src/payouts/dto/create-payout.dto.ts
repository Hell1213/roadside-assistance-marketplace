import { IsNumber, IsString, Min, IsOptional } from 'class-validator';

export class CreatePayoutDto {
  @IsNumber()
  @Min(1)
  amount: number;

  @IsString()
  accountNumber: string;

  @IsString()
  ifsc: string;

  @IsString()
  name: string;

  @IsOptional()
  @IsString()
  contact?: string;
}

