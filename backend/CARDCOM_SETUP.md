# Cardcom Payment Integration Setup

## Overview

This document explains how to set up and test the Cardcom payment integration for the Medical Appointment Management System.

---

## Prerequisites

1. **Cardcom Test Account**
   - Username: `CardTest1994`
   - Password: `Terminaltest2026`
   - Login: https://secure.cardcom.solutions/LogInNew.aspx

2. **API Credentials**
   - Log in to Cardcom test account
   - Go to: **הגדרות** → **הגדרות חברה ומשתמשים** → **ניהול מפתחות API לממשקים**
   - Copy your API credentials:
     - Terminal Number
     - API Key (if available)
     - Username
     - Password

3. **Test Card**
   - Card Number: `4580000000000000`
   - Expiry: `12/30` (December 2030)
   - CVV: Any 3-4 digits

---

## Environment Configuration

Add the following variables to your `.env` file:

```env
# Cardcom Payment Gateway
CARDCOM_USERNAME=CardTest1994
CARDCOM_PASSWORD=Terminaltest2026
CARDCOM_TERMINAL_NUMBER=your_terminal_number_here
CARDCOM_API_KEY=your_api_key_here
CARDCOM_BASE_URL=https://secure.cardcom.solutions
```

**For Production:**
- Use production credentials from Cardcom
- Update `CARDCOM_BASE_URL` if different
- Ensure `NODE_ENV=production`

---

## Installation

1. **Install Dependencies**
   ```bash
   cd backend
   npm install axios
   ```

2. **Build Backend**
   ```bash
   npm run build
   ```

3. **Start Backend**
   ```bash
   npm run dev
   ```

---

## Testing

### Option 1: PowerShell Test Script

Run the test script:
```powershell
cd backend
.\TEST_CARDCOM.ps1
```

This script will:
1. Login to get authentication token
2. Check Cardcom service status
3. Test payment with test card
4. Report results

### Option 2: Manual API Test

1. **Get Authentication Token**
   ```powershell
   $loginBody = @{
       email = "haitham.massarwah@medical-appointments.com"
       password = "Developer@2024"
   } | ConvertTo-Json
   
   $response = Invoke-RestMethod -Uri "http://localhost:3000/api/v1/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
   $token = $response.data.token
   ```

2. **Check Cardcom Status**
   ```powershell
   $headers = @{
       "Authorization" = "Bearer $token"
       "Content-Type" = "application/json"
   }
   
   Invoke-RestMethod -Uri "http://localhost:3000/api/v1/payments/cardcom/status" -Method Get -Headers $headers
   ```

3. **Test Payment**
   ```powershell
   $paymentBody = @{
       appointmentId = "TEST-123"
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

## API Endpoints

### 1. Check Service Status
```
GET /api/v1/payments/cardcom/status
```

**Response:**
```json
{
  "success": true,
  "data": {
    "configured": true,
    "testMode": true
  }
}
```

### 2. Process Payment (Direct Charge)
```
POST /api/v1/payments/cardcom/charge
```

**Request Body:**
```json
{
  "appointmentId": "uuid",
  "amount": 100.00,
  "currency": "ILS",
  "cardNumber": "4580000000000000",
  "cvv": "123",
  "expirationMonth": "12",
  "expirationYear": "2030",
  "holderName": "John Doe",
  "holderEmail": "john@example.com",
  "holderPhone": "+972501234567",
  "holderId": "123456789",
  "description": "Appointment payment"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "transactionId": "uuid",
    "cardcomTransactionId": "cardcom-txn-id",
    "approvalNumber": "123456",
    "cardLast4Digits": "0000",
    "paymentRecord": {...}
  },
  "message": "Payment processed successfully"
}
```

### 3. Create Payment Link (Low Profile)
```
POST /api/v1/payments/cardcom/link
```

**Request Body:**
```json
{
  "appointmentId": "uuid",
  "amount": 100.00,
  "currency": "ILS",
  "successUrl": "https://yourapp.com/success",
  "errorUrl": "https://yourapp.com/error",
  "cancelUrl": "https://yourapp.com/cancel",
  "holderName": "John Doe",
  "holderEmail": "john@example.com"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "paymentUrl": "https://secure.cardcom.solutions/LowProfile.aspx?code=...",
    "lowProfileCode": "code"
  }
}
```

### 4. Process Refund
```
POST /api/v1/payments/cardcom/refund
```

**Request Body:**
```json
{
  "cardcomTransactionId": "cardcom-txn-id",
  "amount": 50.00,
  "reason": "Cancellation"
}
```

### 5. Get Transaction Status
```
GET /api/v1/payments/cardcom/status/:transactionId
```

### 6. Test Payment
```
POST /api/v1/payments/cardcom/test
```

Uses test card automatically for quick testing.

---

## Integration with Frontend

### Flutter/Dart Example

```dart
Future<Map<String, dynamic>> processCardcomPayment({
  required String appointmentId,
  required double amount,
  required Map<String, String> cardDetails,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/payments/cardcom/charge'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'appointmentId': appointmentId,
      'amount': amount,
      'currency': 'ILS',
      'cardNumber': cardDetails['cardNumber'],
      'cvv': cardDetails['cvv'],
      'expirationMonth': cardDetails['expirationMonth'],
      'expirationYear': cardDetails['expirationYear'],
      'holderName': cardDetails['holderName'],
      'holderEmail': cardDetails['holderEmail'],
    }),
  );
  
  return jsonDecode(response.body);
}
```

---

## Error Handling

### Common Error Codes

- **ResponseCode: 0** - Success
- **ResponseCode: -1** - General error
- **ResponseCode: 1** - Invalid credentials
- **ResponseCode: 2** - Card declined
- **ResponseCode: 3** - Insufficient funds
- **ResponseCode: 4** - Invalid card number
- **ResponseCode: 5** - Expired card

### Error Response Format

```json
{
  "success": false,
  "error": "Error message",
  "responseCode": 2,
  "responseMessage": "Card declined"
}
```

---

## Security Considerations

1. **Never store card details**
   - Card numbers should never be stored in database
   - Use tokens for recurring payments

2. **PCI DSS Compliance**
   - Cardcom handles PCI compliance
   - Use Low Profile for redirect-based payments (no PCI required)
   - Direct Debit requires PCI certificate

3. **HTTPS Only**
   - Always use HTTPS in production
   - Never send card details over HTTP

4. **Token Storage**
   - Save Cardcom tokens securely
   - Use tokens for future payments (with user consent)

---

## Troubleshooting

### Issue: Authentication Failed

**Solution:**
- Verify username and password are correct
- Check terminal number is set
- Ensure API credentials are from test account

### Issue: Payment Failed

**Solution:**
- Check card number format (no spaces)
- Verify expiration date format (MMYY)
- Ensure CVV is correct
- Check test card is valid

### Issue: Service Not Configured

**Solution:**
- Set environment variables
- Restart backend server
- Check `.env` file exists and is loaded

---

## Production Deployment

1. **Get Production Credentials**
   - Contact Cardcom for production account
   - Obtain production terminal number
   - Get production API keys

2. **Update Environment**
   ```env
   NODE_ENV=production
   CARDCOM_USERNAME=production_username
   CARDCOM_PASSWORD=production_password
   CARDCOM_TERMINAL_NUMBER=production_terminal
   CARDCOM_BASE_URL=https://secure.cardcom.solutions
   ```

3. **Test Thoroughly**
   - Test with real cards (small amounts)
   - Test refunds
   - Test error scenarios
   - Monitor logs

---

## Support

- **Cardcom Support:** 03-9436100 (press 2 for developer support)
- **Cardcom Email:** dev@secure.cardcom.co.il
- **API Documentation:** https://secure.cardcom.solutions/swagger/index.html?url=/swagger/v11/swagger.json
- **Support Portal:** https://support.cardcom.solutions/hc/he

---

## Next Steps

After successful testing:

1. ✅ Integrate Cardcom into Flutter payment UI
2. ✅ Add Cardcom as payment option alongside Stripe
3. ✅ Update payment method selection
4. ✅ Test end-to-end payment flow
5. ✅ Deploy to production

---

**Last Updated:** November 15, 2025  
**Status:** Ready for Testing

