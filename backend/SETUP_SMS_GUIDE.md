# Complete SMS Service Setup Guide

## 📱 Step-by-Step SMS Configuration

### Current Status:
- ✅ Twilio Account SID: `AC22fc8395b3e91855cf37fdcb48111d5b`
- ✅ Twilio Auth Token: Configured
- ⚠️ Phone Number: **NEEDS TO BE ADDED**

---

## Step 1: Get Twilio Phone Number

### Option A: Buy Israeli Phone Number (Recommended)

1. **Login to Twilio Console:**
   - URL: https://console.twilio.com
   - Use your Account SID and Auth Token

2. **Navigate to Phone Numbers:**
   - Click: **Phone Numbers** → **Manage** → **Buy a Number**

3. **Search for Israeli Number:**
   - Country: **Israel (+972)**
   - Capabilities: Check ✅ **SMS** and ✅ **Voice**
   - Click: **Search**

4. **Purchase Number:**
   - Select a number
   - Click: **Buy** or **Reserve**
   - Confirm purchase

5. **Copy Phone Number:**
   - Format: `+972501234567` (with country code)
   - Example: `+972501234567`

### Option B: Use Twilio Trial Number (For Testing)

1. **Use Trial Number:**
   - Twilio provides a trial number for testing
   - Check your Twilio Console Dashboard
   - Format: Usually US number like `+15005550006`

2. **Limitations:**
   - Can only send to verified numbers
   - Good for testing only
   - Need to buy real number for production

---

## Step 2: Configure Environment Variables

### Edit `backend/.env` file:

```env
# Twilio SMS Configuration
TWILIO_ACCOUNT_SID=AC22fc8395b3e91855cf37fdcb48111d5b
TWILIO_AUTH_TOKEN=03c3053425a39802b291622555b8c669
TWILIO_PHONE_NUMBER=+972501234567
```

**Replace `+972501234567` with your actual Twilio phone number!**

---

## Step 3: Verify Configuration

### Run Configuration Check:

```powershell
cd C:\Projects\medical-app\backend
.\CHECK_SMS_CONFIG.ps1
```

This script will:
- ✅ Check if phone number is configured
- ✅ Test Twilio connection
- ✅ Send test SMS (if number provided)

---

## Step 4: Test SMS Service

### Manual Test:

```powershell
# Login to backend
$loginBody = '{"email":"haitham.massarwah@medical-appointments.com","password":"Developer@2024"}'
$login = Invoke-RestMethod -Uri "http://localhost:3000/api/v1/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
$token = $login.data.tokens.accessToken

# Test SMS
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

$smsBody = @{
    to = "+972501234567"  # Your phone number (verified in Twilio)
    message = "Test SMS from Medical Appointment System"
    type = "test"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3000/api/v1/notifications/sms" -Method Post -Headers $headers -Body $smsBody
```

---

## Step 5: Verify Phone Number (For Trial)

### If Using Twilio Trial:

1. **Verify Your Phone Number:**
   - Go to: https://console.twilio.com/us1/develop/phone-numbers/manage/verified
   - Click: **Add a new number**
   - Enter your phone number
   - Verify via SMS code

2. **Test Only to Verified Numbers:**
   - Trial accounts can only send to verified numbers
   - Add all test numbers to verified list

---

## 📋 Quick Setup Script

Run this PowerShell script to automate setup:

```powershell
cd C:\Projects\medical-app\backend
.\SETUP_SMS.ps1
```

This will:
1. Check current configuration
2. Prompt for phone number
3. Update .env file
4. Test connection
5. Send test SMS

---

## 🔧 Troubleshooting

### Issue: "Phone number not configured"

**Solution:**
- Add `TWILIO_PHONE_NUMBER` to `.env` file
- Restart backend server

### Issue: "Failed to send SMS"

**Possible Causes:**
1. **Trial Account:** Can only send to verified numbers
   - Solution: Verify recipient number in Twilio Console

2. **Invalid Phone Number Format:**
   - Solution: Use format `+972501234567` (with country code)

3. **Insufficient Credits:**
   - Solution: Add credits to Twilio account

4. **Phone Number Not SMS Enabled:**
   - Solution: Buy number with SMS capability

### Issue: "Authentication failed"

**Solution:**
- Verify Account SID and Auth Token are correct
- Check .env file is loaded correctly
- Restart backend server

---

## ✅ Configuration Checklist

- [ ] Twilio Account created
- [ ] Account SID added to .env
- [ ] Auth Token added to .env
- [ ] Phone number purchased from Twilio
- [ ] Phone number added to .env (`TWILIO_PHONE_NUMBER`)
- [ ] Backend restarted
- [ ] Test SMS sent successfully

---

## 📞 Twilio Resources

- **Console:** https://console.twilio.com
- **Documentation:** https://www.twilio.com/docs/sms
- **Support:** https://support.twilio.com
- **Phone Numbers:** https://console.twilio.com/us1/develop/phone-numbers/manage/search

---

## 💰 Pricing Reference

- **SMS (Israel):** ~$0.05 per message
- **Phone Number:** ~$1-2/month
- **Free Trial:** $15.50 credit included

---

**Last Updated:** November 16, 2025

