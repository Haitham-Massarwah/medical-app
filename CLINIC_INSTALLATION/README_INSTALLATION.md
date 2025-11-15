# 🏥 Medical Appointment System - Clinic Installation Guide

**Version:** 1.0  
**Date:** November 1, 2025  
**For:** Clinic Computers - Doctor Installation  
**Login:** Automatic role detection from database

---

## 📋 OVERVIEW

This installation package contains everything needed to install and run the Medical Appointment System on clinic computers.

**What's Included:**
- ✅ Windows Desktop Application (Standalone)
- ✅ Backend Server Setup (Optional - for standalone mode)
- ✅ Database Setup (PostgreSQL)
- ✅ Configuration Files
- ✅ Installation Scripts

---

## 🖥️ SYSTEM REQUIREMENTS

### Minimum Requirements:
- **OS:** Windows 10 or Windows 11 (64-bit)
- **RAM:** 4 GB minimum (8 GB recommended)
- **Storage:** 2 GB free space
- **Internet:** Required for initial setup and updates
- **Network:** Stable internet connection

### Software Requirements:
- **PostgreSQL 15+** (will be installed automatically)
- **Node.js 18+** (for backend server - will be installed automatically)
- **Microsoft Visual C++ Redistributable** (auto-installed)

---

## 🚀 QUICK INSTALLATION (RECOMMENDED)

### For Non-Technical Users:

1. **Double-click:** `INSTALL_CLINIC.bat`
2. **Follow the on-screen instructions**
3. **Wait for installation to complete** (10-15 minutes)
4. **Launch the application**

**That's it!** ✅

---

## 📦 MANUAL INSTALLATION (Step-by-Step)

### STEP 1: Install PostgreSQL Database

**Option A: Automatic Installation**
- Run: `INSTALL_POSTGRESQL.bat`
- Follow the prompts

**Option B: Manual Installation**
1. Run: `postgresql-installer.exe` (if included)
2. Default settings are recommended
3. Remember the password you set!

### STEP 2: Setup Backend Server

1. **Double-click:** `SETUP_BACKEND.bat`
2. Wait for Node.js and dependencies to install
3. Configuration will be done automatically

### STEP 3: Install Desktop Application

1. **Double-click:** `INSTALL_APP.bat`
2. Choose installation location (default: `C:\MedicalAppointmentSystem`)
3. Wait for installation to complete

### STEP 4: First Run Setup

1. Launch the application from Start Menu or desktop shortcut
2. Follow the first-time setup wizard
3. Enter your clinic information
4. Create your admin/doctor account

---

## 🔧 CONFIGURATION

### Database Configuration

The system will automatically configure the database connection. No manual setup needed!

**If manual configuration is required:**
- Edit: `backend\.env` file
- See: `CONFIGURATION_GUIDE.md` for details

### Backend Server Configuration

- Default port: `3000`
- Default database: `medical_app_db`
- Configuration file: `backend\.env`

**To change settings:**
1. Open `backend\.env`
2. Edit the values
3. Restart the backend server

---

## 🎯 POST-INSTALLATION

### After Installation:

1. **Test the Connection:**
   - Launch the application
   - Login with developer account:
     - Email: `haitham.massarwah@medical-appointments.com`
     - Password: `Developer@2024`
   - Verify all features work

2. **Create Test Accounts:**
   - ⚠️ **IMPORTANT:** Email functionality is DISABLED until test accounts are created
   - Login as developer
   - Go to Developer Dashboard → User Management
   - Create test doctor account (recommended: `test.doctor@medical-appointments.com`)
   - Create test customer account (recommended: `test.customer@medical-appointments.com`)
   - Email functionality will automatically enable after test accounts are created
   - See: `ACCOUNT_SETUP_GUIDE.md` for detailed instructions

3. **Create User Accounts for Staff:**
   - Login as developer/doctor
   - Go to User Management
   - Create accounts for clinic staff

4. **Configure Settings:**
   - Set up appointment types
   - Configure payment options
   - Customize clinic information
   - Configure email settings (in `backend/.env`)

---

## 🚨 TROUBLESHOOTING

### Application Won't Start

**Check:**
- Backend server is running
- PostgreSQL service is running
- No firewall blocking ports 3000 and 5432

**Solution:**
- Run: `CHECK_INSTALLATION.bat`
- Or see: `TROUBLESHOOTING.md`

### Database Connection Error

**Check:**
- PostgreSQL is running
- Default credentials are correct
- Port 5432 is not blocked

**Solution:**
- Run: `FIX_DATABASE.bat`

### Backend Server Not Starting

**Check:**
- Node.js is installed (version 18+)
- Dependencies are installed
- Port 3000 is available

**Solution:**
- Run: `REINSTALL_BACKEND.bat`

---

## 📞 SUPPORT

**For technical support:**
- Email: support@medicalapp.com
- Phone: [Your Support Number]
- Documentation: See `DOCUMENTATION` folder

---

## 🔄 UPDATES

**To update the application:**
1. Download the latest installation package
2. Run: `UPDATE_SYSTEM.bat`
3. Follow the prompts

---

## 📝 INSTALLATION CHECKLIST

After installation, verify:

- [ ] Desktop application launches successfully
- [ ] Backend server is running
- [ ] Database connection works
- [ ] Can login with admin account
- [ ] Can create appointments
- [ ] All features are accessible

---

## ✅ INSTALLATION COMPLETE!

Once installation is complete:
1. Launch the application from **Start Menu** or **Desktop**
2. Login with your credentials
3. Start managing appointments!

**Welcome to Medical Appointment System!** 🎉

---

**Installation Date:** ___________  
**Installed By:** ___________  
**Clinic Name:** ___________  

---

**Need Help?** See `TROUBLESHOOTING.md` or contact support.

