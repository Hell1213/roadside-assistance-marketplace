import { Injectable, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Razorpay from 'razorpay';

@Injectable()
export class RazorpayService implements OnModuleInit {
  public readonly client: Razorpay;

  constructor(private readonly config: ConfigService) {
    const keyId = this.config.get<string>('razorpayKeyId');
    const keySecret = this.config.get<string>('razorpayKeySecret');

    if (!keyId || !keySecret) {
      throw new Error('Razorpay credentials not configured. Please set RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET');
    }

    this.client = new Razorpay({
      key_id: keyId,
      key_secret: keySecret,
    });
  }

  async onModuleInit() {
    // Verify connection - skip account fetch as it requires account ID
    // The client will be validated when first API call is made
    console.log('Razorpay client initialized');
  }

  /**
   * Verify webhook signature
   */
  verifyWebhookSignature(body: string, signature: string): boolean {
    const crypto = require('crypto');
    const webhookSecret = this.config.get<string>('razorpayWebhookSecret');
    if (!webhookSecret) {
      return false;
    }

    const expectedSignature = crypto
      .createHmac('sha256', webhookSecret)
      .update(body)
      .digest('hex');

    return crypto.timingSafeEqual(
      Buffer.from(signature),
      Buffer.from(expectedSignature),
    );
  }
}

