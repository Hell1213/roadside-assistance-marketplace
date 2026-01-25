import { IsEnum, IsOptional, IsString } from 'class-validator';
import { RatingValue } from '@prisma/client';

export class SubmitRatingDto {
  @IsEnum(RatingValue)
  rating: RatingValue;

  @IsOptional()
  @IsString()
  comment?: string;
}

