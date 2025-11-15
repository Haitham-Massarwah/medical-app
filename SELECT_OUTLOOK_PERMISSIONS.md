# ✅ Select Outlook Calendar Permissions

## ✅ Current Status:
- ✅ Microsoft Graph selected
- ✅ Delegated permissions selected
- ✅ Calendars.ReadWrite found/selected

---

## 🚀 Select All Required Permissions:

### Step 1: Select Calendars.ReadWrite

**You already have this selected!** ✅

- ✅ **Calendars.ReadWrite** - Allows reading and writing calendar events

---

### Step 2: Search and Select User.Read

1. **In the search box**, clear "Calendars.ReadWrite" (click the X)
2. **Type:** `User.Read`
3. **Check the box** next to **"User.Read"**
   - Description: "Sign in and read user profile"
   - This is required for basic user authentication

---

### Step 3: Search and Select offline_access

1. **In the search box**, clear "User.Read"
2. **Type:** `offline_access`
3. **Check the box** next to **"offline_access"**
   - Description: "Maintain access to data you have given it access to"
   - This is REQUIRED for refresh tokens (so users don't have to re-authenticate)

---

### Step 4: Verify All Permissions Selected

**You should have 3 permissions checked:**

- ✅ **Calendars.ReadWrite**
- ✅ **User.Read**
- ✅ **offline_access**

---

### Step 5: Add Permissions

1. **Scroll down** to the bottom of the dialog
2. **Click "Add permissions"** button (blue button)
3. The dialog will close and you'll return to the API permissions page

---

## 📋 After Adding Permissions:

You'll see the permissions listed on the API permissions page. Then you'll need to:

1. ⏳ **Grant admin consent** (REQUIRED!)
2. ⏳ Create Client Secret
3. ⏳ Save credentials

---

**Select all 3 permissions, then click "Add permissions"!**

