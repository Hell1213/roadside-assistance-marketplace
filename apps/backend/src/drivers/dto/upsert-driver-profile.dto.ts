import { IsArray, IsOptional, IsString } from 'class-validator';

export class UpsertDriverProfileDto {
  @IsOptional()
  @IsArray()
  capabilities?: Array<'TOW' | 'JUMP_START' | 'FUEL_DELIVERY' | 'FLAT_TYRE'>;

  @IsOptional()
  @IsString()
  status?: 'OFFLINE' | 'ONLINE' | 'BUSY' | 'SUSPENDED';
}


