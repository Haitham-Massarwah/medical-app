# 📧 Email Provider Configuration

## 🔍 Current Email Provider Setup

### **Provider:** Gmail (Google SMTP)

**Configuration Details:**

| Setting | Value | Description |
|---------|-------|-------------|
| **SMTP Host** | `smtp.gmail.com` | Gmail's SMTP server |
| **SMTP Port** | `587` | TLS/STARTTLS port (secure) |
| **SMTP Secure** | `false` | Using STARTTLS, not SSL |
| **Email Address** | `haitham.massarwah@medical-appointments.com` | Sender email |
| **Authentication** | App Password required | Gmail requires app-specific password |

---

## 📋 Current Configuration Files

### **Backend Configuration:**
**File:** `backend/env.example`
```env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=haitham.massarwah@medical-appointments.com
SMTP_PASSWORD=your-app-password
EMAIL_FROM=Medical Appointments <haitham.massarwah@medical-appointments.com>
```

### **Code Implementation:**
**File:** `backend/src/services/email.service.ts`
- Uses **Nodemailer** library
- Configured for Gmail SMTP
- Supports email templates
- Handles verification emails, notifications, etc.

---

## 🔐 Gmail Setup Requirements

### **1. Enable 2-Step Verification**
1. Go to: https://myaccount.google.com/security
2. Enable "2-Step Verification"
3. This is required to generate App Password

### **2. Generate App Password**
1. Go to: https://myaccount.google.com/apppasswords
2. Select "Mail" and "Other (Custom name)"
3. Enter name: "Medical Appointment System"
4. Click "Generate"
5. Copy the 16-character password (no spaces)
6. Use this password in `SMTP_PASSWORD`

### **3. Update Backend Configuration**
Create or update `backend/.env`:
```env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=haitham.massarwah@medical-appointments.com
SMTP_PASSWORD=xxxx xxxx xxxx xxxx  # ← 16-character app password
EMAIL_FROM=haitham.massarwah@medical-appointments.com
EMAIL_FROM_NAME=Medical Appointment System
```

---

## 🌐 Alternative Email Providers

You can switch to other providers by changing the SMTP settings:

### **Outlook/Office 365:**
```env
SMTP_HOST=smtp.office365.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=your-email@outlook.com
SMTP_PASSWORD=your-password
```

### **Custom Domain Email (cPanel, etc.):**
```env
SMTP_HOST=mail.yourdomain.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=noreply@yourdomain.com
SMTP_PASSWORD=your-password
```

### **SendGrid:**
```env
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=apikey
SMTP_PASSWORD=your-sendgrid-api-key
```

### **Mailgun:**
```env
SMTP_HOST=smtp.mailgun.org
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=your-mailgun-username
SMTP_PASSWORD=your-mailgun-password
```

### **Amazon SES:**
```env
SMTP_HOST=email-smtp.region.amazonaws.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=your-ses-username
SMTP_PASSWORD=your-ses-password
```

---

## ✅ Setup Checklist for Gmail

- [ ] Create `backend/.env` file (if not exists)
- [ ] Copy configuration from `env.example`
- [ ] Enable 2-Step Verification on Gmail account
- [ ] Generate App Password for Gmail
- [ ] Update `SMTP_PASSWORD` in `.env` file
- [ ] Test email sending

---

## 🧪 Test Email Configuration

To test if email is working:

1. **Start backend server:**
   ```bash
   cd backend
   npm run dev
   ```

2. **Test email endpoint** (if available):
   ```bash
   curl -X POST http://localhost:3000/api/v1/test/email \
     -H "Content-Type: application/json" \
     -d '{"to": "test@example.com"}'
   ```

3. **Check backend logs** for email status

---

## 📊 Email Features Using This Provider

Your system uses this email provider for:

1. ✅ **Email Verification** - Send verification links to new users
2. ✅ **Password Reset** - Send reset password links
3. ✅ **Appointment Reminders** - Notify users before appointments
4. ✅ **Confirmations** - Send appointment confirmation emails
5. ✅ **Notifications** - System notifications and alerts
6. ✅ **Welcome Emails** - New user welcome messages

---

## 🔄 Switching Email Provider

If you want to switch from Gmail to another provider:

1. **Update backend/.env:**
   ```env
   SMTP_HOST=new-provider-smtp.com
   SMTP_PORT=587
   SMTP_USER=your-email@domain.com
   SMTP_PASSWORD=your-password
   ```

2. **Restart backend server:**
   ```bash
   # Stop current server
   # Start again
   npm run dev
   ```

3. **Test email functionality**

**No code changes needed** - the email service automatically uses the new configuration!

---

## ⚠️ Important Notes

### **Gmail Limitations:**
- **Daily sending limit:** 500 emails/day (free account)
- **Rate limit:** ~100 emails/hour
- **App Password required:** Cannot use regular password
- **From address:** Must match Gmail account email

### **For Production:**
Consider switching to:
- **SendGrid** (12,000 free emails/month)
- **Mailgun** (5,000 free emails/month)
- **Amazon SES** (62,000 free emails/month)
- **Custom domain email** (unlimited)

---

## 🎯 Summary

**Current Provider:** 📧 **Gmail (Google SMTP)**

**Status:**
- ✅ Configured in backend
- ⚠️ Needs App Password setup
- ✅ Ready to use once password configured
- ✅ Easy to switch to other providers

**Next Steps:**
1. Generate Gmail App Password
2. Update `backend/.env` with password
3. Restart backend server
4. Test email sending

The email system is **ready to use** as soon as you configure the App Password! 🚀





