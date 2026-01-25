import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { NotificationType, NotificationCategory, NotificationStatus, DevicePlatform } from '@prisma/client';
import { FcmService } from './fcm.service';
import { SmsService } from './sms.service';

interface SendNotificationOptions {
  userId: string;
  category: NotificationCategory;
  title: string;
  body: string;
  data?: any;
  referenceId?: string;
  sendSms?: boolean;
}

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly fcm: FcmService,
    private readonly sms: SmsService,
  ) {}

  /**
   * Send notification (push + optional SMS fallback)
   */
  async sendNotification(options: SendNotificationOptions) {
    const { userId, category, title, body, data, referenceId, sendSms = false } = options;

    // Create notification record
    const notification = await this.prisma.notification.create({
      data: {
        userId,
        type: NotificationType.PUSH,
        category,
        title,
        body,
        data: data as any,
        referenceId,
        status: NotificationStatus.PENDING,
      },
    });

    try {
      // Get active device tokens for user
      const deviceTokens = await this.prisma.deviceToken.findMany({
        where: {
          userId,
          isActive: true,
        },
      });

      let pushSent = false;

      // Send push notifications
      if (deviceTokens.length > 0) {
        for (const deviceToken of deviceTokens) {
          try {
            if (deviceToken.platform === DevicePlatform.ANDROID && deviceToken.fcmToken) {
              await this.fcm.sendToDevice(deviceToken.fcmToken, {
                notification: { title, body },
                data: { ...data, category: category.toString(), referenceId: referenceId || '' },
              } as any);
              pushSent = true;
            } else if (deviceToken.platform === DevicePlatform.IOS && deviceToken.apnsToken) {
              // APNs implementation would go here
              // For now, we'll use FCM for both (FCM supports iOS)
              if (deviceToken.fcmToken) {
                await this.fcm.sendToDevice(deviceToken.fcmToken, {
                  notification: { title, body },
                  data: { ...data, category: category.toString(), referenceId: referenceId || '' },
                } as any);
                pushSent = true;
              }
            }
          } catch (error) {
            this.logger.error(`Failed to send push to device ${deviceToken.id}:`, error);
          }
        }
      }

      // SMS fallback if push fails or if explicitly requested
      if (!pushSent || sendSms) {
        const user = await this.prisma.user.findUnique({
          where: { id: userId },
          select: { phone: true },
        });

        if (user?.phone) {
          try {
            await this.sms.send(user.phone, body);
            // Create SMS notification record
            await this.prisma.notification.create({
              data: {
                userId,
                type: NotificationType.SMS,
                category,
                title,
                body,
                data: data as any,
                referenceId,
                status: NotificationStatus.SENT,
                sentAt: new Date(),
              },
            });
          } catch (error) {
            this.logger.error(`Failed to send SMS to ${user.phone}:`, error);
          }
        }
      }

      // Update notification status
      await this.prisma.notification.update({
        where: { id: notification.id },
        data: {
          status: pushSent ? NotificationStatus.SENT : NotificationStatus.FAILED,
          sentAt: pushSent ? new Date() : null,
          failureReason: pushSent ? null : 'No active device tokens',
        },
      });

      return notification;
    } catch (error) {
      this.logger.error(`Failed to send notification:`, error);
      await this.prisma.notification.update({
        where: { id: notification.id },
        data: {
          status: NotificationStatus.FAILED,
          failureReason: error.message,
        },
      });
      throw error;
    }
  }

  /**
   * Send job-related notifications
   */
  async notifyJobAssigned(jobId: string, driverUserId: string, jobData: any) {
    return this.sendNotification({
      userId: driverUserId,
      category: NotificationCategory.JOB_ASSIGNED,
      title: 'New Job Assigned',
      body: `You have been assigned a ${jobData.serviceName || 'service'} job. Tap to view details.`,
      data: { jobId, ...jobData },
      referenceId: jobId,
      sendSms: true, // Critical notification
    });
  }

  async notifyJobStatusUpdate(jobId: string, userId: string, status: string, jobData: any) {
    return this.sendNotification({
      userId,
      category: NotificationCategory.JOB_STATUS_UPDATE,
      title: 'Job Status Updated',
      body: `Your job status has been updated to: ${status}`,
      data: { jobId, status, ...jobData },
      referenceId: jobId,
    });
  }

  async notifyDriverArrived(jobId: string, customerUserId: string, driverData: any) {
    return this.sendNotification({
      userId: customerUserId,
      category: NotificationCategory.DRIVER_ARRIVED,
      title: 'Driver Arrived',
      body: `Your driver ${driverData.name || 'has arrived'} at the location.`,
      data: { jobId, ...driverData },
      referenceId: jobId,
      sendSms: true,
    });
  }

  async notifyJobCompleted(jobId: string, customerUserId: string, jobData: any) {
    return this.sendNotification({
      userId: customerUserId,
      category: NotificationCategory.JOB_COMPLETED,
      title: 'Job Completed',
      body: `Your service request has been completed. Thank you for using our service!`,
      data: { jobId, ...jobData },
      referenceId: jobId,
    });
  }

  async notifyPaymentSuccess(jobId: string, userId: string, paymentData: any) {
    return this.sendNotification({
      userId,
      category: NotificationCategory.PAYMENT_SUCCESS,
      title: 'Payment Successful',
      body: `Payment of ₹${paymentData.amount} has been processed successfully.`,
      data: { jobId, ...paymentData },
      referenceId: jobId,
    });
  }

  async notifyPayoutProcessed(payoutId: string, userId: string, payoutData: any) {
    return this.sendNotification({
      userId,
      category: NotificationCategory.PAYOUT_PROCESSED,
      title: 'Payout Processed',
      body: `Your payout of ₹${payoutData.amount} has been processed successfully.`,
      data: { payoutId, ...payoutData },
      referenceId: payoutId,
    });
  }
}

