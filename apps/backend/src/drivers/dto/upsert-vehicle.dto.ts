import { IsInt, IsOptional, IsString, MaxLength, Min } from 'class-validator';

export class UpsertVehicleDto {
  @IsOptional()
  @IsString()
  @MaxLength(30)
  type?: string;

  @IsOptional()
  @IsString()
  @MaxLength(20)
  plateNo?: string;

  @IsOptional()
  @IsString()
  @MaxLength(40)
  make?: string;

  @IsOptional()
  @IsString()
  @MaxLength(40)
  model?: string;

  @IsOptional()
  @IsInt()
  @Min(1970)
  year?: number;
}


