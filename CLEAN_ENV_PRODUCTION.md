# 🧹 Clean Up .env.production File

## 📋 Current Issue:

The `.env.production` file has duplicate entries:
- Empty entries: `OUTLOOK_CLIENT_ID=` and `OUTLOOK_CLIENT_SECRET=`
- Correct entries: With actual values

**This is okay** - the last values will be used, but it's better to clean it up.

---

## 🔧 Clean Up Steps:

### Option 1: Remove Empty Entries Manually

```bash
cd /var/www/medical-backend
nano .env.production
```

**Find and delete these empty lines:**
```env
OUTLOOK_CLIENT_ID=
OUTLOOK_CLIENT_SECRET=
```

**Keep only these:**
```env
OUTLOOK_CLIENT_ID=32ca22ee-219b-4000-b429-17e9b56aedda
OUTLOOK_CLIENT_SECRET=dVi8Q~1g0CgWlcWznXFXXqDxwU7k2xHyVZeh.afX
OUTLOOK_REDIRECT_URI=https://api.medical-appointments.com/api/v1/calendar/outlook/callback
```

Save: `Ctrl+X`, then `Y`, then `Enter`

### Option 2: Use sed to Remove Empty Lines

```bash
cd /var/www/medical-backend
sed -i '/^OUTLOOK_CLIENT_ID=$/d' .env.production
sed -i '/^OUTLOOK_CLIENT_SECRET=$/d' .env.production
```

**Verify:**
```bash
cat .env.production | grep OUTLOOK
```

Should only show 3 lines (no empty ones).

---

## ✅ After Cleaning:

**Restart the server to reload environment variables:**
```bash
pm2 restart medical-api
```

**Verify:**
```bash
pm2 logs medical-api --lines 20
```

Look for:
- ✅ Server started successfully
- ✅ No errors about missing credentials

---

## 🎯 Current Status:

- ✅ Outlook credentials are in `.env.production`
- ⏳ Clean up duplicate/empty entries (optional but recommended)
- ⏳ Restart server to ensure it loads the credentials
- ⏳ Test endpoints

---

**The server should work fine even with duplicates, but cleaning up is recommended for clarity.**

