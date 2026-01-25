import { BadRequestException, Injectable, NotFoundException, Inject, forwardRef } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { JobState } from '@prisma/client';
import { RealtimeService } from '../realtime/realtime.service';
import { WalletsService } from '../wallets/wallets.service';
import { NotificationsService } from '../notifications/notifications.service';
import { ConfigService } from '@nestjs/config';
import { TransactionCategory } from '@prisma/client';

@Injectable()
export class JobsService {
  constructor(
    private readonly prisma: PrismaService,
    @Inject(forwardRef(() => RealtimeService))
    private readonly realtime: RealtimeService,
    private readonly wallets: WalletsService,
    private readonly notifications: NotificationsService,
    private readonly config: ConfigService,
  ) {}

  async createJobFromQuote(quoteId: string, customerId: string) {
    const quote = await this.prisma.quote.findUnique({
      where: { id: quoteId },
      include: { service: true },
    });
    if (!quote) throw new NotFoundException('Quote not found');
    if (quote.customerId !== customerId) throw new BadRequestException('Quote belongs to different customer');

    // Check if quote already used
    const existingJob = await this.prisma.job.findUnique({ where: { quoteId } });
    if (existingJob) throw new BadRequestException('Quote already used to create a job');

    // Create job with CREATED state (use raw SQL for PostGIS geography)
    const jobResult = await this.prisma.$queryRawUnsafe<any>(
      `INSERT INTO "Job" (id, "customerId", "serviceId", "quoteId", "originGeo", "destGeo", "quotedPrice", state, "createdAt", "updatedAt")
       SELECT 
         gen_random_uuid(),
         $1::text,
         $2::text,
         $3::text,
         q."originGeo",
         q."destGeo",
         q.price::integer,
         $4::"JobState",
         NOW(),
         NOW()
       FROM "Quote" q
       WHERE q.id = $3
       RETURNING id`,
      customerId,
      quote.serviceId,
      quoteId,
      JobState.CREATED,
    );

    const jobId = jobResult[0].id;

    // Create status history entry
    await this.prisma.jobStatusHistory.create({
      data: {
        jobId,
        state: JobState.CREATED,
        byActor: customerId,
      },
    });

    // Fetch full job with relations
    const fullJob = await this.prisma.job.findUnique({
      where: { id: jobId },
      include: {
        service: true,
        customer: { select: { id: true, phone: true, name: true } },
        quote: true,
      },
    });

    return fullJob!;
  }

  async updateJobState(jobId: string, newState: JobState, byActor: string, meta?: Record<string, any>) {
    const job = await this.prisma.job.findUnique({ where: { id: jobId } });
    if (!job) throw new NotFoundException('Job not found');

    // Validate state transition (simplified - can be enhanced with state machine)
    const validTransitions: Record<JobState, JobState[]> = {
      [JobState.CREATED]: [JobState.DISPATCHING, JobState.CANCELLED],
      [JobState.DISPATCHING]: [JobState.ASSIGNED, JobState.CANCELLED],
      [JobState.ASSIGNED]: [JobState.ARRIVING, JobState.CANCELLED],
      [JobState.ARRIVING]: [JobState.ARRIVED, JobState.CANCELLED],
      [JobState.ARRIVED]: [JobState.IN_PROGRESS, JobState.CANCELLED],
      [JobState.IN_PROGRESS]: [JobState.COMPLETED, JobState.CANCELLED],
      [JobState.COMPLETED]: [],
      [JobState.CANCELLED]: [],
    };

    if (!validTransitions[job.state].includes(newState)) {
      throw new BadRequestException(`Invalid state transition from ${job.state} to ${newState}`);
    }

    const updated = await this.prisma.job.update({
      where: { id: jobId },
      data: {
        state: newState,
        statusHistory: {
          create: {
            state: newState,
            byActor,
            meta: meta ? (meta as any) : undefined,
          },
        },
      },
      include: {
        service: true,
        customer: { select: { id: true, phone: true, name: true } },
        driver: { include: { user: { select: { id: true, phone: true, name: true } }, vehicle: true } },
        quote: true,
        statusHistory: { orderBy: { createdAt: 'desc' }, take: 10 },
      },
    });

    // Broadcast state change via WebSocket
    await this.realtime.broadcastJobStateChange(jobId, newState, meta);

    // Handle job completion: credit driver wallet and deduct commission
    if (newState === JobState.COMPLETED && updated.driverId) {
      await this.handleJobCompletion(updated);
    }

    // Send notifications for status changes
    if (newState === JobState.ASSIGNED && updated.driver) {
      await this.notifications.notifyJobAssigned(
        jobId,
        updated.driver.user.id,
        {
          jobId,
          serviceName: updated.service.name,
          customerName: updated.customer.name,
        },
      );
      await this.notifications.notifyJobStatusUpdate(
        jobId,
        updated.customerId,
        'ASSIGNED',
        { jobId, driverName: updated.driver.user.name },
      );
    } else if (newState === JobState.ARRIVED) {
      await this.notifications.notifyDriverArrived(
        jobId,
        updated.customerId,
        { jobId, driverName: updated.driver?.user.name },
      );
    } else if (newState === JobState.COMPLETED) {
      await this.notifications.notifyJobCompleted(
        jobId,
        updated.customerId,
        { jobId },
      );
    } else {
      await this.notifications.notifyJobStatusUpdate(
        jobId,
        updated.customerId,
        newState,
        { jobId },
      );
    }

    return updated;
  }

  /**
   * Handle job completion: credit driver wallet after deducting commission
   */
  private async handleJobCompletion(job: any) {
    const commissionPct = this.config.get<number>('platformCommissionPct') ?? 15;
    const totalAmount = job.quotedPrice;
    const commission = Math.round((totalAmount * commissionPct) / 100);
    const driverAmount = totalAmount - commission;

    // Get driver user ID
    const driver = await this.prisma.driver.findUnique({
      where: { id: job.driverId },
      include: { user: true },
    });

    if (!driver) return;

    // Credit driver wallet with amount after commission
    await this.wallets.credit(
      driver.userId,
      driverAmount,
      TransactionCategory.COMMISSION,
      `Job completion: ${job.id} (Commission: ₹${commission})`,
      job.id,
      {
        jobId: job.id,
        totalAmount,
        commission,
        driverAmount,
        commissionPct,
      },
    );
  }

  async assignDriver(jobId: string, driverId: string) {
    const job = await this.prisma.job.findUnique({ where: { id: jobId } });
    if (!job) throw new NotFoundException('Job not found');
    if (job.state !== JobState.DISPATCHING) {
      throw new BadRequestException(`Job must be in DISPATCHING state, current: ${job.state}`);
    }

    // Update driverId and state atomically
    const updated = await this.prisma.job.update({
      where: { id: jobId },
      data: {
        driverId,
        state: JobState.ASSIGNED,
        statusHistory: {
          create: {
            state: JobState.ASSIGNED,
            byActor: driverId,
            meta: { assignedAt: new Date().toISOString() } as any,
          },
        },
      },
      include: {
        service: true,
        customer: { select: { id: true, phone: true, name: true } },
        driver: { include: { user: { select: { id: true, phone: true, name: true } }, vehicle: true } },
        quote: true,
        statusHistory: { orderBy: { createdAt: 'desc' }, take: 10 },
      },
    });

    return updated;
  }

  async getJobById(jobId: string, userId: string) {
    const job = await this.prisma.job.findUnique({
      where: { id: jobId },
      include: {
        service: true,
        customer: { select: { id: true, phone: true, name: true } },
        driver: { include: { user: { select: { id: true, phone: true, name: true } }, vehicle: true } },
        quote: true,
        statusHistory: { orderBy: { createdAt: 'desc' }, take: 20 },
      },
    });

    if (!job) throw new NotFoundException('Job not found');
    if (job.customerId !== userId && job.driverId !== userId) {
      throw new BadRequestException('Access denied');
    }

    return job;
  }

  async getCustomerJobs(customerId: string, limit = 50) {
    return this.prisma.job.findMany({
      where: { customerId },
      include: {
        service: true,
        driver: { include: { user: { select: { id: true, phone: true, name: true } }, vehicle: true } },
        quote: true,
      },
      orderBy: { createdAt: 'desc' },
      take: limit,
    });
  }
}

