import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class VehiclesService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Add vehicle for customer
   */
  async addVehicle(userId: string, data: {
    type: string;
    make?: string;
    model?: string;
    year?: number;
    plateNo?: string;
    color?: string;
    isDefault?: boolean;
  }) {
    // If setting as default, unset other defaults
    if (data.isDefault) {
      await this.prisma.customerVehicle.updateMany({
        where: { userId, isDefault: true },
        data: { isDefault: false },
      });
    }

    return this.prisma.customerVehicle.create({
      data: {
        userId,
        ...data,
      },
    });
  }

  /**
   * Update vehicle
   */
  async updateVehicle(vehicleId: string, userId: string, data: {
    type?: string;
    make?: string;
    model?: string;
    year?: number;
    plateNo?: string;
    color?: string;
    isDefault?: boolean;
  }) {
    const vehicle = await this.prisma.customerVehicle.findUnique({
      where: { id: vehicleId },
    });

    if (!vehicle) throw new NotFoundException('Vehicle not found');
    if (vehicle.userId !== userId) {
      throw new BadRequestException('Access denied');
    }

    // If setting as default, unset other defaults
    if (data.isDefault) {
      await this.prisma.customerVehicle.updateMany({
        where: { userId, isDefault: true, id: { not: vehicleId } },
        data: { isDefault: false },
      });
    }

    return this.prisma.customerVehicle.update({
      where: { id: vehicleId },
      data,
    });
  }

  /**
   * Get customer vehicles
   */
  async getCustomerVehicles(userId: string) {
    return this.prisma.customerVehicle.findMany({
      where: { userId },
      orderBy: [{ isDefault: 'desc' }, { createdAt: 'desc' }],
    });
  }

  /**
   * Get default vehicle
   */
  async getDefaultVehicle(userId: string) {
    return this.prisma.customerVehicle.findFirst({
      where: { userId, isDefault: true },
    });
  }

  /**
   * Delete vehicle
   */
  async deleteVehicle(vehicleId: string, userId: string) {
    const vehicle = await this.prisma.customerVehicle.findUnique({
      where: { id: vehicleId },
    });

    if (!vehicle) throw new NotFoundException('Vehicle not found');
    if (vehicle.userId !== userId) {
      throw new BadRequestException('Access denied');
    }

    await this.prisma.customerVehicle.delete({
      where: { id: vehicleId },
    });

    return { ok: true };
  }
}

