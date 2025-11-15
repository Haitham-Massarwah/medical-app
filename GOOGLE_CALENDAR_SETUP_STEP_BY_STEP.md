# 🔵 Google Calendar Setup - Step by Step

## 📋 Current Status
You're in Google Cloud Console → "My First Project" dashboard

---

## 🎯 Step 1: Enable Google Calendar API

### From the Dashboard:

1. **In the left sidebar**, find **"APIs and services"** (it has an arrow →)
   - Click on **"APIs and services"**

2. **You'll see a page with tabs:**
   - Click on **"Library"** tab (or "Enable APIs and services")

3. **Search for Calendar API:**
   - In the search box, type: `Google Calendar API`
   - Click on **"Google Calendar API"** from results

4. **Enable the API:**
   - Click the blue **"Enable"** button
   - Wait for it to enable (may take a few seconds)

✅ **Done!** Google Calendar API is now enabled.

---

## 🎯 Step 2: Configure OAuth Consent Screen

### Go back to APIs & Services:

1. **In the left sidebar**, click **"APIs and services"** again
2. Click on **"OAuth consent screen"** (in the left menu)

### Configure Consent Screen:

**Step 2.1: User Type**
- Select: **"External"** (for users outside your organization)
- Click **"Create"**

**Step 2.2: App Information**
- App name: `Medical Appointments System`
- User support email: Select `hn.medicalapoointments@gmail.com`
- App logo: (optional - skip for now)
- App domain: Leave empty
- Authorized domains: Leave empty
- Developer contact information: `hn.medicalapoointments@gmail.com`
- Click **"Save and Continue"**

**Step 2.3: Scopes**
- Click **"Add or Remove Scopes"**
- In the filter box, search: `calendar`
- Check: `https://www.googleapis.com/auth/calendar`
- Click **"Update"**
- Click **"Save and Continue"**

**Step 2.4: Test Users**
- Click **"Add Users"**
- Add: `hn.medicalapoointments@gmail.com`
- Click **"Add"**
- Click **"Save and Continue"**

**Step 2.5: Summary**
- Review everything
- Click **"Back to Dashboard"**

✅ **OAuth Consent Screen configured!**

---

## 🎯 Step 3: Create OAuth 2.0 Credentials

### Create Credentials:

1. **In the left sidebar**, click **"APIs and services"**
2. Click **"Credentials"** (in the left menu)

### Create OAuth Client:

1. **At the top**, click **"+ Create Credentials"**
2. Select **"OAuth client ID"**

### Configure OAuth Client:

**Application type:**
- Select: **"Web application"**

**Name:**
- Enter: `Medical Appointments Calendar`

**Authorized JavaScript origins:**
- Click **"+ Add URI"**
- Add: `https://api.medical-appointments.com`
- Click **"+ Add URI"** again
- Add: `http://localhost:3000`

**Authorized redirect URIs:**
- Click **"+ Add URI"**
- Add: `https://api.medical-appointments.com/api/v1/calendar/google/callback`
- Click **"+ Add URI"** again
- Add: `http://localhost:3000/api/v1/calendar/google/callback`

**Click "Create"**

### Copy Your Credentials:

**IMPORTANT:** Copy these immediately (you won't see the secret again!)

- **Client ID:** `_________________` (copy this)
- **Client Secret:** `_________________` (copy this - shows only once!)

Click **"OK"**

---

## 🎯 Step 4: Save Credentials

**Save these values somewhere safe:**

```
Google Client ID: _________________
Google Client Secret: _________________
```

---

## ✅ Next Steps

1. ✅ Google Calendar API enabled
2. ✅ OAuth consent screen configured
3. ✅ OAuth credentials created
4. ⏳ **Next:** Set up Outlook Calendar (similar process)
5. ⏳ **Then:** Update `.env` file on server
6. ⏳ **Then:** Run database migration
7. ⏳ **Then:** Test connection

---

## 📝 Quick Navigation Reference

**From Dashboard:**
- Left sidebar → **"APIs and services"** → **"Library"** → Search "Calendar API" → Enable
- Left sidebar → **"APIs and services"** → **"OAuth consent screen"** → Configure
- Left sidebar → **"APIs and services"** → **"Credentials"** → Create OAuth Client ID

---

**Need help?** Let me know which step you're on and I'll guide you!

