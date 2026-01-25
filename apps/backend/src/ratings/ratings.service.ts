import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { RatingValue, JobState } from '@prisma/client';

@Injectable()
export class RatingsService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Submit rating for a completed job
   */
  async submitRating(jobId: string, customerId: string, rating: RatingValue, comment?: string) {
    const job = await this.prisma.job.findUnique({
      where: { id: jobId },
      include: { driver: true },
    });

    if (!job) throw new NotFoundException('Job not found');
    if (job.customerId !== customerId) {
      throw new BadRequestException('Access denied');
    }
    if (job.state !== JobState.COMPLETED) {
      throw new BadRequestException('Can only rate completed jobs');
    }
    if (!job.driverId) {
      throw new BadRequestException('Job has no assigned driver');
    }

    // Check if already rated
    const existing = await this.prisma.rating.findUnique({
      where: { jobId },
    });
    if (existing) {
      throw new BadRequestException('Job already rated');
    }

    // Create rating
    const ratingRecord = await this.prisma.rating.create({
      data: {
        jobId,
        customerId,
        driverId: job.driverId,
        rating,
        comment,
      },
      include: {
        job: { include: { service: true } },
        driver: { include: { user: { select: { name: true } } } },
      },
    });

    // Update driver average rating
    await this.updateDriverRating(job.driverId);

    return ratingRecord;
  }

  /**
   * Get rating for a job
   */
  async getJobRating(jobId: string) {
    return this.prisma.rating.findUnique({
      where: { jobId },
      include: {
        customer: { select: { id: true, name: true } },
        driver: { include: { user: { select: { name: true } } } },
      },
    });
  }

  /**
   * Get driver ratings
   */
  async getDriverRatings(driverId: string, limit = 20, offset = 0) {
    const [ratings, total] = await Promise.all([
      this.prisma.rating.findMany({
        where: { driverId },
        include: {
          customer: { select: { id: true, name: true } },
          job: { include: { service: true } },
        },
        orderBy: { createdAt: 'desc' },
        take: limit,
        skip: offset,
      }),
      this.prisma.rating.count({ where: { driverId } }),
    ]);

    // Calculate average
    const avgRating = await this.calculateAverageRating(driverId);

    return { ratings, total, averageRating: avgRating };
  }

  /**
   * Update driver average rating
   */
  private async updateDriverRating(driverId: string) {
    const avgRating = await this.calculateAverageRating(driverId);
    await this.prisma.driver.update({
      where: { id: driverId },
      data: { avgRating },
    });
  }

  /**
   * Calculate average rating for driver
   */
  private async calculateAverageRating(driverId: string) {
    const ratings = await this.prisma.rating.findMany({
      where: { driverId },
      select: { rating: true },
    });

    if (ratings.length === 0) return null;

    const ratingMap: Record<RatingValue, number> = {
      ONE: 1,
      TWO: 2,
      THREE: 3,
      FOUR: 4,
      FIVE: 5,
    };

    const sum = ratings.reduce((acc, r) => acc + ratingMap[r.rating], 0);
    const avg = sum / ratings.length;

    return Number(avg.toFixed(2));
  }
}

