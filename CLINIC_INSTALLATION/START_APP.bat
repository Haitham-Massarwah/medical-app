@echo off
title Medical Appointment System

echo.
echo ========================================
echo   Medical Appointment System v1.0.0
echo   Starting Application...
echo ========================================
echo.

set "APP_DIR=%~dp0app"

if exist "%APP_DIR%\temp_platform_project.exe" (
    echo Starting application...
    cd /d "%APP_DIR%"
    start "" "temp_platform_project.exe"
    echo.
    echo ✅ Application started!
    echo.
    echo The app window should appear shortly.
    echo.
    echo Login Information:
    echo   - Enter any email and password
    echo   - Select your role (Patient or Doctor)
    echo.
) else (
    echo ❌ Application not found!
    echo.
    echo Please run INSTALL_CLINIC.bat first to install the application.
    echo.
)

pause
