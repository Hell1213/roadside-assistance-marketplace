# RAS Backend API

Complete backend implementation for Roadside Assistance Marketplace platform.

## 🚀 Features

### Core Services
- ✅ **Authentication**: OTP-based login with JWT access/refresh tokens
- ✅ **User Management**: Customer and driver profiles
- ✅ **Pricing Engine**: Dynamic fare calculation with surge pricing
- ✅ **Job Management**: Complete job lifecycle with state machine
- ✅ **Dispatch System**: Geo-spatial driver matching with PostGIS
- ✅ **Real-Time**: WebSocket support with Socket.IO + Redis pub/sub
- ✅ **Payments**: Razorpay integration with webhooks
- ✅ **Wallets**: Balance management with transaction ledger
- ✅ **Payouts**: Driver payout system
- ✅ **Notifications**: Push (FCM) + SMS (MSG91/AWS SNS) with fallback
- ✅ **Ratings & Reviews**: 5-star rating system for completed jobs
- ✅ **Vehicle Management**: Customer vehicle storage
- ✅ **KYC**: Document upload and verification workflow
- ✅ **Support**: Help desk ticket system
- ✅ **Admin Panel**: RBAC with audit logging
- ✅ **Analytics**: Dashboard metrics and reporting APIs

## 📋 Prerequisites

- Node.js 18+
- PostgreSQL 14+ with PostGIS extension
- Redis 6+
- Docker & Docker Compose (for local development)

## 🛠️ Setup

### 1. Install Dependencies
```bash
npm install
```

### 2. Environment Configuration
Copy `.env.example` to `.env` and configure:
```bash
cp env.example .env
```

Required environment variables:
- `DATABASE_URL`: PostgreSQL connection string
- `REDIS_URL`: Redis connection string
- `JWT_ACCESS_SECRET`: JWT secret for access tokens
- `JWT_REFRESH_SECRET`: JWT secret for refresh tokens
- `RAZORPAY_KEY_ID`: Razorpay API key (when available)
- `RAZORPAY_KEY_SECRET`: Razorpay API secret (when available)
- `FCM_SERVICE_ACCOUNT_KEY_PATH`: Path to FCM service account JSON (optional)
- `SMS_PROVIDER`: `msg91` or `aws` (optional)

### 3. Database Setup
```bash
# Start PostgreSQL and Redis
docker-compose up -d

# Run migrations
npm run prisma:migrate:dev

# Generate Prisma Client
npm run prisma:generate
```

### 4. Start Development Server
```bash
npm run start:dev
```

Server runs on `http://localhost:3001`

## 📚 API Documentation

Once the server is running, access Swagger documentation at:
- **Swagger UI**: `http://localhost:3001/docs`

## 🏗️ Architecture

### Tech Stack
- **Framework**: NestJS (TypeScript)
- **Database**: PostgreSQL + PostGIS
- **Cache/Queue**: Redis
- **Real-Time**: Socket.IO with Redis adapter
- **ORM**: Prisma
- **Validation**: class-validator, class-transformer
- **API Docs**: Swagger/OpenAPI

### Project Structure
```
src/
├── auth/           # Authentication (OTP, JWT)
├── users/          # User management
├── drivers/        # Driver management
├── pricing/        # Pricing rules
├── quotes/         # Price quotes
├── jobs/           # Job lifecycle
├── dispatch/       # Driver dispatch system
├── payments/       # Payment processing (Razorpay)
├── wallets/        # Wallet management
├── payouts/        # Driver payouts
├── notifications/  # Push & SMS notifications
├── ratings/        # Ratings & reviews
├── vehicles/       # Customer vehicle management
├── kyc/            # KYC document management
├── support/        # Support tickets
├── admin/          # Admin panel APIs
├── analytics/      # Analytics & reporting
├── realtime/       # WebSocket gateway
├── prisma/         # Prisma service
├── redis/          # Redis service
└── common/         # Shared utilities
```

## 🔐 Authentication Flow

1. **Request OTP**: `POST /auth/request-otp` { phone, role }
2. **Verify OTP**: `POST /auth/verify-otp` { phone, otp } → Returns access_token, refresh_token
3. **Use Access Token**: Include in `Authorization: Bearer <token>` header
4. **Refresh Token**: `POST /auth/refresh` { refresh_token } → New tokens

## 📊 Key Endpoints

### Customer Endpoints
- `POST /quotes` - Get fare estimate
- `POST /jobs` - Create job from quote
- `GET /jobs` - Get job history
- `GET /jobs/:id` - Get job details
- `POST /payments/orders` - Create payment order
- `POST /payments/verify` - Verify payment
- `POST /ratings/jobs/:jobId` - Rate completed job
- `POST /vehicles` - Add vehicle
- `GET /wallets/balance` - Get wallet balance

### Driver Endpoints
- `PUT /driver/profile` - Update driver profile
- `PUT /driver/vehicle` - Update vehicle details
- `GET /driver/jobs` - Get pending job offers
- `POST /driver/jobs/:id/accept` - Accept job
- `POST /driver/jobs/:id/status` - Update job status
- `POST /driver/location` - Update location (for tracking)
- `POST /kyc/documents` - Upload KYC document
- `GET /payouts` - Get payout history
- `POST /payouts` - Initiate payout

### Admin Endpoints
- `GET /admin/dashboard` - Dashboard metrics
- `GET /admin/users` - List users
- `GET /admin/drivers` - List drivers
- `GET /admin/jobs` - List jobs
- `GET /admin/audit-logs` - Audit logs
- `GET /analytics/dashboard` - Analytics dashboard

## 🔄 Real-Time Events

WebSocket namespace: `/realtime`

**Client Events:**
- `subscribe:job` { jobId } - Subscribe to job updates
- `unsubscribe:job` { jobId } - Unsubscribe

**Server Events:**
- `job:state_change` - Job state updated
- `job:driver_location` - Driver location update
- `job:offer` - New job offer (driver)
- `job:assigned` - Job assigned (driver)
- `job:update` - Job update (customer)

## 🧪 Testing

```bash
# Unit tests
npm run test

# E2E tests
npm run test:e2e

# Test coverage
npm run test:cov
```

## 🚢 Production Deployment

1. Set `NODE_ENV=production`
2. Configure production database and Redis
3. Set secure JWT secrets
4. Configure Razorpay production credentials
5. Set up FCM/SMS provider credentials
6. Enable rate limiting (configured by default)
7. Set `ALLOWED_ORIGINS` for CORS

## 📝 Environment Variables

See `env.example` for complete list of environment variables.

## 🔧 Scripts

- `npm run start:dev` - Start development server with watch mode
- `npm run build` - Build for production
- `npm run start:prod` - Start production server
- `npm run prisma:migrate:dev` - Run database migrations
- `npm run prisma:generate` - Generate Prisma Client
- `npm run prisma:studio` - Open Prisma Studio

## 📖 API Versioning

Currently using v1 (implicit). Future versions can be added via route prefixes.

## 🔒 Security Features

- JWT-based authentication
- Role-based access control (RBAC)
- Rate limiting (100 req/min default)
- Input validation (DTOs with class-validator)
- SQL injection prevention (Prisma ORM)
- CORS configuration
- Audit logging for admin actions

## 📈 Monitoring

- Health endpoints: `/health`, `/health/db`, `/health/redis`
- Structured logging via NestJS Logger
- Error tracking via global exception filter

## 🤝 Contributing

Follow the established patterns:
- Use DTOs for all request/response validation
- Implement proper error handling
- Add Swagger documentation
- Follow NestJS module structure
- Write maintainable, production-ready code

## 📄 License

Proprietary - Roadside Assistance Marketplace
