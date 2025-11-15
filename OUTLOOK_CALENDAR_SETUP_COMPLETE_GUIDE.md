# 📅 Outlook Calendar Integration - Complete Step-by-Step Guide

## 🎯 Overview

This guide will walk you through setting up Outlook Calendar OAuth integration for your Medical Appointments application.

**Time Required:** 15-20 minutes  
**Prerequisites:** Azure account, access to Azure Portal

---

## 📋 Step 1: Create App Registration in Azure Portal

### 1.1 Navigate to Azure Portal

1. Go to: **https://portal.azure.com**
2. Sign in with your Microsoft account
3. In the search bar at the top, type: **"Azure Active Directory"** or **"Microsoft Entra ID"**
4. Click on **"Microsoft Entra ID"** from the results

### 1.2 Create App Registration

1. In the left sidebar, click **"App registrations"**
2. Click **"+ New registration"** button (top left)
3. Fill in the form:
   - **Name:** `Medical Appointments Calendar`
   - **Supported account types:** Select **"Accounts in any organizational directory and personal Microsoft accounts"**
   - **Redirect URI:** Leave empty for now (we'll add it later)
4. Click **"Register"** button

### 1.3 Save Your Client ID

1. After registration, you'll see the **"Overview"** page
2. **Copy and save** the **"Application (client) ID"**
   - It looks like: `32ca22ee-219b-4000-b429-17e9b56aedda`
   - **You'll need this later!**

---

## 📋 Step 2: Configure Redirect URIs

### 2.1 Navigate to Authentication

1. In the left sidebar, click **"Authentication"** (under "Manage" section)
   - OR click **"Redirect URIs"** link in the Essentials section

### 2.2 Add Development Redirect URI

1. Under **"Web"** platform section, click **"+ Add URI"**
2. Enter: `http://localhost:3000/api/v1/calendar/outlook/callback`
3. Click **"Add"**

### 2.3 Add Production Redirect URI

1. Click **"+ Add URI"** again
2. Enter: `https://api.medical-appointments.com/api/v1/calendar/outlook/callback`
3. Click **"Add"**

### 2.4 Save Changes

1. Click **"Save"** button at the top of the page
2. You should now see **2 web redirect URIs** configured

---

## 📋 Step 3: Add API Permissions

### 3.1 Navigate to API Permissions

1. In the left sidebar, click **"API permissions"** (under "Manage" section)

### 3.2 Add Microsoft Graph Permissions

1. Click **"+ Add a permission"** button (top of page)
2. Select **"Microsoft Graph"** (first option, blue hexagonal icon)
3. Choose **"Delegated permissions"** tab (should be selected by default)

### 3.3 Select Required Permissions

**Search and select these 3 permissions:**

1. **Calendars.ReadWrite**
   - In search box, type: `Calendars.ReadWrite`
   - Check the box next to **"Calendars.ReadWrite"**
   - Description: "Have full access to user calendars"

2. **User.Read**
   - Clear search box, type: `User.Read`
   - Check the box next to **"User.Read"**
   - Description: "Sign in and read user profile"

3. **offline_access**
   - Clear search box, type: `offline_access`
   - Check the box next to **"offline_access"**
   - Description: "Maintain access to data you have given it access to"

### 3.4 Add Permissions

1. Scroll down to bottom of dialog
2. Click **"Add permissions"** button (blue button)
3. Dialog will close and return to API permissions page

### 3.5 Verify Permissions Added

You should see:
- ✅ **Microsoft Graph (3)** with 3 permissions listed:
  - Calendars.ReadWrite
  - User.Read
  - offline_access

---

## 📋 Step 4: Grant Admin Consent

### 4.1 Grant Consent

1. On the **"API permissions"** page, find the button:
   - **"Grant admin consent for Default Directory"**
   - It has a green checkmark icon
2. **Click this button**

### 4.2 Confirm Consent

1. A confirmation dialog will appear
2. Read the warning message
3. Click **"Yes"** or **"Accept"** to confirm

### 4.3 Verify Success

**After granting consent, you should see:**

- ✅ Blue banner: **"Successfully granted admin consent for the requested permissions."**
- ✅ Green checkmarks next to each permission
- ✅ Status column shows: **"Granted for Default Directory"** for all 3 permissions

**⚠️ IMPORTANT:** Without admin consent, the app will NOT work!

---

## 📋 Step 5: Create Client Secret

### 5.1 Navigate to Certificates & Secrets

1. In the left sidebar, click **"Certificates & secrets"** (under "Manage" section)

### 5.2 Create New Client Secret

1. Find the **"Client secrets"** section
2. Click **"+ New client secret"** button

### 5.3 Configure Secret

1. Fill in the form:
   - **Description:** `Medical Appointments Calendar Secret` (or any name you prefer)
   - **Expires:** Select **"24 months"** (recommended, longest option)
2. Click **"Add"** button

### 5.4 Copy Secret Value (CRITICAL!)

**⚠️ CRITICAL: You can ONLY see the secret value ONCE!**

1. After clicking "Add", a new row appears in the table
2. Find the **"Value"** column - it shows the secret
3. **Click the "Copy" icon** (clipboard icon) next to the value
   - OR click on the value itself to copy it
4. **Save it immediately!** You won't be able to see it again
5. The secret looks like: `dVi8Q~1g0CgWlcWznXFXXqDxwU7k2xHyVZeh.afX`

**📝 Note:** Also save the **Secret ID** and **Expires** date for reference

---

## 📋 Step 6: Save Credentials to Config Files

### 6.1 Update Development Config

**File:** `backend/config/development.config.json`

Update the `outlook` section:
```json
"outlook": {
  "clientId": "32ca22ee-219b-4000-b429-17e9b56aedda",
  "clientSecret": "dVi8Q~1g0CgWlcWznXFXXqDxwU7k2xHyVZeh.afX",
  "redirectUri": "http://localhost:3000/api/v1/calendar/outlook/callback"
}
```

### 6.2 Update Production Config

**File:** `backend/config/production.config.json`

Update the `outlook` section:
```json
"outlook": {
  "clientId": "32ca22ee-219b-4000-b429-17e9b56aedda",
  "clientSecret": "dVi8Q~1g0CgWlcWznXFXXqDxwU7k2xHyVZeh.afX",
  "redirectUri": "https://api.medical-appointments.com/api/v1/calendar/outlook/callback"
}
```

### 6.3 Update Server .env File (Production)

**On your VPS server:** `/var/www/medical-backend/.env.production`

Add these lines:
```env
OUTLOOK_CLIENT_ID=32ca22ee-219b-4000-b429-17e9b56aedda
OUTLOOK_CLIENT_SECRET=dVi8Q~1g0CgWlcWznXFXXqDxwU7k2xHyVZeh.afX
OUTLOOK_REDIRECT_URI=https://api.medical-appointments.com/api/v1/calendar/outlook/callback
```

---

## 📋 Step 7: Restart Server

### 7.1 Development Server

**If your development server is running:**

**Option A:** Press `rs` in the nodemon terminal

**Option B:** Stop and restart:
```bash
cd C:\Projects\medical-app\backend
.\START_SIMPLE.bat
```

### 7.2 Production Server

**On your VPS server:**

```bash
cd /var/www/medical-backend
pm2 restart medical-api
```

---

## 📋 Step 8: Test the Integration

### 8.1 Test Authorization URL Endpoint

**Request:**
```http
GET http://localhost:3000/api/v1/calendar/outlook/auth-url
Authorization: Bearer YOUR_ACCESS_TOKEN
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "authUrl": "https://login.microsoftonline.com/common/oauth2/v2.0/authorize?..."
  }
}
```

### 8.2 Test Connection Status

**Request:**
```http
GET http://localhost:3000/api/v1/calendar/status
Authorization: Bearer YOUR_ACCESS_TOKEN
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "google": false,
    "outlook": false
  }
}
```

### 8.3 Complete OAuth Flow

1. **Get authorization URL** (Step 8.1)
2. **Open the URL in browser**
3. **Sign in with Microsoft account**
4. **Grant permissions**
5. **You'll be redirected to callback URL**
6. **Check status** (Step 8.2) - should show `"outlook": true`

---

## ✅ Verification Checklist

- [ ] App registration created in Azure Portal
- [ ] Client ID saved: `32ca22ee-219b-4000-b429-17e9b56aedda`
- [ ] Development redirect URI added: `http://localhost:3000/api/v1/calendar/outlook/callback`
- [ ] Production redirect URI added: `https://api.medical-appointments.com/api/v1/calendar/outlook/callback`
- [ ] API permissions added: Calendars.ReadWrite, User.Read, offline_access
- [ ] Admin consent granted (all permissions show "Granted for Default Directory")
- [ ] Client secret created and copied
- [ ] Credentials saved to `development.config.json`
- [ ] Credentials saved to `production.config.json`
- [ ] Server .env file updated (production)
- [ ] Server restarted
- [ ] Test endpoints working

---

## 🎉 Setup Complete!

**Outlook Calendar integration is now fully configured and ready to use!**

---

## 📚 Additional Resources

- **Azure Portal:** https://portal.azure.com
- **Microsoft Graph API Docs:** https://docs.microsoft.com/en-us/graph/overview
- **OAuth 2.0 Flow:** https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-auth-code-flow

---

## 🆘 Troubleshooting

### Issue: "Admin consent required"

**Solution:** Make sure you clicked "Grant admin consent for Default Directory" button

### Issue: "Invalid redirect URI"

**Solution:** Verify redirect URIs match exactly in Azure Portal and config files

### Issue: "Invalid client secret"

**Solution:** 
- Check if secret was copied correctly
- If lost, create a new client secret in Azure Portal
- Update config files with new secret

### Issue: "Permissions not granted"

**Solution:**
- Verify all 3 permissions are added
- Check admin consent was granted
- Look for green checkmarks in Status column

---

## 📝 Summary

**What was configured:**
- ✅ Azure App Registration
- ✅ OAuth Redirect URIs (dev + prod)
- ✅ Microsoft Graph API Permissions
- ✅ Admin Consent
- ✅ Client Secret
- ✅ Configuration Files Updated

**Ready to use:** Outlook Calendar integration is fully functional! 🎉

