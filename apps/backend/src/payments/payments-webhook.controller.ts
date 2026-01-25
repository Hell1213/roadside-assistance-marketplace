import { Body, Controller, Headers, Post, Req } from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
import type { RawBodyRequest } from '@nestjs/common';
import { PaymentsService } from './payments.service';
import { RazorpayService } from './razorpay.service';
import { WalletsService } from '../wallets/wallets.service';
import { PrismaService } from '../prisma/prisma.service';
import { TransactionCategory, PaymentStatus, PayoutStatus } from '@prisma/client';

@ApiTags('Webhooks')
@Controller('webhooks')
export class PaymentsWebhookController {
  constructor(
    private readonly payments: PaymentsService,
    private readonly razorpay: RazorpayService,
    private readonly wallets: WalletsService,
    private readonly prisma: PrismaService,
  ) {}

  @Post('razorpay')
  @ApiOperation({ summary: 'Razorpay webhook handler' })
  async handleRazorpayWebhook(
    @Req() req: RawBodyRequest<Request>,
    @Headers('x-razorpay-signature') signature: string,
  ) {
    const body = JSON.stringify(req.body);
    
    // Verify webhook signature
    if (!this.razorpay.verifyWebhookSignature(body, signature)) {
      return { error: 'Invalid signature' };
    }

    const event = (req.body as any).event;
    const payload = (req.body as any).payload;

    switch (event) {
      case 'payment.captured':
        await this.handlePaymentCaptured(payload.payment.entity);
        break;
      case 'payment.failed':
        await this.handlePaymentFailed(payload.payment.entity);
        break;
      case 'order.paid':
        await this.handleOrderPaid(payload.order.entity);
        break;
      case 'payout.processed':
        await this.handlePayoutProcessed(payload.payout.entity);
        break;
      case 'payout.failed':
        await this.handlePayoutFailed(payload.payout.entity);
        break;
    }

    return { received: true };
  }

  private async handlePaymentCaptured(payment: any) {
    const paymentRecord = await this.prisma.payment.findUnique({
      where: { razorpayPaymentId: payment.id },
      include: { job: true },
    });

    if (!paymentRecord) return;

    // Update payment status if not already captured
    if (paymentRecord.status !== PaymentStatus.CAPTURED) {
      await this.prisma.payment.update({
        where: { id: paymentRecord.id },
        data: {
          status: PaymentStatus.CAPTURED,
          capturedAt: new Date(),
        },
      });

      // Credit customer wallet (they paid, so credit their wallet)
      await this.wallets.credit(
        paymentRecord.userId,
        paymentRecord.amount,
        TransactionCategory.PAYMENT,
        `Payment for job ${paymentRecord.jobId}`,
        paymentRecord.id,
        { jobId: paymentRecord.jobId },
      );
    }
  }

  private async handlePaymentFailed(payment: any) {
    const paymentRecord = await this.prisma.payment.findUnique({
      where: { razorpayPaymentId: payment.id },
    });

    if (paymentRecord && paymentRecord.status === PaymentStatus.PENDING) {
      await this.prisma.payment.update({
        where: { id: paymentRecord.id },
        data: { status: PaymentStatus.FAILED },
      });
    }
  }

  private async handleOrderPaid(order: any) {
    // Order paid event - payment should already be captured
    // This is a confirmation event
  }

  private async handlePayoutProcessed(payout: any) {
    const payoutRecord = await this.prisma.payout.findUnique({
      where: { razorpayPayoutId: payout.id },
    });

    if (payoutRecord) {
      await this.prisma.payout.update({
        where: { id: payoutRecord.id },
        data: {
          status: PayoutStatus.COMPLETED,
          processedAt: new Date(),
        },
      });
    }
  }

  private async handlePayoutFailed(payout: any) {
    const payoutRecord = await this.prisma.payout.findUnique({
      where: { razorpayPayoutId: payout.id },
    });

    if (payoutRecord) {
      await this.prisma.payout.update({
        where: { id: payoutRecord.id },
        data: {
          status: PayoutStatus.FAILED,
          failureReason: payout.failure_reason || 'Unknown error',
        },
      });

      // Refund to wallet if payout failed
      await this.wallets.credit(
        payoutRecord.userId,
        payoutRecord.amount,
        TransactionCategory.ADJUSTMENT,
        `Payout failed - refunded`,
        payoutRecord.id,
        { payoutId: payoutRecord.id },
      );
    }
  }
}

