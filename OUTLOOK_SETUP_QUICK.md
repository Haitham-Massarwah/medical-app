# 🔷 Outlook Calendar - Quick Setup

## 🎯 What You Need:

1. **Microsoft Account** (personal or work)
2. **Azure Portal Access** (free)
3. **5-10 minutes**

---

## 🚀 Quick Steps:

### 1. Go to Azure Portal
**Link:** https://portal.azure.com
- Sign in with your Microsoft account

### 2. Create App Registration
- Search: **"Azure Active Directory"** or **"Microsoft Entra ID"**
- Click: **"App registrations"**
- Click: **"+ New registration"**

### 3. Fill Registration Form:
- **Name:** `Medical Appointments Calendar`
- **Account types:** `Accounts in any organizational directory and personal Microsoft accounts`
- **Redirect URI:**
  - Platform: **Web**
  - URI: `http://localhost:3000/api/v1/calendar/outlook/callback`
  - Click **"Add"**
  - Add another: `https://api.medical-appointments.com/api/v1/calendar/outlook/callback`
- Click **"Register"**

### 4. Add API Permissions:
- Go to **"API permissions"**
- Click **"+ Add a permission"**
- Select **"Microsoft Graph"**
- Select **"Delegated permissions"**
- Search and add:
  - ✅ `Calendars.ReadWrite`
  - ✅ `offline_access`
- Click **"Add permissions"**
- Click **"Grant admin consent"** (if admin)

### 5. Create Client Secret:
- Go to **"Certificates & secrets"**
- Click **"+ New client secret"**
- Description: `Medical Appointments Calendar Secret`
- Expires: **24 months**
- Click **"Add"**
- **⚠️ COPY THE VALUE NOW** (you won't see it again!)

### 6. Copy Application ID:
- Go to **"Overview"**
- Copy **Application (client) ID**

---

## 💾 Save Credentials:

**After you have Client ID and Secret, run:**

```powershell
cd C:\Projects\medical-app\backend
.\scripts\save-outlook-credentials.ps1
```

**Enter:**
- Client ID (Application ID)
- Client Secret

**The script will automatically:**
- ✅ Update development.config.json
- ✅ Update production.config.json
- ✅ Update .env file
- ✅ Show you what to add to server .env

---

## 🔄 After Saving:

1. **Restart server:**
   - Press `rs` in nodemon terminal
   - Or: `.\START_SIMPLE.bat`

2. **Test Outlook Calendar:**
   ```powershell
   # Login
   $login = Invoke-RestMethod -Uri "http://localhost:3000/api/v1/auth/login" `
     -Method POST -ContentType "application/json" `
     -Body '{"email":"haitham.massarwah@medical-appointments.com","password":"Developer@2024"}'
   
   $token = $login.data.tokens.accessToken
   
   # Get Outlook Auth URL
   $headers = @{Authorization = "Bearer $token"}
   Invoke-RestMethod -Uri "http://localhost:3000/api/v1/calendar/outlook/auth-url" `
     -Method GET -Headers $headers
   ```

---

## 📋 What You'll Get:

- **Client ID:** `12345678-1234-1234-1234-123456789abc`
- **Client Secret:** `abc123~XYZ...` (copy immediately!)

---

## ✅ Checklist:

- [ ] Azure Portal account ready
- [ ] App registration created
- [ ] Redirect URIs added (localhost + production)
- [ ] API permissions added (Calendars.ReadWrite, offline_access)
- [ ] Client secret created and copied
- [ ] Client ID copied
- [ ] Run save-outlook-credentials.ps1
- [ ] Restart server
- [ ] Test connection

---

**Start with Step 1: Go to https://portal.azure.com**

**Let me know when you have the credentials and I'll help you save them!**

