import { Body, Controller, Post } from '@nestjs/common';
import { CreatePricingRuleDto } from './dto/create-pricing-rule.dto';
import { PricingService } from './pricing.service';
import { ServiceCode } from '@prisma/client';

// NOTE: This is a temporary dev-only controller to create pricing rules quickly.
// In Phase 5 we will move this under /admin with RBAC + audit logs.
@Controller('pricing')
export class PricingController {
  constructor(private readonly pricing: PricingService) {}

  @Post('rules')
  async createRule(@Body() dto: CreatePricingRuleDto) {
    const rule = await this.pricing.createRule({
      city: dto.city,
      serviceCode: dto.service_code as ServiceCode,
      baseFare: dto.base_fare,
      perKm: dto.per_km,
      perMin: dto.per_min,
      minFare: dto.min_fare,
      platformFee: dto.platform_fee,
      taxPct: dto.tax_pct,
      effectiveFrom: new Date(dto.effective_from),
      surgeJson: dto.surge_json,
    });
    return { rule };
  }
}


