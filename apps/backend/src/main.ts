import { ValidationPipe, Logger } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { ConfigService } from '@nestjs/config';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module';
import { ApiExceptionFilter } from './common/http/api-exception.filter';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const logger = new Logger('Bootstrap');
  const config = app.get(ConfigService);

  // Enable CORS
  const allowedOrigins = process.env.ALLOWED_ORIGINS
    ? process.env.ALLOWED_ORIGINS.split(',')
    : [
        'http://localhost:8080', // Flutter web
        'http://localhost:3000', // Admin web (if exists)
        'http://127.0.0.1:8080',
        'http://127.0.0.1:3000',
      ];

  app.enableCors({
    origin: (origin, callback) => {
      // Allow requests with no origin (mobile apps, Postman, etc.)
      if (!origin) {
        return callback(null, true);
      }
      
      // Check if origin is in allowed list
      if (allowedOrigins.includes(origin) || allowedOrigins.includes('*')) {
        return callback(null, true);
      }
      
      // In development, allow all origins
      if (process.env.NODE_ENV !== 'production') {
        return callback(null, true);
      }
      
      callback(new Error('Not allowed by CORS'));
    },
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: [
      'Content-Type',
      'Authorization',
      'Accept',
      'X-Requested-With',
    ],
    exposedHeaders: ['Authorization'],
  });

  // Global validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );
  
  // Global exception filter
  app.useGlobalFilters(new ApiExceptionFilter());

  // Swagger documentation
  if (process.env.NODE_ENV !== 'production') {
    const swaggerConfig = new DocumentBuilder()
      .setTitle('RAS Backend API')
      .setDescription('Roadside Assistance Marketplace - Complete Backend APIs')
      .setVersion('1.0')
      .addBearerAuth()
      .addTag('Auth', 'Authentication endpoints')
      .addTag('Users', 'User profile management')
      .addTag('Drivers', 'Driver management')
      .addTag('Jobs', 'Job/Trip management')
      .addTag('Quotes', 'Price quotes')
      .addTag('Payments', 'Payment processing')
      .addTag('Wallets', 'Wallet management')
      .addTag('Payouts', 'Driver payouts')
      .addTag('Ratings', 'Ratings and reviews')
      .addTag('Vehicles', 'Customer vehicle management')
      .addTag('KYC', 'KYC document management')
      .addTag('Support', 'Support tickets')
      .addTag('Notifications', 'Push notifications and SMS')
      .addTag('Admin', 'Admin panel APIs')
      .addTag('Analytics', 'Analytics and reporting')
      .build();
    const document = SwaggerModule.createDocument(app, swaggerConfig);
    SwaggerModule.setup('docs', app, document);
    logger.log('Swagger documentation available at /docs');
  }

  const port = config.get<number>('port') ?? 3001;
  await app.listen(port);
  logger.log(`🚀 RAS Backend running on port ${port}`);
  logger.log(`📚 Environment: ${process.env.NODE_ENV || 'development'}`);
}
bootstrap();
