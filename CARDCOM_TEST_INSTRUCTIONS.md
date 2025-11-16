# Cardcom Payment Integration - Test Instructions

## 🚀 Quick Start Testing

### Prerequisites
- ✅ Backend server running (`npm run dev` in backend folder)
- ✅ Terminal number from Cardcom account
- ✅ Test credentials ready

---

## Step-by-Step Testing

### Step 1: Get Terminal Number

1. **Login to Cardcom:**
   - URL: https://secure.cardcom.solutions/LogInNew.aspx
   - Username: `CardTest1994`
   - Password: `Terminaltest2026`

2. **Navigate to API Settings:**
   - Click: **הגדרות** (Settings)
   - Click: **הגדרות חברה ומשתמשים** (Company and User Settings)
   - Click: **ניהול מפתחות API לממשקים** (API Key Management)

3. **Copy Terminal Number:**
   - Find your terminal number
   - Copy it (you'll need it for Step 2)

---

### Step 2: Configure Environment

**Option A: Use Script (Recommended)**
```powershell
cd C:\Projects\medical-app\backend
.\ADD_CARDCOM_ENV.ps1
```

Then edit `backend/.env` and add your terminal number:
```env
CARDCOM_TERMINAL_NUMBER=your_terminal_number_here
```

**Option B: Manual Edit**
Edit `backend/.env` and add:
```env
CARDCOM_USERNAME=CardTest1994
CARDCOM_PASSWORD=Terminaltest2026
CARDCOM_TERMINAL_NUMBER=your_terminal_number_here
CARDCOM_BASE_URL=https://secure.cardcom.solutions
```

---

### Step 3: Start Backend (if not running)

```powershell
cd C:\Projects\medical-app\backend
npm run dev
```

Wait for: `Server running on port 3000`

---

### Step 4: Run Test Script

```powershell
cd C:\Projects\medical-app\backend
.\TEST_CARDCOM.ps1
```

---

## Expected Results

### ✅ Success Scenario

```
✅ Payment Test SUCCESSFUL!

Payment Details:
   Transaction ID: uuid
   Cardcom Transaction ID: cardcom-txn-id
   Approval Number: 123456
   Card Last 4 Digits: 0000

✅ Cardcom integration is working correctly!
   You can continue using Cardcom for payments.
```

**If you see this:** ✅ **Cardcom is working! Continue with this system.**

---

### ❌ Failure Scenario

```
❌ Payment Test FAILED
   Error: [error message]

⚠️  Possible Issues:
   1. Cardcom credentials not configured
   2. Terminal number missing
   3. API endpoint incorrect
   4. Network/connectivity issues
```

**If you see this:** ⚠️ **Check the issues listed and troubleshoot.**

---

## Troubleshooting

### Issue: "Service not configured"

**Solution:**
- Check `.env` file has all Cardcom variables
- Verify terminal number is correct
- Restart backend server

### Issue: "Authentication failed"

**Solution:**
- Verify username/password are correct
- Check terminal number matches Cardcom account
- Ensure API credentials are from test account

### Issue: "Payment failed"

**Solution:**
- Check test card number: `4580000000000000`
- Verify expiry: `12/30`
- Check CVV format (3-4 digits)
- Review backend logs for detailed error

### Issue: "Network error"

**Solution:**
- Check internet connection
- Verify Cardcom API URL is accessible
- Check firewall settings
- Try accessing Cardcom website directly

---

## Manual API Testing

If script doesn't work, test manually:

### 1. Check Service Status

```powershell
# Login first
$loginBody = @{
    email = "haitham.massarwah@medical-appointments.com"
    password = "Developer@2024"
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/v1/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
$token = $loginResponse.data.token

# Check Cardcom status
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

Invoke-RestMethod -Uri "http://localhost:3000/api/v1/payments/cardcom/status" -Method Get -Headers $headers
```

### 2. Test Payment

```powershell
$paymentBody = @{
    appointmentId = "TEST-$(Get-Date -Format 'yyyyMMddHHmmss')"
    amount = 1.00
    currency = "ILS"
    cardNumber = "4580000000000000"
    cvv = "123"
    expirationMonth = "12"
    expirationYear = "2030"
    holderName = "Test User"
    holderEmail = "test@example.com"
    description = "Test Payment"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3000/api/v1/payments/cardcom/charge" -Method Post -Headers $headers -Body $paymentBody
```

---

## Decision Matrix

### ✅ If Test Succeeds:

**Decision:** ✅ **USE CARDCOM**

**Next Steps:**
1. ✅ Integration complete - Cardcom works
2. ✅ Integrate into Flutter payment UI
3. ✅ Add Cardcom as payment option
4. ✅ Test end-to-end payment flow
5. ✅ Deploy to production

**Why Cardcom:**
- ✅ Israeli payment gateway (better for local market)
- ✅ Native ILS support
- ✅ Local support (Hebrew, local phone)
- ✅ Familiar to Israeli users
- ✅ Potentially lower fees

---

### ❌ If Test Fails:

**Decision:** ⚠️ **TROUBLESHOOT OR CONSIDER ALTERNATIVE**

**Troubleshooting Steps:**
1. Check all credentials are correct
2. Verify terminal number
3. Review backend logs
4. Test Cardcom API directly
5. Contact Cardcom support if needed

**Alternative Options:**
- **Shva** - Another Israeli payment gateway
- **Bit** - Israeli payment solution
- **Stripe** - International (already integrated)
- **PayPal** - International option

---

## Support Contacts

- **Cardcom Support:** 03-9436100 (press 2 for developer support)
- **Cardcom Email:** dev@secure.cardcom.co.il
- **Cardcom API Docs:** https://secure.cardcom.solutions/swagger/index.html?url=/swagger/v11/swagger.json
- **Cardcom Support Portal:** https://support.cardcom.solutions/hc/he

---

## Test Checklist

Before testing, ensure:
- [ ] Backend server is running
- [ ] Terminal number obtained from Cardcom
- [ ] Environment variables configured
- [ ] Test card details ready
- [ ] Network connection active

After testing:
- [ ] Test payment succeeded or failed?
- [ ] Error messages reviewed?
- [ ] Backend logs checked?
- [ ] Decision made: Continue with Cardcom or alternative?

---

**Ready to Test!** 🚀

Run `.\TEST_CARDCOM.ps1` and let me know the results!

