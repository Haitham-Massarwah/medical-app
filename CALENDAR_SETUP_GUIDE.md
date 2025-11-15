# 📅 Calendar Integration Setup Guide

## 🎯 Overview

This guide will help you set up Google Calendar and Outlook Calendar integration for the Medical Appointments System.

---

## 📋 Prerequisites

- ✅ Backend running on server
- ✅ Domain configured: `api.medical-appointments.com`
- ✅ HTTPS enabled (required for OAuth)

---

## 🔵 Part 1: Google Calendar Setup

### Step 1: Create Google Cloud Project

1. **Go to Google Cloud Console:**
   - Visit: https://console.cloud.google.com/
   - Sign in with: `hn.medicalapoointments@gmail.com`

2. **Create New Project:**
   - Click "Select a project" → "New Project"
   - Project Name: `Medical Appointments System`
   - Click "Create"

### Step 2: Enable Google Calendar API

1. **Navigate to APIs & Services:**
   - Go to: https://console.cloud.google.com/apis/library
   - Search for: "Google Calendar API"
   - Click on "Google Calendar API"
   - Click "Enable"

### Step 3: Create OAuth 2.0 Credentials

1. **Go to Credentials:**
   - Navigate to: https://console.cloud.google.com/apis/credentials
   - Click "Create Credentials" → "OAuth client ID"

2. **Configure OAuth Consent Screen:**
   - User Type: External
   - App Name: `Medical Appointments System`
   - User support email: `hn.medicalapoointments@gmail.com`
   - Developer contact: `hn.medicalapoointments@gmail.com`
   - Click "Save and Continue"
   - Scopes: Add `https://www.googleapis.com/auth/calendar`
   - Click "Save and Continue"
   - Test users: Add `hn.medicalapoointments@gmail.com`
   - Click "Save and Continue"

3. **Create OAuth Client:**
   - Application type: Web application
   - Name: `Medical Appointments Calendar`
   - Authorized redirect URIs:
     ```
     https://api.medical-appointments.com/api/v1/calendar/google/callback
     http://localhost:3000/api/v1/calendar/google/callback
     ```
   - Click "Create"

4. **Copy Credentials:**
   - Copy the **Client ID**
   - Copy the **Client Secret**
   - Save these for Step 4

### Step 4: Configure Backend

**Update `.env` file on server:**
```bash
ssh root@66.29.133.192
cd /var/www/medical-backend
nano .env
```

**Add/Update:**
```env
GOOGLE_CLIENT_ID=your_google_client_id_here
GOOGLE_CLIENT_SECRET=your_google_client_secret_here
GOOGLE_REDIRECT_URI=https://api.medical-appointments.com/api/v1/calendar/google/callback
```

**Update `backend/config/production.config.json`:**
```json
"calendar": {
  "google": {
    "clientId": "your_google_client_id_here",
    "clientSecret": "your_google_client_secret_here",
    "redirectUri": "https://api.medical-appointments.com/api/v1/calendar/google/callback"
  }
}
```

**Restart backend:**
```bash
pm2 restart medical-api
```

---

## 🔷 Part 2: Outlook Calendar Setup

### Step 1: Register App in Azure Portal

1. **Go to Azure Portal:**
   - Visit: https://portal.azure.com/
   - Sign in with Microsoft account

2. **Navigate to App Registrations:**
   - Search for "App registrations"
   - Click "New registration"

3. **Register Application:**
   - Name: `Medical Appointments Calendar`
   - Supported account types: "Accounts in any organizational directory and personal Microsoft accounts"
   - Redirect URI:
     - Platform: Web
     - URI: `https://api.medical-appointments.com/api/v1/calendar/outlook/callback`
   - Click "Register"

### Step 2: Configure API Permissions

1. **Add Permissions:**
   - Go to "API permissions"
   - Click "Add a permission"
   - Select "Microsoft Graph"
   - Select "Delegated permissions"
   - Search and add:
     - `Calendars.ReadWrite`
     - `offline_access`
   - Click "Add permissions"

2. **Grant Admin Consent (if needed):**
   - Click "Grant admin consent for [Your Organization]"
   - Confirm

### Step 3: Create Client Secret

1. **Go to Certificates & secrets:**
   - Click "New client secret"
   - Description: `Calendar Integration Secret`
   - Expires: 24 months (or your preference)
   - Click "Add"

2. **Copy Credentials:**
   - Copy the **Application (client) ID** (this is your Client ID)
   - Copy the **Client secret value** (save immediately, it won't show again)
   - Save these for Step 4

### Step 4: Configure Backend

**Update `.env` file on server:**
```bash
ssh root@66.29.133.192
cd /var/www/medical-backend
nano .env
```

**Add/Update:**
```env
OUTLOOK_CLIENT_ID=your_outlook_client_id_here
OUTLOOK_CLIENT_SECRET=your_outlook_client_secret_here
OUTLOOK_REDIRECT_URI=https://api.medical-appointments.com/api/v1/calendar/outlook/callback
```

**Update `backend/config/production.config.json`:**
```json
"calendar": {
  "outlook": {
    "clientId": "your_outlook_client_id_here",
    "clientSecret": "your_outlook_client_secret_here",
    "redirectUri": "https://api.medical-appointments.com/api/v1/calendar/outlook/callback"
  }
}
```

**Restart backend:**
```bash
pm2 restart medical-api
```

---

## 🗄️ Step 5: Create Database Table

**Create migration for calendar tokens:**

```bash
cd /var/www/medical-backend
npx knex migrate:make create_calendar_tokens_table
```

**Edit the migration file** (`src/database/migrations/XXX_create_calendar_tokens_table.ts`):

```typescript
import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('calendar_tokens', (table) => {
    table.increments('id').primary();
    table.integer('user_id').unsigned().notNullable();
    table.enu('provider', ['google', 'outlook']).notNullable();
    table.text('access_token').notNullable();
    table.text('refresh_token').nullable();
    table.timestamp('expires_at').nullable();
    table.timestamps(true, true);

    table.foreign('user_id').references('id').inTable('users').onDelete('CASCADE');
    table.unique(['user_id', 'provider']);
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('calendar_tokens');
}
```

**Run migration:**
```bash
NODE_ENV=production npx knex migrate:latest
```

---

## 🔧 Step 6: Install Required Dependencies

**On server, install axios (if not already installed):**
```bash
cd /var/www/medical-backend
npm install axios
```

**Or locally:**
```powershell
cd C:\Projects\medical-app\backend
npm install axios
```

---

## 🗄️ Step 7: Create Database Migration

**Create migration file** (already created: `003_calendar_tokens.ts`)

**Run migration on server:**
```bash
cd /var/www/medical-backend
NODE_ENV=production npx knex migrate:latest
```

**Or locally (development):**
```powershell
cd C:\Projects\medical-app\backend
npm run migrate
```

---

## ✅ Step 8: Test Calendar Integration

### Test Google Calendar Connection:

1. **Login to your app** (as developer or any user)
2. **Get auth token** from login response
3. **Get Google auth URL:**
   ```bash
   curl -H "Authorization: Bearer YOUR_TOKEN" \
     https://api.medical-appointments.com/api/v1/calendar/google/auth-url
   ```
4. **Open the authUrl** in browser
5. **Authorize** Google Calendar access
6. **Callback** will save tokens automatically

### Test Outlook Calendar Connection:

Same process, but use:
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  https://api.medical-appointments.com/api/v1/calendar/outlook/auth-url
```

### Check Connection Status:

```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  https://api.medical-appointments.com/api/v1/calendar/status
```

---

## 📋 Summary

✅ **Created Files:**
- `backend/src/services/calendar.service.ts` - Calendar OAuth service
- `backend/src/database/migrations/003_calendar_tokens.ts` - Database migration
- `backend/src/routes/calendar.routes.ts` - Updated with full OAuth flow

✅ **Next Steps:**
1. Set up Google OAuth credentials (Step 1-3)
2. Set up Outlook OAuth credentials (Step 1-3)
3. Update `.env` file with credentials
4. Run database migration
5. Restart backend
6. Test connection

---

## 🎯 Quick Reference

**API Endpoints:**
- `GET /api/v1/calendar/google/auth-url` - Get Google auth URL
- `GET /api/v1/calendar/outlook/auth-url` - Get Outlook auth URL
- `GET /api/v1/calendar/google/callback` - Google OAuth callback (public)
- `GET /api/v1/calendar/outlook/callback` - Outlook OAuth callback (public)
- `GET /api/v1/calendar/status` - Check connection status
- `POST /api/v1/calendar/disconnect` - Disconnect calendar

**Environment Variables Needed:**
```env
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
GOOGLE_REDIRECT_URI=https://api.medical-appointments.com/api/v1/calendar/google/callback

OUTLOOK_CLIENT_ID=your_outlook_client_id
OUTLOOK_CLIENT_SECRET=your_outlook_client_secret
OUTLOOK_REDIRECT_URI=https://api.medical-appointments.com/api/v1/calendar/outlook/callback
```

