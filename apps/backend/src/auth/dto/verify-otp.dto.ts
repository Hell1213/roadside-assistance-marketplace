import { IsIn, IsString, Length, Matches } from 'class-validator';

export class VerifyOtpDto {
  @IsString()
  @Matches(/^\+?[1-9]\d{7,14}$/)
  phone!: string;

  @IsString()
  @IsIn(['customer', 'driver', 'admin'])
  role!: 'customer' | 'driver' | 'admin';

  @IsString()
  @Length(4, 8)
  otp!: string;
}


