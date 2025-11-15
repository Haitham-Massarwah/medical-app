# 🔷 Add Production Redirect URI - Step by Step

## 📋 Current Status:
- ✅ App Registration: Medical Appointments Calendar
- ✅ Client ID: `32ca22ee-219b-4000-b429-17e9b56aedda`
- ⏳ Need to add production redirect URI

---

## 🚀 Add Production Redirect URI:

### Step 1: Go to Authentication/Redirect URIs

**In Azure Portal, on your app registration page:**

**Option A: Click the link**
- Click **"Redirect URIs"** in the Essentials section
  - It shows: "1 web, 0 spa, 0 public client"

**Option B: Left sidebar**
- Click **"Authentication"** in the left sidebar

---

### Step 2: Add Production URI

1. **You'll see a section called "Redirect URIs"**

2. **Under "Web" platform:**
   - Click **"+ Add URI"** or **"+ Add platform"** → **"Web"**

3. **Add this URI:**
   ```
   https://api.medical-appointments.com/api/v1/calendar/outlook/callback
   ```

4. **Click "Add"**

5. **You should now have BOTH:**
   - ✅ `http://localhost:3000/api/v1/calendar/outlook/callback` (development)
   - ✅ `https://api.medical-appointments.com/api/v1/calendar/outlook/callback` (production)

6. **Click "Save"** (top of the page)

---

## ✅ After Adding:

You'll see:
- **Redirect URIs:** 2 web, 0 spa, 0 public client

---

## 📋 Next Steps:

1. ✅ Add production redirect URI (you're doing this now)
2. ⏳ Add API Permissions
3. ⏳ Create Client Secret
4. ⏳ Save credentials

---

**Add the production URI now, then continue with API permissions!**

