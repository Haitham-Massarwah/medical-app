# Cardcom & Twilio Fixes - Complete Guide

## 🔧 Cardcom Authentication Fix

### Current Issue:
- ✅ Terminal Number: 1000 (configured)
- ✅ Credentials: Configured
- ❌ Authentication: Failing with Cardcom API

### Possible Solutions:

#### Solution 1: Verify API Endpoint
The Cardcom API endpoint might be different. Check:
- Current: `/api/v11/Token`
- Alternative: `/api/Token` or `/Token`

#### Solution 2: Check Request Format
Cardcom might require URL-encoded form data instead of JSON:

```typescript
// Try URL-encoded instead of JSON
const formData = new URLSearchParams();
formData.append('Username', this.config.username);
formData.append('Password', this.config.password);
formData.append('TerminalNumber', String(this.config.terminalNumber));

const response = await this.axiosInstance.post(endpoint, formData, {
  headers: {
    'Content-Type': 'application/x-www-form-urlencoded',
  },
});
```

#### Solution 3: Contact Cardcom Support
- **Phone:** 03-9436100 (press 2 for developer support)
- **Email:** dev@secure.cardcom.co.il
- **Ask for:**
  - Correct API endpoint URL
  - Authentication method (Username/Password vs API Name/Password)
  - Request format (JSON vs URL-encoded)
  - Terminal number format (string vs number)

#### Solution 4: Test with Postman
1. Create new request to Cardcom API
2. Test authentication endpoint directly
3. Verify request format and headers
4. Get exact error response from Cardcom

---

## 📱 Twilio SMS & Notifications Status

### ✅ Current Status:

**Twilio Credentials Found:**
- ✅ Account SID: `AC22fc8395b3e91855cf37fdcb48111d5b`
- ✅ Auth Token: `03c3053425a39802b291622555b8c669`
- ⚠️ Phone Number: **NOT SET**
- ⚠️ WhatsApp Number: **NOT SET**

### 🔧 What Needs to Be Done:

#### Step 1: Get Twilio Phone Number

1. **Login to Twilio Console:**
   - URL: https://console.twilio.com
   - Use Account SID and Auth Token

2. **Purchase Phone Number:**
   - Go to: Phone Numbers → Buy a Number
   - Select: Israel (+972)
   - Choose number with SMS capabilities
   - Purchase (free trial includes credits)

3. **Add to .env:**
   ```env
   TWILIO_PHONE_NUMBER=+972501234567
   ```

#### Step 2: Configure WhatsApp (Optional)

1. **Twilio WhatsApp Sandbox:**
   - Go to: Messaging → Try it out → Send a WhatsApp message
   - Use sandbox number: `whatsapp:+14155238886`
   - Join sandbox by sending code to Twilio

2. **Or Apply for WhatsApp Business API:**
   - Contact Twilio support
   - Apply for WhatsApp Business API access
   - Get dedicated WhatsApp number

3. **Add to .env:**
   ```env
   TWILIO_WHATSAPP_NUMBER=whatsapp:+14155238886
   ```

#### Step 3: Test SMS

```powershell
# After adding phone number, test SMS:
cd C:\Projects\medical-app\backend

# Login first
$loginBody = '{"email":"haitham.massarwah@medical-appointments.com","password":"Developer@2024"}'
$login = Invoke-RestMethod -Uri "http://localhost:3000/api/v1/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
$token = $login.data.tokens.accessToken

# Test SMS
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

$smsBody = @{
    to = "+972501234567"
    message = "Test SMS from Medical App"
    type = "test"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3000/api/v1/notifications/sms" -Method Post -Headers $headers -Body $smsBody
```

---

## 📊 Implementation Status

### Cardcom:
- ✅ Code: Complete
- ✅ Terminal Number: Configured (1000)
- ✅ Credentials: Configured
- ⚠️ Authentication: Needs API format verification

### Twilio:
- ✅ Code: Complete
- ✅ Account SID: Configured
- ✅ Auth Token: Configured
- ⚠️ Phone Number: **NEEDS TO BE ADDED**
- ⚠️ WhatsApp Number: **NEEDS TO BE ADDED**

---

## 🚀 Quick Fixes

### For Cardcom:
1. Contact Cardcom support (03-9436100)
2. Verify API endpoint and format
3. Test with Postman
4. Update authentication code

### For Twilio:
1. Login to Twilio Console
2. Buy phone number (+972)
3. Add to `.env`: `TWILIO_PHONE_NUMBER=+972501234567`
4. Restart backend
5. Test SMS

**Time Required:** ~5 minutes for Twilio phone number

---

## ✅ Summary

**Cardcom:** ⚠️ Needs API authentication format verification  
**Twilio:** ⚠️ Needs phone number configuration

Both systems are fully implemented - just need final configuration!

---

**Last Updated:** November 16, 2025

