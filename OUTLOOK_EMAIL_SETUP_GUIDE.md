# 📧 Outlook Email Setup Guide

## ✅ Email Provider Changed to Outlook/Office 365

I've updated your configuration to use **Outlook** as the email provider!

---

## 🔧 Configuration Details

### **Outlook SMTP Settings:**

| Setting | Value |
|---------|-------|
| **SMTP Host** | `smtp.office365.com` |
| **SMTP Port** | `587` |
| **SMTP Secure** | `false` (uses STARTTLS) |
| **Email** | Your Outlook email address |
| **Password** | Your Outlook password |

---

## 📝 Setup Steps

### **Step 1: Get Your Outlook Email Address**
- Your Outlook email: `your-email@outlook.com` (or `@hotmail.com`, `@live.com`)
- Or Office 365 business email: `your-email@yourcompany.com`

### **Step 2: Update Backend Configuration**

I've created `backend/.env` file with Outlook configuration. Now you need to:

1. **Open:** `backend/.env`
2. **Update these lines:**
   ```env
   SMTP_USER=your-email@outlook.com
   SMTP_PASSWORD=your-outlook-password
   EMAIL_FROM=Medical Appointments <your-email@outlook.com>
   ```

### **Step 3: If Using Office 365 (Business Email)**

If you're using Office 365 with a business account:

1. **Enable SMTP AUTH** (if disabled by admin):
   - Go to: https://admin.microsoft.com
   - Navigate to: Settings → Mail → SMTP AUTH
   - Enable "SMTP AUTH enabled"

2. **Or use App Password** (if 2FA enabled):
   - Go to: https://myaccount.microsoft.com/security
   - Click: "Security info" → "Add sign-in method"
   - Select: "App password"
   - Generate password and use it in `SMTP_PASSWORD`

---

## 🔐 Outlook Password Setup

### **Option A: Regular Password (Personal Outlook)**
- Use your normal Outlook password
- Works for @outlook.com, @hotmail.com, @live.com accounts

### **Option B: App Password (If 2FA Enabled)**
1. Go to: https://myaccount.microsoft.com/security
2. Enable "Two-step verification" if not already enabled
3. Go to "App passwords"
4. Generate new app password for "Mail"
5. Use the generated password (16 characters, no spaces)

### **Option C: Office 365 (Business)**
If admin has disabled basic auth:
1. Ask your IT admin to enable SMTP AUTH
2. Or use Microsoft Graph API (more complex)
3. Or request app-specific password

---

## 🧪 Test Your Configuration

### **1. Restart Backend Server:**
```powershell
cd backend
npm run dev
```

### **2. Check Backend Logs:**
Watch for email connection errors or success messages

### **3. Test Email Sending:**
Try registering a new user or triggering a password reset to test email

---

## ✅ Final Configuration

Your `backend/.env` should have:
```env
SMTP_HOST=smtp.office365.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=your-email@outlook.com
SMTP_PASSWORD=your-actual-password
EMAIL_FROM=Medical Appointments <your-email@outlook.com>
```

**Replace:**
- `your-email@outlook.com` → Your actual Outlook email
- `your-actual-password` → Your Outlook password or app password

---

## 🚨 Troubleshooting

### **Error: "Invalid login"**
- ✅ Check email address is correct
- ✅ Verify password is correct
- ✅ Try app password if 2FA is enabled
- ✅ Make sure account is not locked

### **Error: "Connection timeout"**
- ✅ Check firewall allows port 587
- ✅ Try port 25 (if available)
- ✅ Verify SMTP settings are correct

### **Error: "Authentication failed"**
- ✅ Enable SMTP AUTH in Office 365 admin
- ✅ Use app password instead of regular password
- ✅ Check if account requires MFA

### **For Office 365 Business:**
If SMTP AUTH is disabled by admin:
- Contact IT admin to enable it
- Or request app-specific password
- Or use alternative email provider

---

## 📊 Quick Reference

**Personal Outlook (@outlook.com):**
- ✅ Works with regular password
- ✅ Works with app password (if 2FA enabled)
- ✅ Port 587 recommended

**Office 365 Business:**
- ✅ May need admin to enable SMTP AUTH
- ✅ May require app password
- ✅ Same port 587

---

## 🎯 Next Steps

1. ✅ **Edit `backend/.env`** - Update with your Outlook credentials
2. ✅ **Restart backend** - `npm run dev`
3. ✅ **Test email** - Try sending a test email
4. ✅ **Check logs** - Verify no errors

Once configured, your system will send all emails through Outlook! 📧

---

## 📞 Need Help?

If you encounter issues:
1. Check backend logs for specific error messages
2. Verify your Outlook credentials are correct
3. Try using an app password instead of regular password
4. For Office 365, ensure SMTP AUTH is enabled

Your email system is now configured for Outlook! 🚀





