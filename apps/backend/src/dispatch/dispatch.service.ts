import { Injectable, NotFoundException, BadRequestException, Inject, forwardRef } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { RedisService } from '../redis/redis.service';
import { JobsService } from '../jobs/jobs.service';
import { RealtimeService } from '../realtime/realtime.service';
import { JobState } from '@prisma/client';

@Injectable()
export class DispatchService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly redis: RedisService,
    private readonly jobs: JobsService,
    @Inject(forwardRef(() => RealtimeService))
    private readonly realtime: RealtimeService,
  ) {}

  async findNearestDrivers(
    originLat: number,
    originLng: number,
    serviceCode: string,
    radiusKm = 10,
    limit = 10,
  ) {
    // PostGIS query: find drivers within radius, online, with service capability
    const query = `
      SELECT 
        d.id,
        d."userId",
        d.status,
        d."capabilities",
        ST_Distance(
          dl.location::geography,
          ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography
        ) / 1000.0 AS distance_km
      FROM "Driver" d
      LEFT JOIN "DriverLocation" dl ON dl."driverId" = d.id
      WHERE 
        d.status = 'ONLINE'
        AND $3 = ANY(d."capabilities")
        AND dl.location IS NOT NULL
        AND ST_DWithin(
          dl.location::geography,
          ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography,
          $4 * 1000
        )
      ORDER BY distance_km ASC
      LIMIT $5
    `;

    const results = await this.prisma.$queryRawUnsafe<any[]>(
      query,
      originLng,
      originLat,
      serviceCode,
      radiusKm,
      limit,
    );

    return results.map((r) => ({
      driverId: r.id,
      userId: r.userId,
      distanceKm: parseFloat(r.distance_km),
      capabilities: r.capabilities,
    }));
  }

  async offerJobToDriver(jobId: string, driverId: string, ttlSeconds = 60) {
    const job = await this.prisma.job.findUnique({ where: { id: jobId }, include: { service: true } });
    if (!job) throw new NotFoundException('Job not found');
    if (job.state !== JobState.CREATED && job.state !== JobState.DISPATCHING) {
      throw new BadRequestException(`Job must be CREATED or DISPATCHING, current: ${job.state}`);
    }

    // Set job to DISPATCHING if still CREATED
    if (job.state === JobState.CREATED) {
      await this.jobs.updateJobState(jobId, JobState.DISPATCHING, 'system', { dispatchedAt: new Date().toISOString() });
    }

    // Store offer in Redis with TTL
    const offerKey = `job_offer:${jobId}:${driverId}`;
    await this.redis.client.setex(
      offerKey,
      ttlSeconds,
      JSON.stringify({
        jobId,
        driverId,
        expiresAt: new Date(Date.now() + ttlSeconds * 1000).toISOString(),
      }),
    );

    // Also track which drivers have been offered this job
    await this.redis.client.sadd(`job_offers:${jobId}`, driverId);

    // Notify driver via WebSocket
    const driver = await this.prisma.driver.findUnique({
      where: { id: driverId },
      select: { userId: true },
    });
    if (driver) {
      await this.realtime.notifyDriverJobOffer(driver.userId, jobId, {
        jobId,
        service: job.service,
        quote: await this.prisma.quote.findUnique({ where: { id: job.quoteId } }),
        expiresAt: new Date(Date.now() + ttlSeconds * 1000).toISOString(),
      });
    }

    return {
      jobId,
      driverId,
      ttlSeconds,
      expiresAt: new Date(Date.now() + ttlSeconds * 1000).toISOString(),
    };
  }

  async acceptJobOffer(jobId: string, driverId: string) {
    const offerKey = `job_offer:${jobId}:${driverId}`;
    const offerData = await this.redis.client.get(offerKey);
    if (!offerData) {
      throw new BadRequestException('Job offer expired or not found');
    }

    // Check if job already assigned
    const job = await this.prisma.job.findUnique({ where: { id: jobId } });
    if (!job) throw new NotFoundException('Job not found');
    if (job.driverId) {
      throw new BadRequestException('Job already assigned to another driver');
    }

    // Assign driver and update state
    await this.prisma.job.update({
      where: { id: jobId },
      data: { driverId },
    });

    await this.jobs.updateJobState(jobId, JobState.ASSIGNED, driverId, {
      acceptedAt: new Date().toISOString(),
    });

    // Clean up Redis offers
    await this.redis.client.del(offerKey);
    await this.redis.client.srem(`job_offers:${jobId}`, driverId);

    // Return updated job
    const updatedJob = await this.prisma.job.findUnique({
      where: { id: jobId },
      include: {
        service: true,
        customer: { select: { id: true, phone: true, name: true } },
        driver: { include: { user: { select: { id: true, phone: true, name: true } }, vehicle: true } },
        quote: true,
        statusHistory: { orderBy: { createdAt: 'desc' }, take: 10 },
      },
    });

    return updatedJob!;
  }

  async getPendingOffersForDriver(driverId: string) {
    // Find all job offers for this driver
    const pattern = `job_offer:*:${driverId}`;
    const keys = await this.redis.client.keys(pattern);

    const offers: Array<{ jobId: string; driverId: string; expiresAt: string; job: any }> = [];
    for (const key of keys) {
      const data = await this.redis.client.get(key);
      if (data) {
        const offer = JSON.parse(data) as { jobId: string; driverId: string; expiresAt: string };
        const job = await this.prisma.job.findUnique({
          where: { id: offer.jobId },
          include: {
            service: true,
            customer: { select: { id: true, phone: true, name: true } },
            quote: true,
          },
        });
        if (job && job.state === JobState.DISPATCHING) {
          offers.push({
            ...offer,
            job,
          });
        }
      }
    }

    return offers;
  }
}

