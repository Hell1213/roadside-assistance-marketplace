import { Body, Controller, Post } from '@nestjs/common';
import { AuthService } from './auth.service';
import { RequestOtpDto } from './dto/request-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { RefreshDto } from './dto/refresh.dto';
import { TokenService } from './token.service';

@Controller('auth')
export class AuthController {
  constructor(
    private readonly auth: AuthService,
    private readonly tokens: TokenService,
  ) {}

  @Post('request-otp')
  async requestOtp(@Body() dto: RequestOtpDto) {
    return this.auth.requestOtp(dto.phone, dto.role);
  }

  @Post('verify-otp')
  async verifyOtp(@Body() dto: VerifyOtpDto) {
    return this.auth.verifyOtp(dto.phone, dto.role, dto.otp);
  }

  @Post('refresh')
  async refresh(@Body() dto: RefreshDto) {
    return this.tokens.rotateRefresh(dto.refresh_token);
  }

  @Post('logout')
  async logout(@Body() dto: RefreshDto) {
    await this.tokens.revokeRefresh(dto.refresh_token);
    return { ok: true };
  }
}


