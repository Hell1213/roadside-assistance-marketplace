import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { PaymentsService } from './payments.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { CreatePaymentOrderDto } from './dto/create-payment-order.dto';
import { VerifyPaymentDto } from './dto/verify-payment.dto';
import { RefundPaymentDto } from './dto/refund-payment.dto';

@ApiTags('Payments')
@Controller('payments')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class PaymentsController {
  constructor(private readonly payments: PaymentsService) {}

  @Post('orders')
  @ApiOperation({ summary: 'Create payment order for a job' })
  async createOrder(
    @CurrentUser() user: { userId: string },
    @Body() dto: CreatePaymentOrderDto,
  ) {
    return this.payments.createPaymentOrder(dto.jobId, user.userId);
  }

  @Post('verify')
  @ApiOperation({ summary: 'Verify and capture payment' })
  async verifyPayment(
    @CurrentUser() user: { userId: string },
    @Body() dto: VerifyPaymentDto,
  ) {
    return this.payments.verifyAndCapturePayment(
      dto.paymentId,
      dto.razorpayPaymentId,
      dto.razorpayOrderId,
      dto.razorpaySignature,
      user.userId,
    );
  }

  @Post(':id/refund')
  @ApiOperation({ summary: 'Process refund (admin only in production)' })
  async refundPayment(
    @CurrentUser() user: { userId: string },
    @Param('id') paymentId: string,
    @Body() dto: RefundPaymentDto,
  ) {
    // TODO: Add admin check in production
    return this.payments.processRefund(paymentId, dto.amount, dto.reason);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get payment details' })
  async getPayment(
    @CurrentUser() user: { userId: string },
    @Param('id') paymentId: string,
  ) {
    return this.payments.getPayment(paymentId, user.userId);
  }
}

