# FortiGuard Blocking Issue - Solution Guide

## Problem
Your domain `medical-appointments.com` is being blocked by FortiGuard Intrusion Prevention because it's classified as a "Newly Observed Domain". This is a network security policy issue, not a code issue.

**Error Message:**
- "FortiGuard Intrusion Prevention - Access Blocked"
- Category: "Newly Observed Domain"
- URL: `http://medical-appointments.com/`

## Why This Happens
FortiGuard is a web security service that blocks domains that:
1. Are newly registered/observed
2. Don't have a reputation yet
3. Match certain security criteria

This is common for:
- New domains (< 30 days old)
- Domains not yet indexed by security services
- Domains without proper SSL certificates

## Solutions

### Solution 1: Add Domain to FortiGuard Whitelist (If You Control Network)

If you're on a corporate network where you have admin access:

1. **Access FortiGate Admin Panel:**
   - Usually at `https://your-gateway-ip` or `https://fortigate.company.com`
   - Login with admin credentials

2. **Add to Whitelist:**
   - Navigate to: **Web Filter** → **URL Filter** → **Static URL Filter**
   - Click **Create New**
   - Action: **Allow**
   - URL Pattern: `medical-appointments.com`
   - Apply to user groups/policies

3. **Alternative: FortiGuard Category Override:**
   - Navigate to: **Security Profiles** → **Web Filter**
   - Find "Newly Observed Domain" category
   - Set action to **Allow** or **Monitor** for testing

### Solution 2: Test Locally Without Domain (Recommended for Development)

Since FortiGuard is blocking the domain, test everything locally:

**Backend (Already Configured):**
```powershell
cd backend
.\start-server-easy.ps1
```
- Server runs on: `http://localhost:3000`
- This won't be blocked by FortiGuard

**Frontend/Testing:**
- Use `http://localhost:3000` or `http://localhost:8080`
- Our CORS configuration already allows these

### Solution 3: Use IP Address Instead of Domain

If your domain DNS points to a specific IP:

1. **Find your server IP:**
   ```powershell
   # Check DNS resolution
   nslookup medical-appointments.com
   ```

2. **Access via IP:**
   - Use `http://YOUR_IP:3000` instead of domain
   - FortiGuard may not block IP addresses the same way

3. **Update CORS configuration:**
   - Add IP to `CORS_ORIGIN` in `.env`:
   ```
   CORS_ORIGIN=http://YOUR_IP:3000,http://localhost:3000,...
   ```

### Solution 4: Request Domain Review (For Production)

If you need the domain to work on all networks:

1. **Submit to FortiGuard:**
   - Visit: https://www.fortiguard.com/faq/wfratingsubmit
   - Submit your domain for review
   - Request category change or whitelisting
   - Usually takes 24-48 hours

2. **Add to FortiGuard Trusted Sites:**
   - This helps build reputation over time

### Solution 5: Use Different Network

For testing purposes:
- Use mobile hotspot (bypasses corporate network)
- Use personal/home network
- Use VPN (if allowed)

### Solution 6: Bypass FortiGuard for Testing (Not Recommended)

**Warning:** Only if you have explicit permission to bypass security policies.

1. **Use Proxy:**
   - Configure browser to use proxy
   - Bypasses FortiGuard filtering

2. **VPN:**
   - Connect to VPN outside corporate network
   - Traffic routes around FortiGuard

---

## Recommended Approach for Development

**Best Practice: Test Everything Locally**

1. **Backend:**
   ```powershell
   cd backend
   .\start-server-easy.ps1
   ```
   Server: `http://localhost:3000`

2. **Frontend:**
   - Configure to use `http://localhost:3000/api/v1`
   - No domain needed for development

3. **CORS:**
   - Already configured for localhost
   - Development mode allows all origins

4. **Testing:**
   - All localhost endpoints work perfectly
   - No FortiGuard blocking

---

## For Production Deployment

Once your domain is live and properly configured:

1. **Wait for FortiGuard Indexing:**
   - Usually 7-30 days after domain goes live
   - After proper SSL certificate installation
   - After being indexed by search engines

2. **Submit for Review:**
   - Submit to FortiGuard rating system
   - Request whitelisting

3. **Build Domain Reputation:**
   - Proper SSL certificate
   - Valid DNS configuration
   - Proper content (not flagged as malicious)
   - Time (domain age matters)

---

## Testing Without Domain Blocking

### Test CORS Locally:

1. **Start Server:**
   ```powershell
   cd backend
   .\start-server-easy.ps1
   ```

2. **Test Health Check:**
   ```
   http://localhost:3000/health
   ```

3. **Test API:**
   ```
   http://localhost:3000/api/v1/health
   ```

4. **Test CORS:**
   ```powershell
   cd backend
   .\TEST_CORS.ps1
   ```

All of these work on localhost and won't be blocked by FortiGuard!

---

## Quick Fix Summary

**Immediate Solution:**
- ✅ Use `http://localhost:3000` for all testing
- ✅ CORS already configured for localhost
- ✅ No FortiGuard blocking on localhost

**For Network Admin:**
- Add `medical-appointments.com` to FortiGuard whitelist
- Or disable "Newly Observed Domain" category for testing

**For Production:**
- Submit domain to FortiGuard for review
- Wait for domain reputation to build
- Ensure proper SSL certificate is installed

---

## Verify Local Testing Works

Run these tests to verify everything works locally:

```powershell
# 1. Start server
cd backend
.\start-server-easy.ps1

# 2. In another terminal, test health
curl http://localhost:3000/health

# 3. Test CORS
.\TEST_CORS.ps1
```

If all localhost tests pass, your code is working correctly - the only issue is FortiGuard network blocking, which doesn't affect local development.

---

## Summary

| Issue | Cause | Solution |
|-------|-------|----------|
| Domain blocked | FortiGuard "Newly Observed Domain" | Use localhost for testing |
| Both tests blocked | Network-level blocking | Test with localhost instead |
| Need production access | Domain needs reputation | Submit to FortiGuard, wait 7-30 days |

**Bottom Line:** For development, use `localhost` - it works perfectly and avoids all network security blocks!


