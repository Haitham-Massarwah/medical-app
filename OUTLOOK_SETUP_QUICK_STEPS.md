# 📅 Outlook Calendar Setup - Quick Reference

## 🚀 Quick Steps Summary

### Step 1: Create App Registration
1. Azure Portal → Microsoft Entra ID → App registrations
2. New registration → Name: `Medical Appointments Calendar`
3. Copy **Client ID**: `32ca22ee-219b-4000-b429-17e9b56aedda`

### Step 2: Add Redirect URIs
1. Authentication → + Add URI
2. Add: `http://localhost:3000/api/v1/calendar/outlook/callback`
3. Add: `https://api.medical-appointments.com/api/v1/calendar/outlook/callback`
4. Save

### Step 3: Add API Permissions
1. API permissions → + Add a permission
2. Microsoft Graph → Delegated permissions
3. Select: **Calendars.ReadWrite**, **User.Read**, **offline_access**
4. Add permissions

### Step 4: Grant Admin Consent
1. Click **"Grant admin consent for Default Directory"**
2. Confirm → Yes

### Step 5: Create Client Secret
1. Certificates & secrets → + New client secret
2. Description: `Medical Appointments Calendar Secret`
3. Expires: 24 months
4. **Copy the Value immediately!** (only visible once)
5. Secret: `dVi8Q~1g0CgWlcWznXFXXqDxwU7k2xHyVZeh.afX`

### Step 6: Save Credentials
**Development:** `backend/config/development.config.json`
```json
"outlook": {
  "clientId": "32ca22ee-219b-4000-b429-17e9b56aedda",
  "clientSecret": "dVi8Q~1g0CgWlcWznXFXXqDxwU7k2xHyVZeh.afX",
  "redirectUri": "http://localhost:3000/api/v1/calendar/outlook/callback"
}
```

**Production:** `backend/config/production.config.json`
```json
"outlook": {
  "clientId": "32ca22ee-219b-4000-b429-17e9b56aedda",
  "clientSecret": "dVi8Q~1g0CgWlcWznXFXXqDxwU7k2xHyVZeh.afX",
  "redirectUri": "https://api.medical-appointments.com/api/v1/calendar/outlook/callback"
}
```

**Server .env:** `/var/www/medical-backend/.env.production`
```env
OUTLOOK_CLIENT_ID=32ca22ee-219b-4000-b429-17e9b56aedda
OUTLOOK_CLIENT_SECRET=dVi8Q~1g0CgWlcWznXFXXqDxwU7k2xHyVZeh.afX
OUTLOOK_REDIRECT_URI=https://api.medical-appointments.com/api/v1/calendar/outlook/callback
```

### Step 7: Restart Server
- **Dev:** `.\START_SIMPLE.bat` or press `rs` in nodemon
- **Prod:** `pm2 restart medical-api`

### Step 8: Test
```bash
GET /api/v1/calendar/outlook/auth-url
GET /api/v1/calendar/status
```

---

## ✅ Current Status

- ✅ App Registration: Created
- ✅ Client ID: `32ca22ee-219b-4000-b429-17e9b56aedda`
- ✅ Redirect URIs: Both configured
- ✅ API Permissions: All 3 added
- ✅ Admin Consent: Granted
- ✅ Client Secret: Created
- ✅ Config Files: Updated
- ⏳ Server .env: Needs update (production)
- ⏳ Testing: Ready to test

---

**📖 Full Guide:** `OUTLOOK_CALENDAR_SETUP_COMPLETE_GUIDE.md`

