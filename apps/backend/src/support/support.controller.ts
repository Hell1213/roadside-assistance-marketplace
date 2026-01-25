import { Body, Controller, Get, Param, Post, Put, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { SupportService } from './support.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AdminGuard } from '../admin/guards/admin.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { CreateTicketDto } from './dto/create-ticket.dto';
import { SupportTicketStatus, SupportTicketPriority } from '@prisma/client';

@ApiTags('Support')
@Controller('support')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class SupportController {
  constructor(private readonly support: SupportService) {}

  @Post('tickets')
  @ApiOperation({ summary: 'Create support ticket' })
  async createTicket(
    @CurrentUser() user: { userId: string },
    @Body() dto: CreateTicketDto,
  ) {
    return this.support.createTicket(
      user.userId,
      dto.subject,
      dto.description,
      dto.jobId,
      dto.priority,
    );
  }

  @Get('tickets')
  @ApiOperation({ summary: 'Get user tickets' })
  async getUserTickets(
    @CurrentUser() user: { userId: string },
    @Query('limit') limit?: string,
    @Query('offset') offset?: string,
  ) {
    return this.support.getUserTickets(
      user.userId,
      limit ? parseInt(limit, 10) : 50,
      offset ? parseInt(offset, 10) : 0,
    );
  }

  @Get('tickets/:id')
  @ApiOperation({ summary: 'Get ticket details' })
  async getTicket(
    @CurrentUser() user: { userId: string },
    @Param('id') ticketId: string,
  ) {
    return this.support.getTicket(ticketId, user.userId);
  }

  @Put('tickets/:id/status')
  @UseGuards(AdminGuard)
  @ApiOperation({ summary: 'Update ticket status (admin only)' })
  async updateTicketStatus(
    @Param('id') ticketId: string,
    @Body() body: { status: SupportTicketStatus; assignedTo?: string },
  ) {
    return this.support.updateTicketStatus(ticketId, body.status, body.assignedTo);
  }

  @Get('admin/tickets')
  @UseGuards(AdminGuard)
  @ApiOperation({ summary: 'List all tickets (admin only)' })
  async listTickets(
    @Query('status') status?: SupportTicketStatus,
    @Query('priority') priority?: SupportTicketPriority,
    @Query('userId') userId?: string,
    @Query('limit') limit?: string,
    @Query('offset') offset?: string,
  ) {
    return this.support.listTickets(
      { status, priority, userId },
      limit ? parseInt(limit, 10) : 50,
      offset ? parseInt(offset, 10) : 0,
    );
  }
}

