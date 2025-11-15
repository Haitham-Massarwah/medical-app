# 📧 Namecheap Email Configuration Quick Reference

## 🎯 If Using Namecheap Private Email

Based on the URL you shared (`advancedns`), you're using Namecheap for domain management.

### **Email Server Settings:**
```
SMTP Server: mail.privateemail.com
IMAP Server: mail.privateemail.com
Ports: 587 (SMTP), 993 (IMAP SSL)
Username: haitham.massarwah@medical-appointments.com
```

### **Backend Configuration (`backend/.env`):**
```env
SMTP_HOST=mail.privateemail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=haitham.massarwah@medical-appointments.com
SMTP_PASSWORD=your-email-password-here
EMAIL_FROM=Medical Appointments <haitham.massarwah@medical-appointments.com>
```

### **Outlook Configuration:**
- **Account Type:** IMAP
- **Incoming:** `mail.privateemail.com:993` (SSL)
- **Outgoing:** `mail.privateemail.com:587` (STARTTLS)
- **Username:** `haitham.massarwah@medical-appointments.com`

---

## 🔍 Need DNS Records Info

Please check **Advanced DNS** tab and share:

1. **A Records** - For website hosting
2. **MX Records** - For email routing  
3. **TXT Records** - For email authentication

Once you share the DNS records, I can:
- Configure backend email ✅
- Help fix website DNS ✅
- Set up Outlook ✅

Share the DNS records from Advanced DNS tab! 📋





