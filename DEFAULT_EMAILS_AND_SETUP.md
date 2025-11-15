# 📧 Default Emails & Email Setup Guide

**Date:** October 31, 2025

---

## 🔑 YOUR DEVELOPER ACCOUNT

**Email:** `haitham.massarwah@medical-appointments.com`  
**Password:** `Developer@2024`  
**Role:** `developer`  
**Status:** ✅ Active

**This is your main account with full system access.**

---

## 🧪 TEST ACCOUNTS NEEDED

You requested to create **2 test accounts** for testing and reviewing:

### 👨‍⚕️ Test Doctor Account
- **Suggested Email:** `test.doctor@medical-appointments.com`
- **Suggested Password:** `DoctorTest@2025`
- **Purpose:** Testing doctor workflows, invitations, payments

### 👤 Test Customer Account
- **Suggested Email:** `test.customer@medical-appointments.com`
- **Suggested Password:** `CustomerTest@2025`
- **Purpose:** Testing booking, payments, customer flows

---

## 🔒 EMAIL GATE STATUS

**⚠️ Email functionality is currently DISABLED** until test accounts are created.

### Current Behavior:
- ❌ No emails will be sent (invitations, verifications, etc.)
- ❌ Email service silently fails (no errors thrown)
- ✅ System continues to work normally
- ✅ Email gate will auto-enable after test accounts are created

### Why:
To prevent accidental emails during testing/review phase before test accounts exist.

---

## 🚀 HOW TO CREATE TEST ACCOUNTS

### Option 1: Use the PowerShell Script (Recommended)

1. **Review suggested emails above** (or customize them)

2. **Run the script:**
   ```powershell
   .\CREATE_TEST_ACCOUNTS.ps1
   ```

3. **Or customize emails:**
   ```powershell
   .\CREATE_TEST_ACCOUNTS.ps1 `
     -DoctorEmail "your.doctor@email.com" `
     -DoctorPassword "YourPassword123!" `
     -CustomerEmail "your.customer@email.com" `
     -CustomerPassword "YourPassword123!"
   ```

4. **Complete the setup:**
   ```bash
   cd backend
   npm run seed
   ```

### Option 2: Manual Creation via Developer Dashboard

1. Login as developer: `haitham.massarwah@medical-appointments.com`
2. Go to Developer Dashboard → User Management
3. Create Doctor account
4. Create Customer account

### Option 3: Direct Database Insert

Use the seed file: `backend/src/database/seeds/create_test_accounts.ts`

---

## 📋 EMAIL GATE CONFIGURATION

**File:** `backend/src/config/email.gate.ts`

**Allowed Email Addresses:**
- ✅ Developer: `haitham.massarwah@medical-appointments.com` (always allowed)
- ⏳ Test Doctor: (will be added after creation)
- ⏳ Test Customer: (will be added after creation)

**Email Gate Logic:**
- Email is **disabled** if only developer email exists
- Email is **enabled** once test accounts are added to allowed list
- Only emails to allowed addresses will be sent
- All other emails are silently blocked (no errors)

---

## ✅ AFTER CREATING TEST ACCOUNTS

Once test accounts are created:

1. **Email gate will be automatically updated** with new addresses
2. **Email functionality will be enabled**
3. **Emails will work for:**
   - Developer account (always)
   - Test doctor account
   - Test customer account
   - Any addresses added to allowed list

4. **Email will still be blocked for:**
   - Any addresses not in the allowed list
   - This prevents accidental emails during development

---

## 📝 CURRENT ACCOUNT LIST

### Active Accounts:
1. ✅ **Developer** - `haitham.massarwah@medical-appointments.com`

### To Be Created:
2. ⏳ **Test Doctor** - (to be specified)
3. ⏳ **Test Customer** - (to be specified)

### Old Example Accounts (Can be removed):
- `doctor.example@medical-appointments.com` (can be removed)
- `patient.example@medical-appointments.com` (can be removed)

---

## 🎯 NEXT STEPS

1. **Review the suggested test account emails**
2. **Confirm or customize the email addresses**
3. **Run:** `CREATE_TEST_ACCOUNTS.ps1`
4. **Email functionality will be automatically enabled**

---

**Current Status:** Email functionality is **DISABLED** until test accounts are created.

**After creating test accounts:** Email functionality will be **ENABLED** automatically.




