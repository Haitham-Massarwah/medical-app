# 🔷 Outlook Calendar Setup Guide

## 🎯 Overview:
Set up Microsoft Outlook Calendar OAuth integration for your medical appointments system.

---

## 📋 Step-by-Step Setup:

### Step 1: Go to Azure Portal

1. **Open:** https://portal.azure.com
2. **Sign in** with your Microsoft account
3. **Search** for "Azure Active Directory" or "Microsoft Entra ID"

---

### Step 2: Register an Application

1. **In Azure Portal**, go to:
   - **Azure Active Directory** → **App registrations**
   - Click **"+ New registration"**

2. **Fill the form:**
   - **Name:** `Medical Appointments Calendar`
   - **Supported account types:** Select **"Accounts in any organizational directory and personal Microsoft accounts"**
   - **Redirect URI:**
     - Platform: **Web**
     - URI: `http://localhost:3000/api/v1/calendar/outlook/callback`
     - Click **"Add"**
     - Add another: `https://api.medical-appointments.com/api/v1/calendar/outlook/callback`
   - Click **"Register"**

---

### Step 3: Configure API Permissions

1. **In your app registration**, go to **"API permissions"**
2. Click **"+ Add a permission"**
3. Select **"Microsoft Graph"**
4. Select **"Delegated permissions"**
5. **Search and add:**
   - `Calendars.ReadWrite` ✅
   - `offline_access` ✅ (for refresh tokens)
6. Click **"Add permissions"**
7. Click **"Grant admin consent"** (if you're an admin)

---

### Step 4: Create Client Secret

1. **In your app registration**, go to **"Certificates & secrets"**
2. Click **"+ New client secret"**
3. **Description:** `Medical Appointments Calendar Secret`
4. **Expires:** Choose expiration (24 months recommended)
5. Click **"Add"**
6. **⚠️ IMPORTANT:** Copy the **Value** immediately (you won't see it again!)
   - It looks like: `abc123~XYZ...`

---

### Step 5: Copy Application (Client) ID

1. **In your app registration**, go to **"Overview"**
2. Copy the **Application (client) ID**
   - It looks like: `12345678-1234-1234-1234-123456789abc`

---

### Step 6: Save Credentials

**Run this script after you have the credentials:**

```powershell
cd C:\Projects\medical-app\backend
.\scripts\save-outlook-credentials.ps1
```

**Or manually update:**

1. **Development config:** `backend/config/development.config.json`
2. **Production config:** `backend/config/production.config.json`
3. **Server .env:** Update `.env.production` on your VPS

---

## 📋 Credentials Needed:

- **Client ID (Application ID):** `_________________`
- **Client Secret:** `_________________`
- **Redirect URIs:**
  - Development: `http://localhost:3000/api/v1/calendar/outlook/callback`
  - Production: `https://api.medical-appointments.com/api/v1/calendar/outlook/callback`

---

## ✅ Quick Checklist:

- [ ] Azure Portal account ready
- [ ] App registration created
- [ ] Redirect URIs configured
- [ ] API permissions added (Calendars.ReadWrite, offline_access)
- [ ] Client secret created
- [ ] Client ID copied
- [ ] Client Secret copied
- [ ] Credentials saved to config files
- [ ] .env file updated
- [ ] Server restarted

---

## 🔗 Quick Links:

- **Azure Portal:** https://portal.azure.com
- **App Registrations:** https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps/ApplicationsListBlade
- **Microsoft Graph Permissions:** https://learn.microsoft.com/en-us/graph/permissions-reference

---

## 🎯 After Setup:

1. Update `.env` file with Outlook credentials
2. Restart server
3. Test Outlook Calendar connection
4. Test calendar sync

---

**Let me know when you have the Client ID and Secret, and I'll help you save them!**

