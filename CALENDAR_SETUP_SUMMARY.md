# ✅ Calendar Integration Setup - Complete

## 🎯 What Was Done

### ✅ Backend Implementation

1. **Created Calendar Service** (`backend/src/services/calendar.service.ts`)
   - Google Calendar OAuth token exchange
   - Outlook Calendar OAuth token exchange
   - Token storage and retrieval
   - Token refresh functionality
   - Connection status checking
   - Disconnect functionality

2. **Updated Calendar Routes** (`backend/src/routes/calendar.routes.ts`)
   - Google Calendar auth URL generation
   - Outlook Calendar auth URL generation
   - OAuth callback handlers (public routes)
   - Token exchange and storage
   - Connection status endpoint
   - Disconnect endpoint

3. **Created Database Migration** (`backend/src/database/migrations/003_calendar_tokens.ts`)
   - `calendar_tokens` table for storing OAuth tokens
   - Supports both Google and Outlook
   - Automatic token refresh support

4. **Created Setup Guide** (`CALENDAR_SETUP_GUIDE.md`)
   - Complete step-by-step instructions
   - Google Cloud Console setup
   - Azure Portal setup
   - Configuration instructions

---

## 📋 What You Need to Do Next

### Step 1: Set Up Google Calendar OAuth

1. **Go to Google Cloud Console:**
   - https://console.cloud.google.com/
   - Sign in with: `hn.medicalapoointments@gmail.com`

2. **Create Project & Enable API:**
   - Create new project: "Medical Appointments System"
   - Enable "Google Calendar API"

3. **Create OAuth Credentials:**
   - Go to: APIs & Services → Credentials
   - Create OAuth 2.0 Client ID
   - Application type: Web application
   - Authorized redirect URIs:
     ```
     https://api.medical-appointments.com/api/v1/calendar/google/callback
     http://localhost:3000/api/v1/calendar/google/callback
     ```

4. **Copy Credentials:**
   - Client ID: `_________________`
   - Client Secret: `_________________`

---

### Step 2: Set Up Outlook Calendar OAuth

1. **Go to Azure Portal:**
   - https://portal.azure.com/
   - Sign in with Microsoft account

2. **Register Application:**
   - App registrations → New registration
   - Name: "Medical Appointments Calendar"
   - Redirect URI: `https://api.medical-appointments.com/api/v1/calendar/outlook/callback`

3. **Configure Permissions:**
   - API permissions → Add permission → Microsoft Graph
   - Delegated permissions:
     - `Calendars.ReadWrite`
     - `offline_access`

4. **Create Client Secret:**
   - Certificates & secrets → New client secret
   - Copy Application (client) ID
   - Copy Client secret value

---

### Step 3: Update Configuration Files

**On Server** (`/var/www/medical-backend/.env`):
```env
GOOGLE_CLIENT_ID=your_google_client_id_here
GOOGLE_CLIENT_SECRET=your_google_client_secret_here
GOOGLE_REDIRECT_URI=https://api.medical-appointments.com/api/v1/calendar/google/callback

OUTLOOK_CLIENT_ID=your_outlook_client_id_here
OUTLOOK_CLIENT_SECRET=your_outlook_client_secret_here
OUTLOOK_REDIRECT_URI=https://api.medical-appointments.com/api/v1/calendar/outlook/callback
```

**Update Config Files:**
- `backend/config/production.config.json`
- `backend/config/development.config.json`

---

### Step 4: Run Database Migration

**On Server:**
```bash
ssh root@66.29.133.192
cd /var/www/medical-backend
NODE_ENV=production npx knex migrate:latest
```

**Or Locally:**
```powershell
cd C:\Projects\medical-app\backend
npm run migrate
```

---

### Step 5: Restart Backend

**On Server:**
```bash
pm2 restart medical-api
pm2 logs medical-api
```

---

### Step 6: Test Integration

**Get Auth Token:**
```bash
# Login first
curl -X POST https://api.medical-appointments.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"haitham.massarwah@medical-appointments.com","password":"Developer@2024"}'
```

**Get Google Auth URL:**
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  https://api.medical-appointments.com/api/v1/calendar/google/auth-url
```

**Open the `authUrl` in browser** → Authorize → Tokens saved automatically!

**Check Status:**
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  https://api.medical-appointments.com/api/v1/calendar/status
```

---

## 📁 Files Created/Updated

### New Files:
- ✅ `backend/src/services/calendar.service.ts`
- ✅ `backend/src/database/migrations/003_calendar_tokens.ts`
- ✅ `CALENDAR_SETUP_GUIDE.md` (complete guide)
- ✅ `CALENDAR_SETUP_SUMMARY.md` (this file)

### Updated Files:
- ✅ `backend/src/routes/calendar.routes.ts` (full OAuth implementation)

---

## 🎯 Next Steps Summary

1. ⏳ **Set up Google OAuth** (get Client ID & Secret)
2. ⏳ **Set up Outlook OAuth** (get Client ID & Secret)
3. ⏳ **Update `.env` file** on server with credentials
4. ⏳ **Run database migration** (`npx knex migrate:latest`)
5. ⏳ **Restart backend** (`pm2 restart medical-api`)
6. ⏳ **Test connection** (use API endpoints)

---

## 📚 Documentation

- **Complete Guide:** `CALENDAR_SETUP_GUIDE.md`
- **Quick Reference:** See guide for API endpoints and environment variables

---

**Status:** ✅ Backend code ready, waiting for OAuth credentials setup

