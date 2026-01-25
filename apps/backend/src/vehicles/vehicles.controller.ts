import { Body, Controller, Delete, Get, Param, Post, Put, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { VehiclesService } from './vehicles.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { AddVehicleDto } from './dto/add-vehicle.dto';

@ApiTags('Vehicles')
@Controller('vehicles')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class VehiclesController {
  constructor(private readonly vehicles: VehiclesService) {}

  @Post()
  @ApiOperation({ summary: 'Add vehicle' })
  async addVehicle(
    @CurrentUser() user: { userId: string },
    @Body() dto: AddVehicleDto,
  ) {
    return this.vehicles.addVehicle(user.userId, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Get customer vehicles' })
  async getVehicles(@CurrentUser() user: { userId: string }) {
    return this.vehicles.getCustomerVehicles(user.userId);
  }

  @Get('default')
  @ApiOperation({ summary: 'Get default vehicle' })
  async getDefaultVehicle(@CurrentUser() user: { userId: string }) {
    return this.vehicles.getDefaultVehicle(user.userId);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update vehicle' })
  async updateVehicle(
    @CurrentUser() user: { userId: string },
    @Param('id') vehicleId: string,
    @Body() dto: Partial<AddVehicleDto>,
  ) {
    return this.vehicles.updateVehicle(vehicleId, user.userId, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete vehicle' })
  async deleteVehicle(
    @CurrentUser() user: { userId: string },
    @Param('id') vehicleId: string,
  ) {
    return this.vehicles.deleteVehicle(vehicleId, user.userId);
  }
}

