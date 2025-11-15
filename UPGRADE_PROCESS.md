# 🔄 System Upgrade Process

## 📋 Overview

This document provides a clear, step-by-step procedure for performing upgrades on the development and production environments.

---

## ⚠️ Important Notes

- **Always test upgrades in development first**
- **Always backup production database before upgrading**
- **Follow the exact order of steps**
- **Have a rollback plan ready**

---

## 🛠️ Development Environment Upgrade

### Prerequisites

- ✅ Development database backed up (optional but recommended)
- ✅ Git repository updated
- ✅ All local changes committed or stashed

### Step-by-Step Process

#### Step 1: Backup (Optional)

```bash
# Backup development database
cd backend
pg_dump -U medical_admin medical_appointments_dev > backup_dev_$(date +%Y%m%d_%H%M%S).sql
```

#### Step 2: Update Code

```bash
# Navigate to project
cd C:\Projects\medical-app

# Pull latest changes
git pull origin main

# Or if using specific branch
git checkout main
git pull origin main
```

#### Step 3: Update Dependencies

```bash
# Backend dependencies
cd backend
npm install

# Frontend dependencies
cd ..
.\flutter\bin\flutter.bat pub get
```

#### Step 4: Run Database Migrations

```bash
cd backend

# Build TypeScript
npm run build

# Run migrations
npm run migrate

# Run seeds (if needed)
npm run seed
```

#### Step 5: Rebuild Frontend (if needed)

```powershell
# Rebuild Flutter app
cd C:\Projects\medical-app
.\flutter\bin\flutter.bat clean
.\flutter\bin\flutter.bat pub get
.\flutter\bin\flutter.bat build windows --release
```

#### Step 6: Test

```bash
# Start backend
cd backend
npm run dev

# Test all features
# - Login
# - Create accounts
# - Book appointments
# - Process payments
# - etc.
```

#### Step 7: Verify

- ✅ All features working
- ✅ No errors in console
- ✅ Database migrations successful
- ✅ API endpoints responding

---

## 🌐 Production Environment Upgrade

### Prerequisites

- ✅ **MANDATORY**: Production database backup
- ✅ Maintenance window scheduled (if needed)
- ✅ Rollback plan prepared
- ✅ Tested in development first

### Step-by-Step Process

#### Step 1: Backup Production Database ⚠️ CRITICAL

```bash
# SSH to production server
ssh root@66.29.133.192

# Backup database
cd /var/www/medical-backend
pg_dump -U medical_admin medical_appointments > backup_prod_$(date +%Y%m%d_%H%M%S).sql

# Verify backup
ls -lh backup_prod_*.sql

# Copy backup to local machine (optional but recommended)
# From your local machine:
scp root@66.29.133.192:/var/www/medical-backend/backup_prod_*.sql ./
```

#### Step 2: Prepare New Version

```bash
# On your local machine
cd C:\Projects\medical-app

# Ensure code is up to date
git pull origin main

# Build backend
cd backend
npm install
npm run build

# Create deployment package
cd ..
# Option A: Zip backend
Compress-Archive -Path backend\* -DestinationPath backend-prod-upgrade.zip -Force

# Option B: Use git (if server has git access)
# On server: git pull origin main
```

#### Step 3: Upload to Server

```bash
# Upload backend
scp backend-prod-upgrade.zip root@66.29.133.192:/var/www/

# Or upload entire backend folder
scp -r backend root@66.29.133.192:/var/www/medical-backend-new
```

#### Step 4: Deploy on Server

```bash
# SSH to server
ssh root@66.29.133.192

# Stop current backend
cd /var/www/medical-backend
pm2 stop medical-api

# Extract/Prepare new version
cd /var/www
unzip backend-prod-upgrade.zip -d medical-backend-new
# OR if using git:
# cd /var/www/medical-backend-new
# git pull origin main

# Install dependencies
cd /var/www/medical-backend-new
npm install --production

# Build TypeScript
npm run build

# Copy environment file
cp /var/www/medical-backend/.env /var/www/medical-backend-new/.env

# Run database migrations
NODE_ENV=production npm run migrate

# Test new version (optional - start in test mode)
# NODE_ENV=production npm start
```

#### Step 5: Switch to New Version (Zero Downtime)

```bash
# Rename old version (for rollback)
mv /var/www/medical-backend /var/www/medical-backend-old

# Activate new version
mv /var/www/medical-backend-new /var/www/medical-backend

# Start backend
cd /var/www/medical-backend
pm2 start npm --name medical-api -- run start
pm2 save

# Verify it's running
pm2 status
pm2 logs medical-api --lines 50
```

#### Step 6: Verify Production

```bash
# Check health endpoint
curl https://api.medical-appointments.com/health

# Check logs
pm2 logs medical-api --lines 100

# Test critical features:
# - Login
# - API responses
# - Database connectivity
```

#### Step 7: Monitor

```bash
# Monitor for 10-15 minutes
pm2 monit

# Check error logs
pm2 logs medical-api --err --lines 100
```

---

## 🔙 Rollback Process

### If Upgrade Fails

#### Quick Rollback (Same Server)

```bash
# Stop new version
pm2 stop medical-api

# Restore old version
mv /var/www/medical-backend /var/www/medical-backend-broken
mv /var/www/medical-backend-old /var/www/medical-backend

# Start old version
cd /var/www/medical-backend
pm2 start npm --name medical-api -- run start
pm2 save

# Verify
pm2 status
curl https://api.medical-appointments.com/health
```

#### Database Rollback (If Migrations Failed)

```bash
# Restore database backup
psql -U medical_admin medical_appointments < backup_prod_YYYYMMDD_HHMMSS.sql

# Verify data
psql -U medical_admin medical_appointments -c "SELECT COUNT(*) FROM users;"
```

---

## 📊 Upgrade Checklist

### Pre-Upgrade

- [ ] Code tested in development environment
- [ ] All tests passing
- [ ] Database backup created (production)
- [ ] Rollback plan prepared
- [ ] Maintenance window scheduled (if needed)
- [ ] Team notified

### During Upgrade

- [ ] Code uploaded to server
- [ ] Dependencies installed
- [ ] Database migrations run
- [ ] Environment variables configured
- [ ] Backend restarted
- [ ] Health check passed

### Post-Upgrade

- [ ] All endpoints responding
- [ ] Login working
- [ ] Critical features tested
- [ ] No errors in logs
- [ ] Performance normal
- [ ] Database integrity verified

---

## 🔍 Verification Commands

### Check Backend Status

```bash
# On server
pm2 status
pm2 logs medical-api --lines 50

# Health check
curl https://api.medical-appointments.com/health
```

### Check Database

```bash
# Connect to database
psql -U medical_admin medical_appointments

# Check tables
\dt

# Check user count
SELECT COUNT(*) FROM users;

# Check recent activity
SELECT * FROM users ORDER BY created_at DESC LIMIT 10;
```

### Check Frontend

```bash
# Test frontend
curl -I https://medical-appointments.com

# Check SSL
curl -I https://www.medical-appointments.com
```

---

## 📝 Upgrade Log Template

**Date:** _______________
**Version:** _______________
**Upgrader:** _______________

**Pre-Upgrade:**
- [ ] Backup created
- [ ] Code tested
- [ ] Team notified

**Upgrade Steps:**
1. _______________
2. _______________
3. _______________

**Post-Upgrade:**
- [ ] All systems operational
- [ ] No errors detected
- [ ] Performance normal

**Issues Encountered:**
_______________

**Rollback Required:** Yes / No

---

## 🚨 Emergency Contacts

- **Developer Email:** haitham.massarwah@medical-appointments.com
- **Server Access:** SSH root@66.29.133.192
- **Database:** PostgreSQL on localhost

---

## 📚 Related Documentation

- `DEV_PRODUCTION_SETUP_GUIDE.md` - Environment setup
- `SYSTEM_REQUIREMENTS_IMPLEMENTATION.md` - System requirements
- `backend/config/development.config.json` - Dev configuration
- `backend/config/production.config.json` - Production configuration

