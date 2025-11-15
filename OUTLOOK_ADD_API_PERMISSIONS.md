# 📋 Add API Permissions - Step by Step

## ✅ Completed:
- ✅ App Registration: Medical Appointments Calendar
- ✅ Client ID: `32ca22ee-219b-4000-b429-17e9b56aedda`
- ✅ Redirect URIs: Both development and production added

---

## 🚀 Next: Add API Permissions

### Step 1: Navigate to API Permissions

**In Azure Portal, on your app registration page:**

**Option A: Left sidebar**
- Click **"API permissions"** in the left sidebar (under "Manage" section)

**Option B: Overview page**
- Go to **"Overview"** → Click **"API permissions"** link

---

### Step 2: Add Microsoft Graph Permissions

1. **You'll see a page titled "API permissions"**

2. **Click "+ Add a permission"** button (top of the page)

3. **Select "Microsoft Graph"**
   - This is the first option, usually at the top

4. **Choose "Delegated permissions"** (not "Application permissions")
   - This is usually the default tab

5. **Search for and select these permissions:**
   - Type in search box: `Calendars.ReadWrite`
     - ✅ Check **"Calendars.ReadWrite"**
   - Type in search box: `User.Read`
     - ✅ Check **"User.Read"** (usually already selected)
   - Type in search box: `offline_access`
     - ✅ Check **"offline_access"** (for refresh tokens)

6. **Click "Add permissions"** button (bottom right)

---

### Step 3: Grant Admin Consent (IMPORTANT!)

**After adding permissions:**

1. **You'll see the permissions listed**

2. **Click "Grant admin consent for [Your Directory]"** button
   - This is a blue button, usually at the top of the permissions list
   - ⚠️ **This is REQUIRED** - without admin consent, the app won't work!

3. **Confirm the consent**
   - A popup will appear asking to confirm
   - Click **"Yes"** or **"Accept"**

4. **You should see green checkmarks** next to each permission
   - Status should show: "Granted for [Your Directory]"

---

## ✅ After Adding Permissions:

You should see:
- ✅ **Calendars.ReadWrite** - Status: Granted for [Your Directory]
- ✅ **User.Read** - Status: Granted for [Your Directory]
- ✅ **offline_access** - Status: Granted for [Your Directory]

---

## 📋 Next Steps After This:

1. ✅ Add API Permissions (you're doing this now)
2. ⏳ Create Client Secret
3. ⏳ Save credentials to config files

---

**Add the API permissions now, then we'll create the client secret!**

