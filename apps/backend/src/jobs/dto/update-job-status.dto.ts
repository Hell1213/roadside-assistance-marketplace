import { ApiProperty } from '@nestjs/swagger';
import { IsEnum, IsOptional, IsObject } from 'class-validator';
import { JobState } from '@prisma/client';

export class UpdateJobStatusDto {
  @ApiProperty({ enum: JobState, description: 'New job state' })
  @IsEnum(JobState)
  state: JobState;

  @ApiProperty({ required: false, description: 'Optional metadata (e.g., reason, notes)' })
  @IsOptional()
  @IsObject()
  meta?: Record<string, any>;
}

