# 🤖 AUTOMATED SETUP GUIDE

## ✅ YES! Database Setup Can Be Automated!

I've created an automated setup script that will:
1. ✅ Check if PostgreSQL is installed
2. ✅ Offer to install via Docker if needed
3. ✅ Create the database automatically
4. ✅ Generate secure configuration (.env file)
5. ✅ Install all dependencies
6. ✅ Run database migrations
7. ✅ Verify everything works

---

## 🚀 QUICK START (2 Minutes)

### Step 1: Open PowerShell in Backend Folder

```powershell
cd C:\Users\hitha\OneDrive\Desktop\Haitham-Works\App\backend
```

### Step 2: Run the Automated Setup

```powershell
.\setup-database.ps1
```

### Step 3: Follow the Prompts

The script will ask you:
- Database host (default: localhost)
- Database port (default: 5432)
- Database name (default: medical_appointment_dev)
- Database username (default: postgres)
- Database password (you enter this)

**That's it!** The script does everything else automatically.

---

## 📋 WHAT THE SCRIPT DOES

### 1. Checks PostgreSQL Installation
```
✅ PostgreSQL is installed
or
❌ PostgreSQL not found → Offers Docker option
```

### 2. Tests Database Connection
```
Testing connection with your credentials...
✅ Connection successful!
```

### 3. Creates Database
```
Creating database 'medical_appointment_dev'...
✅ Database created!
```

### 4. Generates Configuration
```
Creating .env file with secure settings...
✅ Configuration file created!
```

### 5. Installs Dependencies
```
Installing Node.js packages...
✅ Dependencies installed!
```

### 6. Runs Migrations
```
Creating all database tables...
✅ Tables created successfully!
```

### 7. Verification
```
✅ SETUP COMPLETE!
Your database is ready! 🎉
```

---

## 🐳 OPTION: Use Docker (No Manual Install)

If you don't want to install PostgreSQL manually, the script can use Docker:

```powershell
# The script will ask:
Do you want to use Docker? (y/n): y

# Enter a password, and it automatically:
✅ Downloads PostgreSQL Docker image
✅ Creates container
✅ Starts database
✅ Configures everything
```

**Requirements:** Docker Desktop installed on Windows

---

## 🔧 MANUAL SETUP (If Script Fails)

### Option 1: Install PostgreSQL Manually

1. **Download PostgreSQL**
   - Visit: https://www.postgresql.org/download/windows/
   - Download latest version (15 or 16)

2. **Install**
   - Run installer
   - Use default settings
   - **Remember the password** you set for 'postgres' user
   - Default port: 5432

3. **Run Setup Script**
   ```powershell
   cd backend
   .\setup-database.ps1
   ```

### Option 2: Use Docker

```powershell
# Install Docker Desktop first
# Then run:
docker run --name medical-postgres ^
  -e POSTGRES_PASSWORD=yourpassword ^
  -e POSTGRES_DB=medical_appointment_dev ^
  -p 5432:5432 ^
  -d postgres:15

# Then run setup script
cd backend
.\setup-database.ps1
```

---

## 📝 WHAT YOU GET

After running the setup script, you'll have:

### ✅ `.env` File (Auto-generated)
```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=medical_appointment_dev
DB_USER=postgres
DB_PASSWORD=yourpassword
JWT_SECRET=auto_generated_secure_key
# ... and more
```

### ✅ Database with 13 Tables
- users
- doctors
- patients
- specialties
- appointments
- payments
- notifications
- tenants
- audit_logs
- reviews
- medical_records
- doctor_working_hours
- notification_preferences

### ✅ Ready to Run
```powershell
npm run dev

# Output:
🚀 Server running on port 3000
📝 Environment: development
🔗 API Base URL: http://localhost:3000/api/v1
🏥 Medical Appointment System Backend Ready!
```

---

## 🧪 TESTING AFTER SETUP

### Test 1: Health Check
```powershell
# Open browser or run:
curl http://localhost:3000/health

# Should return:
{
  "status": "OK",
  "timestamp": "2025-10-20T...",
  "uptime": 5.123
}
```

### Test 2: Create a User (API Test)
```powershell
# Using PowerShell:
$body = @{
    email = "test@example.com"
    password = "Test123456"
    first_name = "Test"
    last_name = "User"
    role = "patient"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3000/api/v1/auth/register" `
    -Method Post `
    -Body $body `
    -ContentType "application/json"
```

### Test 3: Login
```powershell
$loginBody = @{
    email = "test@example.com"
    password = "Test123456"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3000/api/v1/auth/login" `
    -Method Post `
    -Body $loginBody `
    -ContentType "application/json"
```

---

## ⚠️ TROUBLESHOOTING

### Error: "psql: command not found"
**Solution:** PostgreSQL not in PATH

```powershell
# Add to PATH manually:
$env:Path += ";C:\Program Files\PostgreSQL\15\bin"

# Or restart computer after PostgreSQL install
```

### Error: "Connection refused"
**Solution:** PostgreSQL not running

```powershell
# Check if running:
Get-Service -Name postgresql*

# Start service:
Start-Service postgresql-x64-15
```

### Error: "Database already exists"
**Solution:** Database exists but empty

```powershell
# Drop and recreate:
psql -U postgres -c "DROP DATABASE medical_appointment_dev;"
.\setup-database.ps1
```

### Error: "Permission denied"
**Solution:** Run as Administrator

```powershell
# Right-click PowerShell → Run as Administrator
cd backend
.\setup-database.ps1
```

---

## 🎯 AFTER SUCCESSFUL SETUP

### You Can:
1. ✅ Start the backend server (`npm run dev`)
2. ✅ Test all API endpoints
3. ✅ Create users, doctors, patients
4. ✅ Book appointments
5. ✅ Everything works!

### Optional Next Steps:
1. ⏳ Configure email (add SMTP credentials to .env)
2. ⏳ Configure SMS (add Twilio credentials to .env)
3. ⏳ Configure payments (add Stripe keys to .env)
4. ⏳ Connect Flutter frontend
5. ⏳ Deploy to production

---

## 📊 SETUP TIME ESTIMATE

| Step | Time |
|------|------|
| Run setup script | 2-3 minutes |
| PostgreSQL install (if needed) | 5-10 minutes |
| Total | 5-15 minutes |

**With Docker:** 3-5 minutes total!

---

## ✨ BENEFITS OF AUTOMATED SETUP

✅ **No manual configuration** - Script does it all  
✅ **Secure by default** - Auto-generates secure keys  
✅ **Error checking** - Verifies each step  
✅ **Helpful messages** - Clear instructions  
✅ **Idempotent** - Safe to run multiple times  
✅ **Cross-platform ready** - Works on Windows (PowerShell)  

---

## 🚀 READY TO START?

### Just run:

```powershell
cd C:\Users\hitha\OneDrive\Desktop\Haitham-Works\App\backend
.\setup-database.ps1
```

**Follow the prompts, and you'll be up and running in 5 minutes!** 🎉

---

## 📞 NEED HELP?

If setup script fails:
1. Check `TROUBLESHOOTING.md`
2. Try manual setup above
3. Check if PostgreSQL/Docker is installed
4. Verify admin permissions

---

**Questions? Just ask!** I'm here to help! 😊

*Last Updated: October 20, 2025*



