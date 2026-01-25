import { ApiProperty } from '@nestjs/swagger';
import { IsUUID } from 'class-validator';

export class CreateJobDto {
  @ApiProperty({ description: 'Quote ID from /quotes endpoint' })
  @IsUUID()
  quoteId: string;
}

