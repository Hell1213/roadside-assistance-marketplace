import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  ConnectedSocket,
  MessageBody,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger, UseGuards } from '@nestjs/common';
import { RedisService } from '../redis/redis.service';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

interface AuthenticatedSocket extends Socket {
  userId?: string;
  userRoles?: string[];
}

@WebSocketGateway({
  cors: {
    origin: '*', // TODO: restrict in production
    credentials: true,
  },
  namespace: '/realtime',
})
export class RealtimeGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(RealtimeGateway.name);
  private readonly jwtService: JwtService;
  private readonly configService: ConfigService;

  constructor(
    private readonly redis: RedisService,
    jwtService: JwtService,
    configService: ConfigService,
  ) {
    this.jwtService = jwtService;
    this.configService = configService;
  }

  async afterInit(server: Server) {
    // Redis adapter setup is optional for single-instance deployments
    // For multi-instance scaling, configure adapter in main.ts using IoAdapter
    // This allows the backend to run without Redis adapter errors
    this.logger.log('Realtime gateway initialized (Redis adapter can be configured in main.ts for scaling)');
  }

  async handleConnection(client: AuthenticatedSocket) {
    try {
      // Extract token from handshake auth or query
      const token =
        client.handshake.auth?.token || client.handshake.query?.token || client.handshake.headers?.authorization?.replace('Bearer ', '');

      if (!token) {
        this.logger.warn(`Client ${client.id} connected without token`);
        client.disconnect();
        return;
      }

      // Verify JWT token
      const secret = this.configService.get<string>('jwtAccessSecret') ?? 'dev_access_secret_change_me';
      const payload = this.jwtService.verify(token, { secret });

      client.userId = payload.sub;
      client.userRoles = payload.roles || [];

      // Join user-specific room
      await client.join(`user:${client.userId}`);

      // Join role-specific rooms
      if (client.userRoles) {
        for (const role of client.userRoles) {
          await client.join(`role:${role}`);
        }
      }

      this.logger.log(`Client ${client.id} authenticated as user ${client.userId}`);
    } catch (error) {
      this.logger.error(`Authentication failed for client ${client.id}: ${error.message}`);
      client.disconnect();
    }
  }

  async handleDisconnect(client: AuthenticatedSocket) {
    this.logger.log(`Client ${client.id} disconnected`);
  }

  @SubscribeMessage('subscribe:job')
  async handleSubscribeJob(@ConnectedSocket() client: AuthenticatedSocket, @MessageBody() data: { jobId: string }) {
    if (!client.userId) {
      return { error: 'Unauthorized' };
    }

    // Verify user has access to this job (customer or assigned driver)
    // TODO: Add proper authorization check
    await client.join(`job:${data.jobId}`);
    this.logger.log(`Client ${client.id} subscribed to job ${data.jobId}`);

    return { ok: true, jobId: data.jobId };
  }

  @SubscribeMessage('unsubscribe:job')
  async handleUnsubscribeJob(@ConnectedSocket() client: AuthenticatedSocket, @MessageBody() data: { jobId: string }) {
    await client.leave(`job:${data.jobId}`);
    this.logger.log(`Client ${client.id} unsubscribed from job ${data.jobId}`);

    return { ok: true, jobId: data.jobId };
  }

  // Broadcast job state change to all subscribers
  broadcastJobStateChange(jobId: string, state: string, data?: any) {
    this.server.to(`job:${jobId}`).emit('job:state_change', {
      jobId,
      state,
      data,
      timestamp: new Date().toISOString(),
    });
  }

  // Broadcast driver location to job subscribers
  broadcastDriverLocation(jobId: string, location: { lat: number; lng: number; heading?: number }) {
    this.server.to(`job:${jobId}`).emit('job:driver_location', {
      jobId,
      location,
      timestamp: new Date().toISOString(),
    });
  }

  // Send message to specific user
  sendToUser(userId: string, event: string, data: any) {
    this.server.to(`user:${userId}`).emit(event, data);
  }

  // Send message to all drivers
  sendToDrivers(event: string, data: any) {
    this.server.to('role:DRIVER').emit(event, data);
  }
}

