import { Injectable, ServiceUnavailableException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { RedisService } from '../redis/redis.service';

@Injectable()
export class HealthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly redisService: RedisService,
  ) {}

  async db() {
    try {
      await this.prisma.$queryRaw`SELECT 1`;
      return { ok: true };
    } catch (e) {
      throw new ServiceUnavailableException('Database not ready');
    }
  }

  async checkRedis() {
    try {
      const pong = await this.redisService.client.ping();
      if (pong !== 'PONG') throw new Error('Bad redis ping');
      return { ok: true };
    } catch (e) {
      throw new ServiceUnavailableException('Redis not ready');
    }
  }
}

