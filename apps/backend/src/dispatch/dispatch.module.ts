import { Module, forwardRef } from '@nestjs/common';
import { DispatchService } from './dispatch.service';
import { PrismaModule } from '../prisma/prisma.module';
import { RedisModule } from '../redis/redis.module';
import { JobsModule } from '../jobs/jobs.module';
import { RealtimeModule } from '../realtime/realtime.module';

@Module({
  imports: [PrismaModule, RedisModule, JobsModule, forwardRef(() => RealtimeModule)],
  providers: [DispatchService],
  exports: [DispatchService],
})
export class DispatchModule {}

