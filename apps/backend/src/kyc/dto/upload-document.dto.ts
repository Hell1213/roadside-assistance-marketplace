import { IsEnum, IsString, IsOptional, IsObject } from 'class-validator';
import { DocumentType } from '@prisma/client';

export class UploadDocumentDto {
  @IsEnum(DocumentType)
  type: DocumentType;

  @IsString()
  documentUrl: string;

  @IsOptional()
  @IsObject()
  metadata?: any;
}

