import { Injectable, UnauthorizedException, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { OtpService } from './otp.service';
import { TokenService } from './token.service';
import { AuthRole, roleToEnum } from './auth.types';
import { SmsService } from '../notifications/sms.service';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly otp: OtpService,
    private readonly tokens: TokenService,
    private readonly sms: SmsService,
  ) {}

  async requestOtp(phone: string, role: AuthRole) {
    const otp = await this.otp.generate(phone, role);

    // Send OTP via SMS
    try {
      const message = `Your OTP for Roadside Assistance is ${otp}. Valid for 3 minutes.`;
      const smsResult = await this.sms.send(phone, message);
      
      if (smsResult.success) {
        this.logger.log(`OTP sent successfully to ${phone}`);
      } else {
        this.logger.warn(`Failed to send OTP SMS to ${phone}: ${smsResult.message}`);
      }
    } catch (error) {
      this.logger.error(`Error sending OTP SMS to ${phone}:`, error);
      // Continue even if SMS fails - OTP is still generated and stored
    }

    // In development, also return OTP in response for testing
    const response: { ok: boolean; otp_dev_only?: string } = { ok: true };
    if (process.env.NODE_ENV !== 'production') {
      response.otp_dev_only = otp;
    }

    return response;
  }

  async verifyOtp(phone: string, role: AuthRole, otp: string) {
    const ok = await this.otp.verify(phone, role, otp);
    if (!ok) throw new UnauthorizedException('Invalid OTP');

    const roleEnum = roleToEnum(role);

    // find or create user by phone
    let user = await this.prisma.user.findUnique({ where: { phone } });
    if (!user) {
      user = await this.prisma.user.create({
        data: {
          phone,
          roles: [roleEnum],
        },
      });
    } else if (!user.roles.includes(roleEnum)) {
      user = await this.prisma.user.update({
        where: { id: user.id },
        data: { roles: { push: roleEnum } },
      });
    }

    const tokens = await this.tokens.issueTokens(user.id, user.roles);
    return {
      ...tokens,
      profile: {
        id: user.id,
        phone: user.phone,
        name: user.name,
        email: user.email,
        roles: user.roles,
      },
    };
  }
}


