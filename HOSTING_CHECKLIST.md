# 📋 Hosting & Email Setup Checklist

## 🔑 Information Needed from Hosting Panel

Please check your hosting control panel and provide:

### **1. Hosting Provider Information**
- [ ] Provider Name: ___________________
- [ ] Control Panel Type: ___________________ (cPanel, Plesk, custom)
- [ ] Server IP Address: ___________________

### **2. Email Server Settings**
From "Email Accounts" or "Email Settings" section:

- [ ] **Incoming Mail Server (IMAP):** ___________________
  - Usually: `mail.medical-appointments.com` or `imap.medical-appointments.com`
  
- [ ] **Outgoing Mail Server (SMTP):** ___________________
  - Usually: `mail.medical-appointments.com` or `smtp.medical-appointments.com`

- [ ] **IMAP Port:** ___________________
  - Usually: **993** (SSL) or **143** (non-SSL)

- [ ] **SMTP Port:** ___________________
  - Usually: **587** (STARTTLS) or **465** (SSL)

- [ ] **Email Address:** `haitham.massarwah@medical-appointments.com` ✅
- [ ] **Email Password:** ___________________ (you set this)

### **3. DNS Settings (For Website)**
From "DNS Management" or "Zone Editor":

- [ ] **A Record:** `@` → IP Address: ___________________
- [ ] **A Record:** `www` → IP Address: ___________________
- [ ] **MX Records:** For email routing (usually auto-configured

### **4. Website Files**
- [ ] Website files uploaded? Yes / No
- [ ] FTP/SFTP access configured?
- [ ] Public HTML folder location: ___________________

---

## 🎯 What I'll Do Once You Provide Information

1. ✅ **Update backend/.env** with correct SMTP settings
2. ✅ **Create Outlook configuration guide** specific to your server
3. ✅ **Help configure DNS** for website
4. ✅ **Test email sending/receiving**
5. ✅ **Verify website deployment**

---

## 📞 Quick Access Links

**Where to find these settings:**

### **cPanel (Most Common):**
- Email: `https://your-site.com:2083` → Email Accounts
- DNS: `https://your-site.com:2083` → DNS Zone Editor

### **Plesk:**
- Email: Email Settings
- DNS: DNS Settings

### **Hostinger:**
- Email: Email section
- DNS: DNS Zone Editor

### **GoDaddy:**
- Email: Email & Office Dashboard
- DNS: DNS Management

---

## 🚀 Next Steps

1. **Log into your hosting control panel**
2. **Find email settings** - Look for account: `haitham.massarwah@medical-appointments.com`
3. **Copy email server details** from above checklist
4. **Share the details** with me
5. **I'll configure everything!**

**Once configured, you'll have:**
- ✅ Emails appearing in Outlook app
- ✅ Backend sending emails through your domain
- ✅ Website accessible on your domain
- ✅ Professional email setup

---

**Please share your hosting email server details!** 📧





