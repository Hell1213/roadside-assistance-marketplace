import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { RazorpayService } from '../payments/razorpay.service';
import { WalletsService } from '../wallets/wallets.service';
import { PayoutStatus, TransactionCategory } from '@prisma/client';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class PayoutsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly razorpay: RazorpayService,
    private readonly wallets: WalletsService,
    private readonly config: ConfigService,
  ) {}

  /**
   * Initiate payout for driver
   */
  async initiatePayout(driverId: string, amount: number, accountDetails: {
    accountNumber: string;
    ifsc: string;
    name: string;
    contact?: string;
  }) {
    if (amount <= 0) {
      throw new BadRequestException('Amount must be positive');
    }

    const driver = await this.prisma.driver.findUnique({
      where: { id: driverId },
      include: { user: true },
    });

    if (!driver) throw new NotFoundException('Driver not found');

    const wallet = await this.wallets.getOrCreateWallet(driver.userId);
    if (wallet.balance < amount) {
      throw new BadRequestException('Insufficient wallet balance');
    }

    // Create payout in Razorpay
    // Note: Razorpay payouts require fund account to be created first
    // For now, we'll create the payout record and mark it as pending
    // In production, implement fund account creation flow first
    let razorpayPayoutId: string | null = null;
    try {
      // TODO: Implement fund account creation and payout creation
      // For now, we'll skip Razorpay API call and create payout record directly
      // This allows the system to work while fund account setup is pending
      console.log('Payout creation - fund account setup required');
    } catch (error: any) {
      // If Razorpay fails, we still create the payout record but mark it as failed
      console.error('Razorpay payout creation failed:', error.message);
    }

    // Create payout record
    const payout = await this.prisma.payout.create({
      data: {
        driverId,
        userId: driver.userId,
        walletId: wallet.id,
        amount,
        razorpayPayoutId,
        status: razorpayPayoutId ? PayoutStatus.PROCESSING : PayoutStatus.FAILED,
        failureReason: razorpayPayoutId ? null : 'Razorpay API error',
        metadata: {
          accountDetails,
        } as any,
      },
    });

    // Debit wallet if payout was successfully initiated
    if (razorpayPayoutId) {
      await this.wallets.debit(
        driver.userId,
        amount,
        TransactionCategory.PAYOUT,
        `Payout to ${accountDetails.name}`,
        payout.id,
        { payoutId: payout.id, razorpayPayoutId },
      );
    }

    return payout;
  }

  /**
   * Get payout status
   */
  async getPayoutStatus(payoutId: string, driverId: string) {
    const payout = await this.prisma.payout.findUnique({
      where: { id: payoutId },
      include: { driver: { include: { user: true } } },
    });

    if (!payout) throw new NotFoundException('Payout not found');
    if (payout.driverId !== driverId) throw new BadRequestException('Access denied');

    // Sync status from Razorpay if processing
    // TODO: Implement when Razorpay payout API is integrated
    if (payout.razorpayPayoutId && payout.status === PayoutStatus.PROCESSING) {
      // For now, skip Razorpay API call
      // In production, fetch payout status from Razorpay
    }

    return payout;
  }

  /**
   * Get driver payout history
   */
  async getDriverPayouts(driverId: string, limit = 50, offset = 0) {
    const [payouts, total] = await Promise.all([
      this.prisma.payout.findMany({
        where: { driverId },
        orderBy: { createdAt: 'desc' },
        take: limit,
        skip: offset,
      }),
      this.prisma.payout.count({ where: { driverId } }),
    ]);

    return { payouts, total };
  }
}

