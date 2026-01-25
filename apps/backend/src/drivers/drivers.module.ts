import { Module } from '@nestjs/common';
import { DriversController } from './drivers.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { RolesGuard } from '../auth/guards/roles.guard';
import { DispatchModule } from '../dispatch/dispatch.module';
import { JobsModule } from '../jobs/jobs.module';
import { RealtimeModule } from '../realtime/realtime.module';

@Module({
  imports: [PrismaModule, DispatchModule, JobsModule, RealtimeModule],
  controllers: [DriversController],
  providers: [RolesGuard],
})
export class DriversModule {}


