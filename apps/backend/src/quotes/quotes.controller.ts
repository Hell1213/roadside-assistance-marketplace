import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { QuotesService } from './quotes.service';
import { CreateQuoteDto } from './dto/create-quote.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { ServiceCode } from '@prisma/client';

@Controller('quotes')
export class QuotesController {
  constructor(private readonly quotes: QuotesService) {}

  @UseGuards(JwtAuthGuard)
  @Post()
  async create(
    @CurrentUser() user: { userId: string },
    @Body() dto: CreateQuoteDto,
  ) {
    return this.quotes.createQuote({
      customerId: user.userId,
      city: dto.city,
      serviceCode: dto.service_code as ServiceCode,
      vehicleClass: dto.vehicle_class,
      origin: { lat: dto.origin_lat, lng: dto.origin_lng },
      dest:
        dto.dest_lat != null && dto.dest_lng != null
          ? { lat: dto.dest_lat, lng: dto.dest_lng }
          : undefined,
    });
  }
}


