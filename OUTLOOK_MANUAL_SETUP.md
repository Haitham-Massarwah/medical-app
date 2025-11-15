# 🔷 Outlook Calendar - Manual Setup Guide

## ✅ You're Signed In!

Now follow these steps to create the App Registration:

---

## 📋 Step 1: Go to App Registrations

**In Azure Portal:**

### Option A: Direct Link (Easiest)
**Copy and paste this URL in your browser:**
```
https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps/ApplicationsListBlade
```

### Option B: Search
1. **Top search bar** → Type: `Azure Active Directory` or `Microsoft Entra ID`
2. Click on the result
3. **Left sidebar** → Click **"App registrations"**

---

## 📋 Step 2: Create New Registration

1. **Click "+ New registration"** (top left, blue button)

2. **Fill the Registration form:**

   **Name:**
   ```
   Medical Appointments Calendar
   ```

   **Supported account types:**
   - Select: **"Accounts in any organizational directory and personal Microsoft accounts"**
   - (This allows both work and personal Outlook accounts)

   **Redirect URI:**
   - Platform: Select **"Web"** from dropdown
   - URI: `http://localhost:3000/api/v1/calendar/outlook/callback`
   - Click **"Add"**
   - Add another URI: `https://api.medical-appointments.com/api/v1/calendar/outlook/callback`
   - Click **"Add"**

3. **Click "Register"** (bottom)

---

## 📋 Step 3: Copy Application (Client) ID

**After clicking Register, you'll see the Overview page:**

1. **Find "Application (client) ID"**
   - It's a long string like: `12345678-1234-1234-1234-123456789abc`
2. **Click the copy icon** next to it
3. **Save it** - you'll need it!

---

## 📋 Step 4: Add API Permissions

1. **Left sidebar** → Click **"API permissions"**

2. **Click "+ Add a permission"**

3. **Select "Microsoft Graph"**

4. **Select "Delegated permissions"** (not Application permissions)

5. **In the search box**, type: `calendar`

6. **Check these permissions:**
   - ✅ `Calendars.ReadWrite` - Read and write calendars
   - ✅ `offline_access` - Maintain access to data (for refresh tokens)

7. **Click "Add permissions"** (bottom)

8. **Click "Grant admin consent"** (if you're an admin)
   - If you see this button, click it to grant consent
   - If not, users will consent individually

---

## 📋 Step 5: Create Client Secret

1. **Left sidebar** → Click **"Certificates & secrets"**

2. **Click "+ New client secret"**

3. **Fill the form:**
   - **Description:** `Medical Appointments Calendar Secret`
   - **Expires:** Select **24 months** (or your preference)

4. **Click "Add"**

5. **⚠️ IMPORTANT:** Copy the **Value** immediately!
   - Look for a row with your secret
   - The **Value** column shows the secret (like `abc123~XYZ...`)
   - **Copy it NOW** - you won't see it again!
   - The Secret ID is not what you need - you need the **Value**

---

## 📋 Step 6: Save Credentials

**After you have both:**

- ✅ **Client ID** (Application ID)
- ✅ **Client Secret** (Value)

**Run this script:**

```powershell
cd C:\Projects\medical-app\backend
.\scripts\save-outlook-credentials.ps1
```

**Enter:**
- Client ID (Application ID)
- Client Secret (Value)

**The script will automatically save to all config files!**

---

## ✅ Quick Checklist:

- [ ] Signed in to Azure Portal
- [ ] Navigated to App Registrations
- [ ] Created new registration
- [ ] Added redirect URIs (localhost + production)
- [ ] Copied Application (Client) ID
- [ ] Added API permissions (Calendars.ReadWrite, offline_access)
- [ ] Created Client Secret
- [ ] Copied Client Secret Value
- [ ] Run save-outlook-credentials.ps1
- [ ] Restart server
- [ ] Test connection

---

## 🔗 Direct Links:

- **App Registrations:** https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps/ApplicationsListBlade
- **Azure Portal:** https://portal.azure.com

---

**Follow the steps above. Let me know when you have the credentials!**

