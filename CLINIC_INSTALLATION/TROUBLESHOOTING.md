# 🔧 Troubleshooting Guide

Common issues and solutions for the Medical Appointment System.

---

## ❌ Application Won't Start

### Issue: "Application failed to start"

**Solutions:**
1. Check if backend server is running:
   - Open: `START_BACKEND.bat`
   - Verify it shows "Server running on port 3000"

2. Check Windows Firewall:
   - Allow ports 3000 and 5432
   - Allow application through firewall

3. Reinstall Visual C++ Redistributable:
   - Download from Microsoft website
   - Install x64 version

4. Check application logs:
   - Location: `C:\MedicalAppointmentSystem\App\logs\`

---

## ❌ Database Connection Error

### Issue: "Cannot connect to database"

**Solutions:**
1. Check PostgreSQL is running:
   ```bat
   sc query postgresql
   ```
   If not running:
   ```bat
   net start postgresql
   ```

2. Verify credentials in `backend\.env`:
   - `DB_HOST=localhost`
   - `DB_PORT=5432`
   - `DB_USER=postgres`
   - `DB_PASSWORD=your-password`

3. Test connection manually:
   ```bat
   psql -U postgres -h localhost -p 5432
   ```

4. Reset PostgreSQL password:
   - Edit: `C:\Program Files\PostgreSQL\15\data\pg_hba.conf`
   - Change to: `trust` (temporary)
   - Restart PostgreSQL
   - Change password: `ALTER USER postgres WITH PASSWORD 'NewPassword';`
   - Change back to: `md5`
   - Restart PostgreSQL

---

## ❌ Backend Server Won't Start

### Issue: "Error: Cannot find module"

**Solutions:**
1. Reinstall dependencies:
   ```bat
   cd C:\MedicalAppointmentSystem\Backend
   npm install
   ```

2. Rebuild backend:
   ```bat
   npm run build
   ```

3. Check Node.js version:
   ```bat
   node --version
   ```
   Must be 18.0.0 or higher

4. Check `.env` file exists and is valid

---

## ❌ Port Already in Use

### Issue: "Error: Port 3000 already in use"

**Solutions:**
1. Find process using port:
   ```bat
   netstat -ano | findstr :3000
   ```
   Kill the process:
   ```bat
   taskkill /PID <process_id> /F
   ```

2. Or change port in `backend\.env`:
   ```env
   PORT=3001
   ```
   Update `App\config.json`:
   ```json
   "apiUrl": "http://localhost:3001"
   ```

---

## ❌ Installation Script Fails

### Issue: "Access Denied" or "Permission Error"

**Solutions:**
1. Run as Administrator:
   - Right-click script
   - Select "Run as Administrator"

2. Check antivirus:
   - Temporarily disable antivirus
   - Run installation
   - Re-enable antivirus

3. Check disk space:
   - Ensure at least 2 GB free space

---

## ❌ Slow Performance

### Issue: Application is slow

**Solutions:**
1. Close other applications
2. Check RAM usage (should have 4GB+ free)
3. Check database connection pool size
4. Enable caching (Redis)
5. Check network latency (if using remote database)

---

## ❌ Email Not Working

### Issue: Invitation emails not sending

**Solutions:**
1. Verify email configuration in `backend\.env`
2. For Gmail: Use App Password (not regular password)
3. Check SMTP port (587 for TLS, 465 for SSL)
4. Verify firewall allows SMTP outbound
5. Check backend logs: `C:\MedicalAppointmentSystem\Backend\logs\`

---

## ❌ Can't Login

### Issue: "Invalid credentials"

**Solutions:**
1. Use default credentials:
   - Developer: `haitham.massarwah@medical-appointments.com` / `Developer@2024`
   - Doctor: `doctor.example@medical-appointments.com` / `Doctor@123`
   - Customer: `patient.example@medical-appointments.com` / `Patient@123`

2. Reset password:
   - Contact administrator
   - Or reset via database

3. Check database connection
4. Verify backend server is running

---

## 🔄 Reset Everything

If nothing works, reset installation:

1. Stop all services
2. Uninstall PostgreSQL (optional)
3. Delete: `C:\MedicalAppointmentSystem`
4. Re-run: `INSTALL_CLINIC.bat`

---

## 📞 Get Help

If issues persist:
- Check logs: `C:\MedicalAppointmentSystem\Backend\logs\`
- Run: `CHECK_INSTALLATION.bat`
- Contact support with error messages

---

## 📋 Quick Diagnostic Commands

```bat
:: Check PostgreSQL
psql --version
sc query postgresql

:: Check Node.js
node --version
npm --version

:: Check Backend
cd C:\MedicalAppointmentSystem\Backend
npm list

:: Check Ports
netstat -ano | findstr :3000
netstat -ano | findstr :5432

:: Test Database Connection
psql -U postgres -h localhost -p 5432 -c "SELECT 1;"

:: Test Backend API
curl http://localhost:3000/api/health
```

---

**Last Updated:** October 31, 2025

