# 🔵 Manual Google Calendar Setup Guide

## ✅ Step 1: Enable Google Calendar API

1. **Open your browser** (where you're signed in)
2. **Go to:** https://console.cloud.google.com/apis/library/calendar-json.googleapis.com
3. **Click the blue "Enable" button**
4. **Wait** for it to enable (takes a few seconds)

✅ **Done!** Calendar API is now enabled.

---

## ✅ Step 2: Configure OAuth Consent Screen

1. **Go to:** https://console.cloud.google.com/apis/credentials/consent
   - Or: Left sidebar → "APIs & services" → "OAuth consent screen"

2. **User Type:**
   - Select: **"External"**
   - Click **"Create"**

3. **App Information:**
   - App name: `Medical Appointments System`
   - User support email: Select `hn.medicalapoointments@gmail.com`
   - Developer contact: `hn.medicalapoointments@gmail.com`
   - Click **"Save and Continue"**

4. **Scopes:**
   - Click **"Add or Remove Scopes"**
   - Search: `calendar`
   - Check: ✅ `https://www.googleapis.com/auth/calendar`
   - Click **"Update"**
   - Click **"Save and Continue"**

5. **Test Users:**
   - Click **"Add Users"**
   - Add: `hn.medicalapoointments@gmail.com`
   - Click **"Add"**
   - Click **"Save and Continue"**

6. **Summary:**
   - Review everything
   - Click **"Back to Dashboard"**

✅ **OAuth Consent Screen configured!**

---

## ✅ Step 3: Create OAuth Credentials

1. **Go to:** https://console.cloud.google.com/apis/credentials
   - Or: Left sidebar → "APIs & services" → "Credentials"

2. **Create Credentials:**
   - Click **"+ Create Credentials"** (top)
   - Select **"OAuth client ID"**

3. **Configure:**
   - **Application type:** Select **"Web application"**
   - **Name:** `Medical Appointments Calendar`

4. **Authorized JavaScript origins:**
   - Click **"+ Add URI"**
   - Add: `https://api.medical-appointments.com`
   - Click **"+ Add URI"** again
   - Add: `http://localhost:3000`

5. **Authorized redirect URIs:**
   - Click **"+ Add URI"**
   - Add: `https://api.medical-appointments.com/api/v1/calendar/google/callback`
   - Click **"+ Add URI"** again
   - Add: `http://localhost:3000/api/v1/calendar/google/callback`

6. **Click "Create"**

7. **Copy Credentials:**
   - **Client ID:** Copy this (starts with something like `123456789-abc...`)
   - **Client Secret:** Copy this NOW (you won't see it again!)

8. **Click "OK"**

---

## ✅ Step 4: Save Credentials

**Run this script to save credentials automatically:**

```powershell
cd C:\Projects\medical-app\backend
.\scripts\save-google-credentials.ps1
```

**Or manually update:**

1. **Development config:** `backend/config/development.config.json`
2. **Production config:** `backend/config/production.config.json`
3. **Server .env:** Update `.env.production` on your VPS

---

## 📋 Quick Checklist

- [ ] Calendar API enabled
- [ ] OAuth consent screen configured
- [ ] OAuth credentials created
- [ ] Client ID copied
- [ ] Client Secret copied
- [ ] Credentials saved to config files
- [ ] Server .env updated

---

## 🎯 Next Steps

After saving credentials:
1. Update server `.env` file
2. Run database migration: `npm run migrate`
3. Restart backend: `pm2 restart medical-api`
4. Test calendar connection

---

**Need help?** Let me know which step you're on!

