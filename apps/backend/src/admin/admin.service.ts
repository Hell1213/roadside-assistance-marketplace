import { Injectable, BadRequestException, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { AdminRole, AuditAction, UserRole } from '@prisma/client';

@Injectable()
export class AdminService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Create or update admin profile
   */
  async upsertAdminProfile(userId: string, role: AdminRole) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');

    // Ensure user has ADMIN role
    if (!user.roles.includes(UserRole.ADMIN)) {
      await this.prisma.user.update({
        where: { id: userId },
        data: { roles: { push: UserRole.ADMIN } },
      });
    }

    return this.prisma.adminProfile.upsert({
      where: { userId },
      create: {
        userId,
        role,
        isActive: true,
      },
      update: {
        role,
      },
    });
  }

  /**
   * Check if user is admin
   */
  async isAdmin(userId: string): Promise<boolean> {
    const admin = await this.prisma.adminProfile.findUnique({
      where: { userId },
    });
    return admin?.isActive === true;
  }

  /**
   * Check if user has required admin role
   */
  async hasRole(userId: string, requiredRole: AdminRole): Promise<boolean> {
    const admin = await this.prisma.adminProfile.findUnique({
      where: { userId },
    });

    if (!admin || !admin.isActive) return false;

    // Super admin has access to everything
    if (admin.role === AdminRole.SUPER_ADMIN) return true;

    // Role hierarchy
    const roleHierarchy: Record<AdminRole, number> = {
      [AdminRole.SUPER_ADMIN]: 5,
      [AdminRole.ADMIN]: 4,
      [AdminRole.OPS]: 3,
      [AdminRole.FINANCE]: 2,
      [AdminRole.SUPPORT]: 1,
    };

    return roleHierarchy[admin.role] >= roleHierarchy[requiredRole];
  }

  /**
   * Create audit log entry
   */
  async createAuditLog(
    adminId: string,
    action: AuditAction,
    resourceType: string,
    resourceId?: string,
    changes?: any,
    ipAddress?: string,
    userAgent?: string,
    metadata?: any,
  ) {
    return this.prisma.auditLog.create({
      data: {
        adminId,
        action,
        resourceType,
        resourceId,
        changes: changes as any,
        ipAddress,
        userAgent,
        metadata: metadata as any,
      },
    });
  }

  /**
   * Get audit logs
   */
  async getAuditLogs(
    filters?: {
      adminId?: string;
      resourceType?: string;
      resourceId?: string;
      action?: AuditAction;
    },
    limit = 50,
    offset = 0,
  ) {
    const where: any = {};
    if (filters?.adminId) where.adminId = filters.adminId;
    if (filters?.resourceType) where.resourceType = filters.resourceType;
    if (filters?.resourceId) where.resourceId = filters.resourceId;
    if (filters?.action) where.action = filters.action;

    const [logs, total] = await Promise.all([
      this.prisma.auditLog.findMany({
        where,
        include: {
          admin: {
            include: {
              user: {
                select: { id: true, name: true, email: true },
              },
            },
          },
        },
        orderBy: { createdAt: 'desc' },
        take: limit,
        skip: offset,
      }),
      this.prisma.auditLog.count({ where }),
    ]);

    return { logs, total };
  }

  /**
   * Get admin profile
   */
  async getAdminProfile(userId: string) {
    return this.prisma.adminProfile.findUnique({
      where: { userId },
      include: {
        user: {
          select: { id: true, name: true, email: true, phone: true, roles: true },
        },
      },
    });
  }

  /**
   * List all admins
   */
  async listAdmins(limit = 50, offset = 0) {
    const [admins, total] = await Promise.all([
      this.prisma.adminProfile.findMany({
        include: {
          user: {
            select: { id: true, name: true, email: true, phone: true, roles: true },
          },
        },
        orderBy: { createdAt: 'desc' },
        take: limit,
        skip: offset,
      }),
      this.prisma.adminProfile.count(),
    ]);

    return { admins, total };
  }

  /**
   * Update admin status
   */
  async updateAdminStatus(userId: string, isActive: boolean, updatedBy: string) {
    const admin = await this.prisma.adminProfile.findUnique({
      where: { userId },
    });
    if (!admin) throw new NotFoundException('Admin not found');

    await this.createAuditLog(
      updatedBy,
      AuditAction.UPDATE,
      'AdminProfile',
      userId,
      { isActive: { before: admin.isActive, after: isActive } },
    );

    return this.prisma.adminProfile.update({
      where: { userId },
      data: { isActive },
    });
  }
}

