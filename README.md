# Roadside Assistance Marketplace

A comprehensive platform connecting customers needing roadside assistance with service providers.

## Project Structure

- `apps/customer_app/` - Flutter customer mobile app
- `apps/driver_app/` - Flutter driver mobile app  
- `apps/admin_web/` - React/Next.js admin web panel
- `packages/shared/` - Shared utilities and models
- `assets/` - Shared assets (fonts, images)

## Quick Start

1. Follow the setup guide in `SETUP.md`
2. Run `./setup.sh` to install all dependencies
3. Use `./scripts/dev.sh [customer|driver|admin]` to start development

## Development

- Customer App: `./scripts/dev.sh customer`
- Driver App: `./scripts/dev.sh driver`
- Admin Panel: `./scripts/dev.sh admin`

## Requirements

- Flutter SDK 3.16.0+
- Node.js 18.0.0+
- Android Studio / Xcode for mobile development