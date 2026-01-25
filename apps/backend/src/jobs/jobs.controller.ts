import { Controller, Post, Get, Param, Body, UseGuards, ParseUUIDPipe } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { JobsService } from './jobs.service';
import { CreateJobDto } from './dto/create-job.dto';
import { UpdateJobStatusDto } from './dto/update-job-status.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser, CurrentUser as CurrentUserType } from '../auth/decorators/current-user.decorator';

@ApiTags('Jobs')
@Controller('jobs')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class JobsController {
  constructor(private readonly jobsService: JobsService) {}

  @Post()
  @ApiOperation({ summary: 'Create job from quote' })
  async createJob(@CurrentUser() user: CurrentUserType, @Body() dto: CreateJobDto) {
    const job = await this.jobsService.createJobFromQuote(dto.quoteId, user.userId);
    return { job };
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get job details' })
  async getJob(@CurrentUser() user: CurrentUserType, @Param('id', ParseUUIDPipe) id: string) {
    const job = await this.jobsService.getJobById(id, user.userId);
    return { job };
  }

  @Get()
  @ApiOperation({ summary: 'Get customer job history' })
  async getCustomerJobs(@CurrentUser() user: CurrentUserType) {
    const jobs = await this.jobsService.getCustomerJobs(user.userId);
    return { jobs };
  }

  @Post(':id/status')
  @ApiOperation({ summary: 'Update job status (customer can cancel)' })
  async updateStatus(
    @CurrentUser() user: CurrentUserType,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateJobStatusDto,
  ) {
    const job = await this.jobsService.updateJobState(id, dto.state, user.userId, dto.meta);
    return { job };
  }
}

