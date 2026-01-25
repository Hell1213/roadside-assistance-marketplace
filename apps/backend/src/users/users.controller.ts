import { Body, Controller, Get, Put, UseGuards } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { UpdateMeDto } from './dto/update-me.dto';

@Controller()
export class UsersController {
  constructor(private readonly prisma: PrismaService) {}

  @UseGuards(JwtAuthGuard)
  @Get('me')
  async me(@CurrentUser() user: { userId: string }) {
    const profile = await this.prisma.user.findUnique({
      where: { id: user.userId },
      select: { id: true, phone: true, name: true, email: true, roles: true },
    });
    return { profile };
  }

  @UseGuards(JwtAuthGuard)
  @Put('me')
  async updateMe(
    @CurrentUser() user: { userId: string },
    @Body() dto: UpdateMeDto,
  ) {
    const profile = await this.prisma.user.update({
      where: { id: user.userId },
      data: { name: dto.name, email: dto.email },
      select: { id: true, phone: true, name: true, email: true, roles: true },
    });
    return { profile };
  }
}


