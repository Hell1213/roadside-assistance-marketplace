import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { TransactionType, TransactionCategory } from '@prisma/client';

@Injectable()
export class WalletsService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Get or create wallet for user
   */
  async getOrCreateWallet(userId: string) {
    return this.prisma.wallet.upsert({
      where: { userId },
      create: {
        userId,
        balance: 0,
        locked: 0,
      },
      update: {},
      include: {
        transactions: {
          orderBy: { createdAt: 'desc' },
          take: 20,
        },
      },
    });
  }

  /**
   * Get wallet balance
   */
  async getBalance(userId: string) {
    const wallet = await this.getOrCreateWallet(userId);
    return {
      balance: wallet.balance,
      locked: wallet.locked,
      available: wallet.balance - wallet.locked,
    };
  }

  /**
   * Credit wallet (atomic operation)
   */
  async credit(
    userId: string,
    amount: number,
    category: TransactionCategory,
    description: string,
    referenceId?: string,
    metadata?: any,
  ) {
    if (amount <= 0) {
      throw new BadRequestException('Amount must be positive');
    }

    return this.prisma.$transaction(async (tx) => {
      const wallet = await tx.wallet.upsert({
        where: { userId },
        create: { userId, balance: 0, locked: 0 },
        update: {},
      });

      const newBalance = wallet.balance + amount;

      const transaction = await tx.walletTransaction.create({
        data: {
          walletId: wallet.id,
          type: TransactionType.CREDIT,
          category,
          amount,
          balanceAfter: newBalance,
          description,
          referenceId,
          metadata: metadata as any,
        },
      });

      await tx.wallet.update({
        where: { id: wallet.id },
        data: { balance: newBalance },
      });

      return transaction;
    });
  }

  /**
   * Debit wallet (atomic operation)
   */
  async debit(
    userId: string,
    amount: number,
    category: TransactionCategory,
    description: string,
    referenceId?: string,
    metadata?: any,
  ) {
    if (amount <= 0) {
      throw new BadRequestException('Amount must be positive');
    }

    return this.prisma.$transaction(async (tx) => {
      const wallet = await tx.wallet.upsert({
        where: { userId },
        create: { userId, balance: 0, locked: 0 },
        update: {},
      });

      if (wallet.balance - wallet.locked < amount) {
        throw new BadRequestException('Insufficient balance');
      }

      const newBalance = wallet.balance - amount;

      const transaction = await tx.walletTransaction.create({
        data: {
          walletId: wallet.id,
          type: TransactionType.DEBIT,
          category,
          amount,
          balanceAfter: newBalance,
          description,
          referenceId,
          metadata: metadata as any,
        },
      });

      await tx.wallet.update({
        where: { id: wallet.id },
        data: { balance: newBalance },
      });

      return transaction;
    });
  }

  /**
   * Lock amount (for pending transactions)
   */
  async lock(userId: string, amount: number) {
    return this.prisma.$transaction(async (tx) => {
      const wallet = await tx.wallet.findUnique({ where: { userId } });
      if (!wallet) throw new NotFoundException('Wallet not found');

      if (wallet.balance - wallet.locked < amount) {
        throw new BadRequestException('Insufficient balance to lock');
      }

      return tx.wallet.update({
        where: { id: wallet.id },
        data: { locked: wallet.locked + amount },
      });
    });
  }

  /**
   * Unlock amount
   */
  async unlock(userId: string, amount: number) {
    return this.prisma.$transaction(async (tx) => {
      const wallet = await tx.wallet.findUnique({ where: { userId } });
      if (!wallet) throw new NotFoundException('Wallet not found');

      if (wallet.locked < amount) {
        throw new BadRequestException('Cannot unlock more than locked amount');
      }

      return tx.wallet.update({
        where: { id: wallet.id },
        data: { locked: wallet.locked - amount },
      });
    });
  }

  /**
   * Get transaction history
   */
  async getTransactionHistory(userId: string, limit = 50, offset = 0) {
    const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
    if (!wallet) {
      return { transactions: [], total: 0 };
    }

    const [transactions, total] = await Promise.all([
      this.prisma.walletTransaction.findMany({
        where: { walletId: wallet.id },
        orderBy: { createdAt: 'desc' },
        take: limit,
        skip: offset,
      }),
      this.prisma.walletTransaction.count({
        where: { walletId: wallet.id },
      }),
    ]);

    return { transactions, total };
  }
}

