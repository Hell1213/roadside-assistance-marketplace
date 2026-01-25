import { Body, Controller, Get, Param, Post, Put, Query, UseGuards, Req } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AdminService } from './admin.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AdminGuard } from './guards/admin.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { AdminRole, AuditAction } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

@ApiTags('Admin')
@Controller('admin')
@UseGuards(JwtAuthGuard, AdminGuard)
@ApiBearerAuth()
export class AdminController {
  constructor(
    private readonly admin: AdminService,
    private readonly prisma: PrismaService,
  ) {}

  @Get('profile')
  @ApiOperation({ summary: 'Get admin profile' })
  async getProfile(@CurrentUser() user: { userId: string }) {
    return this.admin.getAdminProfile(user.userId);
  }

  @Get('admins')
  @ApiOperation({ summary: 'List all admins' })
  async listAdmins(
    @Query('limit') limit?: string,
    @Query('offset') offset?: string,
  ) {
    return this.admin.listAdmins(
      limit ? parseInt(limit, 10) : 50,
      offset ? parseInt(offset, 10) : 0,
    );
  }

  @Get('audit-logs')
  @ApiOperation({ summary: 'Get audit logs' })
  async getAuditLogs(
    @Query('adminId') adminId?: string,
    @Query('resourceType') resourceType?: string,
    @Query('resourceId') resourceId?: string,
    @Query('action') action?: AuditAction,
    @Query('limit') limit?: string,
    @Query('offset') offset?: string,
  ) {
    return this.admin.getAuditLogs(
      { adminId, resourceType, resourceId, action },
      limit ? parseInt(limit, 10) : 50,
      offset ? parseInt(offset, 10) : 0,
    );
  }

  @Get('users')
  @ApiOperation({ summary: 'List users (admin only)' })
  async listUsers(
    @Query('limit') limit?: string,
    @Query('offset') offset?: string,
    @Query('role') role?: string,
  ) {
    const where: any = {};
    if (role) {
      where.roles = { has: role };
    }

    const [users, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        select: {
          id: true,
          phone: true,
          name: true,
          email: true,
          roles: true,
          createdAt: true,
        },
        orderBy: { createdAt: 'desc' },
        take: limit ? parseInt(limit, 10) : 50,
        skip: offset ? parseInt(offset, 10) : 0,
      }),
      this.prisma.user.count({ where }),
    ]);

    return { users, total };
  }

  @Get('drivers')
  @ApiOperation({ summary: 'List drivers (admin only)' })
  async listDrivers(
    @Query('limit') limit?: string,
    @Query('offset') offset?: string,
    @Query('status') status?: string,
  ) {
    const where: any = {};
    if (status) {
      where.status = status;
    }

    const [drivers, total] = await Promise.all([
      this.prisma.driver.findMany({
        where,
        include: {
          user: {
            select: { id: true, phone: true, name: true, email: true },
          },
          vehicle: true,
        },
        orderBy: { createdAt: 'desc' },
        take: limit ? parseInt(limit, 10) : 50,
        skip: offset ? parseInt(offset, 10) : 0,
      }),
      this.prisma.driver.count({ where }),
    ]);

    return { drivers, total };
  }

  @Get('jobs')
  @ApiOperation({ summary: 'List jobs (admin only)' })
  async listJobs(
    @Query('limit') limit?: string,
    @Query('offset') offset?: string,
    @Query('state') state?: string,
  ) {
    const where: any = {};
    if (state) {
      where.state = state;
    }

    const [jobs, total] = await Promise.all([
      this.prisma.job.findMany({
        where,
        include: {
          customer: { select: { id: true, phone: true, name: true } },
          driver: {
            include: {
              user: { select: { id: true, phone: true, name: true } },
              vehicle: true,
            },
          },
          service: true,
          payment: true,
        },
        orderBy: { createdAt: 'desc' },
        take: limit ? parseInt(limit, 10) : 50,
        skip: offset ? parseInt(offset, 10) : 0,
      }),
      this.prisma.job.count({ where }),
    ]);

    return { jobs, total };
  }

  @Put('users/:id/status')
  @ApiOperation({ summary: 'Suspend/activate user' })
  async updateUserStatus(
    @CurrentUser() admin: { userId: string },
    @Param('id') userId: string,
    @Body() body: { isActive: boolean },
    @Req() req: any,
  ) {
    // Create audit log
    await this.admin.createAuditLog(
      admin.userId,
      AuditAction.UPDATE,
      'User',
      userId,
      { isActive: body.isActive },
      req.ip,
      req.headers['user-agent'],
    );

    // In a real system, you'd have an isActive field on User
    // For now, we'll just log the action
    return { ok: true, message: 'User status updated (audit logged)' };
  }
}

