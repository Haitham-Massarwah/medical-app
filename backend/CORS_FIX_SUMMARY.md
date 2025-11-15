# CORS & SSL Configuration - Complete Fix Summary

## ✅ Changes Made

### 1. Enhanced CORS Configuration (`backend/src/config/cors.ts`)

**Improvements:**
- ✅ **Development Mode:** Now VERY permissive - allows ALL origins in development
- ✅ **Production Origins:** Automatically includes `medical-appointments.com` variants:
  - `https://medical-appointments.com`
  - `https://www.medical-appointments.com`
  - `http://medical-appointments.com` (for testing before SSL)
  - `https://api.medical-appointments.com`
- ✅ **Localhost Support:** Multiple localhost ports (3000, 8080, 3001, 5000)
- ✅ **Subdomain Support:** Automatically allows subdomains of `medical-appointments.com`
- ✅ **Better Error Messages:** Logs blocked origins for debugging
- ✅ **Additional Headers:** Added `Access-Control-Request-Method` and `Access-Control-Request-Headers`

**Key Feature:**
```typescript
// In development, ALL origins are allowed automatically
if (process.env.NODE_ENV === 'development') {
  return callback(null, true); // Allow everything!
}
```

### 2. Updated Environment Configuration (`backend/env.example`)

**Added:**
- ✅ Extended CORS_ORIGIN list with all necessary domains
- ✅ Added `LOG_CORS` flag for debugging (set to `true` to see CORS logs)

**Configuration:**
```env
CORS_ORIGIN=http://localhost:8080,http://localhost:3000,http://localhost:3001,https://medical-appointments.com,https://www.medical-appointments.com,http://medical-appointments.com,https://api.medical-appointments.com
CORS_CREDENTIALS=true
LOG_CORS=false
```

### 3. New Helper Scripts

#### `start-server-easy.ps1`
- ✅ Automatically checks for `.env` file
- ✅ Creates `.env` from `env.example` if missing
- ✅ Checks for dependencies
- ✅ Shows clear server information
- ✅ Sets development mode for permissive CORS

#### `TEST_CORS.ps1`
- ✅ Tests if server is running
- ✅ Tests CORS preflight requests
- ✅ Shows CORS headers in response
- ✅ Helps debug CORS issues

#### `SSL_SETUP_GUIDE.md`
- ✅ Complete guide for SSL certificate setup
- ✅ Multiple options: Let's Encrypt, Cloudflare, Self-signed, Commercial
- ✅ DNS configuration instructions
- ✅ Step-by-step instructions for each method

---

## 🚀 Quick Start Guide

### Step 1: Start the Backend Server

**Option A: Easy Script (Recommended)**
```powershell
cd backend
.\start-server-easy.ps1
```

**Option B: Manual**
```powershell
cd backend
npm install  # If not done already
npm run dev
```

**The server will run on:** `http://localhost:3000`

### Step 2: Test the Connection

1. **Health Check:**
   ```
   http://localhost:3000/health
   ```

2. **API Endpoint:**
   ```
   http://localhost:3000/api/v1/health
   ```

3. **Test CORS:**
   ```powershell
   cd backend
   .\TEST_CORS.ps1
   ```

### Step 3: Configure Your `.env` File

**If `.env` doesn't exist:**
1. Copy `env.example` to `.env`:
   ```powershell
   copy env.example .env
   ```

2. Edit `.env` and update:
   - Database credentials
   - JWT secrets
   - Email configuration
   - CORS origins (if needed)

3. The CORS configuration is already good for development!

---

## 🔒 SSL Certificate Issues

### Current Problem:
You're seeing `NET::ERR_CERT_COMMON_NAME_INVALID` because:
- No SSL certificate is installed yet
- Certificate might be for wrong domain
- Self-signed certificate (browsers don't trust it)

### Solutions:

**For Development (Immediate):**
- ✅ Use `http://localhost:3000` (works perfectly, no SSL needed)
- ✅ Use `http://medical-appointments.com` (works in development)
- ✅ Our CORS config allows HTTP in development

**For Production:**
See `SSL_SETUP_GUIDE.md` for complete instructions. Quick options:

1. **Cloudflare (Easiest):**
   - Sign up for free Cloudflare account
   - Add your domain
   - Enable SSL/TLS (automatic)
   - Free SSL certificate!

2. **Let's Encrypt (Free):**
   - Install Certbot
   - Run: `certbot certonly --standalone -d medical-appointments.com`
   - Configure your server to use certificates

---

## 🌐 CORS in Different Environments

### Development Mode (Current)
- ✅ **ALL origins allowed** - no CORS errors
- ✅ Works with any domain
- ✅ Perfect for local development

### Production Mode
- ✅ Only allowed origins from `CORS_ORIGIN` env variable
- ✅ Automatically includes `medical-appointments.com` variants
- ✅ Security enforced

---

## 📝 Testing Checklist

- [ ] Server starts without errors
- [ ] `http://localhost:3000/health` returns JSON
- [ ] CORS preflight requests work (use TEST_CORS.ps1)
- [ ] API endpoints respond correctly
- [ ] No CORS errors in browser console

---

## 🔍 Troubleshooting

### Connection Refused (`ERR_CONNECTION_REFUSED`)
**Problem:** Server is not running

**Solution:**
1. Run `.\start-server-easy.ps1`
2. Check if port 3000 is already in use:
   ```powershell
   netstat -ano | findstr :3000
   ```
3. Kill process if needed or use different port

### CORS Error in Browser
**Problem:** Origin not allowed

**Solution:**
1. Check you're in development mode: `NODE_ENV=development`
2. Check `CORS_ORIGIN` includes your domain
3. Enable CORS logging: `LOG_CORS=true` in `.env`
4. Check browser console for exact error

### SSL Certificate Error
**Problem:** `NET::ERR_CERT_COMMON_NAME_INVALID`

**Solution:**
1. **For development:** Use HTTP instead of HTTPS
2. **For production:** Follow `SSL_SETUP_GUIDE.md`
3. **Quick test:** Use `http://medical-appointments.com` (HTTP) temporarily

---

## ✅ What's Fixed

1. ✅ **CORS Configuration:** Now very permissive in development
2. ✅ **Multiple Origins:** Supports localhost, domain, and subdomains
3. ✅ **SSL Guide:** Complete documentation for certificate setup
4. ✅ **Easy Startup:** Scripts make it easy to start the server
5. ✅ **Better Logging:** Server shows connection info on start
6. ✅ **Testing Tools:** CORS test script available

---

## 🎯 Next Steps

1. **Start the server:**
   ```powershell
   cd backend
   .\start-server-easy.ps1
   ```

2. **Test locally:**
   - Open: `http://localhost:3000/health`
   - Should see JSON response

3. **When ready for production:**
   - Follow `SSL_SETUP_GUIDE.md`
   - Set up SSL certificate
   - Update CORS_ORIGIN in production `.env`
   - Deploy!

---

## 📞 Need Help?

If you're still seeing issues:

1. **Check server logs** for errors
2. **Run TEST_CORS.ps1** to test CORS
3. **Check browser console** for specific errors
4. **Verify .env file** exists and is configured
5. **Check firewall** allows port 3000

**Common Issues:**
- Server not running → Run `start-server-easy.ps1`
- Port in use → Change PORT in `.env`
- CORS errors → Check NODE_ENV is "development"
- SSL errors → Use HTTP for now, set up SSL later


