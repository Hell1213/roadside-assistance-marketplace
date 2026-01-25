import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { RazorpayService } from './razorpay.service';
import { PaymentStatus, PaymentMethod } from '@prisma/client';

@Injectable()
export class PaymentsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly razorpay: RazorpayService,
  ) {}

  /**
   * Create payment order for a job
   */
  async createPaymentOrder(jobId: string, userId: string) {
    const job = await this.prisma.job.findUnique({
      where: { id: jobId },
      include: { service: true, quote: true },
    });

    if (!job) throw new NotFoundException('Job not found');
    if (job.customerId !== userId) throw new BadRequestException('Access denied');

    // Check if payment already exists
    const existingPayment = await this.prisma.payment.findUnique({
      where: { jobId },
    });

    if (existingPayment && existingPayment.status === PaymentStatus.CAPTURED) {
      throw new BadRequestException('Payment already captured');
    }

    // Create Razorpay order
    const order = await this.razorpay.client.orders.create({
      amount: job.quotedPrice * 100, // Razorpay expects amount in paise
      currency: 'INR',
      receipt: `job_${jobId}`,
      notes: {
        jobId,
        service: job.service.code,
        customerId: userId,
      },
    });

    // Create or update payment record
    const payment = await this.prisma.payment.upsert({
      where: { jobId },
      create: {
        jobId,
        userId,
        razorpayOrderId: order.id,
        amount: job.quotedPrice,
        status: PaymentStatus.PENDING,
        metadata: {
          order: order,
        } as any,
      },
      update: {
        razorpayOrderId: order.id,
        status: PaymentStatus.PENDING,
        metadata: {
          order: order,
        } as any,
      },
    });

    return {
      paymentId: payment.id,
      orderId: order.id,
      amount: Number(order.amount) / 100, // Convert back to rupees
      currency: order.currency,
      keyId: process.env.RAZORPAY_KEY_ID,
    };
  }

  /**
   * Verify and capture payment
   */
  async verifyAndCapturePayment(
    paymentId: string,
    razorpayPaymentId: string,
    razorpayOrderId: string,
    razorpaySignature: string,
    userId: string,
  ) {
    const payment = await this.prisma.payment.findUnique({
      where: { id: paymentId },
      include: { job: true },
    });

    if (!payment) throw new NotFoundException('Payment not found');
    if (payment.userId !== userId) throw new BadRequestException('Access denied');
    if (payment.razorpayOrderId !== razorpayOrderId) {
      throw new BadRequestException('Order ID mismatch');
    }

    // Verify signature
    const crypto = require('crypto');
    const webhookSecret = process.env.RAZORPAY_KEY_SECRET;
    const text = `${razorpayOrderId}|${razorpayPaymentId}`;
    const generatedSignature = crypto
      .createHmac('sha256', webhookSecret!)
      .update(text)
      .digest('hex');

    if (generatedSignature !== razorpaySignature) {
      throw new BadRequestException('Invalid payment signature');
    }

    // Fetch payment details from Razorpay
    const razorpayPayment = await this.razorpay.client.payments.fetch(razorpayPaymentId);

    // Update payment record
    const updated = await this.prisma.payment.update({
      where: { id: paymentId },
      data: {
        razorpayPaymentId,
        razorpaySignature,
        status: PaymentStatus.CAPTURED,
        method: this.mapRazorpayMethod(razorpayPayment.method),
        capturedAt: new Date(),
        metadata: {
          razorpayPayment: razorpayPayment,
        } as any,
      },
      include: { job: true },
    });

    return updated;
  }

  /**
   * Process refund
   */
  async processRefund(paymentId: string, amount?: number, reason?: string) {
    const payment = await this.prisma.payment.findUnique({
      where: { id: paymentId },
    });

    if (!payment) throw new NotFoundException('Payment not found');
    if (!payment.razorpayPaymentId) {
      throw new BadRequestException('Payment not captured');
    }
    if (payment.status !== PaymentStatus.CAPTURED) {
      throw new BadRequestException('Payment not in captured state');
    }

    const refundAmount = amount ? amount * 100 : payment.amount * 100 - payment.refundedAmount * 100;

    // Create refund in Razorpay
    const refund = await this.razorpay.client.payments.refund(payment.razorpayPaymentId, {
      amount: refundAmount,
      notes: {
        reason: reason || 'Customer request',
        paymentId,
      },
    });

    // Update payment record
    const newRefundedAmount = payment.refundedAmount + refundAmount / 100;
    const newStatus =
      newRefundedAmount >= payment.amount
        ? PaymentStatus.REFUNDED
        : PaymentStatus.PARTIALLY_REFUNDED;

    const updated = await this.prisma.payment.update({
      where: { id: paymentId },
      data: {
        refundedAmount: newRefundedAmount,
        status: newStatus,
        metadata: {
          ...((payment.metadata as any) || {}),
          refunds: [
            ...((payment.metadata as any)?.refunds || []),
            {
              refundId: refund.id,
              amount: refundAmount / 100,
              reason,
              createdAt: new Date().toISOString(),
            },
          ],
        } as any,
      },
    });

    return updated;
  }

  /**
   * Get payment details
   */
  async getPayment(paymentId: string, userId: string) {
    const payment = await this.prisma.payment.findUnique({
      where: { id: paymentId },
      include: { job: { include: { service: true, quote: true } } },
    });

    if (!payment) throw new NotFoundException('Payment not found');
    if (payment.userId !== userId) throw new BadRequestException('Access denied');

    return payment;
  }

  /**
   * Map Razorpay payment method to our enum
   */
  private mapRazorpayMethod(method: string): PaymentMethod {
    const methodMap: Record<string, PaymentMethod> = {
      card: PaymentMethod.CARD,
      upi: PaymentMethod.UPI,
      netbanking: PaymentMethod.NETBANKING,
      wallet: PaymentMethod.WALLET,
      razorpay_wallet: PaymentMethod.RAZORPAY_WALLET,
    };

    return methodMap[method.toLowerCase()] || PaymentMethod.CARD;
  }
}

