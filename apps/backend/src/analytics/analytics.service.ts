import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { JobState, PaymentStatus, PayoutStatus } from '@prisma/client';

@Injectable()
export class AnalyticsService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Get dashboard metrics
   */
  async getDashboardMetrics(startDate?: Date, endDate?: Date) {
    const where: any = {};
    if (startDate || endDate) {
      where.createdAt = {};
      if (startDate) where.createdAt.gte = startDate;
      if (endDate) where.createdAt.lte = endDate;
    }

    const [
      totalJobs,
      completedJobs,
      cancelledJobs,
      totalRevenue,
      totalCommissions,
      totalPayouts,
      activeDrivers,
      totalCustomers,
      pendingPayments,
    ] = await Promise.all([
      this.prisma.job.count({ where }),
      this.prisma.job.count({ where: { ...where, state: 'COMPLETED' } }),
      this.prisma.job.count({ where: { ...where, state: 'CANCELLED' } }),
      this.prisma.payment.aggregate({
        where: { ...where, status: PaymentStatus.CAPTURED },
        _sum: { amount: true },
      }),
      this.prisma.walletTransaction.aggregate({
        where: {
          ...where,
          category: 'COMMISSION',
          type: 'CREDIT',
        },
        _sum: { amount: true },
      }),
      this.prisma.payout.aggregate({
        where: { ...where, status: PayoutStatus.COMPLETED },
        _sum: { amount: true },
      }),
      this.prisma.driver.count({ where: { status: 'ONLINE' } }),
      this.prisma.user.count({ where: { roles: { has: 'CUSTOMER' } } }),
      this.prisma.payment.count({ where: { ...where, status: PaymentStatus.PENDING } }),
    ]);

    return {
      jobs: {
        total: totalJobs,
        completed: completedJobs,
        cancelled: cancelledJobs,
        completionRate: totalJobs > 0 ? (completedJobs / totalJobs) * 100 : 0,
      },
      revenue: {
        total: totalRevenue._sum.amount || 0,
        commissions: totalCommissions._sum.amount || 0,
        netRevenue: (totalRevenue._sum.amount || 0) - (totalCommissions._sum.amount || 0),
        pendingPayments,
      },
      payouts: {
        total: totalPayouts._sum.amount || 0,
      },
      users: {
        activeDrivers,
        totalCustomers,
      },
    };
  }

  /**
   * Get job statistics by service
   */
  async getJobStatsByService(startDate?: Date, endDate?: Date) {
    const where: any = {};
    if (startDate || endDate) {
      where.createdAt = {};
      if (startDate) where.createdAt.gte = startDate;
      if (endDate) where.createdAt.lte = endDate;
    }

    const jobs = await this.prisma.job.groupBy({
      by: ['serviceId'],
      where,
      _count: { id: true },
    });

    const services = await this.prisma.service.findMany({
      where: { id: { in: jobs.map((j) => j.serviceId) } },
    });

    return jobs.map((job) => ({
      service: services.find((s) => s.id === job.serviceId),
      count: job._count.id,
    }));
  }

  /**
   * Get driver performance metrics
   */
  async getDriverPerformance(driverId?: string, startDate?: Date, endDate?: Date) {
    const where: any = {};
    if (driverId) where.driverId = driverId;
    if (startDate || endDate) {
      where.createdAt = {};
      if (startDate) where.createdAt.gte = startDate;
      if (endDate) where.createdAt.lte = endDate;
    }

    const [totalJobs, completedJobs, ratingsData] = await Promise.all([
      this.prisma.job.count({ where: { ...where, driverId: driverId || undefined } }),
      this.prisma.job.count({ where: { ...where, state: 'COMPLETED', driverId: driverId || undefined } }),
      driverId
        ? this.prisma.rating.findMany({
            where: { driverId },
            select: { rating: true },
          })
        : Promise.resolve<Array<{ rating: string }>>([]),
    ]);

    const ratings = ratingsData as Array<{ rating: string }>;
    const ratingMap: Record<string, number> = {
      ONE: 1,
      TWO: 2,
      THREE: 3,
      FOUR: 4,
      FIVE: 5,
    };

    const avgRating = ratings.length > 0
      ? ratings.reduce((sum, r) => sum + (ratingMap[r.rating] || 0), 0) / ratings.length
      : null;

    return {
      totalJobs,
      completedJobs,
      completionRate: totalJobs > 0 ? (completedJobs / totalJobs) * 100 : 0,
      averageRating: avgRating ? Number(avgRating.toFixed(2)) : null,
      totalRatings: ratings.length,
    };
  }

  /**
   * Get revenue trends (daily/weekly/monthly)
   */
  async getRevenueTrends(period: 'daily' | 'weekly' | 'monthly', days = 30) {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const payments = await this.prisma.payment.findMany({
      where: {
        status: PaymentStatus.CAPTURED,
        createdAt: { gte: startDate },
      },
      select: {
        amount: true,
        createdAt: true,
      },
    });

    // Group by period
    const grouped: Record<string, number> = {};
    payments.forEach((payment) => {
      const date = new Date(payment.createdAt);
      let key: string;

      if (period === 'daily') {
        key = date.toISOString().split('T')[0];
      } else if (period === 'weekly') {
        const week = Math.floor(date.getDate() / 7);
        key = `${date.getFullYear()}-W${date.getMonth() + 1}-${week}`;
      } else {
        key = `${date.getFullYear()}-${date.getMonth() + 1}`;
      }

      grouped[key] = (grouped[key] || 0) + payment.amount;
    });

    return Object.entries(grouped).map(([period, revenue]) => ({
      period,
      revenue,
    }));
  }
}

