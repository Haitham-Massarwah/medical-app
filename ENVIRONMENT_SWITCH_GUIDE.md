# 🌍 Environment Switching Guide

## Quick Overview

You can now easily switch between **Development** and **Production** environments by editing a simple text file!

## 📝 How to Switch Environments

### Step 1: Edit `ENVIRONMENT.txt`

Open the `ENVIRONMENT.txt` file in the root directory of your project and change the content to either:

- `Development` - Connects to local backend: `http://localhost:3000/api/v1`
- `Production` - Connects to production server: `http://66.29.133.192:3000/api/v1`

**Example:**
```
Production
```

or

```
Development
```

### Step 2: Restart the App

After changing `ENVIRONMENT.txt`, restart your Flutter app. The app will automatically detect the change and connect to the correct server.

## 🔍 How It Works

1. **On Desktop (Windows/Mac/Linux):**
   - The app reads `ENVIRONMENT.txt` from the current directory
   - If the file doesn't exist, it defaults to `Development`
   - The setting is cached in SharedPreferences for faster access

2. **On Mobile (Android/iOS):**
   - The app uses SharedPreferences (you can set it programmatically)

3. **On Web:**
   - Uses SharedPreferences only (file reading not available)

## 📍 File Locations

- **Desktop:** `ENVIRONMENT.txt` in the project root directory (where you run `flutter run`)

## ✅ Verification

After switching, check the app logs on startup. You should see:

```
API Environment: Production
Base URL: http://66.29.133.192:3000/api/v1
```

or

```
API Environment: Development
Base URL: http://localhost:3000/api/v1
```

