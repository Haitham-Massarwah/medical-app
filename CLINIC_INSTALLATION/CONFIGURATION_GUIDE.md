# 🔧 Configuration Guide

This guide explains how to configure the Medical Appointment System after installation.

---

## 📍 Configuration Files

### Backend Configuration: `backend\.env`

Location: `C:\MedicalAppointmentSystem\Backend\.env`

```env
# Server Configuration
NODE_ENV=production
PORT=3000

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=medical_app_db
DB_USER=postgres
DB_PASSWORD=YourPasswordHere

# JWT Security
JWT_SECRET=your-secret-key-change-in-production
JWT_EXPIRES_IN=7d

# Email Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password

# CORS (for web access)
CORS_ORIGIN=http://localhost:3000
```

### Application Configuration: `App\config.json`

Location: `C:\MedicalAppointmentSystem\App\config.json`

```json
{
  "apiUrl": "http://localhost:3000",
  "environment": "production",
  "version": "1.0.0"
}
```

---

## 🔐 Security Settings

### Change Database Password

1. Edit `backend\.env`
2. Update `DB_PASSWORD=YourNewPassword`
3. Update PostgreSQL user password:
   ```sql
   ALTER USER postgres WITH PASSWORD 'YourNewPassword';
   ```
4. Restart backend server

### Change JWT Secret

1. Generate a secure random string
2. Edit `backend\.env`
3. Update `JWT_SECRET=YourSecureRandomString`
4. Restart backend server

---

## 📧 Email Configuration

### ⚠️ Email Gate Status

**Important:** Email functionality is **DISABLED** by default until test accounts are created.

**To Enable Email:**
1. Create test doctor account via developer dashboard
2. Create test customer account via developer dashboard
3. Email functionality will automatically enable

**Current Allowed Emails:**
- Developer: `haitham.massarwah@medical-appointments.com` (always allowed)
- Test accounts (after creation)

**Email Gate File:** `backend/src/config/email.gate.ts`

---

### Gmail Setup

1. Enable 2-Factor Authentication on Gmail
2. Generate App Password: https://myaccount.google.com/apppasswords
3. Edit `backend\.env`:
   ```env
   SMTP_HOST=smtp.gmail.com
   SMTP_PORT=587
   SMTP_USER=your-email@gmail.com
   SMTP_PASS=your-16-char-app-password
   ```
4. Restart backend server

### Other Email Providers

**Outlook/Hotmail:**
```env
SMTP_HOST=smtp-mail.outlook.com
SMTP_PORT=587
```

**Custom SMTP:**
```env
SMTP_HOST=mail.yourdomain.com
SMTP_PORT=587
SMTP_USER=your-username
SMTP_PASS=your-password
```

---

## 🌐 Network Configuration

### Change Backend Port

1. Edit `backend\.env`
2. Change `PORT=3000` to desired port (e.g., `PORT=8080`)
3. Update `App\config.json`: `"apiUrl": "http://localhost:8080"`
4. Restart backend server

### Allow Network Access

To allow access from other computers:

1. Edit `backend\.env`
2. Change `CORS_ORIGIN=http://localhost:3000` to your network IP or `*`
3. Update firewall to allow port 3000
4. Update `App\config.json` with server IP

---

## 📊 Database Configuration

### Change Database Name

1. Create new database: `CREATE DATABASE new_db_name;`
2. Edit `backend\.env`: `DB_NAME=new_db_name`
3. Run migrations: `npm run migrate`
4. Restart backend server

### Remote Database

1. Edit `backend\.env`:
   ```env
   DB_HOST=remote-server-ip
   DB_PORT=5432
   DB_NAME=medical_app_db
   DB_USER=remote_user
   DB_PASSWORD=remote_password
   ```
2. Ensure PostgreSQL allows remote connections
3. Update firewall rules

---

## 🚀 Performance Tuning

### Increase Database Connections

Edit `backend\src\config\database.ts`:
```typescript
pool: {
  min: 5,
  max: 20
}
```

### Enable Caching

Add to `backend\.env`:
```env
REDIS_HOST=localhost
REDIS_PORT=6379
```

---

## ✅ Verify Configuration

After making changes:

1. Restart backend server
2. Run `CHECK_INSTALLATION.bat`
3. Test application login
4. Verify all features work

---

## 📞 Need Help?

See `TROUBLESHOOTING.md` or contact support.

