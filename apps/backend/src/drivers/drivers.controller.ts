import { Body, Controller, Get, Put, Post, Param, UseGuards, ParseUUIDPipe } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { PrismaService } from '../prisma/prisma.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { Roles, RolesGuard } from '../auth/guards/roles.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { UpsertDriverProfileDto } from './dto/upsert-driver-profile.dto';
import { UpsertVehicleDto } from './dto/upsert-vehicle.dto';
import { UpdateJobStatusDto } from '../jobs/dto/update-job-status.dto';
import { DispatchService } from '../dispatch/dispatch.service';
import { JobsService } from '../jobs/jobs.service';
import { RealtimeService } from '../realtime/realtime.service';
import { UpdateLocationDto } from './dto/update-location.dto';
import { DriverStatus, ServiceCode } from '@prisma/client';

@ApiTags('Driver')
@Controller('driver')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('DRIVER')
@ApiBearerAuth()
export class DriversController {
  constructor(
    private readonly prisma: PrismaService,
    private readonly dispatch: DispatchService,
    private readonly jobs: JobsService,
    private readonly realtime: RealtimeService,
  ) {}

  @Get('profile')
  async profile(@CurrentUser() user: { userId: string }) {
    const driver = await this.prisma.driver.findUnique({
      where: { userId: user.userId },
      include: { vehicle: true },
    });
    return { driver };
  }

  @Put('profile')
  async upsertProfile(
    @CurrentUser() user: { userId: string },
    @Body() dto: UpsertDriverProfileDto,
  ) {
    const driver = await this.prisma.driver.upsert({
      where: { userId: user.userId },
      create: {
        userId: user.userId,
        status: (dto.status as DriverStatus | undefined) ?? DriverStatus.OFFLINE,
        capabilities: (dto.capabilities as ServiceCode[] | undefined) ?? [],
      },
      update: {
        status: dto.status ? (dto.status as DriverStatus) : undefined,
        capabilities: dto.capabilities ? (dto.capabilities as ServiceCode[]) : undefined,
      },
      include: { vehicle: true },
    });
    return { driver };
  }

  @Put('vehicle')
  async upsertVehicle(
    @CurrentUser() user: { userId: string },
    @Body() dto: UpsertVehicleDto,
  ) {
    // ensure driver exists
    const driver = await this.prisma.driver.upsert({
      where: { userId: user.userId },
      create: { userId: user.userId, capabilities: [] },
      update: {},
    });

    const vehicle = await this.prisma.vehicle.upsert({
      where: { driverId: driver.id },
      create: {
        driverId: driver.id,
        type: dto.type,
        plateNo: dto.plateNo,
        make: dto.make,
        model: dto.model,
        year: dto.year,
      },
      update: {
        type: dto.type,
        plateNo: dto.plateNo,
        make: dto.make,
        model: dto.model,
        year: dto.year,
      },
    });

    return { vehicle };
  }

  @Get('jobs')
  @ApiOperation({ summary: 'Get pending job offers for driver' })
  async getPendingJobs(@CurrentUser() user: { userId: string }) {
    const driver = await this.prisma.driver.findUnique({ where: { userId: user.userId } });
    if (!driver) throw new Error('Driver not found');
    const offers = await this.dispatch.getPendingOffersForDriver(driver.id);
    return { offers };
  }

  @Post('jobs/:id/accept')
  @ApiOperation({ summary: 'Accept a job offer' })
  async acceptJob(
    @CurrentUser() user: { userId: string },
    @Param('id', ParseUUIDPipe) jobId: string,
  ) {
    const driver = await this.prisma.driver.findUnique({ where: { userId: user.userId } });
    if (!driver) throw new Error('Driver not found');
    const job = await this.dispatch.acceptJobOffer(jobId, driver.id);
    return { job };
  }

  @Post('jobs/:id/status')
  @ApiOperation({ summary: 'Update job status (arrived, in_progress, completed)' })
  async updateJobStatus(
    @CurrentUser() user: { userId: string },
    @Param('id', ParseUUIDPipe) jobId: string,
    @Body() dto: UpdateJobStatusDto,
  ) {
    const driver = await this.prisma.driver.findUnique({ where: { userId: user.userId } });
    if (!driver) throw new Error('Driver not found');
    const job = await this.jobs.updateJobState(jobId, dto.state, driver.id, dto.meta);
    return { job };
  }

  @Post('location')
  @ApiOperation({ summary: 'Update driver location (for active jobs, broadcasts to customers)' })
  async updateLocation(
    @CurrentUser() user: { userId: string },
    @Body() dto: UpdateLocationDto,
  ) {
    const driver = await this.prisma.driver.findUnique({ where: { userId: user.userId } });
    if (!driver) throw new Error('Driver not found');

    // Update location in database
    await this.prisma.$queryRawUnsafe(
      `
      INSERT INTO "DriverLocation" ("driverId", location, "updatedAt")
      VALUES ($1, ST_SetSRID(ST_MakePoint($2, $3), 4326), NOW())
      ON CONFLICT ("driverId") DO UPDATE
      SET location = ST_SetSRID(ST_MakePoint($2, $3), 4326), "updatedAt" = NOW()
    `,
      driver.id,
      dto.lng,
      dto.lat,
    );

    // Find active jobs for this driver and broadcast location
    const activeJobs = await this.prisma.job.findMany({
      where: {
        driverId: driver.id,
        state: {
          in: ['ASSIGNED', 'ARRIVING', 'ARRIVED', 'IN_PROGRESS'],
        },
      },
      select: { id: true },
    });

    for (const job of activeJobs) {
      await this.realtime.broadcastDriverLocation(job.id, {
        lat: dto.lat,
        lng: dto.lng,
        heading: dto.heading,
      });
    }

    return { ok: true };
  }
}


