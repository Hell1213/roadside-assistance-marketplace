import { IsDateString, IsInt, IsOptional, IsString, Min } from 'class-validator';

export class CreatePricingRuleDto {
  @IsString()
  city!: string;

  @IsString()
  service_code!: 'TOW' | 'JUMP_START' | 'FUEL_DELIVERY' | 'FLAT_TYRE';

  @IsInt()
  @Min(0)
  base_fare!: number;

  @IsInt()
  @Min(0)
  per_km!: number;

  @IsInt()
  @Min(0)
  per_min!: number;

  @IsInt()
  @Min(0)
  min_fare!: number;

  @IsInt()
  @Min(0)
  platform_fee!: number;

  @IsInt()
  @Min(0)
  tax_pct!: number; // store as integer percent (e.g. 18)

  @IsDateString()
  effective_from!: string;

  @IsOptional()
  surge_json?: any;
}


