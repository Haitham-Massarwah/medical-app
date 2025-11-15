# 🏥 Medical Appointment System

A comprehensive medical appointment booking platform built with Flutter and Node.js/TypeScript.

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.10.0+)
- Node.js (20.x+)
- PostgreSQL
- Git

### Installation

1. **Clone/Open Project:**
   ```bash
   cd C:\Projects\medical-app
   ```

2. **Install Flutter Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Install Backend Dependencies:**
   ```bash
   cd backend
   npm install
   ```

4. **Set Up Environment:**
   - Copy `backend/.env.example` to `backend/.env`
   - Configure database and API keys
   - Edit `ENVIRONMENT.txt` to set Development or Production

5. **Start Backend:**
   ```bash
   cd backend
   npm run dev
   ```

6. **Start Flutter App:**
   ```bash
   flutter run
   ```

---

## 📍 **WORKFLOW**

### ⚠️ **IMPORTANT: Work Locally, Sync at End of Day**

- **Primary Location:** `C:\Projects\medical-app` (LOCAL)
- **Backup Location:** OneDrive (sync at end of day only)
- **Sync Script:** `SYNC_TO_ONEDRIVE.ps1`

**See `WORKFLOW_GUIDE.md` for detailed workflow instructions.**

---

## 🌍 **Environment Switching**

Edit `ENVIRONMENT.txt` in project root:
- `Development` → `http://localhost:3000/api/v1`
- `Production` → `http://66.29.133.192:3000/api/v1`

Restart app after changing.

**See `ENVIRONMENT_SWITCH_GUIDE.md` for details.**

---

## 📋 **Task Tracking**

All tasks are tracked in `AUTOMATED_TASKS.md`.

Update task status:
```powershell
.\UPDATE_TASKS.ps1 -Action complete -TaskNumber 1
```

---

## 🧹 **Cleanup**

Remove garbage files:
```powershell
.\CLEANUP_GARBAGE_FILES.ps1
```

---

## 📚 **Documentation**

- `PROJECT_STATUS_REPORT.md` - Complete project status
- `QUICK_SUMMARY.md` - Quick reference
- `WORKFLOW_GUIDE.md` - Daily workflow guide
- `AUTOMATED_TASKS.md` - Task tracking
- `ENVIRONMENT_SWITCH_GUIDE.md` - Environment switching

---

## 🏗️ **Project Structure**

```
medical-app/
├── lib/                    # Flutter source code
├── backend/               # Node.js/TypeScript backend
├── assets/                # Images, fonts, etc.
├── android/               # Android platform files
├── ios/                   # iOS platform files
├── web/                   # Web platform files
├── windows/               # Windows platform files
├── test/                  # Unit tests
├── integration_test/      # Integration tests
├── DOCUMENTATION/         # Project documentation
└── CLINIC_INSTALLATION/   # Installation scripts
```

---

## 🔧 **Scripts**

- `SYNC_TO_ONEDRIVE.ps1` - Sync to OneDrive backup
- `CLEANUP_GARBAGE_FILES.ps1` - Clean up temporary files
- `UPDATE_TASKS.ps1` - Update task tracker

---

## 📊 **Status**

**Project Health:** 85% Complete

**See `PROJECT_STATUS_REPORT.md` for detailed status.**

---

## 📝 **License**

Private project - All rights reserved

---

**Last Updated:** November 15, 2025

