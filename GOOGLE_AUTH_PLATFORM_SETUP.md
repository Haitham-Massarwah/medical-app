# 🔵 Google Auth Platform Setup (New Interface)

## 🎯 Current Status:
- ✅ You're on: **Google Auth Platform** → **OAuth overview**
- 📋 This is Google's NEW interface for OAuth setup
- ⚠️ Platform not configured yet

---

## 📋 Step-by-Step Setup:

### Step 1: Get Started
1. **Click the blue "Get started" button** (center of page)
2. This will start the OAuth configuration wizard

### Step 2: Configure Your App (Wizard will guide you)

**You'll be asked to fill:**

1. **App Information:**
   - **App name:** `Medical Appointments System`
   - **User support email:** `hn.medicalapoointments@gmail.com`
   - **Developer contact:** `hn.medicalapoointments@gmail.com`

2. **Scopes/Permissions:**
   - Add: `https://www.googleapis.com/auth/calendar`
   - (Search for "calendar" and select it)

3. **Test Users:**
   - Add: `hn.medicalapoointments@gmail.com`

4. **Application Type:**
   - Select: **"Web application"**

5. **Authorized JavaScript origins:**
   - Add: `https://api.medical-appointments.com`
   - Add: `http://localhost:3000`

6. **Authorized redirect URIs:**
   - Add: `https://api.medical-appointments.com/api/v1/calendar/google/callback`
   - Add: `http://localhost:3000/api/v1/calendar/google/callback`

---

## ✅ After Setup:

Once configured:
1. You'll see your OAuth Client ID and Secret
2. **Copy both immediately** (Secret won't show again!)
3. Run: `.\backend\scripts\save-google-credentials.ps1`

---

## 📋 Quick Checklist:

- [ ] Click "Get started" button
- [ ] Fill app information
- [ ] Add calendar scope
- [ ] Add test user
- [ ] Configure as Web application
- [ ] Add JavaScript origins
- [ ] Add redirect URIs
- [ ] Copy Client ID and Secret

---

**Click "Get started" and follow the wizard!**

