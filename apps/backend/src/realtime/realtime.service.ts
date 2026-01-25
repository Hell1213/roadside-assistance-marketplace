import { Injectable, Logger } from '@nestjs/common';
import { RealtimeGateway } from './realtime.gateway';
import { PrismaService } from '../prisma/prisma.service';
import { JobState } from '@prisma/client';

@Injectable()
export class RealtimeService {
  private readonly logger = new Logger(RealtimeService.name);

  constructor(
    private readonly gateway: RealtimeGateway,
    private readonly prisma: PrismaService,
  ) {}

  /**
   * Broadcast job state change to all subscribers
   */
  async broadcastJobStateChange(jobId: string, state: JobState, meta?: any) {
    const job = await this.prisma.job.findUnique({
      where: { id: jobId },
      include: {
        service: true,
        customer: { select: { id: true, phone: true, name: true } },
        driver: {
          include: {
            user: { select: { id: true, phone: true, name: true } },
            vehicle: true,
          },
        },
        quote: true,
      },
    });

    if (!job) {
      this.logger.warn(`Job ${jobId} not found for broadcast`);
      return;
    }

    this.gateway.broadcastJobStateChange(jobId, state, {
      job: {
        id: job.id,
        state: job.state,
        customer: job.customer,
        driver: job.driver,
        service: job.service,
        quote: job.quote,
      },
      meta,
    });

    // Also notify the driver if assigned
    if (job.driverId) {
      const driver = await this.prisma.driver.findUnique({
        where: { id: job.driverId },
        select: { userId: true },
      });
      if (driver) {
        this.gateway.sendToUser(driver.userId, 'job:assigned', {
          jobId: job.id,
          state: job.state,
          customer: job.customer,
          service: job.service,
          quote: job.quote,
        });
      }
    }

    // Notify customer
    this.gateway.sendToUser(job.customerId, 'job:update', {
      jobId: job.id,
      state: job.state,
      driver: job.driver,
      service: job.service,
    });
  }

  /**
   * Broadcast driver location update for an active job
   */
  async broadcastDriverLocation(jobId: string, location: { lat: number; lng: number; heading?: number }) {
    const job = await this.prisma.job.findUnique({
      where: { id: jobId },
      select: { id: true, state: true, driverId: true },
    });

    if (!job || !job.driverId) {
      return;
    }

    // Only broadcast location for jobs in progress states
    const activeStates: JobState[] = [JobState.ASSIGNED, JobState.ARRIVING, JobState.ARRIVED, JobState.IN_PROGRESS];
    if (!activeStates.includes(job.state)) {
      return;
    }

    // Update driver location in database
    await this.prisma.$queryRawUnsafe(
      `
      INSERT INTO "DriverLocation" ("driverId", location, "updatedAt")
      VALUES ($1, ST_SetSRID(ST_MakePoint($2, $3), 4326), NOW())
      ON CONFLICT ("driverId") DO UPDATE
      SET location = ST_SetSRID(ST_MakePoint($2, $3), 4326), "updatedAt" = NOW()
    `,
      job.driverId,
      location.lng,
      location.lat,
    );

    // Broadcast to job subscribers
    this.gateway.broadcastDriverLocation(jobId, location);
  }

  /**
   * Notify driver of new job offer
   */
  async notifyDriverJobOffer(driverUserId: string, jobId: string, offerData: any) {
    this.gateway.sendToUser(driverUserId, 'job:offer', {
      jobId,
      ...offerData,
      expiresAt: offerData.expiresAt,
    });
  }
}

