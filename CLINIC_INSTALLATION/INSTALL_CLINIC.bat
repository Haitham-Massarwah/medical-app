@echo off
setlocal enabledelayedexpansion

:: ========================================
:: Medical Appointment System - Full Installation
:: For Clinic Computers
:: ========================================

echo.
echo ========================================
echo   Medical Appointment System
echo   Complete Clinic Installation
echo ========================================
echo.
echo This will install:
echo   - PostgreSQL Database
echo   - Backend Server (Node.js)
echo   - Desktop Application
echo.
echo Estimated time: 10-15 minutes
echo.

:: Check admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo ERROR: This script requires Administrator privileges!
    echo Please right-click and select "Run as Administrator"
    echo.
    pause
    exit /b 1
)

:: Set installation paths
set "INSTALL_DIR=C:\MedicalAppointmentSystem"
set "APP_DIR=%INSTALL_DIR%\App"
set "BACKEND_DIR=%INSTALL_DIR%\Backend"
set "DB_DIR=%INSTALL_DIR%\Database"

echo.
echo Installation directory: %INSTALL_DIR%
echo.
choice /C YN /M "Continue with installation"
if errorlevel 2 exit /b 0

:: Create directories
echo.
echo [1/5] Creating installation directories...
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
if not exist "%APP_DIR%" mkdir "%APP_DIR%"
if not exist "%BACKEND_DIR%" mkdir "%BACKEND_DIR%"
if not exist "%DB_DIR%" mkdir "%DB_DIR%"

:: Step 1: Check PostgreSQL
echo.
echo [2/5] Checking PostgreSQL installation...
where psql >nul 2>&1
if %errorLevel% neq 0 (
    echo PostgreSQL not found. Installing...
    call "INSTALL_POSTGRESQL.bat"
    if %errorLevel% neq 0 (
        echo ERROR: PostgreSQL installation failed!
        pause
        exit /b 1
    )
) else (
    echo PostgreSQL already installed.
)

:: Step 2: Check Node.js
echo.
echo [3/5] Checking Node.js installation...
where node >nul 2>&1
if %errorLevel% neq 0 (
    echo Node.js not found. Installing...
    call "INSTALL_NODEJS.bat"
    if %errorLevel% neq 0 (
        echo ERROR: Node.js installation failed!
        pause
        exit /b 1
    )
) else (
    echo Node.js already installed.
    node --version
)

:: Step 3: Setup Backend
echo.
echo [4/5] Setting up backend server...
call "SETUP_BACKEND.bat"
if %errorLevel% neq 0 (
    echo ERROR: Backend setup failed!
    pause
    exit /b 1
)

:: Step 4: Install Application
echo.
echo [5/5] Installing desktop application...
call "INSTALL_APP.bat"
if %errorLevel% neq 0 (
    echo ERROR: Application installation failed!
    pause
    exit /b 1
)

:: Step 5: Create Desktop Shortcut
echo.
echo Creating desktop shortcut...
set "SHORTCUT=%USERPROFILE%\Desktop\Medical Appointment System.lnk"
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%SHORTCUT%'); $Shortcut.TargetPath = '%APP_DIR%\medical_appointment_system.exe'; $Shortcut.WorkingDirectory = '%APP_DIR%'; $Shortcut.Description = 'Medical Appointment System'; $Shortcut.Save()"

:: Step 6: Create Start Menu Entry
echo.
echo Creating Start Menu entry...
set "START_MENU=%APPDATA%\Microsoft\Windows\Start Menu\Programs"
set "START_SHORTCUT=%START_MENU%\Medical Appointment System.lnk"
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%START_SHORTCUT%'); $Shortcut.TargetPath = '%APP_DIR%\medical_appointment_system.exe'; $Shortcut.WorkingDirectory = '%APP_DIR%'; $Shortcut.Description = 'Medical Appointment System'; $Shortcut.Save()"

:: Final verification
echo.
echo ========================================
echo   Installation Complete!
echo ========================================
echo.
echo Installation directory: %INSTALL_DIR%
echo.
echo Next steps:
echo   1. Launch the application from Desktop shortcut
echo   2. Complete first-time setup
echo   3. Create your admin account
echo.
echo For support, see: README_INSTALLATION.md
echo.

:: Run installation check
call "CHECK_INSTALLATION.bat"

echo.
echo Press any key to exit...
pause >nul




