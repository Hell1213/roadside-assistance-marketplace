import { BadRequestException, Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { PricingService } from '../pricing/pricing.service';
import { haversineKm } from './geo';
import { randomUUID } from 'crypto';

@Injectable()
export class QuotesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly pricing: PricingService,
  ) {}

  async createQuote(params: {
    customerId: string;
    city: string;
    serviceCode: 'TOW' | 'JUMP_START' | 'FUEL_DELIVERY' | 'FLAT_TYRE';
    vehicleClass?: string;
    origin: { lat: number; lng: number };
    dest?: { lat: number; lng: number };
  }) {
    const { service, rule } = await this.pricing.getActiveRule(
      params.city,
      params.serviceCode,
    );
    if (!rule) throw new BadRequestException('No pricing rule configured for this city/service');

    // For Phase 2B we use haversine approximation.
    // Later we will replace with Google Distance Matrix for road distance + traffic ETA.
    const distanceKm = params.dest
      ? haversineKm(
          params.origin.lat,
          params.origin.lng,
          params.dest.lat,
          params.dest.lng,
        )
      : 0;

    const etaMin = Math.max(5, Math.round((distanceKm / 30) * 60)); // assume 30km/h baseline

    const { price, breakdown } = this.pricing.computeFare({
      baseFare: rule.baseFare,
      perKm: rule.perKm,
      perMin: rule.perMin,
      minFare: rule.minFare,
      platformFee: rule.platformFee,
      taxPct: Number(rule.taxPct),
      distanceKm,
      timeMin: etaMin,
      surgeMultiplier: 1,
    });

    // Insert using raw SQL because PostGIS geography is represented as Unsupported() in Prisma schema.
    const id = randomUUID();
    const destLng = params.dest?.lng ?? null;
    const destLat = params.dest?.lat ?? null;
    const rows: Array<{ id: string }> = await (this.prisma as any).$queryRawUnsafe(
      `
      INSERT INTO "Quote"
        ("id","customerId","serviceId","vehicleClass","originGeo","destGeo","distanceKm","etaMin","price","breakdown","createdAt")
      VALUES
        ($1, $2, $3, $4,
         ST_SetSRID(ST_MakePoint(CAST($5 AS double precision), CAST($6 AS double precision)),4326)::geography,
         CASE
           WHEN CAST($7 AS double precision) IS NULL OR CAST($8 AS double precision) IS NULL THEN NULL
           ELSE ST_SetSRID(ST_MakePoint(CAST($7 AS double precision), CAST($8 AS double precision)),4326)::geography
         END,
         CAST($9 AS double precision),
         CAST($10 AS integer),
         CAST($11 AS integer),
         $12::jsonb,
         NOW())
      RETURNING "id"
      `,
      id,
      params.customerId,
      service.id,
      params.vehicleClass ?? null,
      params.origin.lng,
      params.origin.lat,
      destLng,
      destLat,
      distanceKm,
      etaMin,
      price,
      JSON.stringify(breakdown),
    );

    const quoteId = rows[0]?.id;
    if (!quoteId) throw new Error('Failed to create quote');

    return {
      quote_id: quoteId,
      service: { code: service.code, name: service.name },
      city: params.city,
      distance_km: distanceKm,
      eta_min: etaMin,
      price,
      breakdown,
    };
  }
}


