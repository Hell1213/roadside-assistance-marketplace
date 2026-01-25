import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { ServiceCode } from '@prisma/client';

@Injectable()
export class PricingService {
  constructor(private readonly prisma: PrismaService) {}

  async createRule(params: {
    city: string;
    serviceCode: ServiceCode;
    baseFare: number;
    perKm: number;
    perMin: number;
    minFare: number;
    platformFee: number;
    taxPct: number; // percent (e.g. 18)
    effectiveFrom: Date;
    surgeJson?: any;
  }) {
    const service = await this.prisma.service.findUnique({
      where: { code: params.serviceCode },
    });
    if (!service) throw new Error(`Service ${params.serviceCode} not seeded`);

    const latest = await this.prisma.pricingRule.findFirst({
      where: { city: params.city, serviceId: service.id },
      orderBy: { version: 'desc' },
    });
    const nextVersion = (latest?.version ?? 0) + 1;

    return this.prisma.pricingRule.create({
      data: {
        city: params.city,
        serviceId: service.id,
        baseFare: params.baseFare,
        perKm: params.perKm,
        perMin: params.perMin,
        minFare: params.minFare,
        surgeJson: params.surgeJson,
        platformFee: params.platformFee,
        taxPct: params.taxPct,
        effectiveFrom: params.effectiveFrom,
        version: nextVersion,
      },
    });
  }

  async getActiveRule(city: string, serviceCode: ServiceCode, at = new Date()) {
    const service = await this.prisma.service.findUnique({
      where: { code: serviceCode },
    });
    if (!service) throw new Error(`Service ${serviceCode} not seeded`);

    const rule = await this.prisma.pricingRule.findFirst({
      where: {
        city,
        serviceId: service.id,
        effectiveFrom: { lte: at },
      },
      orderBy: [{ effectiveFrom: 'desc' }, { version: 'desc' }],
    });
    return { service, rule };
  }

  computeFare(params: {
    baseFare: number;
    perKm: number;
    perMin: number;
    minFare: number;
    platformFee: number;
    taxPct: number; // percent
    distanceKm: number;
    timeMin: number;
    surgeMultiplier?: number;
  }) {
    const surge = params.surgeMultiplier ?? 1;

    const base =
      params.baseFare +
      params.perKm * params.distanceKm +
      params.perMin * params.timeMin;
    const minApplied = Math.max(base, params.minFare);
    const surged = minApplied * surge + params.platformFee;
    const taxed = Math.round(surged * (1 + params.taxPct / 100));

    return {
      price: taxed,
      breakdown: {
        base_fare: params.baseFare,
        distance_km: params.distanceKm,
        time_min: params.timeMin,
        per_km: params.perKm,
        per_min: params.perMin,
        min_fare: params.minFare,
        surge_multiplier: surge,
        platform_fee: params.platformFee,
        tax_pct: params.taxPct,
        subtotal: surged,
        total: taxed,
      },
    };
  }
}


