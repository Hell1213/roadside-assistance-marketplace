import { IsIn, IsString, Matches } from 'class-validator';

export class RequestOtpDto {
  @IsString()
  @Matches(/^\+?[1-9]\d{7,14}$/)
  phone!: string;

  @IsString()
  @IsIn(['customer', 'driver', 'admin'])
  role!: 'customer' | 'driver' | 'admin';
}


