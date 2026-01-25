import { IsString, IsUUID } from 'class-validator';

export class VerifyPaymentDto {
  @IsUUID()
  paymentId: string;

  @IsString()
  razorpayPaymentId: string;

  @IsString()
  razorpayOrderId: string;

  @IsString()
  razorpaySignature: string;
}

