# 🔐 Account Setup Guide for Clinics

**Date:** October 31, 2025  
**Purpose:** Guide for setting up accounts and email after installation

---

## 📋 DEFAULT ACCOUNTS CREATED

After installation, the following default accounts are created:

### 👨‍💻 Developer Account
- **Email:** `haitham.massarwah@medical-appointments.com`
- **Password:** `Developer@2024`
- **Role:** `developer`
- **Access:** Full system access

### 👨‍⚕️ Example Doctor Account
- **Email:** `doctor.example@medical-appointments.com`
- **Password:** `Doctor@123`
- **Role:** `doctor`
- **Status:** Example account (can be used or removed)

### 👤 Example Customer Account
- **Email:** `patient.example@medical-appointments.com`
- **Password:** `Patient@123`
- **Role:** `patient` (customer)
- **Status:** Example account (can be used or removed)

---

## 🚨 IMPORTANT: EMAIL FUNCTIONALITY

### Current Status:
**⚠️ Email functionality is DISABLED until test accounts are created**

### Why:
- Prevents accidental emails during setup
- Only allows emails to verified test accounts
- Automatically enables after proper account creation

### What This Means:
- ❌ Invitation emails will NOT be sent
- ❌ Email verification emails will NOT be sent
- ❌ Notification emails will NOT be sent
- ✅ System works normally otherwise
- ✅ All other features function correctly

---

## ✅ CREATING TEST ACCOUNTS

### Step 1: Login as Developer
1. Launch the application
2. Login with: `haitham.massarwah@medical-appointments.com` / `Developer@2024`

### Step 2: Create Test Doctor Account
1. Go to Developer Dashboard
2. Navigate to "Doctors" or "User Management"
3. Create new doctor account:
   - **Suggested Email:** `test.doctor@medical-appointments.com`
   - **Password:** Set a secure password
   - **Role:** `doctor`
   - Fill in doctor details (specialty, etc.)

### Step 3: Create Test Customer Account
1. Still in Developer Dashboard
2. Navigate to "Customers" or "Patients"
3. Create new customer account:
   - **Suggested Email:** `test.customer@medical-appointments.com`
   - **Password:** Set a secure password
   - **Role:** `patient`

### Step 4: Email Functionality Auto-Enables
Once test accounts are created:
- ✅ Email functionality will be automatically enabled
- ✅ Emails can be sent to developer + test accounts
- ✅ Invitation emails will work
- ✅ Email verification will work

---

## 📝 RECOMMENDED TEST ACCOUNTS

For testing and reviewing, create:

### Test Doctor:
- **Email:** `test.doctor@medical-appointments.com` (or your clinic email)
- **Password:** Choose secure password
- **Purpose:** Testing doctor workflows, invitations, payments

### Test Customer:
- **Email:** `test.customer@medical-appointments.com` (or your clinic email)
- **Password:** Choose secure password
- **Purpose:** Testing booking, payments, customer flows

---

## 🔧 MANUAL ACCOUNT CREATION (Alternative)

If you prefer to create accounts via database:

1. **Connect to PostgreSQL:**
   ```bash
   psql -U postgres -d medical_app_db
   ```

2. **Create Doctor Account:**
   ```sql
   -- Hash password first (use bcrypt, 12 rounds)
   -- Then insert user and doctor records
   ```

3. **Or use the seed script:**
   ```bash
   cd backend
   npm run seed
   ```

---

## ⚙️ EMAIL GATE CONFIGURATION

**File:** `backend/src/config/email.gate.ts`

**Allowed Email Addresses:**
- Developer: `haitham.massarwah@medical-appointments.com` (always allowed)
- Test accounts will be added automatically after creation

**Email Gate Status:**
- **Disabled:** Only developer email exists (default after installation)
- **Enabled:** Test accounts have been created and added to allowed list

---

## 📋 CHECKLIST

After installation:

- [ ] Login as developer successfully
- [ ] Verify default accounts exist
- [ ] Create test doctor account via developer dashboard
- [ ] Create test customer account via developer dashboard
- [ ] Verify email functionality is enabled (after test accounts created)
- [ ] Test sending invitation email (should work after test accounts)
- [ ] Change default passwords for security

---

## 🎯 QUICK REFERENCE

**Developer Login:**
```
Email: haitham.massarwah@medical-appointments.com
Password: Developer@2024
```

**Test Accounts to Create:**
1. Test Doctor: `test.doctor@medical-appointments.com`
2. Test Customer: `test.customer@medical-appointments.com`

**Email Status:**
- Before test accounts: ❌ DISABLED
- After test accounts: ✅ ENABLED

---

**Need Help?** See `TROUBLESHOOTING.md` or contact support.




