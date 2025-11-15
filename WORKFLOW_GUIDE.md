# 🔄 Daily Workflow Guide

## 📍 **WORKING LOCATION**

### ✅ **PRIMARY: `C:\Projects\medical-app`** (LOCAL)
- **All development work happens here**
- **Faster performance**
- **No sync conflicts**
- **Better IDE performance**

### 💾 **BACKUP: OneDrive** (End of Day Only)
- **Location:** `C:\Users\hitha\OneDrive\Desktop\Haitham-Works\App`
- **Sync:** Only at end of day
- **Purpose:** Backup and archive

---

## 🌅 **START OF DAY**

1. ✅ Open project: `C:\Projects\medical-app`
2. ✅ Check `ENVIRONMENT.txt` - Set to Development or Production
3. ✅ Pull latest changes (if using Git)
4. ✅ Start backend: `cd backend && npm run dev`
5. ✅ Start Flutter app: `flutter run`

---

## 💻 **DURING THE DAY**

### Working on Features:
- ✅ All code changes in `C:\Projects\medical-app`
- ✅ Test locally
- ✅ Commit changes (if using Git)

### Environment Switching:
- ✅ Edit `ENVIRONMENT.txt`:
  - `Development` → `http://localhost:3000/api/v1`
  - `Production` → `http://66.29.133.192:3000/api/v1`
- ✅ Restart app after changing

### Task Tracking:
- ✅ Update tasks: `.\UPDATE_TASKS.ps1 -Action start -TaskNumber 1`
- ✅ Complete tasks: `.\UPDATE_TASKS.ps1 -Action complete -TaskNumber 1`
- ✅ View progress: Check `AUTOMATED_TASKS.md`

---

## 🌙 **END OF DAY**

### 1. **Save All Work**
- ✅ Save all files
- ✅ Commit changes (if using Git)
- ✅ Update task tracker

### 2. **Sync to OneDrive**
```powershell
cd C:\Projects\medical-app
.\SYNC_TO_ONEDRIVE.ps1
```

This will:
- ✅ Sync all code directories (`lib`, `backend`, `assets`, etc.)
- ✅ Sync configuration files
- ✅ Sync documentation
- ✅ Exclude temporary files and build artifacts

### 3. **Verify Sync**
- ✅ Check OneDrive folder has latest files
- ✅ Verify important files are synced

---

## 📋 **QUICK COMMANDS**

### Start Backend:
```powershell
cd C:\Projects\medical-app\backend
npm run dev
```

### Start Flutter App:
```powershell
cd C:\Projects\medical-app
flutter run
```

### Switch Environment:
1. Edit `ENVIRONMENT.txt`
2. Change to `Production` or `Development`
3. Restart app

### Update Task Status:
```powershell
# Start a task
.\UPDATE_TASKS.ps1 -Action start -TaskNumber 1

# Complete a task
.\UPDATE_TASKS.ps1 -Action complete -TaskNumber 1 -Notes "Completed successfully"

# Block a task
.\UPDATE_TASKS.ps1 -Action block -TaskNumber 1 -Notes "Waiting on dependency"
```

### Clean Up Files:
```powershell
.\CLEANUP_GARBAGE_FILES.ps1
```

### Sync to OneDrive:
```powershell
.\SYNC_TO_ONEDRIVE.ps1
```

---

## 📊 **TASK TRACKING**

### View All Tasks:
- Open `AUTOMATED_TASKS.md`
- See progress, priorities, and status

### Task Numbers:
1. Cleanup garbage files
2. Write comprehensive tests
3. Organize documentation
4. Optimize app performance
5. Security audit
6. Set up CI/CD pipeline
7. Add logging and monitoring
8. Improve error handling
9. Mobile optimization

---

## ⚠️ **IMPORTANT NOTES**

1. **Always work in local folder** (`C:\Projects\medical-app`)
2. **Don't edit OneDrive files directly** - They're backup only
3. **Sync at end of day** - Keeps backup updated
4. **Update tasks** - Track your progress
5. **Check environment** - Make sure `ENVIRONMENT.txt` is correct

---

## 🎯 **DAILY CHECKLIST**

### Morning:
- [ ] Open local project folder
- [ ] Check environment setting
- [ ] Start backend server
- [ ] Start Flutter app
- [ ] Review tasks for the day

### During Day:
- [ ] Work on tasks
- [ ] Update task status
- [ ] Test changes
- [ ] Commit work (if using Git)

### End of Day:
- [ ] Save all files
- [ ] Update task tracker
- [ ] Run sync script
- [ ] Verify sync completed
- [ ] Close project

---

**Remember:** Work locally, sync at end of day! 🚀

