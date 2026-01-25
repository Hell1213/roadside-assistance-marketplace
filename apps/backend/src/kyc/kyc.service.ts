import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { DocumentType, KycStatus } from '@prisma/client';

@Injectable()
export class KycService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Upload KYC document
   */
  async uploadDocument(
    driverId: string,
    type: DocumentType,
    documentUrl: string,
    metadata?: any,
  ) {
    // Check if document of this type already exists
    const existing = await this.prisma.kycDocument.findFirst({
      where: { driverId, type },
    });

    if (existing) {
      // Update existing document
      return this.prisma.kycDocument.update({
        where: { id: existing.id },
        data: {
          documentUrl,
          status: KycStatus.PENDING,
          metadata: metadata as any,
          verifiedBy: null,
          verifiedAt: null,
          rejectionReason: null,
        },
      });
    }

    // Create new document
    return this.prisma.kycDocument.create({
      data: {
        driverId,
        type,
        documentUrl,
        status: KycStatus.PENDING,
        metadata: metadata as any,
      },
    });
  }

  /**
   * Get driver KYC documents
   */
  async getDriverDocuments(driverId: string) {
    return this.prisma.kycDocument.findMany({
      where: { driverId },
      orderBy: { createdAt: 'desc' },
    });
  }

  /**
   * Verify KYC document (admin only)
   */
  async verifyDocument(documentId: string, adminId: string, status: KycStatus, rejectionReason?: string) {
    const document = await this.prisma.kycDocument.findUnique({
      where: { id: documentId },
      include: { driver: true },
    });

    if (!document) throw new NotFoundException('Document not found');

    const updated = await this.prisma.kycDocument.update({
      where: { id: documentId },
      data: {
        status,
        verifiedBy: status === KycStatus.VERIFIED ? adminId : null,
        verifiedAt: status === KycStatus.VERIFIED ? new Date() : null,
        rejectionReason: status === KycStatus.REJECTED ? rejectionReason : null,
      },
    });

    // Update driver KYC status if all required documents are verified
    if (status === KycStatus.VERIFIED) {
      await this.updateDriverKycStatus(document.driverId);
    }

    return updated;
  }

  /**
   * Update driver KYC status based on documents
   */
  private async updateDriverKycStatus(driverId: string) {
    const documents = await this.prisma.kycDocument.findMany({
      where: { driverId },
    });

    const requiredTypes = [DocumentType.DRIVER_LICENSE, DocumentType.VEHICLE_REGISTRATION, DocumentType.INSURANCE];
    const verifiedTypes = documents
      .filter((d) => d.status === KycStatus.VERIFIED)
      .map((d) => d.type);

    const allRequiredVerified = requiredTypes.every((type) => verifiedTypes.includes(type));

    await this.prisma.driver.update({
      where: { id: driverId },
      data: {
        kycStatus: allRequiredVerified ? KycStatus.VERIFIED : KycStatus.PENDING,
      },
    });
  }

  /**
   * Get KYC status for driver
   */
  async getKycStatus(driverId: string) {
    const driver = await this.prisma.driver.findUnique({
      where: { id: driverId },
      include: {
        kycDocuments: {
          orderBy: { createdAt: 'desc' },
        },
      },
    });

    if (!driver) throw new NotFoundException('Driver not found');

    return {
      status: driver.kycStatus,
      documents: driver.kycDocuments,
      requiredDocuments: [
        DocumentType.DRIVER_LICENSE,
        DocumentType.VEHICLE_REGISTRATION,
        DocumentType.INSURANCE,
      ],
    };
  }
}

