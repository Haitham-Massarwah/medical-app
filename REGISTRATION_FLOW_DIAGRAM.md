# 📋 Registration Flow - Complete Block Diagram

## 🎯 Overview

This document provides a complete visual representation of the registration process from initial entry to final approval. **No steps are omitted.**

---

## 🔄 Complete Registration Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    REGISTRATION FLOW DIAGRAM                      │
└─────────────────────────────────────────────────────────────────┘

START
  │
  ├─► User Opens Application
  │   │
  │   └─► [Landing Page / Login Page]
  │
  ├─► User Clicks "Register" / "Sign Up"
  │   │
  │   └─► [Registration Selection Page]
  │
  ├─► User Selects Role
  │   │
  │   ├─► [Option 1: Patient Registration]
  │   │   │
  │   │   └─► [Patient Registration Form]
  │   │       │
  │   │       ├─► Step 1: Personal Information
  │   │       │   ├─► First Name (required)
  │   │       │   ├─► Last Name (required)
  │   │       │   ├─► Email (required, validated)
  │   │       │   ├─► Phone (required, validated)
  │   │       │   ├─► Date of Birth (required)
  │   │       │   └─► Preferred Language (required)
  │   │       │
  │   │       ├─► Step 2: Account Security
  │   │       │   ├─► Password (required, min 8 chars)
  │   │       │   ├─► Confirm Password (required, must match)
  │   │       │   └─► Terms & Conditions (required checkbox)
  │   │       │
  │   │       ├─► Step 3: Medical Information (Optional)
  │   │       │   ├─► Allergies
  │   │       │   ├─► Current Medications
  │   │       │   ├─► Emergency Contact Name
  │   │       │   └─► Emergency Contact Phone
  │   │       │
  │   │       └─► [Submit Registration]
  │   │
  │   └─► [Option 2: Doctor Registration]
  │       │
  │       └─► [Doctor Registration Form]
  │           │
  │           ├─► Step 1: Personal Information
  │           │   ├─► First Name (required)
  │           │   ├─► Last Name (required)
  │           │   ├─► Email (required, validated)
  │           │   ├─► Phone (required, validated)
  │           │   └─► Preferred Language (required)
  │           │
  │           ├─► Step 2: Professional Information
  │           │   ├─► Specialty (required, dropdown)
  │           │   ├─► License Number (required)
  │           │   ├─► Education (required, multi-line)
  │           │   ├─► Languages Spoken (required, multi-select)
  │           │   └─► Bio/Description (optional)
  │           │
  │           ├─► Step 3: Account Security
  │           │   ├─► Password (required, min 8 chars)
  │           │   ├─► Confirm Password (required, must match)
  │           │   └─► Terms & Conditions (required checkbox)
  │           │
  │           ├─► Step 4: Practice Settings (Optional)
  │           │   ├─► Clinic Name
  │           │   ├─► Address
  │           │   ├─► Consultation Fee
  │           │   └─► Available Hours
  │           │
  │           └─► [Submit Registration]
  │
  ├─► [Form Validation]
  │   │
  │   ├─► Validation Passes?
  │   │   │
  │   │   ├─► YES ──► Continue
  │   │   │
  │   │   └─► NO ──► [Display Validation Errors]
  │   │       │
  │   │       └─► [User Fixes Errors]
  │   │           │
  │   │           └─► [Re-submit Form]
  │   │
  │   └─► [Check Email Uniqueness]
  │       │
  │       ├─► Email Already Exists?
  │       │   │
  │       │   ├─► YES ──► [Display Error: "Email already registered"]
  │       │   │   │
  │       │   │   └─► [User Enters Different Email]
  │       │   │
  │       │   └─► NO ──► Continue
  │
  ├─► [Backend Processing]
  │   │
  │   ├─► Create User Account
  │   │   ├─► Hash Password (bcrypt)
  │   │   ├─► Generate User ID
  │   │   ├─► Set Role (patient/doctor)
  │   │   ├─► Set Status: "pending_email_verification"
  │   │   └─► Save to Database
  │   │
  │   ├─► Create Role-Specific Profile
  │   │   │
  │   │   ├─► If Patient:
  │   │   │   └─► Create Patient Profile
  │   │   │       ├─► Link to User ID
  │   │   │       ├─► Save Medical Information
  │   │   │       └─► Set Emergency Contacts
  │   │   │
  │   │   └─► If Doctor:
  │   │       └─► Create Doctor Profile
  │   │           ├─► Link to User ID
  │   │           ├─► Save Professional Information
  │   │           ├─► Set Specialty
  │   │           ├─► Set License Number
  │   │           └─► Set Status: "pending_admin_approval"
  │   │
  │   └─► Generate Email Verification Token
  │       ├─► Create Unique Token
  │       ├─► Set Expiration (24 hours)
  │       └─► Save Token to Database
  │
  ├─► [Send Verification Email]
  │   │
  │   ├─► Email Service Called
  │   │   ├─► SMTP Connection Established
  │   │   ├─► Email Template Loaded
  │   │   │   ├─► Subject: "Verify Your Email Address"
  │   │   │   ├─► Body: Verification Link + Instructions
  │   │   │   └─► Language: User's Preferred Language
  │   │   │
  │   │   └─► Email Sent
  │   │
  │   └─► [Email Delivery Status]
  │       │
  │       ├─► Email Sent Successfully?
  │       │   │
  │       │   ├─► YES ──► Continue
  │       │   │
  │       │   └─► NO ──► [Log Error]
  │       │       │
  │       │       └─► [Display Error to User]
  │       │           │
  │       │           └─► [Option: Resend Email]
  │
  ├─► [Registration Confirmation Screen]
  │   │
  │   ├─► Display Message:
  │   │   "Registration successful! Please check your email
  │   │    to verify your account."
  │   │
  │   └─► [User Returns to Login Page]
  │
  ├─► [Email Verification Process]
  │   │
  │   ├─► User Receives Email
  │   │   │
  │   │   └─► [Email Contains Verification Link]
  │   │       │
  │   │       └─► Link Format:
  │   │           https://medical-appointments.com/verify-email?token=XXX
  │   │
  │   ├─► User Clicks Verification Link
  │   │   │
  │   │   └─► [Verification Page Opens]
  │   │
  │   ├─► [Backend Verifies Token]
  │   │   │
  │   │   ├─► Token Valid?
  │   │   │   │
  │   │   │   ├─► YES ──► Continue
  │   │   │   │
  │   │   │   └─► NO ──► [Display Error: "Invalid or Expired Token"]
  │   │   │       │
  │   │   │       └─► [Option: Request New Verification Email]
  │   │   │
  │   │   ├─► Token Not Expired?
  │   │   │   │
  │   │   │   ├─► YES ──► Continue
  │   │   │   │
  │   │   │   └─► NO ──► [Display Error: "Token Expired"]
  │   │   │       │
  │   │   │       └─► [Option: Request New Verification Email]
  │   │   │
  │   │   └─► [Update User Status]
  │   │       │
  │   │       ├─► Set: is_email_verified = true
  │   │       ├─► Set: email_verified_at = current_timestamp
  │   │       ├─► Delete Verification Token
  │   │       └─► Update Database
  │   │
  │   └─► [Email Verification Success Screen]
  │       │
  │       ├─► Display: "Email verified successfully!"
  │       └─► [Redirect to Login Page]
  │
  ├─► [Role-Specific Next Steps]
  │   │
  │   ├─► If Patient:
  │   │   │
  │   │   ├─► [Account Fully Activated]
  │   │   │   │
  │   │   ├─► User Can Login
  │   │   │   │
  │   │   └─► [Access Patient Dashboard]
  │   │
  │   └─► If Doctor:
  │       │
  │       ├─► [Account Status: Pending Admin Approval]
  │       │   │
  │       ├─► [Display Message]:
  │       │   "Your account is pending admin approval.
  │       │    You will receive an email when approved."
  │       │
  │       ├─► [Admin Review Process]
  │       │   │
  │       │   ├─► Admin Receives Notification
  │       │   │   │
  │       │   ├─► Admin Reviews Doctor Profile
  │       │   │   ├─► Checks License Number
  │       │   │   ├─► Verifies Education
  │       │   │   ├─► Reviews Specialty
  │       │   │   └─► Validates Information
  │       │   │
  │       │   ├─► Admin Decision
  │       │   │   │
  │       │   │   ├─► APPROVE ──► Continue
  │       │   │   │
  │       │   │   └─► REJECT ──► [Send Rejection Email]
  │       │   │       │
  │       │   │       └─► [Process Ends - User Must Re-register]
  │       │   │
  │       │   ├─► [Update Doctor Status]
  │       │   │   │
  │       │   │   ├─► Set: status = "active"
  │       │   │   ├─► Set: approved_at = current_timestamp
  │       │   │   └─► Update Database
  │       │   │
  │       │   └─► [Send Approval Email]
  │       │       │
  │       │       ├─► Email Subject: "Account Approved"
  │       │       ├─► Email Body: "Your doctor account has been approved..."
  │       │       └─► Email Sent
  │       │
  │       └─► [Doctor Account Activated]
  │           │
  │           ├─► User Can Login
  │           │
  │           └─► [Access Doctor Dashboard]
  │
  └─► END ──► [User Successfully Registered and Activated]

```

---

## 📊 Registration States

### Patient Registration States:

1. **pending_email_verification** → Email verification required
2. **email_verified** → Account active, can login
3. **active** → Fully operational

### Doctor Registration States:

1. **pending_email_verification** → Email verification required
2. **pending_admin_approval** → Waiting for admin approval
3. **active** → Account approved, can login
4. **rejected** → Application rejected (must re-register)

---

## 🔐 Security Checks (At Each Step)

1. ✅ **Email Format Validation** - RFC 5322 compliant
2. ✅ **Password Strength** - Min 8 chars, complexity requirements
3. ✅ **Email Uniqueness** - No duplicate emails
4. ✅ **Phone Format Validation** - Valid phone number format
5. ✅ **Token Security** - Cryptographically secure tokens
6. ✅ **Token Expiration** - 24-hour expiration
7. ✅ **Rate Limiting** - Prevent spam registrations
8. ✅ **Input Sanitization** - Prevent SQL injection, XSS
9. ✅ **CSRF Protection** - Token-based protection

---

## 📧 Email Templates

### 1. Email Verification Email

**Subject:** "אמת את כתובת האימייל שלך" / "Verify Your Email Address"

**Body:**
```
שלום [First Name],

תודה שנרשמת למערכת התורים הרפואיים.

אנא לחץ על הקישור הבא כדי לאמת את כתובת האימייל שלך:

[Verification Link]

קישור זה תקף למשך 24 שעות.

אם לא נרשמת למערכת, אנא התעלם מהאימייל הזה.

בברכה,
צוות מערכת התורים הרפואיים
```

### 2. Doctor Approval Email

**Subject:** "חשבון הרופא שלך אושר" / "Doctor Account Approved"

**Body:**
```
שלום ד"ר [Last Name],

חשבון הרופא שלך אושר בהצלחה!

כעת אתה יכול להתחבר למערכת ולנהל את התורים שלך.

[Login Link]

בברכה,
צוות מערכת התורים הרפואיים
```

### 3. Doctor Rejection Email

**Subject:** "בקשה לאישור חשבון רופא" / "Doctor Account Application"

**Body:**
```
שלום [First Name] [Last Name],

לצערנו, לא הצלחנו לאשר את בקשתך לחשבון רופא.

סיבה: [Rejection Reason]

אם יש לך שאלות, אנא צור קשר עם התמיכה.

בברכה,
צוות מערכת התורים הרפואיים
```

---

## 🔄 Error Handling

### Common Errors and Solutions:

1. **Email Already Registered**
   - Display: "כתובת אימייל זו כבר רשומה במערכת"
   - Solution: User must use different email or login

2. **Invalid Email Format**
   - Display: "כתובת אימייל לא תקינה"
   - Solution: User corrects email format

3. **Weak Password**
   - Display: "סיסמה חלשה מדי. נדרשות לפחות 8 תווים"
   - Solution: User creates stronger password

4. **Token Expired**
   - Display: "קישור האימות פג תוקף"
   - Solution: User requests new verification email

5. **Network Error**
   - Display: "שגיאת רשת. אנא נסה שוב"
   - Solution: User retries registration

---

## ✅ Registration Completion Criteria

### Patient Registration Complete When:
- ✅ Email verified
- ✅ Account status = "active"
- ✅ Can login successfully

### Doctor Registration Complete When:
- ✅ Email verified
- ✅ Admin approved
- ✅ Account status = "active"
- ✅ Can login successfully

---

## 📝 Registration Data Flow

```
User Input
    │
    ├─► Frontend Validation
    │   │
    │   └─► [Client-Side Checks]
    │
    ├─► API Request (POST /api/v1/users/register)
    │   │
    │   └─► Backend Validation
    │       │
    │       ├─► [Server-Side Checks]
    │       ├─► [Database Checks]
    │       └─► [Security Checks]
    │
    ├─► Database Insert
    │   │
    │   ├─► users table
    │   ├─► patients/doctors table
    │   └─► email_verification_tokens table
    │
    ├─► Email Service
    │   │
    │   └─► SMTP Send
    │
    └─► Response to User
        │
        └─► Success/Error Message
```

---

## 🎯 Summary

**Total Steps:** 15+ (depending on role)

**Key Milestones:**
1. Form submission
2. Email verification
3. Admin approval (doctors only)
4. Account activation

**No steps omitted** - Complete flow from entry to approval documented above.

