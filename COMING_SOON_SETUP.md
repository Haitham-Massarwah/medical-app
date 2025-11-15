# 🚀 Coming Soon Page Setup

## ✅ Implementation Complete

The Coming Soon page is now configured to:
- ✅ Show **only in production** (release builds)
- ✅ Show **blurred login page** in the background
- ✅ **Hidden in development** (debug builds) - you see the full app

---

## 🎯 How It Works

### Development Mode (Local Testing)
```powershell
cd C:\Projects\medical-app
.\flutter\bin\flutter.bat run -d chrome
# OR
.\flutter\bin\flutter.bat run -d windows
```
**Result**: Shows **normal app** (Login page, full functionality)
- No Coming Soon page
- Full access to all features
- Perfect for development and testing

### Production Mode (Public Website)
```powershell
cd C:\Projects\medical-app
.\flutter\bin\flutter.bat build web --release
```
**Result**: Shows **Coming Soon page** with blurred background
- Coming Soon message displayed
- Blurred login page visible behind
- Public sees this when visiting the website

---

## 🔧 Configuration

**File**: `lib/main.dart` (line 65)

```dart
const bool IS_PRE_RELEASE = true; // Set to false when ready for public release
```

**Logic**:
- `kDebugMode` (development) → Always shows normal app
- `kReleaseMode` (production) → Shows Coming Soon if `IS_PRE_RELEASE = true`

---

## 📋 Next Steps

### 1. Test Locally (Development)
```powershell
cd C:\Projects\medical-app
.\flutter\bin\flutter.bat run -d chrome
```
You should see the **normal login page** (no Coming Soon)

### 2. Build for Production
```powershell
cd C:\Projects\medical-app
.\flutter\bin\flutter.bat build web --release
```

### 3. Deploy to Server
```powershell
# Create zip
Compress-Archive -Path "build\web\*" -DestinationPath "build\web-production.zip" -Force

# Upload to server (using WinSCP or scp)
scp build\web-production.zip root@66.29.133.192:/var/www/
```

### 4. On Server
```bash
ssh root@66.29.133.192
cd /var/www
unzip -o web-production.zip -d medical-frontend
chown -R www-data:www-data medical-frontend
```

### 5. Test Production Website
Visit: `https://medical-appointments.com`
You should see: **Coming Soon page with blurred background**

---

## 🎨 Visual Effect

**Production Website Shows**:
- Blurred login page in background (sigmaX: 15, sigmaY: 15)
- Coming Soon message on top
- Professional white overlay
- Contact email displayed

**Development Shows**:
- Normal login page
- Full app functionality
- No blur, no Coming Soon

---

## 🔄 When Ready for Public Release

**To disable Coming Soon**:
1. Edit `lib/main.dart`
2. Change: `const bool IS_PRE_RELEASE = false;`
3. Rebuild: `flutter build web --release`
4. Redeploy to server

---

## ✅ Summary

| Mode | Command | Shows |
|------|---------|-------|
| **Development** | `flutter run` | Normal app (no Coming Soon) |
| **Production** | `flutter build --release` | Coming Soon with blur |

**Perfect for**:
- ✅ Testing locally without Coming Soon
- ✅ Showing Coming Soon to public visitors
- ✅ Easy toggle when ready for release

