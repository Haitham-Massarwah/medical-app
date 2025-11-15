# 🔄 Rebuild and Test - Final Steps

## ✅ Code Fix Verified!

The server code has the fix. Now rebuild and test.

---

## 🔧 On Your SSH Session:

### Step 1: Rebuild TypeScript

```bash
cd /var/www/medical-backend
npm run build
```

**Wait for:** `tsc` to complete without errors

---

### Step 2: Verify Build

```bash
ls -la dist/server.js
```

**Should show:** File exists and was recently updated

---

### Step 3: Restart Server

```bash
pm2 restart medical-api --update-env
```

**The `--update-env` flag ensures environment variables are reloaded.**

---

### Step 4: Check Logs

```bash
pm2 logs medical-api --lines 30
```

**Look for:**
- ✅ Server started successfully
- ✅ No "JWT_SECRET not configured" errors
- ✅ Database connected
- ✅ Environment: production

---

## 🧪 Test from Your Local Machine:

### Quick Test:

```powershell
# Test login
$login = Invoke-RestMethod -Uri "https://api.medical-appointments.com/api/v1/auth/login" `
  -Method POST `
  -ContentType "application/json" `
  -Body '{"email":"haitham.massarwah@medical-appointments.com","password":"Developer@2024"}'

$login | ConvertTo-Json -Depth 2
```

**Expected:** Should return success with tokens! ✅

---

### Full Automated Test:

```powershell
cd C:\Projects\medical-app
.\AUTOMATED_TESTS.ps1
```

**This will test all endpoints automatically.**

---

## ✅ Success Indicators:

- ✅ Build completes without errors
- ✅ Server restarts successfully
- ✅ No JWT_SECRET errors in logs
- ✅ Login endpoint returns tokens
- ✅ All automated tests pass

---

**Rebuild, restart, then test!**

