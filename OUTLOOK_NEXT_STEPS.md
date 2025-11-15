# 🔷 Outlook Calendar - Next Steps

## ✅ App Registration Created!

**Application (Client) ID:** `32ca22ee-219b-4000-b429-17e9b56aedda`

---

## 📋 Remaining Steps:

### Step 1: Verify Redirect URIs ✅

**You have 1 web redirect URI** - let's make sure it's correct:

1. **Click on "Redirect URIs"** (in Essentials section)
   - Or: Left sidebar → **"Authentication"**

2. **Verify you have BOTH:**
   - ✅ `http://localhost:3000/api/v1/calendar/outlook/callback`
   - ✅ `https://api.medical-appointments.com/api/v1/calendar/outlook/callback`

3. **If missing, add the missing one:**
   - Platform: **Web**
   - URI: Add the missing one
   - Click **"Add"**

---

### Step 2: Add API Permissions

1. **Left sidebar** → Click **"API permissions"**

2. **Click "+ Add a permission"**

3. **Select "Microsoft Graph"**

4. **Select "Delegated permissions"**

5. **Search and add:**
   - ✅ `Calendars.ReadWrite` - Read and write calendars
   - ✅ `offline_access` - Maintain access to data

6. **Click "Add permissions"**

7. **Click "Grant admin consent"** (if you see this button)

---

### Step 3: Create Client Secret

1. **Left sidebar** → Click **"Certificates & secrets"**

2. **Click "+ New client secret"**

3. **Fill the form:**
   - **Description:** `Medical Appointments Calendar Secret`
   - **Expires:** Select **24 months**

4. **Click "Add"**

5. **⚠️ COPY THE VALUE IMMEDIATELY!**
   - Look for your secret in the list
   - The **Value** column shows the secret
   - Copy it NOW - you won't see it again!

---

### Step 4: Save Credentials

**After you have the Client Secret Value:**

```powershell
cd C:\Projects\medical-app\backend
.\scripts\save-outlook-credentials.ps1
```

**Enter:**
- Client ID: `32ca22ee-219b-4000-b429-17e9b56aedda`
- Client Secret: (paste the Value you copied)

---

## ✅ Quick Checklist:

- [x] App registration created
- [x] Client ID copied: `32ca22ee-219b-4000-b429-17e9b56aedda`
- [ ] Redirect URIs verified (both localhost + production)
- [ ] API permissions added (Calendars.ReadWrite, offline_access)
- [ ] Client Secret created
- [ ] Client Secret Value copied
- [ ] Run save-outlook-credentials.ps1
- [ ] Restart server
- [ ] Test connection

---

**Continue with Step 2: Add API Permissions!**

