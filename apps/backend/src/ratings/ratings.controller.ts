import { Body, Controller, Get, Param, Post, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { RatingsService } from './ratings.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { SubmitRatingDto } from './dto/submit-rating.dto';

@ApiTags('Ratings')
@Controller('ratings')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class RatingsController {
  constructor(private readonly ratings: RatingsService) {}

  @Post('jobs/:jobId')
  @ApiOperation({ summary: 'Submit rating for a completed job' })
  async submitRating(
    @CurrentUser() user: { userId: string },
    @Param('jobId') jobId: string,
    @Body() dto: SubmitRatingDto,
  ) {
    return this.ratings.submitRating(jobId, user.userId, dto.rating, dto.comment);
  }

  @Get('jobs/:jobId')
  @ApiOperation({ summary: 'Get rating for a job' })
  async getJobRating(@Param('jobId') jobId: string) {
    return this.ratings.getJobRating(jobId);
  }

  @Get('drivers/:driverId')
  @ApiOperation({ summary: 'Get driver ratings' })
  async getDriverRatings(
    @Param('driverId') driverId: string,
    @Query('limit') limit?: string,
    @Query('offset') offset?: string,
  ) {
    return this.ratings.getDriverRatings(
      driverId,
      limit ? parseInt(limit, 10) : 20,
      offset ? parseInt(offset, 10) : 0,
    );
  }
}

