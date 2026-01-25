import { IsNumber, IsOptional, IsString } from 'class-validator';

export class CreateQuoteDto {
  @IsString()
  city!: string;

  @IsString()
  service_code!: 'TOW' | 'JUMP_START' | 'FUEL_DELIVERY' | 'FLAT_TYRE';

  @IsNumber()
  origin_lat!: number;

  @IsNumber()
  origin_lng!: number;

  @IsOptional()
  @IsNumber()
  dest_lat?: number;

  @IsOptional()
  @IsNumber()
  dest_lng?: number;

  @IsOptional()
  @IsString()
  vehicle_class?: string;
}


