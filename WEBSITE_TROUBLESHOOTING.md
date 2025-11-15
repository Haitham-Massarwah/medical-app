# 🔍 Website Troubleshooting Guide

## 🌐 Your Domain Status

**Domain:** `medical-appointments.com`  
**Email:** `haitham.massarwah@medical-appointments.com`  
**Issue:** "Can't be reached"

---

## 🔎 Common Issues & Solutions

### **Issue 1: DNS Not Configured Yet** ⚠️

**Symptom:** "Can't be reached" or "This site can't be reached"

**Cause:** Domain purchased but DNS records not pointing to hosting server

**Solution:**
1. Check your hosting provider's DNS settings
2. Ensure A records point to your server IP
3. Wait 24-48 hours for DNS propagation

---

### **Issue 2: Website Not Deployed**

**Symptom:** Domain resolves but shows blank/default page

**Cause:** Website files not uploaded to hosting

**Solution:**
1. Upload website files to hosting
2. Configure web server (Apache/Nginx)
3. Set up SSL certificate

---

### **Issue 3: Email Service Not Configured**

**Symptom:** Can't receive emails in Outlook

**Solution:** Configure email in hosting cPanel/email panel

---

## 📧 Email Provider Configuration

Since you bought email service as part of hosting:

### **Step 1: Check Email Settings in Hosting Panel**

1. Log in to your hosting provider's control panel (cPanel/Plesk/etc.)
2. Go to "Email Accounts" or "Email" section
3. Find account: `haitham.massarwah@medical-appointments.com`
4. Note down:
   - **Incoming Mail Server (IMAP/POP3)**
   - **Outgoing Mail Server (SMTP)**
   - **Ports** (usually 993 for IMAP SSL, 587 for SMTP)

### **Step 2: Configure Outlook App**

**Settings for Outlook:**
- **Account Type:** IMAP (recommended) or POP3
- **Email:** `haitham.massarwah@medical-appointments.com`
- **Incoming Mail Server:** Check your hosting panel (usually `mail.medical-appointments.com`)
- **Outgoing Mail Server:** Same as incoming (usually `mail.medical-appointments.com`)
- **Ports:**
  - IMAP: 993 (SSL) or 143 (non-SSL)
  - SMTP: 587 (STARTTLS) or 465 (SSL)
- **Username:** `haitham.massarwah@medical-appointments.com`
- **Password:** Your email account password

### **Step 3: Update Backend Configuration**

Once you have email server details from hosting panel, update `backend/.env`:

```env
SMTP_HOST=mail.medical-appointments.com  # From hosting panel
SMTP_PORT=587  # Usually 587 or 465
SMTP_SECURE=false  # false for 587, true for 465
SMTP_USER=haitham.massarwah@medical-appointments.com
SMTP_PASSWORD=your-email-password
EMAIL_FROM=Medical Appointments <haitham.massarwah@medical-appointments.com>
```

---

## 🛠️ Quick Diagnostics

### **Check Domain DNS:**
```powershell
nslookup medical-appointments.com
```

### **Check Website Accessibility:**
```powershell
Test-NetConnection medical-appointments.com -Port 80
```

### **Check Email Server:**
```powershell
Test-NetConnection mail.medical-appointments.com -Port 587
```

---

## 📋 Information I Need From You

To help configure everything properly, please provide:

1. **Hosting Provider Name** (e.g., GoDaddy, Hostinger, Namecheap, etc.)
2. **cPanel/Control Panel Access** (or screenshot of email settings)
3. **Email Server Details:**
   - Incoming server (IMAP)
   - Outgoing server (SMTP)
   - Ports
4. **Website Status:**
   - Is it deployed?
   - What error message exactly?
   - Can you access hosting control panel?

---

## 🎯 Next Steps

1. **Log into your hosting control panel**
2. **Find email settings** - Look for "Email Accounts" or "Email Configuration"
3. **Configure Outlook app** with those settings
4. **Share email server details** - So I can update backend configuration
5. **Check website deployment** - Ensure files are uploaded

Once I have the email server details, I can:
- ✅ Update backend SMTP configuration
- ✅ Help configure Outlook app
- ✅ Test email sending/receiving

**Please share your hosting provider and email server details!** 📧





