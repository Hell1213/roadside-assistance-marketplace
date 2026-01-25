import { Controller, Get } from '@nestjs/common';
import { HealthService } from './health.service';

@Controller('health')
export class HealthController {
  constructor(private readonly healthService: HealthService) {}

  @Get()
  async health() {
    return {
      ok: true,
      service: 'ras-backend',
      timestamp: new Date().toISOString(),
    };
  }

  @Get('db')
  async db() {
    return this.healthService.db();
  }

  @Get('redis')
  async redis() {
    return this.healthService.checkRedis();
  }
}

