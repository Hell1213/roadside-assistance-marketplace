import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { createHash, randomBytes } from 'crypto';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class TokenService {
  private accessTtlSec = 60 * 60; // 1h
  private refreshTtlSec = 60 * 60 * 24 * 30; // 30d

  constructor(
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
    private readonly prisma: PrismaService,
  ) {}

  private hash(token: string) {
    return createHash('sha256').update(token).digest('hex');
  }

  async issueTokens(userId: string, roles: string[]) {
    const access_secret =
      this.config.get<string>('JWT_ACCESS_SECRET') ?? 'dev_access_secret_change_me';
    const refresh_secret =
      this.config.get<string>('JWT_REFRESH_SECRET') ?? 'dev_refresh_secret_change_me';

    const access_token = await this.jwt.signAsync(
      { sub: userId, roles },
      { secret: access_secret, expiresIn: this.accessTtlSec },
    );

    const refresh_raw = randomBytes(48).toString('base64url');
    const tokenHash = this.hash(refresh_raw);
    const expiresAt = new Date(Date.now() + this.refreshTtlSec * 1000);

    await this.prisma.refreshToken.create({
      data: { userId, tokenHash, expiresAt },
    });

    const refresh_token = await this.jwt.signAsync(
      { sub: userId, jti: tokenHash },
      { secret: refresh_secret, expiresIn: this.refreshTtlSec },
    );

    return { access_token, refresh_token };
  }

  async rotateRefresh(refresh_token: string) {
    const refresh_secret =
      this.config.get<string>('JWT_REFRESH_SECRET') ?? 'dev_refresh_secret_change_me';

    let payload: any;
    try {
      payload = await this.jwt.verifyAsync(refresh_token, { secret: refresh_secret });
    } catch {
      throw new UnauthorizedException('Invalid refresh token');
    }

    const userId = payload?.sub as string | undefined;
    const tokenHash = payload?.jti as string | undefined;
    if (!userId || !tokenHash) throw new UnauthorizedException('Invalid refresh token');

    const existing = await this.prisma.refreshToken.findUnique({
      where: { tokenHash },
    });
    if (!existing || existing.userId !== userId) {
      throw new UnauthorizedException('Invalid refresh token');
    }
    if (existing.revokedAt) throw new UnauthorizedException('Refresh token revoked');
    if (existing.expiresAt.getTime() < Date.now()) {
      throw new UnauthorizedException('Refresh token expired');
    }

    // revoke old token (rotation)
    await this.prisma.refreshToken.update({
      where: { tokenHash },
      data: { revokedAt: new Date() },
    });

    // fetch roles
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new UnauthorizedException('User not found');

    return this.issueTokens(userId, user.roles);
  }

  async revokeRefresh(refresh_token: string) {
    const refresh_secret =
      this.config.get<string>('JWT_REFRESH_SECRET') ?? 'dev_refresh_secret_change_me';
    try {
      const payload: any = await this.jwt.verifyAsync(refresh_token, {
        secret: refresh_secret,
      });
      const tokenHash = payload?.jti as string | undefined;
      if (!tokenHash) return;
      await this.prisma.refreshToken.updateMany({
        where: { tokenHash, revokedAt: null },
        data: { revokedAt: new Date() },
      });
    } catch {
      // ignore
    }
  }
}


