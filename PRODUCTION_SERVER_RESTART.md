# 🔄 Restart Production Server - Step by Step

## ✅ What You've Done:

1. ✅ Connected to production server via SSH
2. ✅ Navigated to `/var/www/medical-backend`
3. ✅ Opened `.env.production` with nano
4. ✅ (Presumably) Added Outlook credentials

---

## 📋 Step 1: Verify .env.production File

**On the production server, check if Outlook credentials were added:**

```bash
cat /var/www/medical-backend/.env.production | grep OUTLOOK
```

**You should see:**
```env
OUTLOOK_CLIENT_ID=32ca22ee-219b-4000-b429-17e9b56aedda
OUTLOOK_CLIENT_SECRET=dVi8Q~1g0CgWlcWznXFXXqDxwU7k2xHyVZeh.afX
OUTLOOK_REDIRECT_URI=https://api.medical-appointments.com/api/v1/calendar/outlook/callback
```

**If you don't see these lines, add them:**

```bash
cd /var/www/medical-backend
nano .env.production
```

Add at the end:
```env
# Outlook Calendar OAuth Configuration
OUTLOOK_CLIENT_ID=32ca22ee-219b-4000-b429-17e9b56aedda
OUTLOOK_CLIENT_SECRET=dVi8Q~1g0CgWlcWznXFXXqDxwU7k2xHyVZeh.afX
OUTLOOK_REDIRECT_URI=https://api.medical-appointments.com/api/v1/calendar/outlook/callback
```

Save: `Ctrl+X`, then `Y`, then `Enter`

---

## 📋 Step 2: Restart Production Server

**On the production server (Linux), use PM2, not nodemon:**

```bash
cd /var/www/medical-backend
pm2 restart medical-api
```

**Or if you want to see the logs:**

```bash
pm2 restart medical-api
pm2 logs medical-api
```

**To check status:**

```bash
pm2 status
```

**You should see:**
```
┌────┬────────────────────┬──────────┬──────┬───────────┬──────────┬──────────┐
│ id │ name               │ mode     │ ↺    │ status    │ cpu      │ memory   │
├────┼────────────────────┼──────────┼──────┼───────────┼──────────┼──────────┤
│ 0  │ medical-api        │ fork     │ 1    │ online    │ 0%       │ 50mb     │
└────┴────────────────────┴──────────┴──────┴───────────┴──────────┴──────────┘
```

---

## 📋 Step 3: Verify Server Restarted Successfully

**Check PM2 logs for any errors:**

```bash
pm2 logs medical-api --lines 50
```

**Look for:**
- ✅ Server started successfully
- ✅ No errors about missing Outlook credentials
- ✅ Database connected
- ✅ Server running on port 3000

**If you see errors:**
- Check `.env.production` file syntax
- Verify all environment variables are set correctly
- Check PM2 logs for detailed error messages

---

## 📋 Step 4: Test Production Endpoints

**From your local machine, test the production API:**

```powershell
# Test health endpoint
Invoke-RestMethod -Uri "https://api.medical-appointments.com/health"

# Test Outlook auth URL (requires authentication)
# First login to get token
$login = Invoke-RestMethod -Uri "https://api.medical-appointments.com/api/v1/auth/login" `
  -Method POST `
  -ContentType "application/json" `
  -Body '{"email":"haitham.massarwah@medical-appointments.com","password":"Developer@2024"}'

$token = $login.data.tokens.accessToken

# Test Outlook endpoint
Invoke-RestMethod -Uri "https://api.medical-appointments.com/api/v1/calendar/outlook/auth-url" `
  -Headers @{"Authorization"="Bearer $token"}
```

---

## ✅ Summary

**Production Server:**
- ✅ `.env.production` updated
- ⏳ Restart with: `pm2 restart medical-api`
- ⏳ Verify: `pm2 logs medical-api`

**Development Server:**
- ✅ Running successfully on `http://localhost:3000`
- ✅ Database connected
- ✅ Ready for testing

---

## 🎯 Next Actions

1. **On Production Server:** Run `pm2 restart medical-api`
2. **On Local Machine:** Test development endpoints (already running)
3. **Test Integration:** Follow testing steps from `NEXT_STEPS_EXPLAINED.md`

