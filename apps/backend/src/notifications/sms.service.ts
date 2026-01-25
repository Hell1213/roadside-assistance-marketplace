import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SNSClient, PublishCommand } from '@aws-sdk/client-sns';

@Injectable()
export class SmsService implements OnModuleInit {
  private readonly logger = new Logger(SmsService.name);
  private snsClient: SNSClient | null = null;
  private provider: 'msg91' | 'aws' = 'msg91';
  private msg91AuthKey: string | null = null;
  private msg91SenderId: string = 'RASAPP';

  constructor(private readonly config: ConfigService) {}

  async onModuleInit() {
    this.provider = (this.config.get<string>('smsProvider') || 'msg91') as 'msg91' | 'aws';

    if (this.provider === 'aws') {
      const region = this.config.get<string>('awsRegion') || 'ap-south-1';
      const accessKeyId = this.config.get<string>('awsAccessKeyId');
      const secretAccessKey = this.config.get<string>('awsSecretAccessKey');

      if (accessKeyId && secretAccessKey) {
        this.snsClient = new SNSClient({
          region,
          credentials: {
            accessKeyId,
            secretAccessKey,
          },
        });
        this.logger.log('AWS SNS initialized for SMS');
      } else {
        this.logger.warn('AWS SNS credentials not configured');
      }
    } else {
      // MSG91
      this.msg91AuthKey = this.config.get<string>('msg91AuthKey') || null;
      this.msg91SenderId = this.config.get<string>('msg91SenderId') || 'RASAPP';

      if (this.msg91AuthKey) {
        this.logger.log('MSG91 initialized for SMS');
      } else {
        this.logger.warn('MSG91 credentials not configured');
      }
    }
  }

  /**
   * Send SMS
   */
  async send(phone: string, message: string) {
    if (this.provider === 'aws' && this.snsClient) {
      return this.sendViaAws(phone, message);
    } else if (this.provider === 'msg91' && this.msg91AuthKey) {
      return this.sendViaMsg91(phone, message);
    } else {
      this.logger.warn('SMS provider not configured. Skipping SMS send.');
      return { success: false, message: 'SMS provider not configured' };
    }
  }

  private async sendViaAws(phone: string, message: string) {
    if (!this.snsClient) {
      throw new Error('AWS SNS not initialized');
    }

    try {
      // Format phone number for India (+91)
      const formattedPhone = phone.startsWith('+91') ? phone : `+91${phone}`;

      const command = new PublishCommand({
        PhoneNumber: formattedPhone,
        Message: message,
        MessageAttributes: {
          'AWS.SNS.SMS.SenderID': {
            DataType: 'String',
            StringValue: this.config.get<string>('snsSenderId') || 'RASAPP',
          },
        },
      });

      const result = await this.snsClient.send(command);
      this.logger.log(`SMS sent via AWS SNS: ${result.MessageId}`);
      return { success: true, messageId: result.MessageId };
    } catch (error) {
      this.logger.error('Failed to send SMS via AWS SNS:', error);
      throw error;
    }
  }

  private async sendViaMsg91(phone: string, message: string) {
    if (!this.msg91AuthKey) {
      throw new Error('MSG91 not initialized');
    }

    try {
      // Format phone number (remove +91 if present, ensure it's 10 digits)
      let formattedPhone = phone.replace(/^\+91/, '').replace(/\s+/g, '');
      
      // Ensure phone number is 10 digits for Indian numbers
      if (formattedPhone.length === 10) {
        formattedPhone = `91${formattedPhone}`;
      }

      const axios = require('axios');
      
      // Use MSG91 REST API v5 for sending SMS
      const response = await axios.post(
        'https://control.msg91.com/api/v5/flow/',
        {
          template_id: 'default', // You'll need to create templates in MSG91 dashboard
          sender: this.msg91SenderId,
          short_url: '0',
          mobiles: formattedPhone,
          message: message,
        },
        {
          headers: {
            authkey: this.msg91AuthKey,
            'Content-Type': 'application/json',
          },
        },
      );

      this.logger.log(`SMS sent via MSG91 to ${phone}`);
      return { success: true, messageId: response.data.request_id || response.data.type };
    } catch (error: any) {
      // Fallback: Try the older HTTP API endpoint if flow API fails
      try {
        const formattedPhone = phone.replace(/^\+91/, '').replace(/\s+/g, '');
        const axios = require('axios');
        
        const httpResponse = await axios.get('https://control.msg91.com/api/sendhttp.php', {
          params: {
            authkey: this.msg91AuthKey,
            mobiles: formattedPhone,
            message: message,
            sender: this.msg91SenderId,
            route: '4', // Transactional route
            country: '91',
          },
        });

        this.logger.log(`SMS sent via MSG91 HTTP API to ${phone}`);
        return { success: true, messageId: httpResponse.data };
      } catch (fallbackError: any) {
        this.logger.error('Failed to send SMS via MSG91:', fallbackError.response?.data || fallbackError.message);
        throw fallbackError;
      }
    }
  }
}

