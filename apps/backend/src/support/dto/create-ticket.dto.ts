import { IsString, IsOptional, IsEnum, IsUUID } from 'class-validator';
import { SupportTicketPriority } from '@prisma/client';

export class CreateTicketDto {
  @IsString()
  subject: string;

  @IsString()
  description: string;

  @IsOptional()
  @IsUUID()
  jobId?: string;

  @IsOptional()
  @IsEnum(SupportTicketPriority)
  priority?: SupportTicketPriority;
}

