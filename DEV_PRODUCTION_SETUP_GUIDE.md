# 🚀 Development vs Production Server Guide

## 📋 Overview

This guide explains how to work with **two separate environments**:
- **Development Server**: For testing and development (localhost)
- **Production Server**: For real clients (https://api.medical-appointments.com)

Both servers use **real data only** - no test/garbage data.

---

## 🛠️ Development Server Setup

### Purpose
- Test new features during development
- Debug issues locally
- Develop without affecting production

### Backend Setup (Local)

1. **Start PostgreSQL** (if not running):
   ```bash
   # Windows: Start PostgreSQL service
   # Or use Docker:
   docker-compose up -d postgres
   ```

2. **Configure Environment**:
   ```bash
   cd backend
   cp .env.example .env
   ```
   
   Edit `.env`:
   ```env
   NODE_ENV=development
   PORT=3000
   BASE_URL=http://localhost:3000
   
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=medical_appointments_dev
   DB_USER=medical_admin
   DB_PASSWORD=Haitham@0412
   ```

3. **Setup Database**:
   ```bash
   npm install
   npm run build
   npm run migrate
   npm run seed  # Creates ONLY developer account
   ```

4. **Start Backend**:
   ```bash
   npm run dev  # Runs with hot-reload
   ```

   Backend will be available at: `http://localhost:3000`

### Frontend Setup (Local)

1. **Run Flutter App in Debug Mode**:
   ```powershell
   cd C:\Projects\medical-app
   .\flutter\bin\flutter.bat run -d windows
   # Or for web:
   .\flutter\bin\flutter.bat run -d chrome
   ```

2. **Automatic Configuration**:
   - Debug mode automatically uses: `http://localhost:3000/api/v1`
   - No configuration needed!

3. **Verify Connection**:
   - Open app
   - Check console logs - should show: `Base URL: http://localhost:3000/api/v1`
   - Login with developer account

---

## 🌐 Production Server Setup

### Purpose
- Serve real clients
- Handle real appointments and payments
- Production-ready environment

### Current Production Setup

**Backend**: `https://api.medical-appointments.com`
- Running on VPS (66.29.133.192)
- Managed by PM2
- PostgreSQL database
- SSL certificate installed

**Frontend**: `https://medical-appointments.com`
- Served by Nginx
- SSL certificate installed
- Points to production backend

### Frontend Configuration

**For Production Builds**:
```powershell
# Build for production (web)
.\flutter\bin\flutter.bat build web --release

# Build for production (Windows)
.\flutter\bin\flutter.bat build windows --release
```

**Automatic Configuration**:
- Release mode automatically uses: `https://api.medical-appointments.com/api/v1`
- No manual configuration needed!

---

## 🔄 Switching Between Environments

### Method 1: Automatic (Recommended)

The app automatically detects the environment:

| Mode | API URL | How to Run |
|------|---------|------------|
| **Development** | `http://localhost:3000/api/v1` | `flutter run` (debug mode) |
| **Production** | `https://api.medical-appointments.com/api/v1` | `flutter build --release` |

### Method 2: Manual Override

For testing production API from development mode:

```powershell
# Run with custom API URL
.\flutter\bin\flutter.bat run --dart-define=API_BASE_URL=https://api.medical-appointments.com/api/v1
```

---

## 📊 Database Management

### Development Database

**Location**: Local PostgreSQL
**Name**: `medical_appointments_dev`
**Data**: Real data (same structure as production)

**Reset Development Database**:
```bash
cd backend
npm run migrate:rollback  # Rollback all migrations
npm run migrate           # Re-run migrations
npm run seed              # Seed developer account only
```

### Production Database

**Location**: VPS PostgreSQL (66.29.133.192)
**Name**: `medical_appointments`
**Data**: Real client data (DO NOT RESET!)

**Access Production Database**:
```bash
ssh root@66.29.133.192
sudo -u postgres psql medical_appointments
```

---

## 🧹 Removing Test/Garbage Data

### Already Done ✅

1. **Seed File Updated**: Only creates developer account
2. **No Test Accounts**: Removed patient.example and doctor.example
3. **Clean Database**: Both dev and production start clean

### Manual Cleanup (if needed)

**Development Database**:
```sql
-- Connect to dev database
psql -U medical_admin -d medical_appointments_dev

-- Remove test users (if any)
DELETE FROM users WHERE email LIKE '%example%' OR email LIKE '%test%';
DELETE FROM users WHERE email NOT IN ('haitham.massarwah@medical-appointments.com');
```

**Production Database**:
```sql
-- ⚠️ BE CAREFUL! This is production!
-- Only remove if you're absolutely sure

-- List all users first
SELECT id, email, role, created_at FROM users ORDER BY created_at;

-- Remove specific test accounts (if any)
-- DELETE FROM users WHERE email = 'test@example.com';
```

---

## 🔐 Developer Account

**Email**: `haitham.massarwah@medical-appointments.com`
**Password**: `Developer@2024`
**Role**: `developer`

**Available in**:
- ✅ Development database
- ✅ Production database

**Use this account to**:
- Create real doctor accounts
- Create real patient accounts
- Manage the system
- Test features

---

## 📝 Workflow Examples

### Example 1: Developing a New Feature

1. **Start Development Backend**:
   ```bash
   cd backend
   npm run dev
   ```

2. **Run Flutter App**:
   ```powershell
   cd C:\Projects\medical-app
   .\flutter\bin\flutter.bat run -d windows
   ```

3. **App automatically connects to**: `http://localhost:3000/api/v1`

4. **Test your feature** with real data structure

5. **When ready**, deploy to production

### Example 2: Testing Production API Locally

1. **Run Flutter with production API**:
   ```powershell
   .\flutter\bin\flutter.bat run --dart-define=API_BASE_URL=https://api.medical-appointments.com/api/v1
   ```

2. **App connects to production** (be careful!)

### Example 3: Building for Production

1. **Build Web**:
   ```powershell
   .\flutter\bin\flutter.bat build web --release
   # Automatically uses production API
   ```

2. **Build Windows**:
   ```powershell
   .\flutter\bin\flutter.bat build windows --release
   # Automatically uses production API
   ```

---

## ✅ Checklist

### Development Environment
- [ ] PostgreSQL running locally
- [ ] Backend `.env` configured for development
- [ ] Database migrated and seeded
- [ ] Backend running on `http://localhost:3000`
- [ ] Flutter app runs in debug mode
- [ ] App connects to local backend automatically

### Production Environment
- [ ] Backend deployed to VPS
- [ ] PM2 running backend
- [ ] Nginx configured
- [ ] SSL certificates installed
- [ ] Frontend deployed
- [ ] Production database contains real data only

---

## 🚨 Important Notes

1. **Never reset production database** - it contains real client data!
2. **Development database** can be reset anytime
3. **Both environments** use the same data structure
4. **No test accounts** are created automatically
5. **All accounts** must be created through the application UI

---

## 📞 Troubleshooting

### App connects to wrong server?

**Check logs**:
```dart
// In Flutter app, check:
print('API Base URL: ${AppConfig.baseUrl}');
```

**Solution**: Make sure you're running in the correct mode:
- Debug mode = Development server
- Release mode = Production server

### Backend not responding?

**Development**:
```bash
# Check if backend is running
curl http://localhost:3000/health
```

**Production**:
```bash
# Check if backend is running
curl https://api.medical-appointments.com/health
```

### Database connection issues?

**Development**:
- Check PostgreSQL is running
- Verify `.env` credentials
- Check database exists: `psql -U medical_admin -d medical_appointments_dev`

**Production**:
- SSH to server: `ssh root@66.29.133.192`
- Check PM2: `pm2 logs medical-api`
- Check database: `sudo -u postgres psql medical_appointments`

---

## 🎯 Summary

- **Development**: Local testing with `http://localhost:3000`
- **Production**: Real clients with `https://api.medical-appointments.com`
- **Both**: Use real data structure, no garbage/test data
- **Automatic**: App detects environment automatically
- **Clean**: Only developer account created by default

