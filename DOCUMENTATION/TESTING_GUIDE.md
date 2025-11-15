# 🧪 Medical Appointment System - Testing Guide

## 🎯 Testing Plan

We'll test in this order:
1. ✅ Flutter Frontend (UI/UX)
2. ✅ Backend API Foundation
3. ⏳ Integration Testing
4. ⏳ End-to-End Testing

---

## 📱 PART 1: Testing Flutter Frontend

### Prerequisites
- Flutter SDK installed
- Chrome browser installed
- VS Code or Android Studio (optional)

### Step 1: Install Flutter Dependencies
```bash
cd C:\Users\Haitham.Massawah\OneDrive\App
flutter pub get
```

**Expected Output:**
```
Running "flutter pub get" in App...
Resolving dependencies...
+ flutter_bloc 8.1.3
+ dio 5.3.2
+ hive_flutter 1.1.0
...
Got dependencies!
```

### Step 2: Run Flutter App
```bash
# Run on Chrome (recommended for first test)
flutter run -d chrome

# Or use START.bat
START.bat
```

**Expected Output:**
```
Launching lib\main.dart on Chrome in debug mode...
✓ Built build\web\main.dart.js
Waiting for connection from debug service on Chrome...
This app is linked to the debug service: ws://127.0.0.1:...
Debug service listening on ws://127.0.0.1:...

🔥  To hot restart changes while running, press "r" or "R".
For a more detailed help message, press "h".
To quit, press "q".

An Observatory debugger and profiler on Chrome is available at: http://127.0.0.1:...
The Flutter DevTools debugger and profiler on Chrome is available at: http://127.0.0.1:...
```

### Step 3: Test Frontend Features

#### ✅ Test Checklist:

**Homepage:**
- [ ] Splash screen appears with animation
- [ ] Redirects to home page after 3 seconds
- [ ] Medical specialties grid displays
- [ ] Search bar is visible
- [ ] Language switcher works (Hebrew/Arabic/English)
- [ ] Navigation menu accessible

**Navigation:**
- [ ] Click on medical specialties (cards work)
- [ ] Navigate to appointments page
- [ ] Navigate to profile page
- [ ] Navigate to login page
- [ ] Back button works

**Login Page:**
- [ ] Form fields visible and functional
- [ ] Email validation works
- [ ] Password field has show/hide toggle
- [ ] Form validation messages appear
- [ ] Register link works

**Register Page:**
- [ ] All form fields work
- [ ] Password confirmation validation
- [ ] Role selector works
- [ ] Form submits (will show error - backend not connected yet)

**Multi-Language:**
- [ ] Switch to Hebrew - UI becomes RTL
- [ ] Switch to Arabic - UI becomes RTL
- [ ] Switch to English - UI becomes LTR
- [ ] All text translates correctly

**UI/UX:**
- [ ] Medical color scheme visible
- [ ] Specialty cards have correct colors
- [ ] Icons display properly
- [ ] Responsive design (resize window)
- [ ] No visual glitches

### Step 4: Check for Errors

Open Chrome DevTools (F12):
- **Console Tab:** Check for JavaScript errors
- **Network Tab:** Check for failed requests (expected - no backend yet)

**Common Issues:**
```
✅ OK: "Failed to load network data" - Expected (backend not running)
✅ OK: Missing images - Use placeholders
❌ ERROR: "RenderFlex overflowed" - UI issue (report this)
❌ ERROR: "Null check operator" - Code bug (report this)
```

---

## 🖥️ PART 2: Testing Backend API

### Prerequisites
- Node.js 18+ installed
- PostgreSQL 14+ installed
- Redis 6+ installed (optional for now)

### Step 1: Install Node.js
```bash
# Check if Node.js is installed
node --version
npm --version

# If not installed, download from:
# https://nodejs.org (LTS version)
```

### Step 2: Install PostgreSQL
```bash
# Download from:
# https://www.postgresql.org/download/windows/

# Or use installer:
# https://www.enterprisedb.com/downloads/postgres-postgresql-downloads
```

### Step 3: Setup Backend
```bash
cd backend

# Install dependencies
npm install

# Create database
psql -U postgres
CREATE DATABASE medical_appointments;
\q

# Copy environment file
copy env.example .env

# Edit .env with your database password
notepad .env
```

**Edit .env - Minimum Required:**
```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=medical_appointments
DB_USER=postgres
DB_PASSWORD=YOUR_POSTGRES_PASSWORD_HERE
JWT_SECRET=test_secret_key_change_in_production
JWT_REFRESH_SECRET=test_refresh_secret_change_in_production
```

### Step 4: Run Database Migrations
```bash
# Run migrations to create tables
npm run migrate
```

**Expected Output:**
```
Batch 1 run: 1 migrations
Migrated: 001_initial_schema.ts
✅ Database connected successfully
```

### Step 5: Start Backend Server
```bash
# Development mode with hot reload
npm run dev
```

**Expected Output:**
```
[DATE TIME] [info]: ✅ Database connected successfully
[DATE TIME] [info]: 🚀 Server running on port 3000
[DATE TIME] [info]: 📝 Environment: development
[DATE TIME] [info]: 🔗 API Base URL: http://localhost:3000/api/v1
[DATE TIME] [info]: 🏥 Medical Appointment System Backend Ready!
```

### Step 6: Test Backend Endpoints

**Health Check:**
```bash
# Open browser or use curl
curl http://localhost:3000/health

# Or visit: http://localhost:3000/health
```

**Expected Response:**
```json
{
  "status": "OK",
  "timestamp": "2024-12-20T10:30:00.000Z",
  "uptime": 5.234,
  "environment": "development"
}
```

### Step 7: Test API Endpoints (Basic)

Since routes aren't implemented yet, you'll see 404s (expected):

```bash
# Test authentication endpoint (will return 404 for now)
curl http://localhost:3000/api/v1/auth/login -X POST

# Expected: 404 Not Found (routes pending implementation)
```

---

## 🔗 PART 3: Integration Testing

### Connect Frontend to Backend

**Step 1: Update Frontend API URL**

Edit: `lib/core/utils/app_constants.dart`

Find:
```dart
static const String baseUrl = 'https://api.medical-appointments.com';
```

Change to:
```dart
static const String baseUrl = 'http://localhost:3000';
```

**Step 2: Restart Flutter App**
```bash
# Stop the app (press 'q' in terminal)
# Restart
flutter run -d chrome
```

**Step 3: Test Login (Will Fail - Expected)**
- Navigate to login page
- Enter test credentials
- Click login
- Check Chrome DevTools Network tab
- Should see POST request to `http://localhost:3000/api/v1/auth/login`
- Will get 404 (routes not implemented yet)

---

## 📊 Testing Results Template

### Frontend Testing Results

```
✅ PASSED:
- [ ] Splash screen works
- [ ] Home page loads
- [ ] Medical specialties display
- [ ] Navigation works
- [ ] Language switching works
- [ ] RTL layout works
- [ ] Forms validate correctly
- [ ] UI is responsive

❌ FAILED:
- [ ] (List any issues found)

⚠️ WARNINGS:
- [ ] Backend not connected (expected)
- [ ] Sample data only
```

### Backend Testing Results

```
✅ PASSED:
- [ ] Node.js installed
- [ ] PostgreSQL installed
- [ ] Database created
- [ ] Migrations ran successfully
- [ ] Server starts without errors
- [ ] Health endpoint responds

❌ FAILED:
- [ ] (List any issues found)

⚠️ WARNINGS:
- [ ] API routes not implemented yet (expected)
- [ ] Redis not configured (optional)
```

---

## 🐛 Troubleshooting

### Flutter Issues

**Issue: "flutter: command not found"**
```bash
# Solution: Flutter not installed or not in PATH
# Follow SETUP_GUIDE.md to install Flutter
```

**Issue: "Waiting for connection from debug service"**
```bash
# Solution: Chrome might be blocked
# Try: flutter run -d web-server --web-port 8080
# Then open: http://localhost:8080
```

**Issue: Build errors**
```bash
# Solution: Clean and rebuild
flutter clean
flutter pub get
flutter run -d chrome
```

### Backend Issues

**Issue: "Cannot find module"**
```bash
# Solution: Dependencies not installed
npm install
```

**Issue: "ECONNREFUSED" database error**
```bash
# Solution: PostgreSQL not running
# Windows: Start PostgreSQL service
# Or: pg_ctl -D "C:\Program Files\PostgreSQL\14\data" start
```

**Issue: Migration failed**
```bash
# Solution: Database doesn't exist
psql -U postgres
CREATE DATABASE medical_appointments;
\q
npm run migrate
```

---

## ✅ Success Criteria

### Minimum Viable Test (MVP)

**Frontend:**
✅ App loads without crashing
✅ Can navigate between pages
✅ Language switching works
✅ Forms are functional
✅ UI looks professional

**Backend:**
✅ Server starts successfully
✅ Database connection works
✅ Health endpoint responds
✅ No critical errors in logs

### Ready for Next Phase

When both frontend and backend tests pass, you're ready to continue with:
1. ⏳ Implementing remaining API routes
2. ⏳ Building appointment engine
3. ⏳ Integrating payment system
4. ⏳ Adding notification system

---

## 📞 Getting Help

If you encounter issues:

1. **Check Logs:**
   - Frontend: Chrome DevTools Console
   - Backend: Terminal output

2. **Read Documentation:**
   - `TROUBLESHOOTING.md`
   - `SETUP_GUIDE.md`
   - `backend/README.md`

3. **Common Issues:**
   - Port already in use: Change PORT in .env
   - Database connection: Check credentials
   - Build errors: Run `flutter clean`

---

## 🎯 Test Summary

After completing tests, fill this out:

```
Date: _______________

Frontend Status: [ ] Pass [ ] Fail
Backend Status:  [ ] Pass [ ] Fail
Integration:     [ ] Pass [ ] Fail

Issues Found: 
_________________________________
_________________________________
_________________________________

Ready for Next Phase: [ ] Yes [ ] No

Notes:
_________________________________
_________________________________
```

---

**Once testing is complete and successful, we'll continue with the remaining TODO items!** 🚀
