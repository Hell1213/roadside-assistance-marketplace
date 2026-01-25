import { UserRole } from '@prisma/client';

export type AuthRole = 'customer' | 'driver' | 'admin';

export function roleToEnum(role: AuthRole): UserRole {
  switch (role) {
    case 'customer':
      return UserRole.CUSTOMER;
    case 'driver':
      return UserRole.DRIVER;
    case 'admin':
      return UserRole.ADMIN;
  }
}


