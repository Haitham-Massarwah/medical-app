@echo off
title Medical Appointment System - Backend Server

echo.
echo ========================================
echo   Starting Backend Server
echo ========================================
echo.

set "BACKEND_DIR=C:\MedicalAppointmentSystem\Backend"

if not exist "%BACKEND_DIR%" (
    echo ERROR: Backend directory not found!
    echo Please run SETUP_BACKEND.bat first.
    pause
    exit /b 1
)

cd /d "%BACKEND_DIR%"

:: Check Node.js
where node >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: Node.js is not installed!
    pause
    exit /b 1
)

:: Check if .env exists
if not exist ".env" (
    echo WARNING: Configuration file (.env) not found!
    echo Using default settings.
)

echo Starting backend server...
echo.
echo Server will run on: http://localhost:3000
echo Press Ctrl+C to stop the server
echo.

:: Start server
if exist "dist\server.js" (
    call npm start
) else (
    echo Building backend first...
    call npm run build
    if %errorLevel% equ 0 (
        call npm start
    ) else (
        echo ERROR: Build failed!
        pause
        exit /b 1
    )
)

pause




