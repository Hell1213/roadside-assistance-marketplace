import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { SupportTicketStatus, SupportTicketPriority } from '@prisma/client';

@Injectable()
export class SupportService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Create support ticket
   */
  async createTicket(
    userId: string,
    subject: string,
    description: string,
    jobId?: string,
    priority: SupportTicketPriority = SupportTicketPriority.MEDIUM,
  ) {
    return this.prisma.supportTicket.create({
      data: {
        userId,
        jobId,
        subject,
        description,
        priority,
        status: SupportTicketStatus.OPEN,
      },
      include: {
        user: { select: { id: true, name: true, phone: true, email: true } },
      },
    });
  }

  /**
   * Get user tickets
   */
  async getUserTickets(userId: string, limit = 50, offset = 0) {
    const [tickets, total] = await Promise.all([
      this.prisma.supportTicket.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' },
        take: limit,
        skip: offset,
        include: {
          user: { select: { id: true, name: true, phone: true } },
        },
      }),
      this.prisma.supportTicket.count({ where: { userId } }),
    ]);

    return { tickets, total };
  }

  /**
   * Get ticket details
   */
  async getTicket(ticketId: string, userId: string) {
    const ticket = await this.prisma.supportTicket.findUnique({
      where: { id: ticketId },
      include: {
        user: { select: { id: true, name: true, phone: true, email: true } },
      },
    });

    if (!ticket) throw new NotFoundException('Ticket not found');
    if (ticket.userId !== userId) {
      throw new BadRequestException('Access denied');
    }

    return ticket;
  }

  /**
   * Update ticket status (admin)
   */
  async updateTicketStatus(
    ticketId: string,
    status: SupportTicketStatus,
    assignedTo?: string,
  ) {
    const updateData: any = { status };
    if (status === SupportTicketStatus.RESOLVED || status === SupportTicketStatus.CLOSED) {
      updateData.resolvedAt = new Date();
    }
    if (assignedTo) {
      updateData.assignedTo = assignedTo;
    }

    return this.prisma.supportTicket.update({
      where: { id: ticketId },
      data: updateData,
      include: {
        user: { select: { id: true, name: true, phone: true, email: true } },
      },
    });
  }

  /**
   * List all tickets (admin)
   */
  async listTickets(
    filters?: {
      status?: SupportTicketStatus;
      priority?: SupportTicketPriority;
      userId?: string;
    },
    limit = 50,
    offset = 0,
  ) {
    const where: any = {};
    if (filters?.status) where.status = filters.status;
    if (filters?.priority) where.priority = filters.priority;
    if (filters?.userId) where.userId = filters.userId;

    const [tickets, total] = await Promise.all([
      this.prisma.supportTicket.findMany({
        where,
        include: {
          user: { select: { id: true, name: true, phone: true, email: true } },
        },
        orderBy: [
          { priority: 'desc' },
          { createdAt: 'desc' },
        ],
        take: limit,
        skip: offset,
      }),
      this.prisma.supportTicket.count({ where }),
    ]);

    return { tickets, total };
  }
}

