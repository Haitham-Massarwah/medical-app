# 📱 Complete SMS Service Configuration Guide

## ✅ Current Status

**What's Already Configured:**
- ✅ Twilio Account SID: `AC22fc8395b3e91855cf37fdcb48111d5b`
- ✅ Twilio Auth Token: Configured
- ✅ Twilio Account: Active
- ✅ SMS Service Code: Complete
- ⚠️ **Phone Number: NEEDS TO BE ADDED**

---

## 🚀 Quick Setup (5 Minutes)

### Step 1: Get Twilio Phone Number

#### Option A: Buy Israeli Number (Recommended for Production)

1. **Login to Twilio Console:**
   ```
   URL: https://console.twilio.com
   Account SID: AC22fc8395b3e91855cf37fdcb48111d5b
   ```

2. **Navigate to Phone Numbers:**
   - Click: **Phone Numbers** (left sidebar)
   - Click: **Manage** → **Buy a Number**

3. **Search for Israeli Number:**
   - **Country:** Select **Israel (+972)**
   - **Capabilities:** Check ✅ **SMS** and ✅ **Voice**
   - Click: **Search**

4. **Purchase Number:**
   - Select a number from the list
   - Click: **Buy** or **Reserve**
   - Confirm purchase
   - **Cost:** ~$1-2/month

5. **Copy Phone Number:**
   - Format: `+972501234567` (with country code)
   - Example: `+972501234567`

#### Option B: Use Trial Number (For Testing Only)

1. **Check Trial Number:**
   - Go to: Twilio Console Dashboard
   - Look for: "Get a trial phone number"
   - Usually: US number like `+15005550006`

2. **Limitations:**
   - ⚠️ Can only send to **verified numbers**
   - ⚠️ Good for testing only
   - ⚠️ Need real number for production

---

### Step 2: Add Phone Number to Configuration

#### Method 1: Use Setup Script (Easiest)

```powershell
cd C:\Projects\medical-app\backend
.\SETUP_SMS.ps1
```

When prompted, enter your phone number: `+972501234567`

#### Method 2: Manual Edit

1. **Open `.env` file:**
   ```
   C:\Projects\medical-app\backend\.env
   ```

2. **Add/Update this line:**
   ```env
   TWILIO_PHONE_NUMBER=+972501234567
   ```
   (Replace with your actual number)

3. **Save the file**

---

### Step 3: Restart Backend

```powershell
cd C:\Projects\medical-app\backend

# Stop current backend (Ctrl+C if running)

# Start backend
npm run dev
```

---

### Step 4: Test SMS Service

#### Quick Test:

```powershell
cd C:\Projects\medical-app\backend
.\TEST_SMS.ps1
```

This will:
1. Check backend is running
2. Login automatically
3. Prompt for test phone number
4. Send test SMS
5. Show results

#### Manual Test:

```powershell
# Login
$loginBody = '{"email":"haitham.massarwah@medical-appointments.com","password":"Developer@2024"}'
$login = Invoke-RestMethod -Uri "http://localhost:3000/api/v1/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
$token = $login.data.tokens.accessToken

# Send SMS
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

$smsBody = @{
    to = "+972501234567"  # Your phone number
    message = "Test SMS from Medical Appointment System ✅"
    type = "test"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3000/api/v1/notifications/sms" -Method Post -Headers $headers -Body $smsBody
```

---

## 🔍 Verify Configuration

### Check Current Status:

```powershell
cd C:\Projects\medical-app\backend
.\CHECK_SMS_CONFIG.ps1
```

This shows:
- ✅ Account SID status
- ✅ Auth Token status
- ✅ Phone Number status

---

## 📋 Configuration Checklist

- [ ] Twilio account created
- [ ] Account SID in `.env` ✅ (Already done)
- [ ] Auth Token in `.env` ✅ (Already done)
- [ ] Phone number purchased from Twilio
- [ ] Phone number added to `.env` (`TWILIO_PHONE_NUMBER`)
- [ ] Backend restarted
- [ ] Test SMS sent successfully

---

## 🧪 Testing Scenarios

### Test 1: Basic SMS
```powershell
.\TEST_SMS.ps1
# Enter your phone number when prompted
```

### Test 2: Appointment Confirmation
```powershell
# Via API - appointment confirmation SMS
# This will be sent automatically when appointments are created
```

### Test 3: Appointment Reminder
```powershell
# Via API - reminder SMS
# This will be sent automatically 24h before appointment
```

---

## ⚠️ Troubleshooting

### Issue: "Phone number not configured"

**Solution:**
- Add `TWILIO_PHONE_NUMBER=+972501234567` to `.env`
- Restart backend

### Issue: "Failed to send SMS - Trial account"

**Solution:**
- Verify recipient number in Twilio Console
- Go to: Phone Numbers → Verified Caller IDs
- Add recipient number
- Or upgrade to paid account

### Issue: "Invalid phone number format"

**Solution:**
- Use format: `+972501234567` (with country code)
- Must start with `+`
- Israeli numbers: `+972` + 9 digits

### Issue: "Authentication failed"

**Solution:**
- Verify Account SID and Auth Token
- Check `.env` file is loaded
- Restart backend

### Issue: "Insufficient credits"

**Solution:**
- Add credits to Twilio account
- Go to: Billing → Add Funds
- Minimum: $20

---

## 💰 Pricing Reference

### SMS Costs:
- **Israel:** ~$0.05 per SMS
- **Phone Number:** ~$1-2/month
- **Free Trial:** $15.50 credit included

### Monthly Estimate:
- **1000 SMS:** ~$50/month
- **5000 SMS:** ~$250/month

---

## 📞 Twilio Resources

- **Console:** https://console.twilio.com
- **Phone Numbers:** https://console.twilio.com/us1/develop/phone-numbers/manage/search
- **Verified Numbers:** https://console.twilio.com/us1/develop/phone-numbers/manage/verified
- **Documentation:** https://www.twilio.com/docs/sms
- **Support:** https://support.twilio.com

---

## ✅ Quick Commands Reference

```powershell
# Check configuration
.\CHECK_SMS_CONFIG.ps1

# Setup SMS (add phone number)
.\SETUP_SMS.ps1

# Test SMS service
.\TEST_SMS.ps1

# Check backend status
Invoke-WebRequest http://localhost:3000/health
```

---

## 🎯 Next Steps After Configuration

Once SMS is working:

1. ✅ **Test SMS** - Send test message
2. ✅ **Verify Delivery** - Check phone received message
3. ✅ **Test Appointment Flow** - Create appointment, verify SMS sent
4. ✅ **Monitor Logs** - Check backend logs for SMS status
5. ✅ **Production Ready** - SMS service ready for use!

---

**Last Updated:** November 16, 2025  
**Status:** Ready - Just add phone number!

