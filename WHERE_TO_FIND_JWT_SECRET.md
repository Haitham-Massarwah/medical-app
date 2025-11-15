# 🔍 Where to Find JWT_SECRET

## 📋 Important Understanding:

**The backend code reads JWT_SECRET from environment variables (`process.env.JWT_SECRET`), NOT from config files!**

---

## 📍 Where JWT_SECRET Should Be:

### ✅ Production Server (Required!)

**File:** `/var/www/medical-backend/.env.production`

**Location:** On your VPS server (66.29.133.192)

**Check if it exists:**
```bash
ssh root@66.29.133.192
cd /var/www/medical-backend
cat .env.production | grep JWT_SECRET
```

**If missing:** Add it:
```bash
nano .env.production
# Add this line:
JWT_SECRET=<generate-a-secret-here>
```

---

### ✅ Development (Local Machine)

**File:** `C:\Projects\medical-app\backend\.env` (if exists)

**OR:** The development server might be using the config file value, but production needs environment variable.

---

## 🔍 Where JWT_SECRET is Currently:

### 1. Config Files (NOT USED by code)

**Development Config:**
- File: `backend/config/development.config.json`
- Value: `"jwtSecret": "development-secret-key-change-in-production"`
- ⚠️ **Code doesn't read from here!**

**Production Config:**
- File: `backend/config/production.config.json`
- Value: `"jwtSecret": "PRODUCTION_SECRET_MUST_BE_CHANGED"`
- ⚠️ **Code doesn't read from here!**

### 2. Environment Variables (REQUIRED by code)

**Production:** `/var/www/medical-backend/.env.production`
- ❌ **Currently MISSING!**
- ✅ **Must be added here!**

**Development:** `backend/.env` (if exists)
- May or may not exist
- Development server works, so it might be using a default or config

---

## 🔧 How to Add JWT_SECRET to Production:

### Step 1: Connect to Server

```bash
ssh root@66.29.133.192
```

### Step 2: Navigate to Backend Directory

```bash
cd /var/www/medical-backend
```

### Step 3: Generate a Secret

```bash
openssl rand -base64 32
```

**Example output:**
```
aB3xK9mP2qR7sT5vW8yZ1cD4fG6hJ0kL3nO6pQ9rS2tU5vW8xY1zA4bC7dE0fG==
```

### Step 4: Add to .env.production

```bash
nano .env.production
```

**Add this line (use your generated secret):**
```env
JWT_SECRET=aB3xK9mP2qR7sT5vW8yZ1cD4fG6hJ0kL3nO6pQ9rS2tU5vW8xY1zA4bC7dE0fG==
```

**Save:** `Ctrl+X`, then `Y`, then `Enter`

### Step 5: Verify It Was Added

```bash
cat .env.production | grep JWT_SECRET
```

**Should show:**
```env
JWT_SECRET=aB3xK9mP2qR7sT5vW8yZ1cD4fG6hJ0kL3nO6pQ9rS2tU5vW8xY1zA4bC7dE0fG==
```

### Step 6: Restart Server

```bash
pm2 restart medical-api --update-env
```

### Step 7: Verify No Errors

```bash
pm2 logs medical-api --lines 20
```

**Look for:** No "JWT_SECRET not configured" errors

---

## 📋 Quick Reference:

| Location | File | Status | Used by Code? |
|----------|------|--------|---------------|
| **Production** | `/var/www/medical-backend/.env.production` | ❌ Missing | ✅ **YES** |
| Development Config | `backend/config/development.config.json` | ✅ Exists | ❌ No |
| Production Config | `backend/config/production.config.json` | ✅ Exists | ❌ No |

---

## 🎯 Summary:

**Where to find it:** It doesn't exist yet - you need to **create it**!

**Where to add it:** `/var/www/medical-backend/.env.production` on your production server

**How to create it:** Generate with `openssl rand -base64 32`

**After adding:** Restart server with `pm2 restart medical-api --update-env`

---

**The JWT_SECRET doesn't exist yet - you need to generate it and add it to .env.production!**

