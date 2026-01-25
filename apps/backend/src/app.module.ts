import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { configuration } from './config/configuration';
import { HealthModule } from './health/health.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { DriversModule } from './drivers/drivers.module';
import { SetupModule } from './setup/setup.module';
import { PricingModule } from './pricing/pricing.module';
import { QuotesModule } from './quotes/quotes.module';
import { JobsModule } from './jobs/jobs.module';
import { DispatchModule } from './dispatch/dispatch.module';
import { RealtimeModule } from './realtime/realtime.module';
import { PaymentsModule } from './payments/payments.module';
import { WalletsModule } from './wallets/wallets.module';
import { PayoutsModule } from './payouts/payouts.module';
import { NotificationsModule } from './notifications/notifications.module';
import { AdminModule } from './admin/admin.module';
import { RatingsModule } from './ratings/ratings.module';
import { VehiclesModule } from './vehicles/vehicles.module';
import { KycModule } from './kyc/kyc.module';
import { SupportModule } from './support/support.module';
import { AnalyticsModule } from './analytics/analytics.module';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [configuration],
    }),
    ThrottlerModule.forRoot([
      {
        ttl: 60000, // 1 minute
        limit: 100, // 100 requests per minute
      },
    ]),
    HealthModule,
    AuthModule,
    UsersModule,
    DriversModule,
    SetupModule,
    PricingModule,
    QuotesModule,
    JobsModule,
    DispatchModule,
    RealtimeModule,
    PaymentsModule,
    WalletsModule,
    PayoutsModule,
    NotificationsModule,
    AdminModule,
    RatingsModule,
    VehiclesModule,
    KycModule,
    SupportModule,
    AnalyticsModule,
  ],
  controllers: [AppController],
  providers: [
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
  ],
})
export class AppModule {}
