import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from '@nestjs/common';
import { AdminService } from '../admin.service';
import { AdminRole } from '@prisma/client';

@Injectable()
export class AdminGuard implements CanActivate {
  constructor(private readonly adminService: AdminService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user || !user.userId) {
      throw new ForbiddenException('Authentication required');
    }

    const isAdmin = await this.adminService.isAdmin(user.userId);
    if (!isAdmin) {
      throw new ForbiddenException('Admin access required');
    }

    return true;
  }
}

@Injectable()
export class AdminRoleGuard implements CanActivate {
  constructor(
    private readonly adminService: AdminService,
    private readonly requiredRole: AdminRole,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user || !user.userId) {
      throw new ForbiddenException('Authentication required');
    }

    const hasRole = await this.adminService.hasRole(user.userId, this.requiredRole);
    if (!hasRole) {
      throw new ForbiddenException(`Required role: ${this.requiredRole}`);
    }

    return true;
  }
}

