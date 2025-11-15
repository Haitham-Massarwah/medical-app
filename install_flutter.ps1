# Flutter Installation Script for Medical Appointment System
# Run this script in PowerShell as Administrator

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "Medical Appointment System Setup" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "⚠️  Please run this script as Administrator" -ForegroundColor Yellow
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    pause
    exit
}

# Configuration
$flutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.9-stable.zip"
$flutterInstallPath = "C:\flutter"
$tempDir = "$env:TEMP\flutter_install"

# Step 1: Check if Flutter is already installed
Write-Host "📋 Step 1: Checking for existing Flutter installation..." -ForegroundColor Green
$existingFlutter = Get-Command flutter -ErrorAction SilentlyContinue
if ($existingFlutter) {
    Write-Host "✅ Flutter is already installed at: $($existingFlutter.Source)" -ForegroundColor Green
    $continue = Read-Host "Do you want to reinstall? (y/n)"
    if ($continue -ne "y") {
        Write-Host "Skipping Flutter installation..." -ForegroundColor Yellow
        goto :dependencies
    }
}

# Step 2: Create temporary directory
Write-Host ""
Write-Host "📂 Step 2: Creating temporary directory..." -ForegroundColor Green
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

# Step 3: Download Flutter SDK
Write-Host ""
Write-Host "⬇️  Step 3: Downloading Flutter SDK..." -ForegroundColor Green
Write-Host "This may take a few minutes depending on your internet connection..." -ForegroundColor Yellow
$flutterZip = "$tempDir\flutter_windows.zip"

try {
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $flutterUrl -OutFile $flutterZip -UseBasicParsing
    Write-Host "✅ Download completed!" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to download Flutter: $_" -ForegroundColor Red
    pause
    exit
}

# Step 4: Extract Flutter
Write-Host ""
Write-Host "📦 Step 4: Extracting Flutter SDK to $flutterInstallPath..." -ForegroundColor Green
try {
    if (Test-Path $flutterInstallPath) {
        Write-Host "Removing existing Flutter installation..." -ForegroundColor Yellow
        Remove-Item -Path $flutterInstallPath -Recurse -Force
    }
    Expand-Archive -Path $flutterZip -DestinationPath "C:\" -Force
    Write-Host "✅ Extraction completed!" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to extract Flutter: $_" -ForegroundColor Red
    pause
    exit
}

# Step 5: Add Flutter to PATH
Write-Host ""
Write-Host "🔧 Step 5: Adding Flutter to PATH..." -ForegroundColor Green
$flutterBin = "$flutterInstallPath\bin"

# Add to User PATH
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$flutterBin*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$flutterBin", "User")
    Write-Host "✅ Flutter added to User PATH" -ForegroundColor Green
} else {
    Write-Host "✅ Flutter already in PATH" -ForegroundColor Green
}

# Update current session PATH
$env:Path = "$env:Path;$flutterBin"

# Step 6: Run Flutter Doctor
Write-Host ""
Write-Host "🏥 Step 6: Running Flutter Doctor..." -ForegroundColor Green
Write-Host "This will check for any missing dependencies..." -ForegroundColor Yellow
& "$flutterBin\flutter" doctor

# Step 7: Enable web support
Write-Host ""
Write-Host "🌐 Step 7: Enabling Flutter web support..." -ForegroundColor Green
& "$flutterBin\flutter" config --enable-web

# Step 8: Install project dependencies
:dependencies
Write-Host ""
Write-Host "📦 Step 8: Installing project dependencies..." -ForegroundColor Green
$projectPath = "C:\Users\Haitham.Massawah\OneDrive\App"

if (Test-Path $projectPath) {
    Set-Location $projectPath
    & flutter pub get
    Write-Host "✅ Dependencies installed!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Project path not found: $projectPath" -ForegroundColor Yellow
}

# Step 9: Clean up
Write-Host ""
Write-Host "🧹 Step 9: Cleaning up temporary files..." -ForegroundColor Green
if (Test-Path $tempDir) {
    Remove-Item -Path $tempDir -Recurse -Force
    Write-Host "✅ Cleanup completed!" -ForegroundColor Green
}

# Final message
Write-Host ""
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "✅ Installation Complete!" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Close and reopen your terminal/IDE" -ForegroundColor White
Write-Host "2. Run: flutter doctor" -ForegroundColor White
Write-Host "3. Navigate to: $projectPath" -ForegroundColor White
Write-Host "4. Run: flutter run -d chrome" -ForegroundColor White
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
