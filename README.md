# Roadside Assistance Marketplace

A comprehensive platform connecting customers needing roadside assistance with service providers. This repository contains the complete UI/UX implementation for all three applications.

## 🚀 Features

- **Customer App**: Request roadside assistance, track drivers, make payments
- **Driver App**: Manage availability, accept jobs, track earnings
- **Admin Panel**: Manage users, drivers, trips, pricing, and analytics

## 📁 Project Structure

- `apps/customer_app/` - Flutter customer mobile app
- `apps/driver_app/` - Flutter driver mobile app  
- `apps/admin_web/` - Next.js admin web panel
- `packages/shared/` - Shared design system and constants
- `assets/` - Shared assets (fonts, images)

## 🛠️ Prerequisites

- **Flutter SDK**: 3.16.0 or higher
- **Node.js**: 18.0.0 or higher
- **Git**: Latest version
- **Chrome/Chromium**: For web testing

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/Hell1213/roadside-assistance-marketplace.git
cd roadside-assistance-marketplace
```

### 2. Setup Flutter Apps

**Customer App:**
```bash
cd apps/customer_app
flutter pub get
flutter run -d chrome --web-port 8080
```

**Driver App:**
```bash
cd apps/driver_app
flutter pub get
flutter run -d chrome --web-port 8081
```

### 3. Setup Admin Web Panel
```bash
cd apps/admin_web
npm install
npm run dev
```

## 🌐 Access Applications

- **Customer App**: http://localhost:8080
- **Driver App**: http://localhost:8081  
- **Admin Panel**: http://localhost:3000

## 🎨 Design System

The project uses a shared design system with:
- **Primary Color**: Yellow (#fbbd00)
- **Secondary Color**: Dark Purple (#573c80)
- **Typography**: Roboto font family
- **Consistent spacing and components** across all apps


## 🔧 Development Notes

- All apps are currently configured for web development
- Mobile deployment requires additional platform setup
- Design system is centralized in `packages/shared/`
- Helper documentation files are excluded from repository

## 📄 License

This project is proprietary software developed for roadside assistance marketplace.