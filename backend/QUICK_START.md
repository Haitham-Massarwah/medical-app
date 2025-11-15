# 🚀 Quick Start Guide

## ✅ Dependencies Installed!

All Node.js dependencies are now installed and ready.

---

## 🚀 Start Development Server:

### Option 1: Simple Batch File (Recommended)
```batch
.\START_SIMPLE.bat
```

### Option 2: Direct Command
```batch
cmd /c "npm run dev"
```

### Option 3: PowerShell (if execution policy allows)
```powershell
npm run dev
```

---

## 📋 Server Information:

- **Backend URL:** http://localhost:3000
- **API Base:** http://localhost:3000/api/v1
- **Calendar API:** http://localhost:3000/api/v1/calendar
- **Google Callback:** http://localhost:3000/api/v1/calendar/google/callback

---

## ✅ What's Configured:

- ✅ Google Calendar OAuth credentials
- ✅ Database connection
- ✅ Email (Gmail)
- ✅ Twilio SMS
- ✅ All dependencies installed

---

## 🧪 Test the Server:

Once the server starts, test it:

```powershell
# Check health (if endpoint exists)
curl http://localhost:3000/api/v1/health

# Or open in browser
start http://localhost:3000
```

---

## 🛑 Stop the Server:

Press `Ctrl+C` in the terminal where the server is running.

---

**Server should be starting now! Check the terminal output.**

