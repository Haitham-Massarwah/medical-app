# 🧪 Test Endpoints Guide

## ✅ Server is Running!

Your backend server is running on **http://localhost:3000**

---

## 📋 Available Endpoints:

### Calendar Endpoints:
- **GET** `/api/v1/calendar/google/auth-url` - Get Google Calendar OAuth URL (requires auth)
- **GET** `/api/v1/calendar/outlook/auth-url` - Get Outlook Calendar OAuth URL (requires auth)
- **GET** `/api/v1/calendar/google/callback` - Google OAuth callback (public)
- **GET** `/api/v1/calendar/outlook/callback` - Outlook OAuth callback (public)
- **GET** `/api/v1/calendar/status` - Get calendar connection status (requires auth)
- **POST** `/api/v1/calendar/disconnect` - Disconnect calendar (requires auth)

### Auth Endpoints:
- **POST** `/api/v1/auth/register` - Register new user
- **POST** `/api/v1/auth/login` - Login
- **POST** `/api/v1/auth/logout` - Logout (requires auth)
- **GET** `/api/v1/auth/me` - Get current user (requires auth)

### Admin Endpoints (requires developer/admin role):
- **GET** `/api/v1/admin/database/stats` - Database statistics
- **GET** `/api/v1/admin/database/users` - List users
- **GET** `/api/v1/admin/database/appointments` - List appointments
- **GET** `/api/v1/admin/database/doctors` - List doctors
- **GET** `/api/v1/admin/database/patients` - List patients

---

## 🧪 Quick Tests:

### 1. Test Server is Running:
```powershell
# Should return 404 (endpoint doesn't exist, but server is running)
curl http://localhost:3000/api/v1/health
```

### 2. Test Calendar Auth URL (requires login first):
```powershell
# First, login to get token
$loginResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/v1/auth/login" `
  -Method POST `
  -ContentType "application/json" `
  -Body '{"email":"haitham.massarwah@medical-appointments.com","password":"Developer@2024"}'

$token = $loginResponse.data.token

# Then get calendar auth URL
Invoke-RestMethod -Uri "http://localhost:3000/api/v1/calendar/google/auth-url" `
  -Method GET `
  -Headers @{Authorization="Bearer $token"}
```

### 3. Test Calendar Status (requires auth):
```powershell
Invoke-RestMethod -Uri "http://localhost:3000/api/v1/calendar/status" `
  -Method GET `
  -Headers @{Authorization="Bearer $token"}
```

---

## ✅ Server Status:

- ✅ **Server Running:** http://localhost:3000
- ✅ **API Base:** http://localhost:3000/api/v1
- ✅ **Google Calendar:** Configured and ready
- ✅ **Calendar Callback:** http://localhost:3000/api/v1/calendar/google/callback

---

## 🎯 Next Steps:

1. **Test Google Calendar Connection:**
   - Login to get auth token
   - Get calendar auth URL
   - Open URL in browser to authorize
   - Test calendar sync

2. **Test Calendar Features:**
   - Create calendar events
   - Sync appointments
   - Test reminders

---

**Server is ready! Start testing the Google Calendar integration!**

