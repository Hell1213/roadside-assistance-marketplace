import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { KycService } from './kyc.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { Roles, RolesGuard } from '../auth/guards/roles.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { UploadDocumentDto } from './dto/upload-document.dto';
import { PrismaService } from '../prisma/prisma.service';
import { KycStatus } from '@prisma/client';

@ApiTags('KYC')
@Controller('kyc')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class KycController {
  constructor(
    private readonly kyc: KycService,
    private readonly prisma: PrismaService,
  ) {}

  @Post('documents')
  @UseGuards(RolesGuard)
  @Roles('DRIVER')
  @ApiOperation({ summary: 'Upload KYC document' })
  async uploadDocument(
    @CurrentUser() user: { userId: string },
    @Body() dto: UploadDocumentDto,
  ) {
    const driver = await this.prisma.driver.findUnique({
      where: { userId: user.userId },
    });
    if (!driver) throw new Error('Driver not found');

    return this.kyc.uploadDocument(driver.id, dto.type, dto.documentUrl, dto.metadata);
  }

  @Get('status')
  @UseGuards(RolesGuard)
  @Roles('DRIVER')
  @ApiOperation({ summary: 'Get KYC status' })
  async getKycStatus(@CurrentUser() user: { userId: string }) {
    const driver = await this.prisma.driver.findUnique({
      where: { userId: user.userId },
    });
    if (!driver) throw new Error('Driver not found');

    return this.kyc.getKycStatus(driver.id);
  }

  @Get('documents')
  @UseGuards(RolesGuard)
  @Roles('DRIVER')
  @ApiOperation({ summary: 'Get driver documents' })
  async getDocuments(@CurrentUser() user: { userId: string }) {
    const driver = await this.prisma.driver.findUnique({
      where: { userId: user.userId },
    });
    if (!driver) throw new Error('Driver not found');

    return this.kyc.getDriverDocuments(driver.id);
  }

  @Post('documents/:id/verify')
  @UseGuards(RolesGuard)
  @Roles('ADMIN')
  @ApiOperation({ summary: 'Verify KYC document (admin only)' })
  async verifyDocument(
    @CurrentUser() admin: { userId: string },
    @Param('id') documentId: string,
    @Body() body: { status: KycStatus; rejectionReason?: string },
  ) {
    return this.kyc.verifyDocument(documentId, admin.userId, body.status, body.rejectionReason);
  }
}

