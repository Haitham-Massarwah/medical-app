# Medical Appointment System - Setup Guide

## 🚀 Quick Start Options

### Option 1: Install Flutter (Recommended for Full Development)

#### Step 1: Download Flutter
1. Visit: https://docs.flutter.dev/get-started/install/windows
2. Download Flutter SDK (latest stable version)
3. Extract to `C:\flutter` (or your preferred location)

#### Step 2: Add Flutter to PATH
1. Open **System Properties** → **Environment Variables**
2. Under **System Variables**, find and select **Path**
3. Click **Edit** → **New**
4. Add: `C:\flutter\bin` (or your Flutter SDK bin path)
5. Click **OK** to save
6. **Restart your terminal/IDE**

#### Step 3: Verify Installation
```powershell
# Open a new PowerShell window
flutter doctor

# Accept Android licenses if prompted
flutter doctor --android-licenses

# Enable web support
flutter config --enable-web
```

#### Step 4: Install Dependencies
```powershell
# Navigate to project directory
cd C:\Users\Haitham.Massawah\OneDrive\App

# Get all packages
flutter pub get

# Run the app
flutter run -d chrome
```

---

### Option 2: Quick Manual Installation Script

Run this in PowerShell (as Administrator):

```powershell
# Create a temporary directory
$tempDir = "$env:TEMP\flutter_install"
New-Item -ItemType Directory -Force -Path $tempDir

# Download Flutter SDK
Write-Host "Downloading Flutter SDK..." -ForegroundColor Green
$flutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.9-stable.zip"
$flutterZip = "$tempDir\flutter_windows.zip"
Invoke-WebRequest -Uri $flutterUrl -OutFile $flutterZip

# Extract Flutter
Write-Host "Extracting Flutter..." -ForegroundColor Green
Expand-Archive -Path $flutterZip -DestinationPath "C:\" -Force

# Add to PATH (User level)
Write-Host "Adding Flutter to PATH..." -ForegroundColor Green
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*C:\flutter\bin*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;C:\flutter\bin", "User")
}

Write-Host "Flutter installed successfully!" -ForegroundColor Green
Write-Host "Please restart your terminal and run: flutter doctor" -ForegroundColor Yellow

# Clean up
Remove-Item -Path $tempDir -Recurse -Force
```

---

### Option 3: Use Web Demo (No Installation Required)

I've created a simplified HTML demo that you can run immediately:

```powershell
# Navigate to project directory
cd C:\Users\Haitham.Massawah\OneDrive\App

# Start a simple web server (if you have Python)
python -m http.server 8080

# Or use Node.js http-server
npx http-server -p 8080
```

Then open: http://localhost:8080

---

## 🔧 After Flutter Installation

### 1. Get Dependencies
```powershell
flutter pub get
```

### 2. Run the App
```powershell
# Run on web
flutter run -d chrome

# Run on Windows desktop (if enabled)
flutter run -d windows

# Build for web
flutter build web
```

### 3. Fix Any Issues
```powershell
# Check for issues
flutter doctor -v

# Clean and rebuild
flutter clean
flutter pub get
```

---

## 🌐 Running on Different Platforms

### Web (Chrome)
```powershell
flutter run -d chrome
```

### Web Server (Any browser)
```powershell
flutter run -d web-server --web-port 8080
# Then open: http://localhost:8080
```

### Windows Desktop
```powershell
flutter config --enable-windows-desktop
flutter create --platforms windows .
flutter run -d windows
```

---

## 📦 Project Dependencies

The project uses these main packages:
- **flutter_bloc** - State management
- **dio** - HTTP client
- **hive** - Local storage
- **intl** - Internationalization
- **table_calendar** - Calendar widget
- **flutter_localizations** - Multi-language support

All dependencies will be installed with `flutter pub get`.

---

## 🐛 Common Issues & Solutions

### Issue: "flutter: command not found"
**Solution**: Restart your terminal after adding Flutter to PATH

### Issue: "Unable to find git in your PATH"
**Solution**: Install Git from https://git-scm.com/download/win

### Issue: "Android SDK not found"
**Solution**: 
```powershell
flutter doctor --android-licenses
# Or skip Android: flutter config --no-analytics
```

### Issue: Service Worker Error (Web)
**Solution**: The web files I created should fix this. If not:
```powershell
flutter create --platforms web .
flutter pub get
```

### Issue: Build errors
**Solution**:
```powershell
flutter clean
flutter pub get
flutter pub upgrade
```

---

## ✅ Verify Installation

After installation, run:

```powershell
flutter doctor -v
```

You should see:
- ✅ Flutter (Channel stable)
- ✅ Windows Version
- ✅ Chrome (for web)
- ⚠️ Android/iOS (optional, can skip)

---

## 🎯 What's Next?

1. **Install Flutter** using one of the options above
2. **Run `flutter pub get`** to install dependencies
3. **Run `flutter run -d chrome`** to see your app
4. **Start developing** - the codebase is ready!

---

## 💡 Quick Tips

- Use **VS Code** with Flutter extension for best experience
- Enable **hot reload** for fast development
- Use **flutter run -d chrome** for web development
- Use **flutter doctor** to diagnose issues

---

## 📞 Need Help?

If you encounter any issues:
1. Check `flutter doctor -v` output
2. Review error messages carefully
3. Clear cache: `flutter clean`
4. Reinstall packages: `flutter pub get`

---

## 🎉 Ready to Code!

Once Flutter is installed and running, you'll have:
- ✅ Full medical appointment system
- ✅ Hebrew/Arabic/English support
- ✅ RTL layout
- ✅ Medical-themed UI
- ✅ User role system
- ✅ Cross-platform support

Happy coding! 🚀
