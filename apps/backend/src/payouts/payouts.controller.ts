import { Body, Controller, Get, Param, Post, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { PayoutsService } from './payouts.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { Roles, RolesGuard } from '../auth/guards/roles.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { CreatePayoutDto } from './dto/create-payout.dto';
import { PrismaService } from '../prisma/prisma.service';

@ApiTags('Payouts')
@Controller('payouts')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('DRIVER')
@ApiBearerAuth()
export class PayoutsController {
  constructor(
    private readonly payouts: PayoutsService,
    private readonly prisma: PrismaService,
  ) {}

  @Post()
  @ApiOperation({ summary: 'Initiate payout' })
  async createPayout(
    @CurrentUser() user: { userId: string },
    @Body() dto: CreatePayoutDto,
  ) {
    const driver = await this.prisma.driver.findUnique({
      where: { userId: user.userId },
    });
    if (!driver) throw new Error('Driver not found');

    return this.payouts.initiatePayout(driver.id, dto.amount, {
      accountNumber: dto.accountNumber,
      ifsc: dto.ifsc,
      name: dto.name,
      contact: dto.contact,
    });
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get payout status' })
  async getPayoutStatus(
    @CurrentUser() user: { userId: string },
    @Param('id') payoutId: string,
  ) {
    const driver = await this.prisma.driver.findUnique({
      where: { userId: user.userId },
    });
    if (!driver) throw new Error('Driver not found');

    return this.payouts.getPayoutStatus(payoutId, driver.id);
  }

  @Get()
  @ApiOperation({ summary: 'Get payout history' })
  async getPayouts(
    @CurrentUser() user: { userId: string },
    @Query('limit') limit?: string,
    @Query('offset') offset?: string,
  ) {
    const driver = await this.prisma.driver.findUnique({
      where: { userId: user.userId },
    });
    if (!driver) throw new Error('Driver not found');

    return this.payouts.getDriverPayouts(
      driver.id,
      limit ? parseInt(limit, 10) : 50,
      offset ? parseInt(offset, 10) : 0,
    );
  }
}

