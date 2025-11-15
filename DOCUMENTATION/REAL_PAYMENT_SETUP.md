# 🏥 MEDICAL APPOINTMENT SYSTEM - REAL PAYMENT SETUP

## 📋 **REQUIRED INFORMATION FROM YOU**

To make the payment system work with real money, I need the following information:

### 1. **Payment Gateway Credentials**
```
SHVA Payment Gateway:
- Merchant ID: _______________
- Terminal ID: _______________
- API Key: _______________

OR

Cardcom Payment Gateway:
- Terminal Number: _______________
- Username: _______________
- Password: _______________
```

### 2. **Bank Account Information**
```
Bank Name: _______________
Account Number: _______________
Branch Number: _______________
```

### 3. **Business Information**
```
Business Name: _______________
Business Address: _______________
Tax ID (ח.פ.): _______________
Business License: _______________
```

### 4. **Email Configuration**
```
SMTP Host: _______________
SMTP Port: _______________
Email Username: _______________
Email Password: _______________
```

### 5. **System Configuration**
```
Developer Email: _______________
System URL: _______________
JWT Secret Key: _______________
```

## 🔧 **SETUP STEPS**

### Step 1: Contact Payment Processors
1. **Shva**: https://www.shva.co.il
   - Call: +972-3-611-6111
   - Email: info@shva.co.il
   
2. **Cardcom**: https://www.cardcom.co.il
   - Call: +972-3-612-1000
   - Email: info@cardcom.co.il

### Step 2: Get Merchant Account
- Apply for merchant account
- Provide business documents
- Get API credentials
- Test with small amounts

### Step 3: Update Configuration
Replace the placeholder values in `lib/config/real_payment_config.dart`:

```dart
static const String SHVA_MERCHANT_ID = 'YOUR_ACTUAL_MERCHANT_ID';
static const String SHVA_TERMINAL_ID = 'YOUR_ACTUAL_TERMINAL_ID';
static const String SHVA_API_KEY = 'YOUR_ACTUAL_API_KEY';
// ... etc
```

### Step 4: Test Payment System
1. Test with small amounts (₪1-5)
2. Verify money goes to your account
3. Check receipt generation
4. Test email notifications

## 💰 **MONEY FLOW**

```
Customer Card → Payment Gateway → Your Bank Account
     ₪300    →    ₪7.50 fee   →    ₪292.50 net
```

**Commission Rates:**
- Shva: ~2.5% per transaction
- Cardcom: ~2.8% per transaction
- Additional fees for international cards

## 🚀 **CURRENT STATUS**

✅ **Completed:**
- Complete user registration system
- Customer self-registration
- Doctor-created customer accounts
- Email verification system
- Israeli payment gateway integration
- 17% VAT compliance
- Hebrew receipts
- Card-only payments (Visa/Mastercard)

❌ **Needs Your Input:**
- Real payment gateway credentials
- Bank account information
- Business registration details
- Email server configuration

## 📞 **NEXT STEPS**

1. **Provide the required information above**
2. **I'll update the configuration files**
3. **Test the payment system**
4. **Deploy to production**

**The app is ready - just needs your real payment credentials!** 🎉


