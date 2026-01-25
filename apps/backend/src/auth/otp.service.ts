import { Injectable } from '@nestjs/common';
import { RedisService } from '../redis/redis.service';
import { AuthRole } from './auth.types';

@Injectable()
export class OtpService {
  constructor(private readonly redis: RedisService) {}

  private key(phone: string, role: AuthRole) {
    return `otp:${role}:${phone}`;
  }

  async generate(phone: string, role: AuthRole) {
    const otp = (Math.floor(100000 + Math.random() * 900000)).toString();
    // 3 minutes validity
    await this.redis.client.set(this.key(phone, role), otp, 'EX', 180);
    return otp;
  }

  async verify(phone: string, role: AuthRole, otp: string) {
    const expected = await this.redis.client.get(this.key(phone, role));
    if (!expected) return false;
    if (expected !== otp) return false;
    await this.redis.client.del(this.key(phone, role));
    return true;
  }
}


