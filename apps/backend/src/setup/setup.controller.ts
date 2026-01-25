import { Controller, Post } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import { ServiceCode } from '@prisma/client';

@Controller('setup')
export class SetupController {
  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
  ) {}

  @Post('seed-services')
  async seedServices() {
    const env = this.config.get<string>('NODE_ENV') ?? 'development';
    if (env !== 'development') {
      return { ok: false, message: 'Not allowed outside development' };
    }

    const services: Array<{ code: ServiceCode; name: string }> = [
      { code: ServiceCode.TOW, name: 'Tow' },
      { code: ServiceCode.JUMP_START, name: 'Jump-start' },
      { code: ServiceCode.FUEL_DELIVERY, name: 'Fuel Delivery' },
      { code: ServiceCode.FLAT_TYRE, name: 'Flat Tyre' },
    ];

    for (const s of services) {
      await this.prisma.service.upsert({
        where: { code: s.code },
        create: { code: s.code, name: s.name },
        update: { name: s.name, isActive: true },
      });
    }

    return { ok: true, seeded: services.map((s) => s.code) };
  }
}


