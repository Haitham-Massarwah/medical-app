# 🔷 Outlook Calendar Setup - Step by Step

## 🎯 Current Status:
Browser opened to Azure Portal sign-in page

---

## 📋 Step 1: Sign In to Azure Portal

1. **In the browser window**, enter your Microsoft email
   - Use: `hn.medicalapoointments@gmail.com` (or your Microsoft account)
2. **Click "Next"**
3. **Enter your password**
4. **Complete sign-in**

---

## 📋 Step 2: Navigate to App Registrations

**After signing in:**

### Option A: Direct Link (Easiest)
**Click this link:** https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps/ApplicationsListBlade

### Option B: Manual Navigation
1. **Search bar** (top): Type `Azure Active Directory` or `Microsoft Entra ID`
2. Click on **"Microsoft Entra ID"** or **"Azure Active Directory"**
3. **Left sidebar** → Click **"App registrations"**

---

## 📋 Step 3: Create New App Registration

1. **Click "+ New registration"** (top left)

2. **Fill the form:**

   **Name:**
   - Enter: `Medical Appointments Calendar`

   **Supported account types:**
   - Select: **"Accounts in any organizational directory and personal Microsoft accounts"**
   - (This allows both work and personal accounts)

   **Redirect URI:**
   - Platform: Select **"Web"**
   - URI: `http://localhost:3000/api/v1/calendar/outlook/callback`
   - Click **"Add"**
   - Add another URI: `https://api.medical-appointments.com/api/v1/calendar/outlook/callback`
   - Click **"Add"**

3. **Click "Register"** (bottom)

---

## 📋 Step 4: Copy Application (Client) ID

**After registration:**

1. **On the Overview page**, you'll see:
   - **Application (client) ID** ← Copy this!
   - It looks like: `12345678-1234-1234-1234-123456789abc`

2. **Save it somewhere** - you'll need it!

---

## 📋 Step 5: Configure API Permissions

1. **Left sidebar** → Click **"API permissions"**

2. **Click "+ Add a permission"**

3. **Select "Microsoft Graph"**

4. **Select "Delegated permissions"**

5. **Search and check:**
   - ✅ `Calendars.ReadWrite` - Read and write calendars
   - ✅ `offline_access` - Maintain access to data (for refresh tokens)

6. **Click "Add permissions"**

7. **Click "Grant admin consent"** (if you're an admin)
   - If not admin, users will consent individually

---

## 📋 Step 6: Create Client Secret

1. **Left sidebar** → Click **"Certificates & secrets"**

2. **Click "+ New client secret"**

3. **Fill the form:**
   - **Description:** `Medical Appointments Calendar Secret`
   - **Expires:** Select **24 months** (or your preference)

4. **Click "Add"**

5. **⚠️ IMPORTANT:** Copy the **Value** immediately!
   - It looks like: `abc123~XYZ...`
   - **You won't see it again!**
   - Copy both **Secret ID** and **Value**

---

## 📋 Step 7: Save Credentials

**After you have both Client ID and Secret:**

**Run this script:**
```powershell
cd C:\Projects\medical-app\backend
.\scripts\save-outlook-credentials.ps1
```

**Enter:**
- Client ID (Application ID)
- Client Secret (Value)

**The script will automatically:**
- ✅ Update development.config.json
- ✅ Update production.config.json
- ✅ Update .env file
- ✅ Show server .env instructions

---

## ✅ Quick Checklist:

- [ ] Signed in to Azure Portal
- [ ] Created App Registration
- [ ] Added redirect URIs (localhost + production)
- [ ] Added API permissions (Calendars.ReadWrite, offline_access)
- [ ] Created Client Secret
- [ ] Copied Client ID
- [ ] Copied Client Secret Value
- [ ] Run save-outlook-credentials.ps1
- [ ] Restart server
- [ ] Test connection

---

## 🔗 Quick Links:

- **Azure Portal:** https://portal.azure.com
- **App Registrations:** https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps/ApplicationsListBlade
- **Microsoft Graph Permissions:** https://learn.microsoft.com/en-us/graph/permissions-reference

---

## 📝 What You'll Need:

- **Client ID (Application ID):** `_________________`
- **Client Secret Value:** `_________________`

---

**Sign in to Azure Portal and follow the steps above!**

**Let me know when you have the credentials and I'll help you save them!**

