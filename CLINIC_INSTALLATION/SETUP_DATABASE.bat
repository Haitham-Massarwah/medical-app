@echo off
setlocal enabledelayedexpansion

echo.
echo ========================================
echo   Database Setup
echo ========================================
echo.

:: Check PostgreSQL
where psql >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: PostgreSQL is not installed or not in PATH!
    echo Please run INSTALL_POSTGRESQL.bat first.
    pause
    exit /b 1
)

:: Set database configuration
set "DB_NAME=medical_app_db"
set "DB_USER=postgres"
set "DB_PASSWORD=Postgres123!"

echo Creating database: %DB_NAME%
echo.

:: Create database using psql
set "PGPASSWORD=%DB_PASSWORD%"
psql -U %DB_USER% -h localhost -p 5432 -c "SELECT 1 FROM pg_database WHERE datname='%DB_NAME%'" | findstr /C:"1" >nul

if %errorLevel% equ 0 (
    echo Database %DB_NAME% already exists.
    choice /C YN /M "Recreate database (this will delete all data)"
    if errorlevel 2 goto :skip_create
    
    psql -U %DB_USER% -h localhost -p 5432 -c "DROP DATABASE IF EXISTS %DB_NAME%;"
)

echo Creating database...
psql -U %DB_USER% -h localhost -p 5432 -c "CREATE DATABASE %DB_NAME%;"

if %errorLevel% equ 0 (
    echo Database created successfully!
) else (
    echo ERROR: Failed to create database!
    echo.
    echo Please verify:
    echo   - PostgreSQL is running
    echo   - Username and password are correct
    echo   - You have permission to create databases
    pause
    exit /b 1
)

:skip_create

:: Run migrations
echo.
echo Running database migrations...
set "BACKEND_DIR=C:\MedicalAppointmentSystem\Backend"

if exist "%BACKEND_DIR%\dist\server.js" (
    cd /d "%BACKEND_DIR%"
    call npm run migrate
    if %errorLevel% equ 0 (
        echo Migrations completed successfully!
    ) else (
        echo WARNING: Migrations may have failed, but continuing...
    )
) else (
    echo WARNING: Backend not built yet. Migrations will run on first start.
)

:: Run seeds (create default accounts)
echo.
echo Creating default accounts...
cd /d "%BACKEND_DIR%"
if exist "package.json" (
    call npm run seed
    if %errorLevel% equ 0 (
        echo Default accounts created!
        echo.
        echo Default login credentials:
        echo   - Developer: haitham.massarwah@medical-appointments.com / Developer@2024
        echo   - Doctor: doctor.example@medical-appointments.com / Doctor@123
        echo   - Customer: patient.example@medical-appointments.com / Patient@123
        echo.
        echo IMPORTANT: 
        echo   1. Change these passwords after first login!
        echo   2. Email functionality is DISABLED until test accounts are created
        echo   3. Create test doctor and customer accounts via developer dashboard
    )
)

echo.
echo ========================================
echo   Database Setup Complete!
echo ========================================
echo.
echo Database: %DB_NAME%
echo Host: localhost
echo Port: 5432
echo.
pause

