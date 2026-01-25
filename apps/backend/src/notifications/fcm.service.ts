import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';

@Injectable()
export class FcmService implements OnModuleInit {
  private readonly logger = new Logger(FcmService.name);
  private app: admin.app.App | null = null;

  constructor(private readonly config: ConfigService) {}

  async onModuleInit() {
    try {
      const serviceAccountPath = this.config.get<string>('fcmServiceAccountKeyPath');
      const projectId = this.config.get<string>('fcmProjectId');
      const privateKey = this.config.get<string>('fcmPrivateKey');
      const clientEmail = this.config.get<string>('fcmClientEmail');

      if (serviceAccountPath) {
        // Initialize with service account file
        const serviceAccount = require(serviceAccountPath);
        this.app = admin.initializeApp({
          credential: admin.credential.cert(serviceAccount),
        });
      } else if (projectId && privateKey && clientEmail) {
        // Initialize with individual credentials
        this.app = admin.initializeApp({
          credential: admin.credential.cert({
            projectId,
            privateKey: privateKey.replace(/\\n/g, '\n'),
            clientEmail,
          }),
        });
      } else {
        this.logger.warn('FCM credentials not configured. Push notifications will be disabled.');
        return;
      }

      this.logger.log('FCM initialized successfully');
    } catch (error) {
      this.logger.error('Failed to initialize FCM:', error);
    }
  }

  /**
   * Send push notification to a single device
   */
  async sendToDevice(token: string, message: admin.messaging.Message) {
    if (!this.app) {
      throw new Error('FCM not initialized');
    }

    try {
      const result = await admin.messaging(this.app).send({
        ...message,
        token,
      });
      this.logger.log(`FCM message sent: ${result}`);
      return result;
    } catch (error) {
      this.logger.error(`Failed to send FCM message:`, error);
      throw error;
    }
  }

  /**
   * Send push notification to multiple devices
   */
  async sendToDevices(tokens: string[], message: admin.messaging.Message) {
    if (!this.app) {
      throw new Error('FCM not initialized');
    }

    if (tokens.length === 0) return { successCount: 0, failureCount: 0 };

    try {
      const result = await admin.messaging(this.app).sendEachForMulticast({
        ...message,
        tokens,
      });
      this.logger.log(`FCM multicast sent: ${result.successCount} success, ${result.failureCount} failures`);
      return result;
    } catch (error) {
      this.logger.error(`Failed to send FCM multicast:`, error);
      throw error;
    }
  }

  /**
   * Send to topic
   */
  async sendToTopic(topic: string, message: admin.messaging.Message) {
    if (!this.app) {
      throw new Error('FCM not initialized');
    }

    try {
      const result = await admin.messaging(this.app).send({
        ...message,
        topic,
      });
      this.logger.log(`FCM topic message sent: ${result}`);
      return result;
    } catch (error) {
      this.logger.error(`Failed to send FCM topic message:`, error);
      throw error;
    }
  }
}

