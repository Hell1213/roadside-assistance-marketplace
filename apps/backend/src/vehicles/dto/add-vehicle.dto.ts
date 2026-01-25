import { IsString, IsOptional, IsNumber, IsBoolean, Min, Max } from 'class-validator';

export class AddVehicleDto {
  @IsString()
  type: string;

  @IsOptional()
  @IsString()
  make?: string;

  @IsOptional()
  @IsString()
  model?: string;

  @IsOptional()
  @IsNumber()
  @Min(1900)
  @Max(2100)
  year?: number;

  @IsOptional()
  @IsString()
  plateNo?: string;

  @IsOptional()
  @IsString()
  color?: string;

  @IsOptional()
  @IsBoolean()
  isDefault?: boolean;
}

