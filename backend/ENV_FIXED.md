# ✅ Environment Variables Fixed!

## 🔧 What Was Fixed:

The Google Calendar credentials were missing from the `.env` file. They've been added now!

---

## 📋 Added to .env:

```env
GOOGLE_CLIENT_ID=460829863462-cld9ijbevsa23fiphrbi1po9al23l0ae.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=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
GOOGLE_REDIRECT_URI=http://localhost:3000/api/v1/calendar/google/callback
```

---

## 🔄 Restart Server:

**Nodemon should auto-restart**, but if it doesn't:

### Option 1: Manual Restart in Nodemon
In the terminal where nodemon is running, type:
```
rs
```

### Option 2: Stop and Restart
1. Press `Ctrl+C` to stop the server
2. Run: `.\START_SIMPLE.bat`

---

## 🧪 Test After Restart:

```powershell
.\TEST_CALENDAR.ps1
```

Or manually:
```powershell
# Login
$login = Invoke-RestMethod -Uri "http://localhost:3000/api/v1/auth/login" `
  -Method POST -ContentType "application/json" `
  -Body '{"email":"haitham.massarwah@medical-appointments.com","password":"Developer@2024"}'

$token = $login.data.tokens.accessToken

# Get Calendar Auth URL
$headers = @{Authorization = "Bearer $token"}
Invoke-RestMethod -Uri "http://localhost:3000/api/v1/calendar/google/auth-url" `
  -Method GET -Headers $headers
```

---

## ✅ Expected Result:

After restart, the auth URL should show:
```
https://accounts.google.com/o/oauth2/v2/auth?client_id=460829863462-cld9ijbevsa23fiphrbi1po9al23l0ae.apps.googleusercontent.com&redirect_uri=...
```

**NOT** `YOUR_GOOGLE_CLIENT_ID`

---

**Restart the server and test again!**

