import { Body, Controller, Delete, Get, Param, Post, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { NotificationsService } from './notifications.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { RegisterDeviceDto } from './dto/register-device.dto';
import { PrismaService } from '../prisma/prisma.service';

@ApiTags('Notifications')
@Controller('notifications')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class NotificationsController {
  constructor(
    private readonly notifications: NotificationsService,
    private readonly prisma: PrismaService,
  ) {}

  @Post('devices')
  @ApiOperation({ summary: 'Register device token for push notifications' })
  async registerDevice(
    @CurrentUser() user: { userId: string },
    @Body() dto: RegisterDeviceDto,
  ) {
    const deviceToken = await this.prisma.deviceToken.upsert({
      where: { token: dto.token },
      create: {
        userId: user.userId,
        token: dto.token,
        platform: dto.platform,
        fcmToken: dto.fcmToken,
        apnsToken: dto.apnsToken,
        isActive: true,
        lastUsedAt: new Date(),
      },
      update: {
        platform: dto.platform,
        fcmToken: dto.fcmToken,
        apnsToken: dto.apnsToken,
        isActive: true,
        lastUsedAt: new Date(),
      },
    });

    return { deviceToken };
  }

  @Delete('devices/:token')
  @ApiOperation({ summary: 'Unregister device token' })
  async unregisterDevice(
    @CurrentUser() user: { userId: string },
    @Param('token') token: string,
  ) {
    await this.prisma.deviceToken.updateMany({
      where: {
        token,
        userId: user.userId,
      },
      data: {
        isActive: false,
      },
    });

    return { ok: true };
  }

  @Get()
  @ApiOperation({ summary: 'Get notification history' })
  async getNotifications(
    @CurrentUser() user: { userId: string },
  ) {
    const notifications = await this.prisma.notification.findMany({
      where: { userId: user.userId },
      orderBy: { createdAt: 'desc' },
      take: 50,
    });

    return { notifications };
  }
}

